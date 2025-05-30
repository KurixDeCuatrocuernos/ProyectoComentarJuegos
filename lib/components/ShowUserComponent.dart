import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/UserImage.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:game_box/viewModels/AdminViewModel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth/models/UserModel.dart';
import '../routes/AppRoutes.dart';
import 'EditUserComponent.dart';

class ShowUserComponent extends StatelessWidget {
  final UserModel user;
  const ShowUserComponent({super.key, required this.user});

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

  void _showDeleteUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Deleting User'),
          content: Text("Are you sure you want to delete this user? (This action will delete this user's comments too)"),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // It closes the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cerramos antes de async

                /// Esperamos un frame para asegurar que el diálogo cerró
                await Future.delayed(Duration(milliseconds: 100));

                final bool cell = await Get.context!
                    .read<AdminViewModel>()
                    .deleteUser(user.uid);

                if (cell) {
                  Get.offAllNamed(Routes.manageUsers);
                } else {
                  showDialog(
                    context: Get.context!,
                    builder: (BuildContext errorDialogContext) {
                      return AlertDialog(
                        title: Icon(Icons.warning),
                        content: Text(
                          'BAN FAILED',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Ok'),
                            onPressed: () {
                              Navigator.of(errorDialogContext).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showBanUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Ban User'),
          content: Text("Are you sure you want to ban this user? (Its commentaries will be banned too)"),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Usamos el context del diálogo
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cerramos antes de async

                /// Esperamos un frame para asegurar que el diálogo cerró
                await Future.delayed(Duration(milliseconds: 100));

                final bool cell = await Get.context!
                    .read<AdminViewModel>()
                    .banUser(user.uid);

                if (cell) {
                  Get.offAllNamed(Routes.manageUsers);
                } else {
                  showDialog(
                    context: Get.context!,
                    builder: (BuildContext errorDialogContext) {
                      return AlertDialog(
                        title: Icon(Icons.warning),
                        content: Text(
                          'BAN FAILED',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Ok'),
                            onPressed: () {
                              Navigator.of(errorDialogContext).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showUnbanUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Unban User'),
          content: Text("Are you sure you want to unban this user? (Its commentaries will be show again)"),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cerramos antes de async

                /// Esperamos un frame para asegurar que el diálogo cerró
                await Future.delayed(Duration(milliseconds: 100));

                final bool cell = await Get.context!
                    .read<AdminViewModel>()
                    .unbanUser(user.uid);

                if (cell) {
                  Get.offAllNamed(Routes.manageUsers);
                } else {
                  showDialog(
                    context: Get.context!,
                    builder: (BuildContext errorDialogContext) {
                      return AlertDialog(
                        title: Icon(Icons.warning),
                        content: Text(
                          'UNBAN FAILED',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Ok'),
                            onPressed: () {
                              Navigator.of(errorDialogContext).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    double _textSize = MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * 0.06 : MediaQuery.of(context).size.height * 0.015;
    print("UserManagePage construido con los usuarios: $user");
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: user.status==5 ? Color(0xFF4E0101) : Colors.black,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              UserImage(size: MediaQuery.of(context).size.width * 0.1, uid: user.uid),
              Column(
                children: [
                  SizedBox(height: 10,),
                  Text(
                    'Username: ${user.name ?? 'NULL'}',
                    style: TextStyle(
                      color: user.status ==5 ? Colors.black : Colors.white,
                      fontSize: _textSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10,),
                  Text(
                    'Email: ${user.email ?? 'NULL'}',
                    style: TextStyle(
                      color: user.status ==5 ? Colors.black : Colors.white,
                      fontSize: _textSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10,),
                  Text(
                    'Start Date: ${_formatDateTime(user.createdAt)}',
                    style: TextStyle(
                      color: user.status ==5 ? Colors.black : Colors.white,
                      fontSize: _textSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10,),
                  Text(
                    'Role: ${user.role ?? 'NULL'}',
                    style: TextStyle(
                      color: user.status == 5 ? Colors.black : Colors.white,
                      fontSize: _textSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ],
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
                    Get.dialog(EditUserComponent(user: user));                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 32,),
                  onPressed: () {
                   _showDeleteUser(context);
                  },
                ),
                if (user.status != 5)
                IconButton(
                  icon: Icon(Icons.cancel_outlined, size: 32,),
                  onPressed: () {
                    _showBanUser(context);
                  },
                ),
                if (user.status == 5)
                IconButton(
                  icon: Icon(Icons.check_circle_outline_outlined, size: 32,),
                  onPressed: () {
                    _showUnbanUser(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
