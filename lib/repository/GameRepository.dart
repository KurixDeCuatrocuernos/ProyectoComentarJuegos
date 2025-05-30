

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_box/games/models/GameModel.dart';

class GameRepository {
  final String _collection = 'games';

  Future<bool> getIfGameExists(int id) async {
    try {
      final DocumentSnapshot response = await FirebaseFirestore.instance.collection(_collection).doc(id.toString()).get();
      if (response.exists) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print("HUBO UN ERROR AL REVISAR LA BASE DE DATOS EN BUSCA DEL JUEGO");
      return false;
    }
  }

  Future<GameModel?> getGameById(int id) async {
    //print("Buscando el Juego: $id, en la Base de Datos");
    try {
      final DocumentSnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id.toString())
          .get();
      if (response.exists) {
        //print("Se ha obtenido: ${response.data()}");
        return GameModel.fromMap(response.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (error) {
      print('HUBO UN ERROR AL BUSCAR EL JUEGO EN LA BASE DE DATOS');
      return null;
    }
  }

  Future<List<GameModel>?> getAllGames() async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .get();
      if (response.docs.isNotEmpty) {
        return response.docs.map((doc) {
          final game = doc.data();
          if (game is Map<String, dynamic>) {
            return GameModel.fromMap(game);
          } else {
            print("Se Obtuvo un juego en formato extraño de la base de datos");
            return <String, dynamic>{};
          }
        }).whereType<GameModel>().toList();
      } else {
        print("SE OBTUVO UN LISTADO DE JUEGOS VACÍO DE LA BASE DE DATOS");
        return [];
      }
    } catch (error) {
      print("HUBO UN ERROR AL BUSCAR LOS JUEGOS EN LA BASE DE DATOS: $error");
      return null;
    }
  }

  Future<List<GameModel>?> getGamesByQuery(String query) async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('name_lowercase', isGreaterThanOrEqualTo: query)
          .where('name_lowercase', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      if (response.docs.isNotEmpty) {
        return response.docs.map((doc) {
          final game = doc.data();
          if (game is Map<String, dynamic>) {
            return GameModel.fromMap(game);
          } else {
            print("This game: $game, is in strange format");
            return <String, dynamic>{};
          }
        }).whereType<GameModel>().toList();
      } else {
        return [];
      }
    } catch (error) {
      print("HUBO UN ERROR AL BUSCAR LOS JUEGOS EN LA BASE DE DATOS: $error");
      return null;
    }
  }
  
  Future<List<Map<String, int>>> getGamesIdByQuery(String query) async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('name_lowercase', isGreaterThanOrEqualTo: query)
          .where('name_lowercase', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      if (response.docs.isNotEmpty) {
        List<Map<String, int>> games = [];
        for(var game in response.docs) {
          games.add({'id': game['id']});
        }
        return games;
      } else {
        print("NO SE ENCONTRÓ JUEGO PARA BUSCAR COMENTARIOS CON ESA QUERY");
        return [];
      }
    } catch (error) {
      print("HUBO UN ERROR AL RECOGER LOS JUEGOS PARA BUSCAR COMENTARIOS EN LA BASE DE DATOS");
      return [];
    }
  }

  Future<bool> deleteGameById(String id) async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(id).delete();
      return true;
    } catch (error) {
      print('HUBO UN ERROR AL BORRAR EL JUEGO DE LA BASE DE DATOS: $error');
      return false;
    }
  }

  Future<bool> updateGame(GameModel game) async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(game.id.toString()).update(game.toMap());
      return true;
    } catch (error) {
      print("HUBO UN ERROR AL ACTUALIZAR LOS DATOS DEL JUEGO EN LA BASE DE DATOS: $error");
      return false;
    }
  }

  addNewGame(GameModel game, URL) async {

    double randomNumber = Random().nextDouble() * 100;

    final gameSetted = await FirebaseFirestore.instance
        .collection(_collection)
        .doc(game.id.toString())
        .set({
      'id': game.id,
      'name': game.name,
      'name_lowercase': game.name.toString().toLowerCase(),
      'summary': game.summary,
      'rating': game.rating ?? randomNumber,
      'cover': game.coverId,
      'url': URL,
      'first_release_date': game.first_release_date,
    }, SetOptions(merge: true));
  }
}