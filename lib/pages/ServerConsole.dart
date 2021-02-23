import 'package:flutter/material.dart';
import 'package:pterodactyl_mobile/helpers/PterodactylWebSocketHelper.dart';
import 'package:pterodactyl_mobile/models/PterodactylEvent.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ServerConsole extends StatefulWidget {
  final String serverIdentifier;

  const ServerConsole({ Key key, this.serverIdentifier }): super(key: key);

  @override
  _ServerConsoleState createState() => _ServerConsoleState();
}

class _ServerConsoleState extends State<ServerConsole> {

  List<String> _serverLog = [
    "Log started"
  ];

  WebSocketChannel _serverWebSocket;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    PterodactylWebSocketHelper.establishWebSocketConnection(widget.serverIdentifier).then((wsc){
      _serverWebSocket = wsc;
      _serverWebSocket.stream.listen((message){
        _webSocketListener(message);
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

  void _webSocketListener(String message){
    PterodactylWebSocketEvent event = pterodactylWebSocketEventFromJson(message);

    switch(event.event){
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Server Console"),
      ),
      body: ListView.builder(
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
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 1000),
          );
        },
        child: Icon(Icons.arrow_downward_rounded),
      ),
    );
  }
}
