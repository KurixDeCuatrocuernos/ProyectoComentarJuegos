import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/comments/controllers/CommentaryController.dart';
import 'package:game_box/comments/utils/CommentaryValidator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:provider/provider.dart';

import '../games/services/IgdbApiRepository.dart';
import '../routes/AppRoutes.dart';

class CommentaryComponent extends StatelessWidget {
  final Map<String, dynamic>? game;
  CommentaryComponent({super.key, required this.game});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    CommentaryController commentaryController = CommentaryController();
    CommentaryValidator commentaryValidator = CommentaryValidator();
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      width: 300,
      height: 600,
      decoration: BoxDecoration(
        color: Color(0xFF120B0B), // Color de fondo
        borderRadius: BorderRadius.circular(20),  // Radio para redondear las esquinas
        border: Border.all(
          color: Colors.black, // Color del borde
          width: 4, // Grosor del borde
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: SizedBox(),),
              IconButton(
                onPressed: () {Navigator.of(context).pop();}, /// Closes the Dialog
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
              child:Column(
                children: [
                  SizedBox(height: 10),
                  Flexible(
                    child: TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      validator: commentaryValidator.isValidCommentary,
                      controller: commentaryController.titleController,
                      decoration: const InputDecoration(
                        hintText:'Resume your opinion about this videogame in a few words',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Flexible(
                    child: SingleChildScrollView(
                      child: TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        validator: commentaryValidator.isValidCommentary,
                        controller: commentaryController.commentController,
                        decoration: const InputDecoration(
                          hintText:'¿What do you think about the videogame?',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Obx(() {
                    return Column(
                      children: [
                        // Texto que muestra el valor del slider
                        Text(
                            "${commentaryController.sliderController.value}",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        ),

                        // Slider que usa el valor del slider de la clase CommentaryController
                        Slider(
                          value: commentaryController.sliderController.value.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: '${commentaryController.sliderController.value}',
                          onChanged: (double newValue) {
                            commentaryController.sliderController.value = newValue.toInt();  // Actualiza el valor del slider
                          },
                        ),
                        // Texto que muestra errores
                        Text(commentaryValidator.isValidValue(commentaryController.sliderController.value) ?? ''),
                      ],
                    );
                  }),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black, // Color de fondo
                      shape: BoxShape.circle, // Para hacerlo circular
                    ),
                    child: IconButton(
                        onPressed: () async {
                          bool cell=true;
                          if(_formKey.currentState!.validate()) {
                            try{
                              commentaryController.addNewCommentary(game!, uid!, await Provider.of<IgdbApiRepository>(context, listen: false).getCover(game?['cover']));
                            } catch (error) {
                              cell=false;
                            }
                            if (cell==true) {
                              Get.offAllNamed(Routes.game, arguments: game);
                              ///Se podría mostrar un dialog de confirmación y otro de negación
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
