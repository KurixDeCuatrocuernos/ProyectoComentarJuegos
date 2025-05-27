import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_box/viewModels/AdminViewModel.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../games/models/GameModel.dart';
import '../routes/AppRoutes.dart';
import 'EditGameComponent.dart';

class ShowGameComponent extends StatelessWidget {
  final GameModel game;
  const ShowGameComponent({super.key, required this.game});

  String _formatDateTime(dynamic rawDate) {
    DateTime date;
    if (rawDate is Timestamp) {
      // Si el rawDate es un Timestamp de Firestore
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      // Si ya es un DateTime
      date = rawDate;
    } else {
      // Si no hay fecha, se usa la fecha y hora actual
      date = DateTime.now();
    }
    // Formateamos la fecha a un formato legible
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }

  Widget _showErrorDialog(String text, BuildContext context) {
   return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.25,
          maxHeight:  MediaQuery.of(context).size.height * 0.15,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 25,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Color(0xFFA10505),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showDeleteGame(context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.25,
          maxHeight:  MediaQuery.of(context).size.height * 0.20,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 20,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Are you sure you want to delete this game? (this could affect to the commentaries behavior)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      'DELETE',
                      style: TextStyle(
                        color: Color(0xFFA10505),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () async {
                      Get.back();
                      bool isDeleted = await context.read<AdminViewModel>().deleteGame();
                      if (isDeleted) {
                        Get.offAllNamed(Routes.manageGames);
                      } else {
                        Get.dialog(_showErrorDialog('ERROR DELETING GAME', context));
                      }
                    },
                  ),
                  TextButton(
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Color(0xFF176504),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary(String text, BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight:  MediaQuery.of(context).size.height * 0.5,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xFF0B0A0A),
            border: Border.all(
              color: Colors.white,
              width: 4.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(Icons.close, size: 32,),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      text, // Aquí usas el texto que le pasas
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final _dataStyle = TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500,);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10,),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black,
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox( height: 10,),
                  Text(
                    'ID: ${game.id}' ,
                    style: _dataStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox( height: 10,),
                  Text(
                    'TITLE: ${game.name}' ,
                    style: _dataStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox( height: 10,),
                  TextButton(
                    child: Text(
                      'ABSTRACT: ${game.summary}',
                      style: _dataStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () {
                      if (game.summary != null) {
                        Get.dialog(_summary(game.summary!, context));
                      }
                    },
                  ),
                  SizedBox( height: 10,),
                  Text(
                    'COVER ID: ${game.coverId}',
                    style: _dataStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox( height: 10,),
                  Text(
                    'COVER URL: ${game.url ?? 'NULL'}',
                    style: _dataStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox( height: 10,),
                  Text(
                    'RELEASE DATE: ${_formatDateTime(game.first_release_date)}',
                    style: _dataStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox( height: 10,),
                  Text(
                    'RATING: ${game.rating}',
                    style: _dataStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox( height: 10,),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Color(0xFFDDD8D8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 32,),
                    onPressed: () {
                      Get.dialog(EditGameComponent(game: game));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 32,),
                    onPressed: () {
                      Get.dialog(_showDeleteGame(context));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
