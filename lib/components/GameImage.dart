import 'package:flutter/material.dart';
import 'package:game_box/games/models/GameApiProjection.dart';
import 'package:game_box/games/models/GameModel.dart';
import 'package:provider/provider.dart';

import '../viewModels/GameViewModel.dart';

class GameImage extends StatelessWidget {
  final GameModel? game;
  final GameApiProjection? gameApi;
  const GameImage({super.key, this.game, this.gameApi});

  @override
  Widget build(BuildContext context) {

    final int? gameId = game?.id ?? gameApi?.id;
    final gameCollected = context.read<GameViewModel>().getGameById(gameId!);
    final GameApiProjection? gameInList = context.read<GameViewModel>().getGameFromList(gameId);

    // Si el juego ya tiene una URL válida, la mostramos directamente
    if (gameCollected?.url != null && gameCollected!.url!.isNotEmpty) {
      return Image.network(gameCollected.url!);
    } else if (gameInList != null && gameInList.url != null) {
       return Image.network(gameInList.url!);
    } else { // Si no, la buscamos en la API
      final int? coverId = game?.coverId ?? gameApi?.coverId;
      if (coverId != null) {
        return FutureBuilder<String>(
          future: context.read<GameViewModel>().getCoverFromApi(coverId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Image.network(snapshot.data!);
            } else {
              return Text('COVER NOT FOUND (API ERROR)');
            }
          },
        );
      } else {
        return Text("COVER NOT FOUND");
      }
    }
  }
}
