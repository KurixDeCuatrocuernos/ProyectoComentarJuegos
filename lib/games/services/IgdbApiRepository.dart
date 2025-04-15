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
      body: 'fields name, genres.name, rating, summary, cover, first_release_date; search "$query"; where game_type = 0;',    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 429) {
      ///If we recieve 429 status code means too much queries at the same time
      await initToken(); /// regenerate the access token
      return getGames(query); /// we call the same method (we make callback)
    } else {
      throw Exception('Error in query: ${response.statusCode}');
    }
  }

  Future<dynamic> getGameById(String id) async {
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
      body: 'fields id, name, genres.name, rating, summary, cover; where id = $id;',    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 429) {
      ///If we recieve 429 status code means too much queries at the same time
      await initToken(); /// regenerate the access token
      return getGames(id); /// we call the same method (we make callback)
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
    } else if (response.statusCode == 429) {
      ///If we recieve 429 status code means too much queries at the same time
      await initToken(); /// regenerate the access token
      return getCover(coverId); /// we call the same method (we make callback)
    } else {
      throw Exception('Error in query: ${response.statusCode}');
    }
  }
  
  Future<int>? getGenreId(String genre) async {
    if (_clientId == null || _accessToken == null || _clientSecret == null) {
      throw Exception('Any authentication credential is null');
    } else {
      final url = Uri.parse('https://api.igdb.com/v4/genres');
      final response = await http.post(
        url,
        headers: {
          "Client-ID": _clientId,
          "Authorization": 'Bearer $_accessToken',
        },
        body: 'fields id, name; where name = "$genre";',
      );
      if (response.statusCode == 200) {

        final data = await jsonDecode(response.body);
        print("IGDB DEVOLVIÓ: $data");
        if(data.isNotEmpty) {
          return data[0]['id'];
        } else {
          throw Exception('Genre not found');
        }
      }  else {
        throw Exception('Genre not found');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getAllGamesByGenre(int genre) async {
    if (_clientId == null || _accessToken == null || _clientSecret == null) {
      throw Exception('Any authentication credential is null');
    } else {
      final url = Uri.parse('https://api.igdb.com/v4/games');
      final response = await http.post(
        url,
        headers: {
          "Client-ID": _clientId,
          "Authorization": 'Bearer $_accessToken',
        },
        body: '''
        fields id, name, cover, rating, first_release_date;
        where genres = $genre & first_release_date != null & game_type = 0;
        sort first_release_date desc;
        limit 10;
      ''',
      );

      if (response.statusCode == 200) {
        final data = await jsonDecode(response.body);
        if (data.isNotEmpty) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('Not found games');
        }
      } else if (response.statusCode == 429) {
        // Si el código de respuesta es 429, significa que se ha superado el límite
        print('Se alcanzó el límite de solicitudes, espera antes de intentar de nuevo.');
        // Aquí puedes agregar un delay de unos segundos y reintentar la solicitud
        await initToken();  // Generamos un nuevo AccessToken
        return getAllGamesByGenre(genre);  // Volver a llamar la función después de esperar
      } else {
        throw Exception('ResponseStatus != 200');
      }
    }
  }



}