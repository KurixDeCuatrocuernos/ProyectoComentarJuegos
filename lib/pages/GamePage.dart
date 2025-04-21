import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/CommentaryComponent.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../auth/structure/controllers/AuthController.dart';
import '../components/CommentByUserComponent.dart';
import '../components/CommentsListComponent.dart';
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
                title: UserImage(size: 45),
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

              /// 👇 Reemplazamos Expanded por Flexible + SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GameComponent(game: _game!),
                      SizedBox(height: 20),
                      CommentByUserComponent(game: _game!),
                      SizedBox(height: 30,),
                      Text(
                        'COMMENTARIES FROM OTHER USERS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF750202),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20,),
                      CommentsListComponent(game: _game!),

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
                  ListTile(
                    title: Text("Comentarios", style: TextStyle(color: Colors.white)),
                    onTap: () => Get.offAllNamed(Routes.comments),
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
