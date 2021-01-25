import 'dart:convert';

import 'package:pterodactyl_mobile/models/PterodactylWebSocket.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PterodactylWebSocketHelper {

  static Future<WebSocketChannel> establishWebSocketConnection(String serverIdentifier) async {
    PterodactylWebSocket webSocketInfo = await getWebSocketInfo(serverIdentifier);

    WebSocketChannel _serverWebSocket = IOWebSocketChannel.connect(webSocketInfo.url);
    _serverWebSocket.sink.add('{"event":"auth","args":["' + webSocketInfo.token + '"]}');

    return _serverWebSocket;
  }

  static Future<PterodactylWebSocket> getWebSocketInfo(String serverIdentifier) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _pterodactylApiKey = prefs.getString("pterodactyl_apikey") ?? "";
    String _pterodactylUrl = prefs.getString("pterodactyl_url") ?? "";

    final response = await http.get(
      _pterodactylUrl + '/api/client/servers/' + serverIdentifier + '/websocket',
      headers: {
        "Authorization": "Bearer " + _pterodactylApiKey,
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      return PterodactylWebSocket(
        token: responseJson["data"]["token"],
        url: responseJson["data"]["socket"]
      );
    } else {
      throw Exception('Could not renew WebSocket token');
    }
  }

}