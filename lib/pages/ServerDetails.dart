import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pterodactyl_mobile/helpers/PterodactylHelper.dart';
import 'package:pterodactyl_mobile/helpers/PterodactylWebSocketHelper.dart';
import 'package:pterodactyl_mobile/models/PterodactylEvent.dart';
import 'package:pterodactyl_mobile/models/ServerList.dart';
import 'package:pterodactyl_mobile/models/ServerResources.dart';
import 'package:pterodactyl_mobile/one_ui_scroll_view/one_ui_scroll_view.dart';
import 'package:pterodactyl_mobile/widgets/CustomCard.dart';
import 'package:pterodactyl_mobile/widgets/ErrorCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'ServerConsole.dart';

class ServerDetails extends StatefulWidget {
  final String serverIdentifier;

  const ServerDetails({ Key key, this.serverIdentifier }): super(key: key);

  @override
  _ServerDetailsState createState() => _ServerDetailsState();
}

class _ServerDetailsState extends State<ServerDetails> {

  void _webSocketListener(String message){
    PterodactylWebSocketEvent event = pterodactylWebSocketEventFromJson(message);

    switch(event.event){
      case 'stats': {
        setState(() {
          _currentRAMBytes = jsonDecode(event.args[0])["memory_bytes"] ?? 0;
          _maxRAMBytes = jsonDecode(event.args[0])["memory_limit_bytes"] ?? 0;
          _currentCPU = jsonDecode(event.args[0])["cpu_absolute"].runtimeType == double ?
                jsonDecode(event.args[0])["cpu_absolute"] : double.parse(jsonDecode(event.args[0])["cpu_absolute"].toString()) ?? 0.0;
          _serverState = jsonDecode(event.args[0])["state"];
        });
        break;
      }

      case 'auth success':
        setState(() {
          _serverLog.add("Successfully authenticated with Panel.");
        });
        _serverWebSocket.sink.add('{"event":"send logs","args":[null]}');
        break;

      case 'console output': {
        setState(() {
          _serverLog.add(event.args[0]);
        });
        break;
      }

      case 'token expiring':
        PterodactylWebSocketHelper.getWebSocketInfo(widget.serverIdentifier).then((webSocketInfo){
          _serverWebSocket.sink.add('{"event":"auth","args":["' + webSocketInfo.token + '"]}');
        });
        break;

      default: {
        setState(() {
          _serverLog.add(message);
        });
      }
    }
  }

  Server _server = new Server();
  String _serverName = "Loading...";

  int _maxRAMBytes = 0;
  int _maxDiskBytes = 0;
  double _maxCPU = 0;

  int _currentRAMBytes = 0;
  int _currentDiskBytes = 0;
  double _currentCPU = 0;

  String _serverState = "Unknown";

  WebSocketChannel _serverWebSocket;
  String _serverWebSocketError = "";

  List<String> _serverLog = [
    "Log started"
  ];

