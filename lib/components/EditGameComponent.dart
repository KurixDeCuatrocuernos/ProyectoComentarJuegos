import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_box/games/controllers/GameFormController.dart';
import 'package:game_box/games/models/GameModel.dart';
import 'package:game_box/games/utils/GameFormValidator.dart';
import 'package:game_box/viewModels/AdminViewModel.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../routes/AppRoutes.dart';

class EditGameComponent extends StatefulWidget {
  final GameModel game;
  const EditGameComponent({super.key, required this.game});

  @override
  State<EditGameComponent> createState() => _EditGameComponentState();
}

class _EditGameComponentState extends State<EditGameComponent> {
  final _formKey = GlobalKey<FormState>();
  final TextStyle _formTextStyle = TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,);
  final TextStyle _inputFormStyle = TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold,);
  GameFormValidator _formValidator = GameFormValidator();
  GameFormController _formController = GameFormController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _setData();
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _setData() {
    _formController.idController.text = widget.game.id.toString();
    _formController.titleController.text = widget.game.name.toString();
    _formController.abstractController.text = widget.game.summary.toString();
    _formController.coverIdController.text = widget.game.coverId.toString();
    _formController.coverPathController.text = widget.game.url.toString();
    _formController.rateController.text = widget.game.rating.toString();
    _formController.dateController.text = DateFormat('yyyy-MM-dd').format(widget.game.first_release_date!.toDate());
    _selectedDate = widget.game.first_release_date!.toDate();
  }

  Future<bool> _submitForm() async {
    try {
      GameModel newData = GameModel(
        id: widget.game.id,
        name: _formController.titleController.text,
        summary: _formController.abstractController.text,
        rating: double.parse(_formController.rateController.text),
        coverId: int.parse(_formController.coverIdController.text),
        first_release_date: Timestamp.fromDate(_selectedDate!),
        url: _formController.coverPathController.text,
      );
      // print("SE HAN MANDADO LOS DATOS: $newData");
      bool cell = await context.read<AdminViewModel>().updateGame(newData);
      return cell;
    } catch (error) {
      print("HUBO UN ERROR ACTUALIZANDO LOS DATOS: $error");
      return false;
    }
  }

  Widget _showErrorDialog(String text, BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.25,
          maxHeight:  MediaQuery.of(context).size.height * 0.25,
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width *0.8,
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /// Button to close the dialog
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.close, size: 32, color: Colors.white,),
                  ),
                  SizedBox(width: 10,),
                ],
              ),
              Center(
                child: Text(
                  "New Game's Data",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Flexible(
                child: SingleChildScrollView(
                  child:               Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "GAME ID: ",
                                style: _formTextStyle,
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          TextFormField(
                            controller: _formController.idController,
                            validator: _formValidator.isValidId,
                            decoration:  InputDecoration(
                              filled: true,
                              fillColor: Colors.grey,
                              hintText: 'New ID...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: _inputFormStyle,
                            readOnly: true,
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "GAME TITLE: ",
                                style: _formTextStyle,
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          TextFormField(
                            controller: _formController.titleController,
                            validator: _formValidator.isValidName,
                            decoration:  InputDecoration(
                              filled: true,
                              fillColor: Colors.grey,
                              hintText: 'New Title...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: _inputFormStyle,
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "GAME COVER NUMBER: ",
                                style: _formTextStyle,
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          TextFormField(
                            controller: _formController.coverIdController,
                            validator: _formValidator.isValidCover,
                            decoration:  InputDecoration(
                              filled: true,
                              fillColor: Colors.grey,
                              hintText: "New Cover Id...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: _inputFormStyle,
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "GAME COVER URL: ",
                                style: _formTextStyle,
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          TextFormField(
                            controller: _formController.coverPathController,
                            validator: _formValidator.isValidUrl,
                            decoration:  InputDecoration(
                              filled: true,
                              fillColor: Colors.grey,
                              hintText: "New Cover URL...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: _inputFormStyle,
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "GAME RATING: ",
                                style: _formTextStyle,
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          TextFormField(
                            controller: _formController.rateController,
                            validator: _formValidator.isValidRating,
                            decoration:  InputDecoration(
                              filled: true,
                              fillColor: Colors.grey,
                              hintText: 'New Rating...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: _inputFormStyle,
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "GAME RELEASE DATE: ",
                                style: _formTextStyle,
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          TextFormField(
                            controller: _formController.dateController,
                            decoration:  InputDecoration(
                              filled: true,
                              fillColor: Colors.grey,
                              hintText: 'New release date...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: _inputFormStyle,
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: widget.game.first_release_date!.toDate(), // Fecha inicial
                                firstDate: DateTime(1900), // Fecha más antigua permitida
                                lastDate: DateTime(DateTime.now().year+11), // Fecha más reciente permitida
                              );
                              if(pickedDate != null) {
                                setState(() {
                                  _formController.dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                  _selectedDate = pickedDate;
                                });
                              }
                            },
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "GAME ABSTRACT: ",
                                style: _formTextStyle,
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          TextFormField(
                            controller: _formController.abstractController,
                            validator: _formValidator.isValidSummary,
                            decoration:  InputDecoration(
                              filled: true,
                              fillColor: Colors.grey,
                              hintText: 'New Abstract...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: _inputFormStyle,
                            minLines: 1,
                            maxLines: null,
                          ),
                          SizedBox(height: 20,),
                          /// Button to submit the form
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Color(0xF71D7509)),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                bool cell = await _submitForm();
                                if (cell) {
                                  Get.offAllNamed(Routes.manageGames);
                                } else {
                                  Get.dialog(_showErrorDialog("THERE WAS A ERROR UPDATING THE GAME'S DATA!\nCheck all fields!", context));
                                }
                              }
                            },
                          ),
                          SizedBox(height: 20,),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
