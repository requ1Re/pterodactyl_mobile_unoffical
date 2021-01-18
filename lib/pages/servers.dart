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
      return ServerList.fromJson(responseJson);
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
        child: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Container(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 50),
                  child: Text("Servers", style: TextStyle(fontSize: 38)),
                ),
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
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 15),
                                      child: FaIcon(FontAwesomeIcons.circle, color: Colors.red),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(server.attributes.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
