
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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


}