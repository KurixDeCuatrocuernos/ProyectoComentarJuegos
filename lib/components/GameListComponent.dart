import 'package:flutter/material.dart';
import 'package:game_box/games/services/IgdbApiRepository.dart';
import 'package:game_box/routes/AppRoutes.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import 'package:game_box/components/GameImage.dart';

class GameListComponent extends StatelessWidget {
  final String genre;
  const GameListComponent({super.key, required this.genre});

  Future<List<Map<String, dynamic>>?> _getGames(BuildContext context, String genre) async {
    var genreId = await Provider.of<IgdbApiRepository>(context, listen: false).getGenreId(genre);
    if (genreId != null) {
      List<Map<String, dynamic>> gamesList = await Provider.of<IgdbApiRepository>(context, listen: false).getAllGamesByGenre(genreId);
      if (!gamesList.isEmpty) {
        print("LA LISTA DE JUEGOS ES: ${gamesList.toString()}");
        return gamesList;
      } else {
        print("THERE IS NO GAME IN THE RETURNED LIST");
        return [];
      }
    } else {
      print('The GENRE ID IS NULL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            genre.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          // NO uses Row aquí
          FutureBuilder(
            future: _getGames(context, genre),
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
                  child: Row(
                    children: gameIds
                        .where((game) => game['cover'] != null)
                        .map((game) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: 64,
                        height: 128,
                        child: GestureDetector(
                            child: GameImage(game: game),
                          onTap: () {
                              Get.toNamed(Routes.game, arguments: game);
                          },
                        ),
                      ),
                    ))
                        .toList(),
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
