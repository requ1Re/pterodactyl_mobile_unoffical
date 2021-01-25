import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pterodactyl_mobile/helpers/PterodactylHelper.dart';
import 'package:pterodactyl_mobile/models/ServerList.dart';
import 'package:pterodactyl_mobile/models/ServerResources.dart';
import 'package:pterodactyl_mobile/one_ui_scroll_view/one_ui_scroll_view.dart';
import 'package:pterodactyl_mobile/pages/ServerDetails.dart';
import 'package:pterodactyl_mobile/widgets/CustomCard.dart';
import 'package:pterodactyl_mobile/widgets/ErrorCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ServersPage extends StatefulWidget {
  @override
  _ServersPageState createState() => _ServersPageState();
}

class _ServersPageState extends State<ServersPage> with AutomaticKeepAliveClientMixin {

  bool showApiKeyError = false;



  Future<ServerList> _serverList;


  @override
  void initState() {
    _serverList = PterodactylHelper.fetchServerList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _serverList = PterodactylHelper.fetchServerList();
          });
        },
        child: Icon(Icons.refresh),
        backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
      ),
      body: OneUiScrollView(
        expandedHeight: 200,
        bottomDivider: Divider(
          color: Theme.of(context).shadowColor,
          indent: 0,
          endIndent: 0,
          height: 1,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        expandedTitle: Text('Servers', style: TextStyle(fontSize: 32)),
        collapsedTitle: Row(
          children: [
            FaIcon(FontAwesomeIcons.server),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Servers', style: TextStyle(fontSize: 24)),
            )
          ],
        ),
        childrenPadding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        children: [
          FutureBuilder<ServerList>(
            future: _serverList, // async work
            builder: _serverCardsFutureBuilder,
          )
        ],
      )
    );
  }

  Widget _serverCardsFutureBuilder(BuildContext context, AsyncSnapshot<ServerList> snapshot){
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );

      default:
        if (snapshot.hasError) {
          return ErrorCard(
              errorTitle: 'Error while loading servers:',
              errorText: _getFetchErrorText(snapshot.error.toString())
          );
        } else {
          return Column(
            children: snapshot.data.data.map((server) => CustomCard(
              onTap: () {
                _navigateToScreen(ServerDetails(serverIdentifier: server.attributes.identifier));
              },
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: _getStatusDot(server.resources.attributes.currentState)
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                                server.attributes.name,
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                            Visibility(
                              visible: server.resources.attributes.currentState == "running",
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: CustomCard(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            FaIcon(FontAwesomeIcons.memory, size: 16),
                                            Padding(
                                              padding: EdgeInsets.only(left: 5),
                                              child: Text(_formatBytesString(server.resources.attributes.resources.memoryBytes.toString()) +
                                                  "/" + _formatBytesString(_megabytesToBytes(server.attributes.limits.memory)), maxLines: 2),
                                            )
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            FaIcon(FontAwesomeIcons.solidHdd, size: 16),
                                            Padding(
                                              padding: EdgeInsets.only(left: 5),
                                              child: Text(_formatBytesString(server.resources.attributes.resources.diskBytes.toString()) +
                                                  "/" + _formatBytesString(_megabytesToBytes(server.attributes.limits.disk)), maxLines: 2),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            FaIcon(FontAwesomeIcons.microchip, size: 16),
                                            Padding(
                                              padding: EdgeInsets.only(left: 5),
                                              child: Text(server.resources.attributes.resources.cpuAbsolute.toStringAsFixed(2) + "%", maxLines: 2),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                )
            )).toList(),
          );
        }
    }
  }

  Widget _getStatusDot(String status){
    switch(status){
      case "offline":
        return FaIcon(FontAwesomeIcons.solidCircle, color: Colors.red, size: 18);
      case "starting":
        return FaIcon(FontAwesomeIcons.circle, color: Colors.yellow, size: 18);
      case "running":
        return FaIcon(FontAwesomeIcons.solidCircle, color: Colors.green, size: 18);
      default:
        return FaIcon(FontAwesomeIcons.questionCircle, color: Colors.yellow, size: 18);
    }
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

  void _navigateToScreen(Widget screen){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  bool get wantKeepAlive => true;
}