
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:get/get.dart';

class CommentaryRepository {

  final _collection = 'comments';

  Future<bool> getIfUserHasCommented(User user) async {
    bool hasCommented = false ;
    try {
      final AggregateQuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: user.uid)
          .count()
          .get();
      int comments = response.count ?? 0; /// If returns null it'll be 0
     if (comments > 0){
       hasCommented = true;
     } else {
       hasCommented = false;
     }
    } catch (error){
      print("HUBO UN ERROR AL COMPROBAR SI ESE USUARIO HA COMENTADO: $error");

    }
    return hasCommented;
  }

  Future<List<dynamic>?> getGamesFromCommentsByUserId(User user) async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      List gamesIds = response.docs
          .map((doc) => doc['gameId'])
          .toList();
      return gamesIds;
    } catch (error){
      print("HUBO UN ERROR AL OBTENER LOS JUEGOS COMENTADOS POR ESE USUARIO: $error");
      return null;
    }
  }

  Future<bool> getIfUserHasCommentedThisGame(User? user, Map<String, dynamic>? game) async {
    bool hasCommented = false ;
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: user?.uid)
          .where('gameId', isEqualTo: game?['id'])
          .get();
      if (response.docs.isNotEmpty){
        hasCommented = true;
      } else {
        hasCommented = false;
      }
    } catch (error){
      print("HUBO UN ERROR AL COMPROBAR SI ESE USUARIO HA COMENTADO: $error");

    }
    return hasCommented;
  }

  Future<Map<String,dynamic>?> getCommentaryByUserAndGame(User user, Map<String,dynamic> game) async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: user.uid)
          .where('gameId', isEqualTo: game['id'])
          .get();
      if(response.docs.isNotEmpty){
        var doc = response.docs.first.data() as Map <String,dynamic>;
        return doc;
      } else {
        print("SE OBTUVO UN COMENTARIO VACÍO");
        return null;
      }
    } catch (error){
      print("ERROR AL OBTENER EN COMENTARIO: $error");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCommentsByGame(Map<String, dynamic> game) async{
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('gameId', isEqualTo: game['id'])
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      if(response.docs.isNotEmpty){
        List<Map<String, dynamic>> docs = response.docs.map((doc)=>doc.data() as Map<String,dynamic>).toList();
        UserRepository _userRepo = UserRepository();
        for (var element in docs) {
          String? username = await _userRepo.getUserNameByUid(element['userId']);
          if (username != null) {
            element['name'] = username;
          } else {
            element['name'] = 'Username';
          }
        }
        // print("Resultados obtenidos: $docs");
        return docs;
      } else {
        print("SE OBTUVO UNA LISTA DE COMENTARIOS VACÍA");
        return null;
      }
    } catch (error) {
      print("ERROR AL OBTENER LOS COMENTARIOS");
      return null;
    }
  }

  Future<int?> countCommentsByGame(Map<String, dynamic> game) async {
    try{
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('gameId', isEqualTo: game['id'])
          .get();
      return response.size;
    } catch (error) {
      print("ERROR AL OBTENER LOS COMENTARIOS");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getWeightAndValuesByGame(Map<String, dynamic> game) async {
    try {
      UserRepository _userRepo = UserRepository();
      List<Map<String, dynamic>>? comments = await getCommentsByGame(game);
      if (comments!.isNotEmpty) {
        List<Map<String, dynamic>> retorno = [];
        for (var comment in comments) {
          retorno.add({
            'value': comment['value'].toDouble(),
            'weight': await _userRepo.getWeightById(comment['userId']),
          });
        }
        return retorno;
      } else {
        print("La lista de comentarios está vacía");
        return null;
      }
    } catch (error) {
      print("Error al obtener los datos");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserCommentariesByUid(String uid) async {
    List<Map<String, dynamic>> list = [];
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();
      if (response.docs.isNotEmpty) {
        list = response.docs.map((doc)=>doc.data() as Map<String,dynamic>).toList();
      }
      return list;
    } catch (error) {
      print("HUBO UN ERROR AL OBTENER LOS DATOS: $error");
      return list;
    }
  }


}