import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_box/comments/models/CommentProjection.dart';
import 'package:game_box/components/UserImage.dart';
import 'package:game_box/games/models/GameModel.dart';
import 'package:game_box/viewModels/CommentViewModel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentsListComponent extends StatefulWidget {
  final GameModel game;
  const CommentsListComponent({super.key, required this.game});

  @override
  State<CommentsListComponent> createState() => _CommentsListComponentState();
}

class _CommentsListComponentState extends State<CommentsListComponent> {

  String _formatDateTime(dynamic rawDate) {
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
    final viewModel = context.watch<CommentViewModel>();

    return FutureBuilder<List<CommentProjection>?>(
        future: viewModel.getCommentsFromRepository(widget.game),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            /// If connection state is wating, we show a circular progress indicator
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            /// If future has errors we show an error message
            return Text('Error getting the commentaries');
          } else if (snapshot.hasData) {
            return Column(
              children: snapshot.data!
                  .map((comment) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFF1C1B1B),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header con imagen y nombre de usuario
                      Row(
                        children: [
                          UserImage(size: 50, uid: comment.comment.userId),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              comment.userId,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Color(_gameRatingColor(comment.comment.value.toDouble())),
                            ),
                            child: Center(
                              child: Text(
                                comment.comment.value.toString() ?? 'NULL',
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
                      const SizedBox(height: 12),

                      /// Título
                      Center(
                        child: Text(
                          comment.comment.title ?? 'TITLE NOT FOUND',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),

                      /// Cuerpo del comentario
                      Text(
                        comment.comment.body ?? 'BODY NOT FOUND',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 8),

                      /// Fecha
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _formatDateTime(comment.comment.createdAt),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
                  .toList(),
            );
          } else {
            /// in any other case (like snapshot has not data or null) we show nothing
            return SizedBox();
          }
        },
    );
  }
}
