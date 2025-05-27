import 'package:flutter/material.dart';
import 'package:game_box/components/CommentaryComponent.dart';
import 'package:game_box/components/GameImage.dart';
import 'package:game_box/games/models/GameModel.dart';
import 'package:game_box/viewModels/CommentViewModel.dart';
import 'package:provider/provider.dart';

class GameComponent extends StatelessWidget {
  final GameModel? game;
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:        Row(
            spacing: 20,
            children: [
              SizedBox(
                width: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * 0.3  : MediaQuery.of(context).size.width * 0.3,
                height: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.3 : MediaQuery.of(context).size.height * 0.3,
                child: game?.url != null ? Image.network(game!.url!): GameImage(game: game!), /// Hay que cambiarlo por la imagen correspondiente
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child:
                Text(
                  game!.name,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.025,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              FutureBuilder(
                  future: context.read<CommentViewModel>().whichRating(game!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      print("ERROR: ${snapshot.error}");
                      return Text("Error");
                    } else if (snapshot.hasData) {
                      return Container(
                        width: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.1 : MediaQuery.of(context).size.height * 0.07,
                        height: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.1 : MediaQuery.of(context).size.height * 0.07,
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
                            fontSize: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.045,
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
              SizedBox(width: 10,),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Text(
              game?.summary != null ? game!.summary! : 'This game has no abstract',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.02,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FutureBuilder<bool>(
              future: context.read<CommentViewModel>().isCommented(game!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Mientras espera el resultado del future
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error al verificar comentario");
                } else if (snapshot.hasData) {
                  bool isCommented = snapshot.data!;
                  final size = MediaQuery.of(context).orientation == Orientation.landscape
                      ? MediaQuery.of(context).size.height * 0.25
                      : MediaQuery.of(context).size.width * 0.15;

                  return SizedBox(
                    width: size,
                    height: size,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (isCommented) {
                          showEditCommentForm(context);
                        } else {
                          showCommentForm(context);
                        }
                      },
                      shape: const CircleBorder(),
                      backgroundColor: Colors.black,
                      child: Icon(
                        isCommented ? Icons.edit : Icons.add,
                        size: size * 0.5, // El ícono ocupa la mitad del FAB
                        color: Colors.white,
                      ),
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
