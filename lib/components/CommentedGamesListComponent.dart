import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/GameImage.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../games/services/IgdbApiRepository.dart';
import '../routes/AppRoutes.dart';

class CommentedGamesListComponent extends StatelessWidget {
  final User? user;
  const CommentedGamesListComponent({super.key, required this.user});

  Future<List<Map<String, dynamic>>?> _getGames(BuildContext context) async {
    CommentaryRepository commentRepo = CommentaryRepository();
    List<dynamic>? commentedGames = await commentRepo.getGamesFromCommentsByUserId(user!);
    if (commentedGames == null) {
      print('COMMENTED GAMES IS NULL');
    } else {
      if (commentedGames.isNotEmpty) {
        print("Juegos comentados: $commentedGames");
        List<Map<String, dynamic>> gamesList = [];
        /// WE SAVE EACH GAME IN THE LIST
        for (var game in commentedGames) {
          if (gamesList.length < 10){
            /// ESTO DEBERÍA SUSTITUIRSE POR UNA CONSULTA A FIRESTOR DESDE GAMESREPOSITORY
            final result = await Provider.of<IgdbApiRepository>(context, listen: false).getGameById(game.toString());
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
            'GAMES YOU HAVE COMMENTED',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          FutureBuilder(
            future: _getGames(context),
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
