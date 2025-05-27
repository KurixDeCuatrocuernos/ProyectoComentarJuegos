
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/GameListComponent.dart';
import 'package:game_box/components/SearchPlaceholder.dart';
import 'package:game_box/components/UserImage.dart';
import 'package:game_box/viewModels/AuthViewModel.dart';
import 'package:game_box/viewModels/PageViewModel.dart';
import 'package:game_box/viewModels/UserViewModel.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

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
              onPressed: () async {
                await context.read<AuthViewModel>().signOut();
                Get.offAllNamed(Routes.login);// Llamar a la función para cerrar sesión
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? _user = FirebaseAuth.instance.currentUser;
    final _pageVM = context.read<PageViewModel>();
    bool _isSidebarOpen = context.watch<PageViewModel>().isSidebarOpen;
    final String? userId = context.read<UserViewModel>().getCurrentUserId();

    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: ToolBar(onMenuPressed: _pageVM.toggleSidebar),
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
                title: UserImage(size: 45, uid: userId ?? "",),
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
                      /// Se Reconstruye necesariamente a partir del usuario (current user)
                      FutureBuilder<bool>(
                        future: _pageVM.haveCommented(),
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

                      /// No necesita reconstruirse si no hay cambios
                      GameListComponent(genre: "Role-playing (RPG)"),
                      SizedBox(height: 20,),
                      GameListComponent(genre: "Turn-based strategy (TBS)"),
                      SizedBox(height: 20,),
                      GameListComponent(genre: "Adventure"),
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
              onTap: _pageVM.closeSidebar,
              child: Container(
                color: Colors.black54, // oscurece el fondo
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _isSidebarOpen ? 0 : -MediaQuery.of(context).size.width *0.6,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              color: Colors.grey[900],
              child: Column(
                children: [
                  SizedBox(height: 50),
                  ListTile(
                    title: Text("Comentarios", style: TextStyle(color: Colors.white)),
                    onTap: () => Get.offAllNamed(Routes.comments),
                  ),
                  FutureBuilder<bool>(
                    future: context.read<AuthViewModel>().tryRole(),
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
