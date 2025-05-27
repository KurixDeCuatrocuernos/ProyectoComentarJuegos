
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_box/auth/models/UserProjection.dart';
import 'package:game_box/comments/models/CommentProjection.dart';
import 'package:game_box/comments/models/CommentaryModel.dart';
import 'package:game_box/games/models/GameModel.dart';
import 'package:game_box/repository/GameRepository.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:get/get.dart';

import '../comments/models/CommentEditProjection.dart';
import '../games/models/GameWeightAndValueProjection.dart';

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

  Future<String?> getCommentaryIdByUserAndGame(String uid, int gameId) async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('gameId', isEqualTo: gameId)
          .where('userId', isEqualTo: uid)
          .get();
      if (response.docs.isEmpty) {
        print("NO SE ENCONTRARON COMENTARIOS PARA EDITAR CON ESE JUEGO Y USUARIO");
        return null;
      } else if (response.size>1) {
        print("SE ENCONTRÓ MÁS DE UN COMENTARIO CON ESE JUEGO Y USUARIO");
        return null;
      } else {
        return response.docs[0].id;
      }

    } catch (error) {
      print("HUBO UN ERROR BUSCANDO LA ID DEL COMENTARIO");
      return null;
    }
  }

  Future<List<dynamic>?> getGamesFromCommentsByUserId(String uid) async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(11)
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

  Future<bool> getIfUserHasCommentedThisGame(User? user, GameModel? game) async {
    bool hasCommented = false ;
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: user?.uid)
          .where('gameId', isEqualTo: game?.id)
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

  Future<CommentaryModel?> getCommentaryByUserAndGame(String uid, GameModel game) async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: uid)
          .where('gameId', isEqualTo: game.id)
          .get();
      if(response.docs.isNotEmpty){
        var doc = CommentaryModel.fromMap(response.docs.first.data() as Map <String,dynamic>);
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

  Future<List<CommentProjection>?> getCommentsByGame(GameModel game) async{
    try {
      // print("SE VAN A BUSCAR LOS COMENTARIOS DEL JUEGO: ${game.name} con id: ${game.id}");
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('gameId', isEqualTo: game.id)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      // print("SE OBTUVO LA RESPUESTA CON Comentarios: ${response.docs}");
      if(response.docs.isNotEmpty){
        List<CommentaryModel> docs = response.docs.map((doc) => CommentaryModel.fromMap(doc.data() as Map<String,dynamic>)).toList();
        List<CommentProjection> commentsWithName= [];
        UserRepository _userRepo = UserRepository();
        // print("COMENTARIOS RECOGIDOS: $docs");
        for (var element in docs) {
          String? username = await _userRepo.getUserNameByUid(element.userId);
          final CommentProjection commentProj = CommentProjection(
            comment: element,
            userId: username ?? "Username",
          );
          commentsWithName.add(commentProj);
        }
        // print("Resultados obtenidos: $docs");
        return commentsWithName;
      } else {
        print("SE OBTUVO UNA LISTA DE COMENTARIOS VACÍA");
        return null;
      }
    } catch (error) {
      print("ERROR AL OBTENER LOS COMENTARIOS");
      return null;
    }
  }

  Future<int?> countCommentsByGame(GameModel game) async {
    try{
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('gameId', isEqualTo: game.id)
          .get();
      return response.size;
    } catch (error) {
      print("ERROR AL OBTENER LOS COMENTARIOS");
      return null;
    }
  }

  Future<List<GameWeightAndValueProjection>?> getWeightAndValuesByGame(GameModel game) async {
    try {
      UserRepository _userRepo = UserRepository();
      List<CommentProjection>? comments = await getCommentsByGame(game);
      if (comments!.isNotEmpty) {
        List<GameWeightAndValueProjection> retorno = [];
        for (var comment in comments) {
          double? weight = await _userRepo.getWeightById(comment.comment.userId);
          //print("se va a añadir a la lista el peso $weight, y el valor: ${comment.comment.value} del comentario: ${comment.comment.id}");
          retorno.add(GameWeightAndValueProjection(
              weight: weight,
              value: comment.comment.value.toDouble()));
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

  Future<List<CommentaryModel>> getUserCommentariesByUid(String uid) async {
    List<CommentaryModel> list = [];
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();
      if (response.docs.isNotEmpty) {
        list = response.docs.map((doc) => CommentaryModel.fromMap(doc.data() as Map<String,dynamic>)).toList();
      }
      return list;
    } catch (error) {
      print("HUBO UN ERROR AL OBTENER LOS DATOS: $error");
      return list;
    }
  }

  /// This method deletes all comments by a Batch object instantiated in deleteUserByUid from UserRepository in order to delete everything or nothing
  Future<void> deleteAllCommentsByUser(String uid, WriteBatch batch) async {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: uid)
          .get();
      for (final doc in response.docs) {
        final docId = FirebaseFirestore.instance.collection(_collection).doc(doc.id);
        batch.delete(docId);
      }
  }
  
  Future<List<CommentaryModel>?> getAllComments() async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      if (response.docs.isNotEmpty) {
        return response.docs.map((doc) {
          final comment = doc.data();
          if (comment is Map<String, dynamic>) {
            return CommentaryModel.fromMap(comment);
          } else {
            print("SE OBTUVO UN COMENTARIO EN FORMATO EXTRAÑO DE LA BASE DE DATOS");
            return null;
          }
        }).whereType<CommentaryModel>().toList();
      } else {
        print("NO SE PUDIERON RECOGER COMENTARIOS DE LA BASE DE DATOS");
        return null;
      }
    } catch (error) {
      print("HUBO UN ERROR AL RECOGER LOS COMENTARIOSEN LA BASE DE DATOS");
      return null;
    }
  }

  Future<List<CommentaryModel>?> getCommentsInUsersAndGamesByQuery(String query) async {
    try {
      UserRepository _userRepo = UserRepository();
      GameRepository _gameRepo = GameRepository();

      final List<UserProjection> users = await _userRepo.getUsersUidByQuery(query);
      final List<Map<String, int>> games = await _gameRepo.getGamesIdByQuery(query);

      final List<String> userIds = users.map((user) => user.uid).toList();
      final List<int> gameIds = games.map((game) => game['id']!).toList();
      // Mapa para evitar duplicados por document ID
      Map<String, Map<String, dynamic>> commentMap = {};

      print("SE HAN ENCONTRADO LOS JUEGOS: $gameIds Y USUARIOS: $userIds");

      if (userIds.isNotEmpty) {
        final QuerySnapshot userComments = await FirebaseFirestore.instance
            .collection(_collection)
            .where('userId', whereIn: userIds)
            .get();

        for (var doc in userComments.docs) {
          commentMap[doc.id] = doc.data() as Map<String, dynamic>;
        }
      }

      if (gameIds.isNotEmpty) {
        final QuerySnapshot gameComments = await FirebaseFirestore.instance
            .collection(_collection)
            .where('gameId', whereIn: gameIds)
            .get();

        for (var doc in gameComments.docs) {
          commentMap[doc.id] = doc.data() as Map<String, dynamic>;
        }
      }
      //Ordenamos los elementos por orden cronológico descandente
      final sortedMaps = commentMap.values.toList()
        ..sort((a, b) {
          final tsA = a['createdAt'] as Timestamp?;
          final tsB = b['createdAt'] as Timestamp?;
          // Orden descendente (más reciente primero)
          return (tsB?.compareTo(tsA ?? Timestamp(0, 0)) ?? 0);
      });
      final sortedComments = sortedMaps.map((map) => CommentaryModel.fromMap(map)).toList();
      // Devuelve los comentarios únicos y ordenados
      return sortedComments;
    } catch (error) {
      print("HUBO UN ERROR AL RECOGER LOS COMENTARIOS CON LA QUERY PROPORCIONADA: $error");
      return null;
    }
  }
  
  Future<bool> banCommentById(String id) async {
    try {
       await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id)
          .update({'status': 5});
       return true;
    } catch (error) {
      print("HUBO UN ERROR AL BANNEAR EL COMENTARIO");
      return false;
    }
  }

  Future<bool> unbanCommentById(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id)
          .update({'status': 0});
      return true;
    } catch (error) {
      print("HUBO UN ERROR AL BANNEAR EL COMENTARIO");
      return false;
    }
  }

  Future<bool> deleteCommentById(String id) async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(id).delete();
      return true;
    } catch (error) {
      print("HUBO UN ERROR AL BORRAR EL COMENTARIO");
      return false;
    }
  }

  Future<bool> updateCommentById(String id, CommentEditProjection comment) async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(id).update(comment.toMap());
      return true;
    } catch (error) {
      print("THERE WAS AN ERROR UPDATING THE COMMENT IN DATABASE");
      return false;
    }
  }

  Future<bool> addComment(CommentaryModel commentData) async {
    try {
      final DocumentReference docRef = FirebaseFirestore.instance.collection(_collection).doc();
      final CommentaryModel comment = CommentaryModel(
        id: docRef.id,
        title: commentData.title,
        body: commentData.body,
        value: commentData.value,
        userId: commentData.userId,
        gameId: commentData.gameId,
        createdAt: FieldValue.serverTimestamp(),
      );
      await docRef.set(comment.toMap());
      return true;
    } catch (error) {
      print("HUBO UN ERROR AL SUBIR EL NUEVO COMENTARIO A LA BASE DE DATOS");
      return false;
    }
  }

  Future<bool> updateFullCommentById(String id, CommentaryModel comment) async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(id).update(comment.toMap());
      return true;
    } catch (error) {
      print("THERE WAS AN ERROR UPDATING THE COMMENT IN DATABASE");
      return false;
    }
  }

}