
import 'package:flutter/material.dart';

import '../games/models/GameModel.dart';
import '../games/services/IgdbApiRepository.dart';
import '../repository/CommentaryRepository.dart';
import '../repository/GameRepository.dart';

class GameViewModel extends ChangeNotifier{
  final IgdbApiRepository _apiRepo;
  ///Metodo constructor Shingleton
  GameViewModel(this._apiRepo);
  final List<GameModel> _games = [];
  List<GameModel> get games => List.unmodifiable(_games);
  GameRepository _gameRepo = GameRepository();
  CommentaryRepository _commentRepo = CommentaryRepository();


  void addGame(GameModel game) {
    _games.add(game);
    notifyListeners();
  }

  void addAllGames(List<GameModel> games) {
    for(GameModel game in games) {
      _games.add(game);
    }
    notifyListeners();
  }

  void updateGame(int id, GameModel gameUpdated) {
    final index = _games.indexWhere((game) => game.id == id);
    if (index != -1) {
      _games[index] = gameUpdated;
      notifyListeners();
    }
  }

  void removeGame(int id) {
    _games.removeWhere((game) => game.id == id);
    notifyListeners();
  }

  GameModel? getGameById(int id) {
    try {
      return _games.firstWhere((game) => game.id == id);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _games.clear();
    notifyListeners();
  }

  /// Hasta aquí métodos por defecto de ViewModel

  Future<Map<String, dynamic>?> getGameByIdFromRepository(int id) async {
    try {
      Map<String, dynamic>? game = await _gameRepo.getGameById(id);
      return game;
    } catch (error) {
      print("HUBO UN ERROR AL RECOGER LOS DATOS DEL JUEGO");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllGamesFromRepository(String uid) async {
    print("User id: $uid");
    List<dynamic>? commentedGames = await _commentRepo.getGamesFromCommentsByUserId(uid);
    if (commentedGames == null) {
      print('COMMENTED GAMES IS NULL');
      return [];
    } else {
      if (commentedGames.isNotEmpty) {
        print("Juegos comentados: $commentedGames");
        List<Map<String, dynamic>> gamesList = [];

        /// WE SAVE EACH GAME IN THE LIST
        for (var game in commentedGames) {
          if (gamesList.length < 10) {
            /// ESTO DEBERÍA SUSTITUIRSE POR UNA CONSULTA A FIRESTOR DESDE GAMESREPOSITORY
            final result = await _apiRepo.getGameById(game.toString());
            if (result is List && result.isNotEmpty) {
              gamesList.add(result.first as Map<String, dynamic>);
            }
          }
        }

        if (gamesList.isNotEmpty) {
          print("LA LISTA DE JUEGOS ES: ${gamesList.toString()}");
          return gamesList;
        } else {
          print("THERE IS NO GAME IN THE RETURNED LIST");
          return [];
        }
      } else {
        print('COMMENTED GAMES IS EMPTY');
        return [];
      }
    }
  }

}