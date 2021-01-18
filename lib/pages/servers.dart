import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pterodactyl_mobile/models/ServerList.dart';
import 'package:pterodactyl_mobile/models/ServerResources.dart';
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
  Future<ServerList> fetchServerList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _pterodactylApiKey = prefs.getString("pterodactyl_apikey") ?? "";
    String _pterodactylUrl = prefs.getString("pterodactyl_url") ?? "";


    final response = await http.get(
      _pterodactylUrl + '/api/client',
      headers: {
        "Authorization": "Bearer " + _pterodactylApiKey,
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      ServerList serverList = ServerList.fromJson(responseJson);
      for(Server s in serverList.data){
        s.resources = await fetchServerResources(s.attributes.identifier);
      }
      return serverList;
    } else {
      switch(response.statusCode){
        case 404:
          throw Exception('404 Not Found - Please check your Pterodactyl Panel URL in the settings.');
        default:
          throw Exception('Server responded with ${response.statusCode}');
      }
    }
  }

  Future<ServerResources> fetchServerResources(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _pterodactylApiKey = prefs.getString("pterodactyl_apikey") ?? "";
    String _pterodactylUrl = prefs.getString("pterodactyl_url") ?? "";


    final response = await http.get(
      _pterodactylUrl + '/api/client/servers/' + uid + '/resources',
      headers: {
        "Authorization": "Bearer " + _pterodactylApiKey,
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      return ServerResources.fromJson(responseJson);
    } else {
      switch(response.statusCode){
        case 404:
          throw Exception('404 Not Found - Please check your Pterodactyl Panel URL in the settings.');
        default:
          throw Exception('Server responded with ${response.statusCode}');
      }
    }
  }


  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        showApiKeyError = prefs.getString("pterodactyl_apikey") == null || prefs.getString("pterodactyl_url") == "";
      });
    });
    _serverList = fetchServerList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _serverList = fetchServerList();
          });
        },
        child: Icon(Icons.refresh),
        backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
      ),
      body: Center(
        child: NestedScrollView (
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: MyDynamicHeader(),
              ),
            ];
          },
          body: ListView(
            padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
            children: [
              Visibility(
                  visible: showApiKeyError,
                  child: ErrorCard(
                      errorText: "No Panel URL or API Key found. Please set your Pterodactyl Panel URL and API Key in the settings."
                  )
              ),
              FutureBuilder<ServerList>(
                future: _serverList, // async work
                builder: (BuildContext context, AsyncSnapshot<ServerList> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting: return FaIcon(FontAwesomeIcons.spinner);
                    default:
                      if (snapshot.hasError) {
                        return ErrorCard(
                            errorTitle: 'Could not load servers:',
                            errorText: '${snapshot.error}'
                        );
                      } else {
                        return Column(
                          children: snapshot.data.data.map((server) => CustomCard(
                              child: Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Row(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(right: 15),
                                        child: _getStatusDot(server.resources.attributes.currentState)
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(server.attributes.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: [
                                              CustomCard(
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
                                                          FaIcon(FontAwesomeIcons.hdd, size: 16),
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
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                          )).toList(),
                        );
                      }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStatusDot(String status){
    switch(status){
      case "offline":
        return FaIcon(FontAwesomeIcons.circle, color: Colors.red);
      case "starting":
        return FaIcon(FontAwesomeIcons.circle, color: Colors.yellow);
      case "running":
        return FaIcon(FontAwesomeIcons.solidCircle, color: Colors.green);
      default:
        return FaIcon(FontAwesomeIcons.questionCircle, color: Colors.yellow);
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

  @override
  bool get wantKeepAlive => true;
}

class MyDynamicHeader extends SliverPersistentHeaderDelegate {
  int index = 0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final double percentage = (constraints.maxHeight - minExtent)/(maxExtent - minExtent);

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.25),
                  spreadRadius: 3 * (1 - percentage),
                  blurRadius: 6 * (1 - percentage),
                ),
              ],
            ),
            height: constraints.maxHeight,
            child: SafeArea(
                child: Center(
                  child: Text("Servers", textAlign: TextAlign.center, style: TextStyle(fontSize: 38)),
                )
            ),
          );
        }
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;

  @override
  double get maxExtent => 200.0;

  @override
  double get minExtent => 100.0;
}