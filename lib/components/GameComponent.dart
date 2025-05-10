import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/CommentaryComponent.dart';
import 'package:game_box/components/GameImage.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:get/get.dart';


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
          content: CommentaryComponent(game: game!, edit: false,),
        );
      },
    );
  }

  void showEditCommentForm(BuildContext context) {
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
          content: CommentaryComponent(game: game!, edit: true,),
        );
      },
    );
  }

  Future<int> _getRating(Map<String, dynamic> game) async {
    /// Recoger valor comentario
    CommentaryRepository _commentRepo = CommentaryRepository();
    List<Map<String, dynamic>>? list = await _commentRepo.getWeightAndValuesByGame(game);
    if (list != null) {
      print("Firestore ha devuelto: $list");
      double sumWeight = 0;
      double productValues = 0;
      for(var element in list!) {
        /// sum all the weights
        sumWeight += element['weight'] as double;
        /// sum the products of the values and weights
        productValues += (element['value'] as double) * (element['weight'] as double);
      }

      /// dividir la suma de los productos entre la suma de los pesos
      print("la media ponderada de: $productValues entre: $sumWeight es: ${(productValues/sumWeight).round()}");
      return (productValues/sumWeight).round();
    } else {
      return 0;
    }
  }

  Future<int> _whichRating(Map<String, dynamic> game) async {
    CommentaryRepository _commentRepo = CommentaryRepository();
    int? commentaries = await _commentRepo.countCommentsByGame(game);
    print("NÚMERO DE COMENTARIOS: $commentaries");
    if (commentaries != null && commentaries >= 1) {
      print("SE HA CALCULADO EL RATING: ${_getRating(game)}");
      return _getRating(game);
    } else {
      double doubleRandom = Random().nextDouble()*101; /// NÚMERO RANDOM POR SI RATING ES NULO
      if (game['rating'] != null) {
        print("SE HA DEVUELTO EL RATING DE IGDB: ${game['rating']}");
        return game['rating'].round();
      } else {
        print("SE HA DEVUELTO UN RATING ALEATORIO: $doubleRandom");
        return doubleRandom.round();
      }
    }
  }


  Future<bool> _isCommented() async{
  /// verificamos si el usuario ha comentado o no este juego
    CommentaryRepository _commentRepo = CommentaryRepository();
    User? _user = FirebaseAuth.instance.currentUser;
    bool cell = await _commentRepo.getIfUserHasCommentedThisGame(_user!, game);
    return cell;
  }

  int _gameRatingColor(int rating) {
    if (rating > 0 && rating < 10) {
      return 0xFFBC0101; // Color rojo
    } else if (rating >= 10 && rating < 20) {
      return 0xFFAF1B02; // Color naranja oscuro
    } else if (rating >= 20 && rating < 30) {
      return 0xFFBD4F01; // Color naranja
    } else if (rating >= 30 && rating < 40) {
      return 0xFFC18101; // Color naranja claro
    } else if (rating >= 40 && rating < 50) {
      return 0xFFBD9302; // Color amarillo oscuro
    } else if (rating >= 50 && rating < 60) {
      return 0xFFC5B201; // Color amarillo
    } else if (rating >= 60 && rating < 70) { // Añadido para valores de 60
      return 0xFF9EB500; // Color verde claro
    } else if (rating >= 70 && rating < 80) {
      return 0xFF9EB500; // Color verde claro
    } else if (rating >= 80 && rating < 90) {
      return 0xFF5FA802; // Color verde
    } else if (rating >= 90) {
      return 0xFF029C05; // Color verde oscuro
    } else {
      return 0xFF0048FF; // Color azul (valor por defecto)
    }
  }


  @override
  Widget build(BuildContext context) {
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
              child: game?['url'] != null ? Image.network(game!['url']): GameImage(game: game!), /// Hay que cambiarlo por la imagen correspondiente
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
            FutureBuilder(
                future: _whichRating(game!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    print("ERROR: ${snapshot.error}");
                    return Text("Error");
                  } else if (snapshot.hasData) {
                    return Container(
                      width: 64,
                      height: 64,
                      decoration:
                      BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(_gameRatingColor(snapshot.data!)),
                      ),
                      alignment: Alignment.center,
                      child:
                      Text(
                        snapshot.data!.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    return Text("Empty Data");
                  }
                }
            ),
          ],
        ),
        SizedBox(
          width: 320,
          child: Text(
              game?['summary'] != null ? game!['summary'] : 'This game has no abstract',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FutureBuilder<bool>(
              future: _isCommented(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Mientras espera el resultado del future
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error al verificar comentario");
                } else if (snapshot.hasData) {
                  bool isCommented = snapshot.data!;

                  return FloatingActionButton(
                    onPressed: () {},
                    shape: const CircleBorder(),
                    backgroundColor: Colors.black,
                    child: IconButton(
                      icon: Icon(
                        isCommented ? Icons.edit : Icons.add,
                        size: 40,
                      ),
                      onPressed: () {
                        if (isCommented) {
                          showEditCommentForm(context);
                        } else {
                          showCommentForm(context);
                        }
                      },
                      color: Colors.white,
                    ),
                  );
                } else {
                  return SizedBox(); // fallback
                }
              },
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
