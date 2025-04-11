import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../auth/structure/controllers/AuthController.dart';
import '../components/SearchPlaceholder.dart';
import '../components/SearchResults.dart';
import '../components/ToolBar.dart';
import '../components/UserImage.dart';
import '../components/UserName.dart';
import '../components/GameComponent.dart';
import '../routes/AppRoutes.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}
class _GamePageState extends State<GamePage> {
  AuthController _authController = AuthController();
  Map<String, dynamic>? _game;

@override
void initState() {
  super.initState();

  // Comprobamos si Get.arguments tiene un valor válido
  if (Get.arguments != null && Get.arguments.isNotEmpty) {
    _game = Get.arguments;  // Asigna el gameId desde los argumentos
  } else {
    // Si no se recibe un gameId, redirige a una página de error o una pantalla de carga
    Future.delayed(Duration.zero, () {
      Get.offAllNamed(Routes.loading);  // Redirige a una página de error
    });
  }
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
              ),

              Expanded(
                child:
                // prueba de que funciona: Text(_gameId!['name'] ?? 'juego desconocido'),
                GameComponent(game: _game!,),
              ),
            ],
          ),
          SearchResults(), // Muestra la lista de resultados
        ],
      ),
    );
  }
}
