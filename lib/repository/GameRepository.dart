

import 'package:cloud_firestore/cloud_firestore.dart';

class GameRepository {
  final String _collection = 'games';

  Future<Map<String,dynamic>?> getGameById(int id) async {
    try {
      final DocumentSnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id.toString())
          .get();
      if (response.exists) {
        return response.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (error) {
      print('HUBO UN ERROR AL BUSCAR EL JUEGO EN LA BASE DE DATOS');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllGames() async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .get();
      if (response.docs.isNotEmpty) {
        return response.docs.map((doc) {
          final game = doc.data();
          if (game is Map<String, dynamic>) {
            return game;
          } else {
            print("Se Obtuvo un juego en formato extraño de la base de datos");
            return <String, dynamic>{};
          }
        }).toList();
      } else {
        print("SE OBTUVO UN LISTADO DE JUEGOS VACÍO DE LA BASE DE DATOS");
        return null;
      }
    } catch (error) {
      print("HUBO UN ERROR AL BUSCAR LOS JUEGOS EN LA BASE DE DATOS: $error");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getGamesByQuery(String query) async {
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
            return game;
          } else {
            print("This game: $game, is in strange format");
            return <String, dynamic>{};
          }
        }).toList();
      } else {
        return [];
      }
    } catch (error) {
      print("HUBO UN ERROR AL BUSCAR LOS JUEGOS EN LA BASE DE DATOS: $error");
      return null;
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

  Future<bool> updateGame(Map<String,dynamic> game) async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(game['id'].toString()).update(game);
      return true;
    } catch (error) {
      print("HUBO UN ERROR AL ACTUALIZAR LOS DATOS DEL JUEGO EN LA BASE DE DATOS: $error");
      return false;
    }
  }
}