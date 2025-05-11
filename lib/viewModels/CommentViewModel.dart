
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_box/comments/models/CommentaryModel.dart';
import 'package:provider/provider.dart';

import '../comments/models/CommentEditProjection.dart';
import '../comments/models/CommentProjection.dart';
import '../games/services/IgdbApiRepository.dart';
import '../repository/CommentaryRepository.dart';
import '../repository/GameRepository.dart';

class CommentViewModel extends ChangeNotifier{
  final IgdbApiRepository _apiRepo;
  ///Metodo constructor Shingleton
  CommentViewModel(this._apiRepo);
  final CommentaryRepository _commentRepo = CommentaryRepository();
  GameRepository _gameRepo = GameRepository();
  final List<CommentaryModel> _comments = [];
  List<CommentaryModel> get comments => List.unmodifiable(_comments);

  void addComment(CommentaryModel comment) {
    _comments.add(comment);
    notifyListeners();
  }

  void addAllComments(List<CommentaryModel> comments) {
    for(CommentaryModel comment in comments) {
      _comments.add(comment);
    }
    notifyListeners();
  }

  void updateComment(String id, CommentaryModel commentUpdated) {
    final index = _comments.indexWhere((comment) => comment.id == id);
    if (index != -1) {
      _comments[index] = commentUpdated;
      notifyListeners();
    }
  }

  void removeComment(String id) {
    _comments.removeWhere((comment) => comment.id == id);
    notifyListeners();
  }

  CommentaryModel? getCommentById(String id) {
    try{
      return _comments.firstWhere((comment) => comment.id == id);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _comments.clear();
    notifyListeners();
  }

  Future<List<CommentProjection>?> getCommentsFromRepository(Map<String, dynamic> game) async {
    try {
      return await _commentRepo.getCommentsByGame(game);
    } catch (error) {
      return null;
    }
  }

  /// Devuelve true si contiene caracteres no alfanumericos y false si no los contiene
  bool _containsCharNoAlfanumeric(String texto) {
    final alfanumerico = RegExp(r'^[a-zA-Z0-9 _\-\:\.\,áéíóúüÁÉÍÓÚÜñÑ]+$');
    return !alfanumerico.hasMatch(texto);
  }

  Future<List<CommentaryModel>?> searchCommentsFromRepository(String query) async {
    if (_containsCharNoAlfanumeric(query)) {
      return [];
    } else {
      try {
        final List<CommentaryModel>? commentsList = await _commentRepo.getCommentsInUsersAndGamesByQuery(query.toLowerCase());
        if (commentsList != null) {
          if (commentsList.isNotEmpty) {
            return commentsList;
          } else {
            return [];
          }
        } else {
          print("Query for games answered null");
          return null;
        }
      } catch (error) {
        print("THERE WAS AN ERROR GETTING THE DATA REQUESTED FROM THE DATABASE: $error");
        return null;
      }
    }
  }

  Future<List<CommentaryModel>?> getAllCommentsFromRepository() async {
    try {
      List<CommentaryModel>? response = await _commentRepo.getAllComments();
      return response;
    } catch (error) {
      print("HUBO UN ERROR AL BUSCAR LOS COMENTARIOS");
      return null;
    }
  }

  Future<bool> editCommentFromRepository(CommentEditProjection comment, int gameId, String uid) async {
    try {
      String? commentId = await _commentRepo.getCommentaryIdByUserAndGame(uid, gameId);
      if (commentId != null) {
        return await _commentRepo.updateCommentById(commentId, comment);
      } else {
        return false;
      }
    } catch (error) {
      print("HUBO UN ERROR AL EDITAR EL COMENTARIO: $error");
      return false;
    }
    return false;
  }

  Future<bool> addCommentToRepository(CommentaryModel comment, Map<String, dynamic> game, String uid) async {
    try {
      // print("Revisando si el juego existe");
      bool gameExists = await _gameRepo.getIfGameExists(game['id']);
      // print("RECOGIDO EL ID: $gameExists");
      if (gameExists) {
        bool added = await _commentRepo.addComment(comment);
        // print("SE HA AÑADIDO EL COMENTARIO: $added");
        return added;
      } else {
        // print("AÑADIENDO EL JUEGO ANTES QUE EL COMENTARIO");
        String gameCover = await _apiRepo.getCover(game['cover']);
        // print("SE VA A AÑADIR EL COVER: $gameCover");
        await _gameRepo.addNewGame(game, gameCover);
        // print("SE AÑADIÓ EL JUEGO, VA A AÑADIRSE EL COMENTARIO");
        bool addedComment = await _commentRepo.addComment(comment);
        // print("AÑADIDO EL COMENTARIO: $addedComment");
        return addedComment;
      }
    } catch (error) {
      print("HUBO UN ERROR AL AÑADIR EL COMENTARIO: $error");
      return false;
    }
  }

  Future<CommentaryModel?> getCommentaryByUserAndGame(String uid, Map<String, dynamic> game) async {
    return await _commentRepo.getCommentaryByUserAndGame(uid, game);
  }

  Future<CommentaryModel?> isCommentedThisGameByThisUser(Map<String,dynamic> game, String uid) async {
    try {
      return await _commentRepo.getCommentaryByUserAndGame(uid, game);
    } catch (error) {
      print("There was an error connecting with database");
      return null;
    }

  }

  Future<bool> updateFullCommentFromRepository(CommentaryModel comment, String id) async {
    try {
      return await _commentRepo.updateFullCommentById(id, comment);
    } catch (error) {
      print("HUBO UN ERROR AL EDITAR EL COMENTARIO: $error");
      return false;
    }
    return false;
  }

  Future<List<CommentaryModel>> getCommentsByUserId(String uid) async {
    List<CommentaryModel> list = [];
    try {
      list = await _commentRepo.getUserCommentariesByUid(uid);
      return list;
    } catch (error) {
      print("HUBO UN ERROR AL RECOGER LOS COMENTARIOS DE LA BASE DE DATOS: $error");
      return list;
    }
  }

  Future<bool> banCommentById(String id) async {
    try {
      bool isDeleted = await _commentRepo.banCommentById(id);
      return isDeleted;
    } catch (error) {
      print("HUBO UN ERROR AL BORRAR EL COMENTARIO");
      return false;
    }
  }

  Future<bool> unbanCommentById(String id) async {
    try {
      bool isDeleted = await _commentRepo.unbanCommentById(id);
      return isDeleted;
    } catch (error) {
      print("HUBO UN ERROR AL BORRAR EL COMENTARIO");
      return false;
    }
  }

  Future<bool> deleteCommentById(String id) async {
    try {
      bool isDeleted = await _commentRepo.deleteCommentById(id);
      return isDeleted;
    } catch (error) {
      print("HUBO UN ERROR AL BORRAR EL COMENTARIO");
      return false;
    }
  }

}