
import 'package:flutter/material.dart';
import 'package:game_box/comments/models/CommentaryModel.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:get/get.dart';

import '../auth/models/UserModel.dart';
import '../games/models/GameModel.dart';
import '../repository/GameRepository.dart';
import '../repository/UserRepository.dart';

class AdminViewModel extends ChangeNotifier {

  final UserRepository _userRepo = UserRepository();
  final GameRepository _gameRepo = GameRepository();
  final CommentaryRepository _commentRepo = CommentaryRepository();

  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  List<GameModel> _games = [];
  List<GameModel> _filteredGames = [];
  List<CommentaryModel> _comments = [];
  List<CommentaryModel> _filteredComments = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUsers;
  List<GameModel> get games => _games;
  List<GameModel> get filteredGames => _filteredGames;
  List<CommentaryModel> get comments => _comments;
  List<CommentaryModel> get filteredComments => _filteredComments;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;



  Future<void> loadUsers() async {
    _isLoading = true;
    _hasError = false;

    try {
      final data = await _userRepo.getAllUsers();
      print("Usuarios recogidos en el viewModel: $data");
      _users = data ?? [];
    } catch (e) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGames() async {
    _isLoading = true;
    _hasError = false;

    try{
      final data = await _gameRepo.getAllGames();
      _games = data ?? [];
    } catch (error) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadComments() async {
    _isLoading = true;
    _hasError = false;

    try {
      final data = await _commentRepo.getAllComments();
      _comments = data ?? [];
    } catch (e) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _containsCharNoAlfanumeric(String texto) {
    final alfanumerico = RegExp(r'^[a-zA-Z0-9 _\-\:\.\,\@áéíóúüÁÉÍÓÚÜñÑ]+$');
    return !alfanumerico.hasMatch(texto);
  }

  void searchUser(String query) async {
    if (_containsCharNoAlfanumeric(query)) {
     _filteredUsers = [];
    } else {
      try {
        _filteredUsers.clear();
        for (UserModel user in _users) {
          if(user.name.toLowerCase().contains(query.toLowerCase()) || user.email.toLowerCase().contains(query.toLowerCase())) {
            _filteredUsers.add(user);
          }
        }
        print("USUARIOS RECOGIDOS A PARTIR DE LA BÚSQUEDA: $_filteredUsers");
      } catch (e) {
        print("Error in Search: $e");
      }
    }
    notifyListeners();
  }

  Future<bool> deleteUser(String uid) async {
    try {
      final result = await _userRepo.deleteUserByUid(uid);
      if (result) {
        await loadUsers();
      }
      return result;
    } catch (error) {
      print("Error deleting the user $error");
      return false;
    }
  }

  Future<bool> banUser(String uid) async {
    try {
      final result = await _userRepo.banUserByUid(uid);
      if (result) {
        await loadUsers();
      }
      return result;
    } catch (error) {
      print('Hubo un error al bannear al usuario $error');
      return false;
    }
  }

  Future<bool> unbanUser(String uid) async {
    try {
      final result = await _userRepo.unbanUserByUid(uid);
      if (result) {
        await loadUsers();
      }
      return result;
    } catch (error) {
      print('Hubo un error al desbannear al usuario $error');
      return false;
    }
  }

  Future<bool> updateUser (UserModel newUser) async {
    try{
      bool updated = await _userRepo.updateUser(newUser);
      if (updated) {
        await loadUsers();
      }
      return updated;
    } catch (error) {
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// GAMES PAGE

  void searchGames(String query) async {
    if (_containsCharNoAlfanumeric(query)) {
      _filteredGames = [];
    } else {
      try {
        _filteredGames.clear();
        for (GameModel game in games) {
          if (game.name.toLowerCase().contains(query.toLowerCase()) || game.id.toString().contains(query.toLowerCase())) {
            _filteredGames.add(game);
          }
        }
        print("Juegos Encontrados: $_filteredGames");
      } catch (error) {
        print("THERE WAS AN ERROR GETTING THE DATA REQUESTED FROM THE DATABASE: $error");
      } finally {
        notifyListeners();
      }
    }
  }

  Future<bool> deleteGame(int gameId) async {
    try {
      bool deleted = await _gameRepo.deleteGameById(gameId.toString());
      if (deleted) {
        await loadGames();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print("HUBO UN ERROR DURANTE EL BORRADO DEL JUEGO: $error");
      return false;
    }
  }

  Future<bool> updateGame(GameModel gameData) async {
    try {
      bool updated = await _gameRepo.updateGame(gameData);
      if (updated) {
        await loadGames();
      }
      return updated;
    } catch (error) {
      print("HUBO UN ERROR ACTUALIZANDO LOS DATOS: $error");
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// COMMENTS PAGE

  void searchComments(String query) async {
    if (_containsCharNoAlfanumeric(query)) {
      _filteredComments = [];
    } else {
      try {
        _filteredComments.clear();

        /// Buscamos IDs por nombre de juego o usuario con set para evitar duplicados
        final gameIds = games
            .where((game) => game.name.toLowerCase().contains(query.toLowerCase()))
            .map((game) => game.id.toString())
            .toSet();

        final userIds = users
            .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
            .map((user) => user.uid.toString())
            .toSet();

        /// Filtramos los comentarios
        for (final comment in comments) {
          final titleMatch = comment.title.toLowerCase().contains(query.toLowerCase());
          final gameMatch = gameIds.contains(comment.gameId.toString());
          final userMatch = userIds.contains(comment.userId.toString());

          if (titleMatch || gameMatch || userMatch) {
            _filteredComments.add(comment);
          }
        }

        print("Comentarios encontrados: $_filteredComments");
      } catch (error) {
        print("Error buscando comentarios: $error");
      } finally {
        notifyListeners();
      }
    }
  }

  Future<bool> banCommentById(String id) async {
    try {
      bool banned = await _commentRepo.banCommentById(id);
      if (banned) {
        await loadComments();
      }
      return banned;
    } catch (error) {
      print("HUBO UN ERROR AL BORRAR EL COMENTARIO");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> unbanCommentById(String id) async {
    try {
      bool unbanned = await _commentRepo.unbanCommentById(id);
      if (unbanned) {
        await loadComments();
      }
      return unbanned;
    } catch (error) {
      print("HUBO UN ERROR AL BORRAR EL COMENTARIO");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteCommentById(String id) async {
    try {
      bool deleted = await _commentRepo.deleteCommentById(id);
      if (deleted) {
        await loadComments();
      }
      return deleted;
    } catch (error) {
      print("HUBO UN ERROR AL BORRAR EL COMENTARIO");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<GameModel?> getGameByCommentId(int gameId) async {
    try {
      for (GameModel game in games) {
        if (game.id == gameId) {
          return game;
        }
      }
    } catch (error) {
      print("HUBO UN ERROR AL RECOGER EL JUEGO A PARTIR DEL COMENTARIO");
      return null;
    }
  }

  Future<UserModel?> getUserByCommentId(String userId) async {
    try {
      return users.firstWhereOrNull((user) => user.uid == userId);
    } catch (error) {
      print("HUBO UN ERROR AL RECOGER EL USUARIO A PARTIR DEL COMENTARIO");
      return null;
    }
  }

}