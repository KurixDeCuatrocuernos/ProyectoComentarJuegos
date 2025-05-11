import 'package:flutter/material.dart';
import 'package:game_box/comments/controllers/CommentaryController.dart';
import 'package:game_box/comments/models/CommentaryModel.dart';
import 'package:game_box/comments/utils/CommentaryValidator.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:game_box/viewModels/CommentViewModel.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../routes/AppRoutes.dart';

class EditCommentComponent extends StatefulWidget {
  final CommentaryModel comment;
  const EditCommentComponent({super.key, required this.comment});

  @override
  State<EditCommentComponent> createState() => _EditCommentComponentState();
}

class _EditCommentComponentState extends State<EditCommentComponent> {

  final _formKey = GlobalKey<FormState>();
  final _textFormStyle = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  final _textButtonStyle = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  final CommentaryController _commentController = CommentaryController();
  final CommentaryValidator _commentValidator = CommentaryValidator();

  @override
  void initState() {
    super.initState();
    _setData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _setData() {
    _commentController.idController.text = widget.comment.id;
    _commentController.titleController.text = widget.comment.title;
    _commentController.commentController.text = widget.comment.body;
    _commentController.sliderController.value = widget.comment.value.toInt();
    _commentController.gameIdController.text = widget.comment.gameId.toString();
    _commentController.userIdController.text = widget.comment.userId;
  }

  Future<bool> _submitData() async {
    final _commentViewModel = context.read<CommentViewModel>();
    try {
      CommentaryModel newComment = CommentaryModel.fromMap({
        'id': widget.comment.id,
        'title': _commentController.titleController.text,
        'body': _commentController.commentController.text,
        'value': _commentController.sliderController.value.toInt(),
        'gameId': int.parse(_commentController.gameIdController.text),
        'userId': _commentController.userIdController.text,
      });
      bool isUpdated = await _commentViewModel.updateFullCommentFromRepository(newComment, newComment.id);
      return isUpdated;
    } catch (error) {
      print("THERE WAS ERRORS UPDATING THE COMMENT $error");
      return false;
    }
  }
  
  Widget _showErrorDialog(String texto) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFF120B0B),
        ),
        width: 400,
        height: 200,
        child: Column(
          children: [
            SizedBox(height: 10,),
            Text(
              texto,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20,),
            TextButton(
              onPressed: () {
                Get.back();
              }, 
              child: Text('OK', style: _textFormStyle,),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFF120B0B),
        ),
        width: 400,
        height: 600,
        child: Column(
          children: [
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: 5,),
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.close, color: Colors.white, size: 32,),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(
              "COMMENT'S DATA",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child:             SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('ID: ', style: _textFormStyle,),
                          ],
                        ),
                        TextFormField(
                          controller: _commentController.idController,
                          validator: _commentValidator.isValidId,
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey,
                            hintText: 'New ID...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('TITLE: ', style: _textFormStyle,),
                          ],
                        ),
                        TextFormField(
                          controller: _commentController.titleController,
                          validator: _commentValidator.isValidTitle,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey,
                            hintText: 'New Title...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('BODY: ', style: _textFormStyle,),
                          ],
                        ),
                        TextFormField(
                          controller: _commentController.commentController,
                          validator: _commentValidator.isValidCommentary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey,
                            hintText: 'New Body...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('USERID: ', style: _textFormStyle,),
                          ],
                        ),
                        TextFormField(
                          controller: _commentController.userIdController,
                          validator: _commentValidator.isValidUserId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey,
                            hintText: 'New UserId...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('GAMEID: ', style: _textFormStyle,),
                          ],
                        ),
                        TextFormField(
                          controller: _commentController.gameIdController,
                          validator: _commentValidator.isValidGameId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey,
                            hintText: 'New GameId...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('VALUE: ', style: _textFormStyle,),
                          ],
                        ),
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
                        SizedBox(height: 40,),
                        TextButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              bool isUpdated = await _submitData();
                              if (isUpdated == true) {
                                Get.offAllNamed(Routes.manageComments);
                              } else {
                                Get.dialog(_showErrorDialog("THERE WAS A PROBLEM UPDATING THE FORM IN DATABASE"));
                              }
                            } else {
                              Get.dialog(_showErrorDialog("THERE IS ANY ERROR IN THE FORM"));
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Color(0xF71D7509)),
                          ),
                          child: Text(
                            'SUBMIT',
                            style: _textButtonStyle,
                          ),
                        ),
                        SizedBox(height: 40,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
