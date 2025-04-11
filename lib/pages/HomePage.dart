
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/auth/structure/controllers/AuthController.dart';
import 'package:game_box/components/SearchPlaceholder.dart';
import 'package:game_box/components/UserImage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: ToolBar(),
      body: Stack(
        children: [
          Column(
            children: [
              AppBar(
                leading: IconButton(
                  onPressed: _signOut,
                  icon: Icon(Icons.logout_rounded),
                  color: Colors.white,
                  iconSize: 30,
                ),
                title: UserImage(),
                actions: [
                  SearchPlaceholder(),
                  if (kIsWeb) UserName(),
                ],
                backgroundColor: Colors.black,
                //bottom: , Aquí iría el bottom
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      50,
                          (index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Elemento $index',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
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
