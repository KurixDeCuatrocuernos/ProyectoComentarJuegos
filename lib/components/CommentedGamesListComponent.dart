import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/GameImage.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:game_box/viewModels/GameViewModel.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../games/services/IgdbApiRepository.dart';
import '../routes/AppRoutes.dart';

class CommentedGamesListComponent extends StatelessWidget {
  final User? user;
  const CommentedGamesListComponent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final _gameViewModel = context.watch<GameViewModel>();

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
            future: _gameViewModel.getAllGamesFromRepository(user!.uid),
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
