import 'package:flutter/material.dart';
import 'package:game_box/games/models/GameApiProjection.dart';
import 'package:game_box/routes/AppRoutes.dart';
import 'package:game_box/viewModels/GameViewModel.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import 'package:game_box/components/GameImage.dart';

import '../games/models/GameModel.dart';

class GameListComponent extends StatefulWidget {
  final String genre;
  const GameListComponent({super.key, required this.genre});

  @override
  State<GameListComponent> createState() => _GameListComponentState();
}

class _GameListComponentState extends State<GameListComponent> {

  late Future<List<GameApiProjection>?> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _getGames(context, widget.genre);
  }

  Future<List<GameApiProjection>?> _getGames(BuildContext context, String genre) async {
    final existingGames = context.read<GameViewModel>().getListGamesByGenre(genre);
    if (existingGames.isNotEmpty) {
      print("ExistingGames is not empty: ${existingGames.toString()}");
      return existingGames;
    } else {
      var genreId = await context.read<GameViewModel>().getGenreIdFromApi(genre);
      if (genreId != null) {
        print("Se van a buscar los juegos por género de: $genreId");
        return await context.read<GameViewModel>().getAllGamesByGenreFromApi(genre, genreId);
      } else {
        print('The GENRE ID IS NULL');
        return [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final GameViewModel _gameViewModel = context.watch<GameViewModel>();
    if (_gameViewModel.listGames.isNotEmpty) {
      final List<GameApiProjection> gameList = context.read<GameViewModel>().getListGamesByGenre(widget.genre);
      print("La LISTA DEL MODELO ES: $gameList");
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.genre.toUpperCase()}, From ViewModel",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  Row(
                    children: gameList
                        .where((game) => game.coverId != null)
                        .map((game) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: 64,
                        height: 128,
                        child: GestureDetector(
                          child: GameImage(gameApi: game),
                          onTap: () async {
                            GameModel? gameModeled = await _gameViewModel.getGameByIdFromApi(game.id!);
                            if (gameModeled != null) {
                              Get.toNamed(Routes.game, arguments: gameModeled);
                            } else {
                              /// Redirigir a la página de error
                              Get.offAllNamed(Routes.loading);
                            }
                          },
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.genre.toUpperCase()}, From Api",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            FutureBuilder(
              future: _gamesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No hay juegos', style: TextStyle(color: Colors.white));
                } else {
                  final gameIds = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        Row(
                          children: gameIds
                              .where((game) => game.coverId != null)
                              .map((game) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              width: 64,
                              height: 128,
                              child: GestureDetector(
                                child: GameImage(gameApi: game),
                                onTap: () async {
                                  GameModel? gameModeled = await _gameViewModel.getGameByIdFromApi(game.id!);
                                  if (gameModeled != null) {
                                    Get.toNamed(Routes.game, arguments: gameModeled);
                                  } else {
                                    /// Redirigir a la página de error
                                    Get.offAllNamed(Routes.loading);
                                  }
                                },
                              ),
                            ),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );
    }
  }
}