  @override
  void initState() {
    PterodactylHelper.fetchServer(widget.serverIdentifier).then((server){
      setState(() {
        _server = server;

        _serverName = server.attributes.name;

        _maxRAMBytes = (server.attributes.limits.memory * 1024 * 1024).round();
        _currentRAMBytes = server.resources.attributes.resources.memoryBytes;

        _maxDiskBytes = (server.attributes.limits.disk * 1024 * 1024).round();
        _currentDiskBytes = server.resources.attributes.resources.diskBytes;

        _maxCPU = (server.attributes.limits.cpu).roundToDouble();
        _currentCPU = (server.resources.attributes.resources.cpuAbsolute).roundToDouble();
      });
    });

    runZoned(() async {
      PterodactylWebSocketHelper.establishWebSocketConnection(widget.serverIdentifier).then((wsc){
        _serverWebSocket = wsc;
        _serverWebSocket.stream.listen((message){
          _webSocketListener(message);
        });
      });
    }, onError: (error, stackTrace) {
      setState(() {
        _serverWebSocketError = error.toString();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    if(_serverWebSocket != null){
      _serverWebSocket.sink.close(status.goingAway);
    }
  }

  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: OneUiScrollView(
          expandedHeight: 200,
          bottomDivider: Divider(
            color: Theme.of(context).shadowColor,
            indent: 0,
            endIndent: 0,
            height: 1,
          ),
          backgroundColor: Theme.of(context).canvasColor,
          expandedTitle: Text("Server Details", style: TextStyle(fontSize: 32)),
          collapsedTitle: Row(
            children: [
              FaIcon(FontAwesomeIcons.server),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Server Details", style: TextStyle(fontSize: 24)),
              )
            ],
          ),
          childrenPadding: EdgeInsets.all(10),
          children: [
            Text(_serverName, style: TextStyle(fontSize: 24), textAlign: TextAlign.center, maxLines: 3),
            Visibility(
              visible: _serverWebSocketError.length == 0,
              child: Chip(
                label: Text('Connected to Server'),
                backgroundColor: Colors.green,
              ),
            ),
            Visibility(
              visible: _serverWebSocketError.length > 0,
              child: Chip(
                label: Text('Connection to Server was interrupted'),
                backgroundColor: Colors.red,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FlatButton(
                  color: Colors.green,
                  onPressed: (){
                    PterodactylWebSocketEvent event = new PterodactylWebSocketEvent(
                        event: "set state",
                        args: [
                          "start"
                        ]
                    );
                    _serverWebSocket.sink.add(pterodactylWebSocketEventToJson(event));
                  },
                  child: Text("Start"),
                ),
                FlatButton(
                  color: Colors.red,
                  onPressed: (){
                    PterodactylWebSocketEvent event = new PterodactylWebSocketEvent(
                        event: "set state",
                        args: [
                          "stop"
                        ]
                    );
                    _serverWebSocket.sink.add(pterodactylWebSocketEventToJson(event));
                  },
                  child: Text("Stop"),
                ),
                FlatButton(
                  color: Colors.orange,
                  onPressed: (){
                    PterodactylWebSocketEvent event = new PterodactylWebSocketEvent(
                        event: "set state",
                        args: [
                          "restart"
                        ]
                    );
                    _serverWebSocket.sink.add(pterodactylWebSocketEventToJson(event));
                  },
                  child: Text("Restart"),
                )
              ],
            ),
            CustomCard(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 25,
                              child: FaIcon(FontAwesomeIcons.powerOff, size: 16),
                            ),
                            Text("Status")
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(_serverState),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 25,
                              child: FaIcon(FontAwesomeIcons.memory, size: 16),
                            ),
                            Text("RAM")
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(_formatBytesString(_currentRAMBytes.toString() ?? "0") +
                              "/" + _formatBytesString(_maxRAMBytes.toString()), maxLines: 2),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 25,
                              child: FaIcon(FontAwesomeIcons.solidHdd, size: 16),
                            ),
                            Text("Disk")
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(_formatBytesString(_currentDiskBytes.toString()) +
                              "/" + _formatBytesString(_maxDiskBytes.toString()), maxLines: 2),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 25,
                              child: FaIcon(FontAwesomeIcons.microchip, size: 16),
                            ),
                            Text("CPU")
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(_currentCPU.toString() + ' %', maxLines: 2),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _serverWebSocketError.length > 0,
              child: ErrorCard(
                errorTitle: "Could not connect to WebSocket",
                errorText: _serverWebSocketError,
              ),
            ),
            Visibility(
              visible: _serverWebSocketError.length == 0,
              child: CustomCard(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ServerConsole(serverIdentifier: widget.serverIdentifier)),
                  );
                },
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          itemCount: _serverLog.length,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${List.from(_serverLog.reversed)[index]}', style: TextStyle(fontSize: 12)),
                                Divider()
                              ],
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                        ],
                      )
                    ],
                  ),
              ),
            ),
          ],
        )
    );
  }

  String _getFetchErrorText(String errorText){
    if(errorText.contains("Server responded with Status Code 401")){
      return errorText + " (Unauthorized) This probably means your API Key is invalid.";
    }else if(errorText.contains("Server responded with Status Code 403")){
      return errorText + " (Forbidden)";
    }else if(errorText.contains("Server responded with Status Code 404")){
      return errorText + " (Not Found) This probably means your Panel URL is invalid. Make sure to remove any trailing slashes from the URL.";
    }else{
      return errorText;
    }
  }

  String _megabytesToBytes(int megabytes){
    return (megabytes * 1024 * 1024).round().toString();
  }
  String _formatBytesString(String bytes){
    int _bytes = int.parse(bytes);
    double _megabytes = (_bytes / 1024 / 1024);

    if(_megabytes >= 1000){
      return (_megabytes / 1024).toStringAsFixed(2) + " GB";
    }else{
      return _megabytes.toStringAsFixed(2) + " MB";
    }
  }
}
