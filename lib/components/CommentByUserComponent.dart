import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/comments/models/CommentaryModel.dart';
import 'package:game_box/components/UserImage.dart';
import 'package:game_box/games/models/GameModel.dart';
import 'package:game_box/viewModels/CommentViewModel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewModels/UserViewModel.dart';

class CommentByUserComponent extends StatefulWidget {
  final GameModel game;
  const CommentByUserComponent({super.key, required this.game});

  @override
  State<CommentByUserComponent> createState() => _CommentByUserComponentState();
}

class _CommentByUserComponentState extends State<CommentByUserComponent> {

  String formatDateTime(dynamic rawDate) {
    DateTime date;

    if (rawDate is Timestamp) {
      // Si el rawDate es un Timestamp de Firestore
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      // Si ya es un DateTime
      date = rawDate;
    } else {
      // Si no hay fecha, usamos la fecha y hora actual
      date = DateTime.now();
    }

    // Formateamos la fecha a un formato legible
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }

  int _gameRatingColor(double rating) {
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
    final _commentViewModel = context.watch<CommentViewModel>();
    final String? _uid = context.read<UserViewModel>().getCurrentUserId();
    return FutureBuilder<CommentaryModel?>(
      future: _commentViewModel.isCommentedThisGameByThisUser(widget.game, _uid!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error getting the commentary");
        } else if (snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFF1C1B1B),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna con imagen y puntuación
                  Column(
                    children: [
                      UserImage(size: 50, uid: _uid ?? "",),
                      SizedBox(height: 10),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Color(_gameRatingColor(snapshot.data!.value.toDouble())),
                        ),
                        child: Center(
                          child: Text(
                            snapshot.data?.value.toString() ?? 'NULL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 10),

                  // Columna con el contenido del comentario
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text(
                          snapshot.data?.title ?? 'COMMENT TITLE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          snapshot.data?.body ?? 'SIN CONTENIDO',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                          softWrap: true,
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            formatDateTime(snapshot.data?.createdAt),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedBox(); // Nada si no hay comentario
        }
      },
    );
  }

}

