import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/viewModels/AuthViewModel.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../components/CommentByUserComponent.dart';
import '../components/CommentsListComponent.dart';
import '../components/SearchPlaceholder.dart';
import '../components/SearchResults.dart';
import '../components/ToolBar.dart';
import '../components/UserImage.dart';
import '../components/UserName.dart';
import '../components/GameComponent.dart';
import '../games/models/GameModel.dart';
import '../routes/AppRoutes.dart';
import '../viewModels/PageViewModel.dart';
import '../viewModels/UserViewModel.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}
class _GamePageState extends State<GamePage> {

  // Si no se recibe un gameId, redirige a una página de error o una pantalla de carga
  final GameModel _game = Get.arguments ?? Future.delayed(Duration.zero, () {Get.offAllNamed(Routes.home);});  // Redirige a una página de error

@override
void initState() {
  super.initState();
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
    bool _isSidebarOpen = context.watch<PageViewModel>().isSidebarOpen;
    final _pageVM = context.read<PageViewModel>();
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
                title: UserImage(size: 45, uid: userId ?? ""),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GameComponent(game: _game),
                      SizedBox(height: 20),
                      CommentByUserComponent(game: _game),
                      SizedBox(height: 30,),
                      Text(
                        'COMMENTARIES FROM OTHER USERS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF750202),
                          fontSize: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20,),
                      CommentsListComponent(game: _game),

                    ],
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
            left: _isSidebarOpen ? 0 : -MediaQuery.of(context).size.width * 0.6,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              color: Colors.grey[900],
              child: Column(
                children: [
                  SizedBox(height: 50),
                  ListTile(
                    title: Text("Inicio", style: TextStyle(color: Colors.white)),
                    onTap: () => Get.offAllNamed(Routes.home),
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
          /// SHOWS THE RESULTS LIST
          SearchResults(),
        ],
      ),
    );
  }

}
