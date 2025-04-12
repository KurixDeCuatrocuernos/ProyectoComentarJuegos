import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_box/components/CommentaryComponent.dart';
import 'package:game_box/components/GameImage.dart';


class GameComponent extends StatelessWidget {
  final Map<String, dynamic>? game;
  const GameComponent({super.key, required this.game});

  void showCommentForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Si el cuadro de diálogo debe cerrarse al tocar fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero, // Elimina el relleno alrededor del contenido
          content: CommentaryComponent(game: game!),
        );
      },
    );
  }


  bool _isCommented() {
  /// verificamos si el usuario ha comentado o no este juego
    bool cell = false;
    return cell;
  }

  int _gameRatingColor(double rating) {
    if (rating > 0 && rating < 10) {
      return 0xFFBC0101;
    } else if (rating >= 10 && rating < 20) {
      return 0xFFAF1B02;
    } else if (rating >= 20 && rating < 30) {
      return 0xFFBD4F01;
    } else if (rating >= 30 && rating < 40) {
      return 0xFFC18101;
    } else if (rating >= 40 && rating < 50) {
      return 0xFFBD9302;
    } else if (rating >= 50 && rating < 60) {
      return 0xFFC5B201;
    } else if (rating >= 70 && rating < 80) {
      return 0xFF9EB500;
    } else if (rating >= 80 && rating < 90) {
      return 0xFF5FA802;
    } else if (rating >= 90) {
      return 0xFF029C05;
    } else {
      return 0xFF0048FF;
    }
  }

  @override
  Widget build(BuildContext context) {
    double doubleRandom = Random().nextDouble()*101; /// NÚMERO RANDOM POR SI RATING ES NULO
    return Column(
      children: [
        Row(
          spacing: 20,
          children: [
            SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 128,
              height: 256,
              child: GameImage(game: game!),
            ),
            SizedBox(
              width: 128,
              child:
              Text(
                  game?['name'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration:
                BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(
                    _gameRatingColor((game?['rating'] ?? doubleRandom)), /// REVISAR LA LÓGICA POR SI RATING ES NULO
                  ),
                ),
              alignment: Alignment.center,
              child:
                Text(
                  (game?['rating'] ?? doubleRandom).round().toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            )
          ],
        ),
        SizedBox(
          width: 320,
          child: Text(
              game?['summary'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Expanded(
            child: SizedBox(

            ),
        ),
        Row(
          children: [
            Expanded(
                child: SizedBox(),
            ),
            _isCommented() == false ?
            FloatingActionButton(
              onPressed: () {},
              shape: const CircleBorder(),
              backgroundColor: Colors.black,
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 40,
                ),
                onPressed: () => showCommentForm(context),
                color: Colors.white,
              ),
            )
                :
            FloatingActionButton(
              onPressed: () {},
              shape: const CircleBorder(),
              backgroundColor: Colors.black,
              child: IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 40,
                ),
                onPressed: () {print("EDITASTE TU COMENTARIO DEL JUEGO: "+game!['name']);},
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 20,
            )
          ],
        ),
        SizedBox(
          height: 50,
        ),
      ],
    );
  }
}
