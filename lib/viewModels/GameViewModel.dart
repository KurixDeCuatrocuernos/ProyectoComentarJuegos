
import 'package:flutter/material.dart';

import '../games/models/GameApiProjection.dart';
import '../games/models/GameModel.dart';
import '../games/services/IgdbApiRepository.dart';
import '../repository/CommentaryRepository.dart';
import '../repository/GameRepository.dart';

class GameViewModel extends ChangeNotifier{
  final IgdbApiRepository _apiRepo;
  ///Metodo constructor Shingleton
  GameViewModel(this._apiRepo);

  final CommentaryRepository _commentRepo = CommentaryRepository();
  final GameRepository _gameRepo = GameRepository();

  final List<GameModel> _games = [];
  List<GameModel> get games => List.unmodifiable(_games);

  final Map<String, List<GameApiProjection>> _listGames = {};
  Map<String, List<GameApiProjection>> get listGames => _listGames;

  final List<GameModel> _commentedGamesList = [];
  List<GameModel> get commentedGamesList => _commentedGamesList;

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

  Future<GameModel?> getGameByIdFromRepository(int id) async {
    try {
      GameModel? game = await _gameRepo.getGameById(id);
      return game;
    } catch (error) {
      print("HUBO UN ERROR AL RECOGER LOS DATOS DEL JUEGO");
      return null;
    }
  }

  Future<List<GameModel>?> getAllGamesFromRepository(String uid) async {
    //print("User id: $uid");
    List<dynamic>? commentedGames = await _commentRepo.getGamesFromCommentsByUserId(uid);
    if (commentedGames == null) {
      //print('COMMENTED GAMES IS NULL');
      return [];
    } else {
      if (commentedGames.isNotEmpty) {
        //print("Juegos comentados: $commentedGames");
        List<GameModel> gamesList = [];

        /// WE SAVE EACH GAME IN THE LIST
        for (var game in commentedGames) {
          if (gamesList.length < 10) {
            /// ESTO DEBERÍA SUSTITUIRSE POR UNA CONSULTA A FIRESTORE DESDE GAMESREPOSITORY
            //print("Buscando juego: $game");
            try{
              final int gameId = int.parse(game.toString());
              //print("id transformado $gameId");
              final result = await _gameRepo.getGameById(gameId);
              if(result != null) {
                gamesList.add(result);
              } else {
                final apiResult = await _apiRepo.getGameById(game);
                gamesList.add(apiResult);
              }

            } catch (error) {
              print("Error al obtener el juego: $error");
            }
          }
        }
       // print("Juegos encontrados $gamesList");

        if (gamesList.isNotEmpty) {
          //print("LA LISTA DE JUEGOS ES: ${gamesList.toString()}");
          commentedGamesList.clear();
          commentedGamesList.addAll(gamesList);
          notifyListeners();
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

  Future<String> getCoverFromApi(int coverId) async {
    try {
      String? cover = await _apiRepo.getCover(coverId);
      return cover ?? "";
    } catch (error) {
      print("Hubo un error recogiendo el cover del juego");
      return "";
    }
  }

  Future<int?> getGenreIdFromApi(String genre) async {
    try {
      return await _apiRepo.getGenreId(genre);
    } catch (error) {
      print("Error getting the GenreId from API: $error");
      return null;
    }
  }

  Future<List<GameApiProjection>> getAllGamesByGenreFromApi(String genreName, int genre) async {
    try {
      List<GameApiProjection> list = await _apiRepo.getAllGamesByGenre(genre);
      listGames.addAll({genreName: list});
      print("LISTA DEL GÉNERO: $list");
      return list;
    } catch (error) {
      print("Error Getting the games by genre from API: $error");
      return [];
    } finally {
      notifyListeners();
    }
  }

  List<GameApiProjection> getListGamesByGenre(String genre) {
    try {
      return listGames[genre] ?? [];
    } catch (error) {
      print("NO SE ENCONTRARON JUEGOS DE ESE GÉNERO EN EL VIEW MODEL: $error");
      return [];
    }
  }

  GameApiProjection? getGameFromList(int id) {
    for(var entry in listGames.entries) {
      try {
        final GameApiProjection game = entry.value.firstWhere((g) => g.id == id);
        return game;
      } catch (error) {
        return null;
      }
    }
  }

  Future<GameModel?> getGameByIdFromApi(int id) async {
    try {
      final GameModel? game = await _apiRepo.getGameById(id.toString());
      if (game != null) {
        addGame(game);
      }
      return game;
    } catch (error) {
      return null;
    } finally {
      notifyListeners();
    }
  }

  List<GameModel> getListCommentedGames() {
    try {
      return commentedGamesList ?? [];
    } catch (error) {
      print("NO SE ENCONTRARON JUEGOS DE ESE GÉNERO EN EL VIEW MODEL: $error");
      return [];
    }
  }



}