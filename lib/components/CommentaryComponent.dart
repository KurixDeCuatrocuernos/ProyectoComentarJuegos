import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/comments/controllers/CommentaryController.dart';
import 'package:game_box/comments/models/CommentaryModel.dart';
import 'package:game_box/comments/utils/CommentaryValidator.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:game_box/repository/GameRepository.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:provider/provider.dart';

import '../games/services/IgdbApiRepository.dart';
import '../pages/GamePage.dart';
import '../routes/AppRoutes.dart';

class CommentaryComponent extends StatefulWidget {
  final Map<String, dynamic> game;
  final bool edit;

  const CommentaryComponent({super.key, required this.game, this.edit = false});

  @override
  _CommentaryComponentState createState() => _CommentaryComponentState();
}

class _CommentaryComponentState extends State<CommentaryComponent> {
  final _formKey = GlobalKey<FormState>();
  late CommentaryController _commentController;
  late CommentaryValidator _commentValidator;

  @override
  void initState() {
    super.initState();
    _commentController = CommentaryController();
    _commentValidator = CommentaryValidator();

    if (widget.edit) {
      print("SE VA A EDITAR EL COMENTARIO");
      _isEditing();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _isEditing() async {
    print("EDITANDO COMENTARIO");
    User? user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic>? commentary = await CommentaryRepository().getCommentaryByUserAndGame(user!, widget.game);

    if (commentary != null) {
      _commentController.titleController.text = commentary['title'];
      _commentController.commentController.text = commentary['body'];
      _commentController.sliderController.value = commentary['value'];
    } else {
      print("COMENTARIO RECOGIDO NO DISPONIBLE");
    }
  }
  
  Future<bool> _addComment(Map<String,dynamic> comment) async {
    String? _uid;
    if (FirebaseAuth.instance.currentUser != null) {
     _uid = FirebaseAuth.instance.currentUser!.uid;
    }
    if (_uid != null) {
      try {
        GameRepository _gameRepo = GameRepository();
        CommentaryRepository _commentRepo = CommentaryRepository();
        // print("Revisando si el juego existe");
        bool gameExists = await _gameRepo.getIfGameExists(widget.game['id']);
        // print("RECOGIDO EL ID: $gameExists");
        if (gameExists) {
          bool added = await _commentRepo.addComment(comment, widget.game['id'], _uid);
          // print("SE HA AÑADIDO EL COMENTARIO: $added");
          return added;
        } else {
          // print("AÑADIENDO EL JUEGO ANTES QUE EL COMENTARIO");
          String gameCover = await Provider.of<IgdbApiRepository>(context, listen: false).getCover(widget.game['cover']);
          // print("SE VA A AÑADIR EL COVER: $gameCover");
          await _gameRepo.addNewGame(widget.game, gameCover);
          // print("SE AÑADIÓ EL JUEGO, VA A AÑADIRSE EL COMENTARIO");
          bool addedComment = await _commentRepo.addComment(comment, widget.game['id'], _uid);
          // print("AÑADIDO EL COMENTARIO: $addedComment");
          return addedComment;
        }
      } catch (error) {
        print("HUBO UN ERROR AL AÑADIR EL COMENTARIO: $error");
        return false;
      }
    }
    return false;
  }

  Future<bool> _editComment(Map<String, dynamic> comment) async {
    try {
      CommentaryRepository _commentRepo = CommentaryRepository();
      String _uid;
      if (FirebaseAuth.instance.currentUser != null) {
        _uid = FirebaseAuth.instance.currentUser!.uid;
        String? commentId = await _commentRepo.getCommentaryIdByUserAndGame(_uid, widget.game['id']);
        if (commentId != null) {
          return await _commentRepo.updateCommentById(commentId, comment);
        } else {
          return false;
        }
      }
    } catch (error) {
      print("HUBO UN ERROR AL EDITAR EL COMENTARIO: $error");
      return false;
    }
    return false;
  }

  Widget _showErrorMessage(String text) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          color: Colors.black,
        ),
        child: Column(
          children: [
            SizedBox(height: 10,),
            Text(
              text,
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10,),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      width: 300,
      height: 600,
      decoration: BoxDecoration(
        color: Color(0xFF120B0B), // Color de fondo
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black,
          width: 4,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: SizedBox(),),
              IconButton(
                onPressed: () {Navigator.of(context).pop();},
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  weight: 100,
                ),
              ),
            ],
          ),
          Text(
            'YOUR VALORATION',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            width: 250,
            height: 400,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Flexible(
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      validator: _commentValidator.isValidCommentary,
                      controller: _commentController.titleController,
                      decoration: const InputDecoration(
                        hintText: 'Resume your opinion about this videogame in a few words',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(),
                  Flexible(
                    child: SingleChildScrollView(
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        validator: _commentValidator.isValidCommentary,
                        controller: _commentController.commentController,
                        decoration: const InputDecoration(
                          hintText: 'What do you think about the videogame?',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Obx(() {
                    return Column(
                      children: [
                        Text(
                          "${_commentController.sliderController.value}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: _commentController.sliderController.value.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: '${_commentController.sliderController.value}',
                          onChanged: (double newValue) {
                            _commentController.sliderController.value = newValue.toInt();
                          },
                        ),
                        Text(_commentValidator.isValidValue(_commentController.sliderController.value.toString()) ?? ''),
                      ],
                    );
                  }),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                        onPressed: () async {
                          bool cell = true;
                          if (_formKey.currentState!.validate()) {
                            try {
                              if (widget.edit==true){
                                print("EDITANDO COMENTARIO");
                                Map<String, dynamic> comment = {
                                  'title': _commentController.titleController.text,
                                  'body': _commentController.commentController.text,
                                  'value': _commentController.sliderController.value,
                                  'editedAt': Timestamp.now(),
                                };
                                bool isEdited = await _editComment(comment);
                                if (isEdited == true) {
                                  Get.offAllNamed(Routes.game, arguments: widget.game);
                                } else {
                                  Get.dialog(_showErrorMessage('There was a problem adding the new comment'));
                                }
                              } else {
                                print("GUARDANDO NUEVO COMENTARIO");
                                Map<String, dynamic> comment = {
                                  'title': _commentController.titleController.text,
                                  'body': _commentController.commentController.text,
                                  'value': _commentController.sliderController.value,
                                  'createdAt': Timestamp.now(),
                                };
                                bool isCommented = await _addComment(comment);
                                if (isCommented == true) {
                                  Get.offAllNamed(Routes.game, arguments: widget.game);
                                } else {
                                  Get.dialog(_showErrorMessage('There was a problem adding the new comment'));
                                }
                              }
                            } catch (error) {
                              cell = false;
                            }
                            if (cell == true) {
                              Get.off(() => GamePage(), arguments: widget.game);
                            }
                          } else {
                            print("Try again!");
                          }
                        },
                        color: Colors.green,
                        iconSize: 40,
                        icon: Icon(Icons.check)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

