import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class IgdbApiRepository {
  final String? _clientId = dotenv.env['CLIENT_ID'];
  final String? _clientSecret = dotenv.env['CLIENT_SECRET'];
  String? _accessToken;

  Future<void> initToken() async {
    _accessToken = await getIgdbToken(_clientId, _clientSecret);
  }

  Future<String?> getIgdbToken(String? client, String? secret) async {
    var url = Uri.parse('https://id.twitch.tv/oauth2/token');
    var response = await http.post(url, body: {
      'client_id': client,
      'client_secret': secret,
      'grant_type': 'client_credentials',
    });

    if (response.statusCode == 200) {
      print('Token obtenido: ${response.body}');
      var data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      print('Error: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  Future<dynamic> getGamesOnWeb(String query) async {
    if (_clientId == null || _accessToken == null || _clientSecret == null){
      throw Exception('Any authentication credential is null: Client=$_clientId, secret=$_clientSecret, token=$_accessToken');
    }

    final url = Uri.parse('https://api.igdb.com/v4/games');

    final response = await http.post(
      url,
      headers: {
        "Client-ID": _clientId,
        'Authorization': 'Bearer $_accessToken',
      },
      body: 'fields name, genres.name, rating, cover; search "$query";',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error in query: ${response.statusCode}');
    }
  }

  Future<dynamic> getGames(String query) async {
    if (_clientId == null || _accessToken == null || _clientSecret == null){
      throw Exception('Any authentication credential is null: Client=$_clientId, secret=$_clientSecret, token=$_accessToken');
    }

    final url = Uri.parse('https://api.igdb.com/v4/games');

    final response = await http.post(
      url,
      headers: {
        "Client-ID": _clientId,
        'Authorization': 'Bearer $_accessToken',
      },
      body: 'fields name, genres.name, rating, cover; search "$query";',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error in query: ${response.statusCode}');
    }
  }

  Future<String> getCover(int coverId) async {
    if (_clientId == null || _accessToken == null || _clientSecret == null) {
      throw Exception('Any authentication credential is null');
    }
    print("Cover id: $coverId");
    final url = Uri.parse('https://api.igdb.com/v4/covers');

    final response = await http.post(
      url,
      headers: {
        "Client-ID": _clientId,
        'Authorization': 'Bearer $_accessToken',
      },
      body: 'fields image_id; where id = $coverId;',
    );

    if (response.statusCode == 200) {
      final data = await jsonDecode(response.body);
      print('COVER OBTENIDA: $data');
      if (data.isNotEmpty && data[0]['image_id'] != null) {
        final imageId = data[0]['image_id'];
        return 'https://images.igdb.com/igdb/image/upload/t_cover_big/$imageId.jpg';
      } else {
        throw Exception('Cover not found');
      }
    } else {
      throw Exception('Error in query: ${response.statusCode}');
    }
  }



}