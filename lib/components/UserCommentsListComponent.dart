import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/UserImage.dart';
import 'package:game_box/components/UserName.dart';
import 'package:game_box/games/services/IgdbApiRepository.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:game_box/repository/GameRepository.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../routes/AppRoutes.dart';

class UserCommentsListComponent extends StatelessWidget {
  const UserCommentsListComponent({super.key});

  Future<void>? _redirectToGame(BuildContext context, int gameId) async {
    try {
      Map<String, dynamic>? game = {};
      GameRepository _gameRepo = GameRepository();
      game = await _gameRepo.getGameById(gameId);
      if (game != null) {
        Get.toNamed(Routes.game, arguments: game);
      } else {
        print("EL JUEGO RECIBIDO ESTABA VACÍO");
      }
    } catch (error) {
      print("HUBO UN ERROR AL BUSCAR EL JUEGO");
    }
  }

  Future<List<Map<String, dynamic>>> _getComments() async {
    List<Map<String, dynamic>> list = [];
    User? _user = FirebaseAuth.instance.currentUser;
    CommentaryRepository _commentRepo = CommentaryRepository();
    if (_user != null && !_user.isAnonymous) {
      try {
        list = await _commentRepo.getUserCommentariesByUid(_user.uid);
        return list;
      } catch (error) {
        print("HUBO UN ERROR AL RECOGER LOS COMENTARIOS DE LA BASE DE DATOS: $error");
        return list;
      }
    } else {
      print("EL USUARIO NO ESTÁ LOGGEADO");
      return list;
    }

  }

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
    return Container(
      child: Column(
        children: [
          Text(
            'Your Comments',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF750202),
            ),
          ),
          SizedBox(height: 30,),
          FutureBuilder <List<Map<String, dynamic>>>(
            future: _getComments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                /// If future is charging, shows a progress indicator
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                /// if future return error shows an error message
                return Text(
                  'ERROR GETTING DATA TRY LATER',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF0000),
                  ),
                );
              } else if (snapshot.hasData) {
                /// If future has data, shows it
                return Container(
                  child: Column(
                    children: [
                      SizedBox(height: 30,),
                      ...snapshot.data!.map((comment) =>
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: GestureDetector(
                          onTap: () {
                            _redirectToGame(context, comment['gameId']);
                          },
                          child: Container(
                          width: 600,
                          decoration: BoxDecoration(
                            color: Color(0xFF1C1B1B),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  UserImage(size: 64),
                                  UserName(),
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Color(_gameRatingColor(comment['value'].toDouble())),
                                    ),
                                    child: Center(
                                      child: Text(
                                        comment['value'].toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25),
                                      child: Text(
                                        comment['title'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25),
                                      child: Text(
                                        comment['body'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 25),
                                    child: Text(
                                      _formatDateTime(comment['createdAt']),
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                      ),
                      ),
                      ),
                    ],
                  ),
                );

              } else {
                /// in other case shows an unknown advice
                return Text(
                  'UNKNOWN ERROR TRY LATER OR CONTACT WITH AN ADMIN',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF0000),
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
