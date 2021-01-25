import 'dart:convert';

import 'package:pterodactyl_mobile/models/ServerList.dart';
import 'package:pterodactyl_mobile/models/ServerResources.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PterodactylHelper {

  static Future<Server> fetchServer(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _pterodactylApiKey = prefs.getString("pterodactyl_apikey") ?? "";
    String _pterodactylUrl = prefs.getString("pterodactyl_url") ?? "";


    final response = await http.get(
      _pterodactylUrl + '/api/client/servers/' + uid,
      headers: {
        "Authorization": "Bearer " + _pterodactylApiKey,
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      Server s = Server.fromJson(responseJson);
      s.resources = await fetchServerResources(s.attributes.identifier);
      return s;
    } else {
      switch(response.statusCode){
        case 404:
          throw Exception('404 Not Found - Please check your Pterodactyl Panel URL in the settings.');
        default:
          throw Exception('Server responded with ${response.statusCode}');
      }
    }
  }

  static Future<ServerResources> fetchServerResources(String uid) async {
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

  static Future<ServerList> fetchServerList() async {
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
      throw Exception('Server responded with Status Code ${response.statusCode}');
    }
  }

}