import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/UserImage.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  Future<bool> _deleteUser() async {
    try {
      UserRepository _userRepo = UserRepository();
      final bool response = await _userRepo.deleteUserByUid(user.uid);
      return response;
    } catch (error) {
      print("Error deleting the user");
      return false;
    }
  }

  void _showDeleteUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deleting User'),
          content: Text('Are you sure you want to delete this user?'),
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
                final bool isDeleted = await _deleteUser();
                if (isDeleted == true) {
                  /// Closes the dialog and recharges the page after one second
                  Navigator.of(context).pop();  // It closes the dialog
                  Future.delayed(Duration.zero, () {
                    Get.offAllNamed(Routes.manageUsers);
                  });
                } else {
                  /// Closes the dialog and opens a new one after one second
                  Navigator.of(context).pop();
                  Future.delayed(Duration.zero, () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Icon(Icons.warning),
                          content: Text('DELETION FAILED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _banUser() async {
    try {
      UserRepository _userRepo = UserRepository();
      final bool response = await _userRepo.banUserByUid(user.uid);
      return response;
    } catch (error) {
      print('Hubo un error al bannear al usuario $error');
      return false;
    }
  }

  void _showBanUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: Text('Ban User'),
          content: Text("Are you sure you want to ban this user? (Its commentaries will be banned too)"),
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
                bool cell = await _banUser();
                if (cell == true) {
                  Navigator.of(context).pop();
                  Future.delayed(Duration.zero, () {
                    Get.offAllNamed(Routes.manageUsers);
                  });
                } else {
                  Navigator.of(context).pop();
                  Future.delayed(Duration.zero, () {
                    showDialog(
                      context: context,
                      builder: (BuildContext builder) {
                        return AlertDialog(
                          title: Icon(Icons.warning),
                          content: Text('DELETION FAILED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _unbanUser() async {
    try {
      UserRepository _userRepo = UserRepository();
      final bool response = await _userRepo.unbanUserByUid(user.uid);
      return response;
    } catch (error) {
      print('Hubo un error al bannear al usuario $error');
      return false;
    }
  }

  void _showUnbanUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext builder) {
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
                bool cell = await _unbanUser();
                if (cell == true) {
                  Navigator.of(context).pop();
                  Future.delayed(Duration.zero, () {
                    Get.offAllNamed(Routes.manageUsers);
                  });
                } else {
                  Navigator.of(context).pop();
                  Future.delayed(Duration.zero, () {
                    showDialog(
                      context: context,
                      builder: (BuildContext builder) {
                        return AlertDialog(
                          title: Icon(Icons.warning),
                          content: Text('DELETION FAILED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  });
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
    return Container(
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: user.status==5 ? Color(0xFF4E0101) : Colors.black,
      ),
      child: Column(
        children: [
          Row(
            children: [
              UserImage(size: 40),
              Column(
                children: [
                  SizedBox(height: 10,),
                  Text(
                    'Username: ${user.name ?? 'NULL'}',
                    style: TextStyle(
                      color: user.status ==5 ? Colors.black : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10,),
                  Text(
                    'Email: ${user.email ?? 'NULL'}',
                    style: TextStyle(
                      color: user.status ==5 ? Colors.black : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10,),
                  Text(
                    'Start Date: ${_formatDateTime(user.createdAt)}',
                    style: TextStyle(
                      color: user.status ==5 ? Colors.black : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10,),
                  Text(
                    'Role: ${user.role ?? 'NULL'}',
                    style: TextStyle(
                      color: user.status == 5 ? Colors.black : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
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
