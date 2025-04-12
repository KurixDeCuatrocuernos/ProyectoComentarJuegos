import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CommentaryController extends GetxController {
  TextEditingController commentController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  var sliderController = 50.obs;

  addNewCommentary(Map<String, dynamic> game, String UID, URL) async{
    print("AÑADIDO EL COMENTARIO:\nTITLE: ${titleController.text}\nBODY: ${commentController.text}\nVALUE: ${sliderController.value}\nUSER: $UID\nGAME: ${game['id']}");
    final doc = await FirebaseFirestore.instance
    .collection('games')
    .doc(game['id'].toString())
    .get();
    print("SE VA A AÑADIR EL JUEGO A LA BASE DE DATOS");
    addNewGame(game, URL);

    final commentSetted = await FirebaseFirestore.instance.collection('comments').add({
      'title': titleController.text,
      'body': commentController.text,
      'value': sliderController.value,
      'userId': UID,
      'gameID': game['id']
    });


  }

  ///Este metodo pertenece a GameRepository, pero lo pongo aquí por ahora
  addNewGame(Map<String, dynamic> game, URL) async {
    print("AÑADIENDO JUEGO A LA BASE DE DATOS");
    print('COVER OBTENIDA: $URL');
    final gameSetted = await FirebaseFirestore.instance
        .collection('games').doc(game['id'].toString()).set({
      'id': game['id'],
      'name': game['name'],
      'summary': game['summary'],
      'rating': game['rating'],
      'coverId': game['cover'],
      'url': URL
    }, SetOptions(merge: true));
  }

}