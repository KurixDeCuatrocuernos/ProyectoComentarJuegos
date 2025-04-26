
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/auth/structure/controllers/AuthController.dart';
import 'package:game_box/components/GameListComponent.dart';
import 'package:game_box/components/SearchPlaceholder.dart';
import 'package:game_box/components/UserImage.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:get/get.dart';

import '../components/CommentedGamesListComponent.dart';
import '../components/SearchResults.dart';
import '../components/ToolBar.dart';
import '../components/UserName.dart';
import '../routes/AppRoutes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  AuthController _authController = AuthController();

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
                Get.offAllNamed(Routes.login);// Llamar a la función para cerrar sesión
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _haveCommented() async{
    User? _user = FirebaseAuth.instance.currentUser;
    bool commented = false;
    if (_user != null) {
      commented = await CommentaryRepository().getIfUserHasCommented(_user);
    }
    print("EL USUARIO HA COMENTADO: $commented");
    return commented;
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
    User? _user = FirebaseAuth.instance.currentUser;
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

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      FutureBuilder<bool>(
                        future: _haveCommented(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(height: 20);
                          } else if (snapshot.hasData && snapshot.data == true) {
                            return Column(
                              children: [
                                SizedBox(height: 20),
                                CommentedGamesListComponent(user: _user),
                                SizedBox(height: 20,),
                              ],
                            );
                          } else {
                            return SizedBox(height: 20);
                          }
                        },
                      ),

                    GameListComponent(genre: "Role-playing (RPG)"),
                      // SizedBox(height: 20,),
                      // GameListComponent(genre: "Visual Novel"),
                      // SizedBox(height: 20,),
                      // GameListComponent(genre: "Indie"),
                      // SizedBox(height: 20,),
                      // GameListComponent(genre: "Adventure"),
                      // SizedBox(height: 20,),
                      // GameListComponent(genre: "Platform"),

                      SizedBox(height: 20,),
                    ]
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
                    title: Text("Comentarios", style: TextStyle(color: Colors.white)),
                    onTap: () => Get.offAllNamed(Routes.comments),
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
