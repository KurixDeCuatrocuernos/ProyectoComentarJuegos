import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CommentaryController extends GetxController {
  TextEditingController commentController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  var sliderController = 50.obs;
  String _collectionC = 'comments';
  String _collectionG = 'games';

  addNewCommentary(Map<String, dynamic> game, String UID, URL) async{
    print("AÑADIDO EL COMENTARIO:\nTITLE: ${titleController.text}\nBODY: ${commentController.text}\nVALUE: ${sliderController.value}\nUSER: $UID\nGAME: ${game['id']}");
    final doc = await FirebaseFirestore.instance
    .collection(_collectionG)
    .doc(game['id'].toString())
    .get();
    print("SE VA A AÑADIR EL JUEGO A LA BASE DE DATOS");
    addNewGame(game, URL);

    final commentSetted = await FirebaseFirestore.instance.collection(_collectionC).add({
      'title': titleController.text,
      'body': commentController.text,
      'value': sliderController.value,
      'userId': UID,
      'gameId': game['id'],
      'createdAt': FieldValue.serverTimestamp(),
    });


  }

  ///Este metodo pertenece a GameRepository, pero lo pongo aquí por ahora
  addNewGame(Map<String, dynamic> game, URL) async {
    print("AÑADIENDO JUEGO A LA BASE DE DATOS");
    print('COVER OBTENIDA: $URL');
    var rawTimestamp = game['first_release_date'];
    print("FECHA RECOGIDA: $rawTimestamp");
    if (rawTimestamp is String){
      rawTimestamp = int.tryParse(rawTimestamp);
    }
    DateTime? convertedDate;
    if (rawTimestamp != null) {
      convertedDate = DateTime.fromMillisecondsSinceEpoch(rawTimestamp * 1000);
      print("FECHA CONVERTIDA: $convertedDate");
    }

    final gameSetted = await FirebaseFirestore.instance
        .collection(_collectionG).doc(game['id'].toString()).set({
      'id': game['id'],
      'name': game['name'],
      'summary': game['summary'],
      'rating': game['rating'],
      'coverId': game['cover'],
      'url': URL,
      'first_release_date': rawTimestamp != null ? convertedDate : null,
    }, SetOptions(merge: true));
  }

  Future<bool> editCommentary(Map<String, dynamic> game, String uid) async {
    bool cell = true;
    print("SUBIENDO MODIFICACIONES A LA BASE DE DATOS");
    try {
      String commentId;
      QuerySnapshot response = await FirebaseFirestore.instance.collection(_collectionC)
          .where('gameId', isEqualTo: game['id'])
          .where('userId', isEqualTo: uid)
          .get();
      if (response.docs.isNotEmpty){
        commentId = response.docs[0].id;
        await FirebaseFirestore.instance.collection(_collectionC)
            .doc(commentId)
            .update({
              'title': titleController.text,
              'body': commentController.text,
              'value': sliderController.value,
              'createdAt': FieldValue.serverTimestamp(),
            })
            .then((_) => print("COMENTARIO ACTUALIZADO"));
      }
    } catch (error) {
      print("HUBO UN ERROR AL EDITAR EL COMENTARIO: $error");
      cell = false;
    }
    return cell;
  }

}