import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_box/comments/models/CommentaryModel.dart';
import 'package:game_box/components/ShowGameComponent.dart';
import 'package:game_box/components/ShowUserComponent.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:game_box/repository/GameRepository.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:game_box/viewModels/AdminViewModel.dart';
import 'package:game_box/viewModels/CommentViewModel.dart';
import 'package:game_box/viewModels/GameViewModel.dart';
import 'package:game_box/viewModels/UserViewModel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth/models/UserModel.dart';
import '../games/models/GameModel.dart';
import '../routes/AppRoutes.dart';
import 'EditCommentComponent.dart';

class ShowCommentComponent extends StatelessWidget {
  final CommentaryModel comment;
  const ShowCommentComponent({super.key, required this.comment});



  @override
  Widget build(BuildContext context) {

    final _commentTextStyle = TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold);
    final _dialogStyle = BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white, width: 2,));
    final _commentViewModel = context.watch<CommentViewModel>();
    final _userViewModel = context.watch<UserViewModel>();
    final _gameViewModel = context.watch<GameViewModel>();

    String _capitalizeLetter(String text) {
      if (text.isEmpty) {
        return text;
      } else {
        return text[0].toUpperCase() + text.substring(1);
      }
    }

    String _formatDateTime() {
      var originalDate = comment.createdAt!;
      DateTime date;
      // Si el rawDate es un Timestamp de Firestore
      date = originalDate.toDate();
      // Formateamos la fecha a un formato legible
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    }

    Widget _showDialogText(String text) {
      return Dialog(
        child: Container(
          decoration: _dialogStyle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.close, size: 32, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 20,
                    maxHeight: 400,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      style: _commentTextStyle,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      );
    }

    Widget _showDialogUser(UserModel user) {
      return Dialog(
        child: Container(
          decoration: _dialogStyle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.close, size: 32, color: Colors.white),
                  ),
                ],
              ),
              ShowUserComponent(user: user),
              SizedBox(height: 20,),
            ],
          ),
        ),
      );
    }

    Widget _showDialogGame(GameModel game) {
      return Dialog(
        child: Container(
          decoration: _dialogStyle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.close, size: 32, color: Colors.white),
                  ),
                ],
              ),
              ShowGameComponent(game: game),
              SizedBox(height: 20,),
            ],
          ),
        ),
      );
    }

    Future<bool?> _confirmDelete(BuildContext context) async {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('CONFIRM DELETE'),
          content: Text("Are you sure you want to delete this comment? (This action can't be undone)"),
          actions: [
            TextButton(
              child: Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      );
    }

    Future<bool?> _confirmBan(BuildContext context) async {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('CONFIRM BAN'),
          content: Text('Are you sure you want to ban this comment?'),
          actions: [
            TextButton(
              child: Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      );
    }

    Future<bool?> _confirmUnban(BuildContext context) async {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('CONFIRM UNBAN'),
          content: Text('Are you sure you want to unban this comment?'),
          actions: [
            TextButton(
              child: Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      );
    }

    Widget _showErrorAlert(String textIn) {
      return Dialog(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          width: 400,
          height: 150,
          child: Column(
            children: [
              SizedBox(height: 10,),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    textIn,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  'Ok',
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

    return Center(
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: (comment.status != null && comment.status == 5) ? Color(0xFF4E0101) : Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('TITLE: ', style: _commentTextStyle,),
                      SizedBox(width: 5,),
                      Flexible(
                        child: TextButton(
                          child: Text(
                            _capitalizeLetter(comment.title),
                            style: _commentTextStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onPressed: () {
                            Get.dialog(_showDialogText(comment.title));
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('COMMENT: ', style: _commentTextStyle, ),
                      SizedBox(width: 5,),
                      Flexible(
                        child: TextButton(
                          child: Text(
                            _capitalizeLetter(comment.body),
                            style: _commentTextStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onPressed: () {
                            Get.dialog(_showDialogText(comment.body));
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('USER: ', style: _commentTextStyle,),
                      SizedBox(width: 5,),
                      Flexible(
                        child: TextButton(
                          child: Text(
                            comment.userId.toString(),
                            style: _commentTextStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onPressed: () async {
                            UserModel? user = await context.read<AdminViewModel>().getUserByCommentId(comment.userId);
                            if (user == null) {
                              Get.dialog(_showDialogText("USER DATA ERROR"));
                            } else {
                              Get.dialog(_showDialogUser(user));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('GAME: ', style: _commentTextStyle,),
                      SizedBox(width: 5,),
                      Flexible(
                        child: TextButton(
                          child: Text(
                            comment.gameId.toString(),
                            style: _commentTextStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onPressed: () async {
                            GameModel? game = await context.read<AdminViewModel>().getGameByCommentId(comment.gameId);
                            if (game == null) {
                              Get.dialog(_showDialogText("GAME DATA ERROR"));
                            } else {
                              Get.dialog(_showDialogGame(game));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatDateTime(),
                        style: _commentTextStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),

            Container(
              width: 400,
              decoration: BoxDecoration(
                color: Color(0xFFDDD8D8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 32,),
                    onPressed: () {
                      Get.dialog(EditCommentComponent(comment: comment));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 32,),
                    onPressed: () async {
                      bool? del = await _confirmDelete(context);
                      if (del != null) {
                        if(del == true) {
                          bool isDeleted = await context.read<AdminViewModel>().deleteCommentById(comment.id);
                          if (isDeleted == true) {
                            Get.offAllNamed(Routes.manageComments);
                          } else {
                            Get.dialog(_showErrorAlert("There was an error deleting the Commentary"));
                          }
                        }
                      }
                    },
                  ),
                  if (comment.status == null || comment.status == 0)
                    IconButton(
                      icon: Icon(Icons.cancel_outlined, size: 32,),
                      onPressed: () async {
                        bool? ban = await _confirmBan(context);
                        if (ban != null) {
                          if(ban == true) {
                            bool isBanned = await context.read<AdminViewModel>().banCommentById(comment.id);
                            if (isBanned == true) {
                              Get.offAllNamed(Routes.manageComments);
                            } else {
                              Get.dialog(_showErrorAlert("There was an error banning the Commentary"));
                            }
                          }
                        }
                      },
                    ),
                  if (comment.status != null && comment.status == 5)
                    IconButton(
                      icon: Icon(Icons.check_circle_outline_outlined, size: 32,),
                      onPressed: () async {
                        bool? ban = await _confirmUnban(context);
                        if (ban != null) {
                          if(ban == true) {
                            bool isBanned = await context.read<AdminViewModel>().unbanCommentById(comment.id);
                            if (isBanned == true) {
                              Get.offAllNamed(Routes.manageComments);
                            } else {
                              Get.dialog(_showErrorAlert("There was an error unbanning the Commentary"));
                            }
                          }
                        }
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
