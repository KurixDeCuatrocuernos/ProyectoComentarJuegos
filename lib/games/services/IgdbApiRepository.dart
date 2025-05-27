import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:game_box/games/models/GameApiProjection.dart';
import 'package:game_box/games/models/GameModel.dart';
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

  /// Este Metodo retorna una lista de GameModel recogisdos de IGDBAPI con base en la query proporcionada
  Future<List<GameModel>> getGames(String query) async {
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
      final List decoded = jsonDecode(response.body);
      return decoded.map<GameModel>((json) {
        try{
          return GameModel.fromMap(json);
        } catch (error) {
          print("ERROR AL CONVERTIR AUTOMÄTICAMENTE JSON A GAMEMODEL EN EL REPOSITORIO DE LA API: $error");
          return GameModel(
            id: int.parse(json['id']),
            name: json['name'],
            coverId: int.parse(json['cover']),
            first_release_date: Timestamp.fromMillisecondsSinceEpoch(json['first_release_date']),
            summary: json['summary'],
            rating: double.parse(json['rating']),
          );
        }
      }).whereType<GameModel>().toList();
    } else if (response.statusCode == 429) {
      ///If we recieve 429 status code means too much queries at the same time
      await initToken(); /// regenerate the access token
      return getGames(query); /// we call the same method (we make callback)
    } else {
      throw Exception('Error in query: ${response.statusCode}');
    }
  }

  Future<GameModel> getGameById(String id) async {
    print("Buscando el juego en la API");
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
      final data = await jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        final gameData = data.first;
        return GameModel(
          id: gameData['id'],
          name: gameData['name'],
          summary: gameData['summary'],
          rating: gameData['rating'],
          coverId: gameData['cover'],
          first_release_date: gameData['first_release_date'] !=null ? Timestamp.fromMillisecondsSinceEpoch(gameData['first_release_date']) : null,
        );
      } else {
        throw Exception("Game Not Found or Empty Data");
      }
    } else if (response.statusCode == 429) {
      ///If we recieve 429 status code means too much queries at the same time
      await initToken(); /// regenerate the access token
      return getGameById(id); /// we call the same method (we make callback)
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
      print('COVER OBTENIDA DE LA API: $data');
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
        /// Consulta RegEx para IGDB API
        body: 'fields id, name; where name ~ *"$genre"*;',
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

  Future<List<GameApiProjection>> getAllGamesByGenre(int genre) async {
    //print("Se van a buscar los juegos por género en la API");
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
        /// Hay más datos de los utilizados de cara a la escalabilidad (agregar el nombre)
        body: '''
        fields id, name, cover, first_release_date;
        where genres = $genre & first_release_date != null & game_type = 0;
        sort first_release_date desc;
        limit 10;
      ''',
      );
      if (response.statusCode == 200) {
        final data = await jsonDecode(response.body);
        //print("La API DEVOLVIÓ: $data");
        if (data.isNotEmpty) {
          List<GameApiProjection> list = [];
          for (var element in data) {
            element['url'] = await getCover(element['cover']);
            list.add(GameApiProjection.fromMap(element as Map<String, dynamic>));
          }
          //print("los datos de la API se han convertido en: $list");
          return list;
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