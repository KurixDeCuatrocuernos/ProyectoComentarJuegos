import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/comments/controllers/CommentaryController.dart';
import 'package:game_box/comments/models/CommentaryModel.dart';
import 'package:game_box/comments/utils/CommentaryValidator.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:provider/provider.dart';

import '../games/services/IgdbApiRepository.dart';
import '../routes/AppRoutes.dart';

class CommentaryComponent extends StatefulWidget {
  final Map<String, dynamic>? game;
  final bool edit;

  const CommentaryComponent({super.key, required this.game, this.edit = false});

  @override
  _CommentaryComponentState createState() => _CommentaryComponentState();
}

class _CommentaryComponentState extends State<CommentaryComponent> {
  final _formKey = GlobalKey<FormState>();
  late CommentaryController commentaryController;
  late CommentaryValidator commentaryValidator;

  @override
  void initState() {
    super.initState();
    commentaryController = CommentaryController();
    commentaryValidator = CommentaryValidator();

    if (widget.edit) {
      print("SE VA A EDITAR EL COMENTARIO");
      _isEditing();
    }
  }

  Future<void> _isEditing() async {
    print("EDITANDO COMENTARIO");
    User? user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic>? commentary = await CommentaryRepository().getCommentaryByUserAndGame(user!, widget.game!);

    if (commentary != null) {
      commentaryController.titleController.text = commentary?['title'];
      commentaryController.commentController.text = commentary?['body'];
      commentaryController.sliderController.value = commentary?['value'];
    } else {
      print("COMENTARIO RECOGIDO NO DISPONIBLE");
    }
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
                      validator: commentaryValidator.isValidCommentary,
                      controller: commentaryController.titleController,
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
                        validator: commentaryValidator.isValidCommentary,
                        controller: commentaryController.commentController,
                        decoration: const InputDecoration(
                          hintText: '¿What do you think about the videogame?',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Obx(() {
                    return Column(
                      children: [
                        Text(
                          "${commentaryController.sliderController.value}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: commentaryController.sliderController.value.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: '${commentaryController.sliderController.value}',
                          onChanged: (double newValue) {
                            commentaryController.sliderController.value = newValue.toInt();
                          },
                        ),
                        Text(commentaryValidator.isValidValue(commentaryController.sliderController.value) ?? ''),
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
                                 cell = await commentaryController.editCommentary(widget.game!, uid!);
                              } else {
                                print("GUARDANDO NUEVO COMENTARIO");
                                commentaryController.addNewCommentary(
                                    widget.game!,
                                    uid!,
                                    await Provider.of<IgdbApiRepository>(context, listen: false).getCover(widget.game?['cover'])
                                );
                              }
                            } catch (error) {
                              cell = false;
                            }
                            if (cell == true) {
                              Get.offAllNamed(Routes.game, arguments: widget.game);
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

