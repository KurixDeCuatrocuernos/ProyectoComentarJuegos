import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/UserImage.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:intl/intl.dart';

class CommentByUserComponent extends StatefulWidget {
  final Map<String, dynamic> game;
  const CommentByUserComponent({super.key, required this.game});

  @override
  State<CommentByUserComponent> createState() => _CommentByUserComponentState();
}

class _CommentByUserComponentState extends State<CommentByUserComponent> {

  CommentaryRepository _commentRepo = CommentaryRepository();

  Future<Map<String, dynamic>?> _isComment(Map<String,dynamic> game) async {
    if (FirebaseAuth.instance.currentUser != null) {
      if (FirebaseAuth.instance.currentUser!.uid.isNotEmpty) {
        try {
          return await _commentRepo.getCommentaryByUserAndGame(FirebaseAuth.instance.currentUser!, widget.game);
        } catch (error) {
          print("There was an error connecting with database");
          return null;
        }
      } else {
        print("User has not uid");
        return null;
      }
    } else {
      print("User is not logged");
      return null;
    }
  }

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
    return FutureBuilder<Map<String, dynamic>?>(
      future: _isComment(widget.game),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(width: 10,),
                      UserImage(size: 50),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Color(_gameRatingColor(snapshot.data?['value'].toDouble())),
                        ),
                        child: Center(
                          child: Text(
                            snapshot.data?['value'].toString() ?? 'NULL',
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

                  /// Limitamos el ancho de la columna de texto
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 300, // el máximo ancho que quieras permitir
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                snapshot.data?['title'] ?? 'COMMENT TITLE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 5),
                          Text(
                            snapshot.data?['body'] ?? 'SIN CONTENIDO',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                formatDateTime(snapshot.data?['createdAt']),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 20,),
                            ],
                          ),
                        ],
                      ),
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

