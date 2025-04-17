
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/auth/structure/controllers/AuthController.dart';
import 'package:game_box/components/GameListComponent.dart';
import 'package:game_box/components/SearchPlaceholder.dart';
import 'package:game_box/components/UserImage.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

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

  void _redirectToMain() {
    Get.offAllNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    Future<bool> _haveCommented() async{

      bool commented = false;
      if (user != null) {
        commented = await CommentaryRepository().getIfUserHasCommented(user);
      }
      print("EL USUARIO HA COMENTADO: $commented");
      return commented;
    }

    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: ToolBar(),
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
                            return SizedBox(height: 20); // o un loader si prefieres
                          } else if (snapshot.hasData && snapshot.data == true) {
                            return Column(
                              children: [
                                SizedBox(height: 20),
                                CommentedGamesListComponent(user: user),
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
          SearchResults(), // Muestra la lista de resultados
        ],
      ),
    );
  }
}
