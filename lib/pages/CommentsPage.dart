import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/UserCommentsListComponent.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../auth/structure/controllers/AuthController.dart';
import '../components/SearchPlaceholder.dart';
import '../components/SearchResults.dart';
import '../components/ToolBar.dart';
import '../components/UserImage.dart';
import '../components/UserName.dart';
import '../repository/UserRepository.dart';
import '../routes/AppRoutes.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {

  bool _isSidebarOpen = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _closeSidebar() {
    setState(() {
      _isSidebarOpen = false;
    });
  }

  AuthController _authController = AuthController();

  void _signOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('¿Are you sure you want to Sign out?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // It closes the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                _authController.signOut();
                Get.offAllNamed(Routes.login);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _tryRole() async {
    UserRepository _userRepo = UserRepository();
    User? _user = FirebaseAuth.instance.currentUser;
    if (_user != null && !_user.isAnonymous){
      final String? check = await _userRepo.getUserRoleByUid(_user.uid);
      if (check != null) {
        if(check=="ADMIN") {
          print("USER IS ADMIN");
          return true;
        } else {
          print("User is not an Admin");
          return false;
        }
      } else {
        print("The database returned null");
        return false;
      }
    } else {
      print("User is Unknown");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: ToolBar(onMenuPressed: _toggleSidebar),
      body: Stack(
        children: [
          Column(
            children: [
              AppBar(
                leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  color: Colors.white,
                  icon: Icon(Icons.arrow_back),
                ),
                title: UserImage(size: 45,),
                actions: [
                  SearchPlaceholder(),
                  if (kIsWeb) UserName(),
                  IconButton(
                    onPressed: _signOut,
                    icon: Icon(Icons.logout_rounded),
                    color: Colors.white,
                    iconSize: 30,
                  ),
                ],
                backgroundColor: Colors.black,
              ),

              ///Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20,),

                      UserCommentsListComponent(),


                    ],
                  ),
                ),
              ),

            ],
          ),

          /// BARRA LATERAL + OVERLAY
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: Colors.black54, // oscurece el fondo
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _isSidebarOpen ? 0 : -250,
            top: 0,
            bottom: 0,
            child: Container(
              width: 250,
              color: Colors.grey[900],
              child: Column(
                children: [
                  SizedBox(height: 50),
                  ListTile(
                    title: Text("Inicio", style: TextStyle(color: Colors.white)),
                    onTap: () => Get.offAllNamed(Routes.home),
                  ),
                  FutureBuilder<bool>(
                    future: _tryRole(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasData && snapshot.data == true) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text("Users Page", style: TextStyle(color: Colors.white)),
                              onTap: () {Get.toNamed(Routes.manageUsers);},
                            ),
                            ListTile(
                              title: Text("Games Page", style: TextStyle(color: Colors.white)),
                              onTap: () {Get.toNamed(Routes.manageGames);},
                            ),
                            ListTile(
                              title: Text("Comments Page", style: TextStyle(color: Colors.white)),
                              onTap: () {Get.toNamed(Routes.manageComments);},
                            ),
                          ],
                        );
                      } else {
                        return SizedBox(); // No es admin o error
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          SearchResults(), // Muestra la lista de resultados
        ],
      ),
    );
  }
}

