import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/pages/CommentsPage.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:get/get.dart';

import '../auth/structure/controllers/AuthController.dart';
import '../components/SearchPlaceholder.dart';
import '../components/SearchResults.dart';
import '../components/ShowCommentComponent.dart';
import '../components/ToolBar.dart';
import '../components/UserImage.dart';
import '../components/UserName.dart';
import '../repository/UserRepository.dart';
import '../routes/AppRoutes.dart';

class CommentsManagePage extends StatefulWidget {
  const CommentsManagePage({super.key});

  @override
  State<CommentsManagePage> createState() => _CommentsManagePageState();
}

class _CommentsManagePageState extends State<CommentsManagePage> {

  AuthController _authController = AuthController();
  bool _isSidebarOpen = false;
  bool _searchStatus = false;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  void _toggleSearch() {
    setState(() {
      _searchStatus = true;
    });
  }

  void _closeSearch() {
    setState(() {
      _searchStatus = false;
    });
  }

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

  void _checkRole() async {
    UserRepository _userRepo = UserRepository();
    User? _user = FirebaseAuth.instance.currentUser;
    if (_user != null && !_user.isAnonymous){
      final String? check = await _userRepo.getUserRoleByUid(_user.uid);
      if (check != null) {
        if(check != "ADMIN") {
          /// If user is not an Admin, we redirect to HomePage
          print("User is not an Admin");
          Get.offAllNamed(Routes.home);
        }
      } else {
        print("The database returned null");
        Get.offAllNamed(Routes.home);
      }
    } else {
      print("User is Unknown");
      Get.offAllNamed(Routes.home);
    }
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

  Future<List<Map<String, dynamic>>?> _manageComments() async {
    try {
      CommentaryRepository _commentRepo = CommentaryRepository();
      List<Map<String, dynamic>>? response = await _commentRepo.getAllComments();
      return response;
    } catch (error) {
      print("HUBO UN ERROR AL BUSCAR LOS COMENTARIOS");
      return null;
    }
  }

  /// Devuelve true si contiene caracteres no alfanumericos y false si no los contiene
  bool _containsCharNoAlfanumeric(String texto) {
    final alfanumerico = RegExp(r'^[a-zA-Z0-9 _\-\:\.\,áéíóúüÁÉÍÓÚÜñÑ]+$');
    return !alfanumerico.hasMatch(texto);
  }

  Future<List<Map<String, dynamic>>?> _searchComments(String query) async {
    if (_containsCharNoAlfanumeric(query)) {
      return [];
    } else {
      try {
        CommentaryRepository _commentRepo = CommentaryRepository();
        final List<Map<String, dynamic>>? commentsList = await _commentRepo.getCommentsInUsersAndGamesByQuery(query.toLowerCase());
        if (commentsList != null) {
          if (commentsList.isNotEmpty) {
            return commentsList;
          } else {
            return [];
          }
        } else {
          print("Query for games answered null");
          return null;
        }
      } catch (error) {
        print("THERE WAS AN ERROR GETTING THE DATA REQUESTED FROM THE DATABASE: $error");
        return null;
      }
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

              /// CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 50,),
                      Text(
                        'COMMENTS MANAGE PAGE',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 50,),
                      Row(
                        children: [
                          SizedBox(width: 20,),
                          SizedBox(
                            width: 300, height: 50,
                            child: SearchBar(
                              backgroundColor: WidgetStatePropertyAll(Color(0xFFDDDBDB)),
                              hintText: "Search User's or Game's commentary...",
                              hintStyle: WidgetStatePropertyAll(
                                TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              leading: Icon(Icons.search),
                              onChanged: (text) {
                                setState(() {
                                  _searchText = text;
                                  if (text.isEmpty) {
                                    _closeSearch();
                                  } else {
                                    _toggleSearch();
                                  }
                                });
                              },
                            ),
                          ),
                          /// SE PODRÍA AÑADIR UN BOTÓN PARA AÑADIR JUEGOS
                        ],
                      ),
                      SizedBox(height: 40,),
                      if (!_searchStatus) ...[
                        FutureBuilder<List<Map<String, dynamic>>?>(
                          future: _manageComments(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('THERE WAS AN ERROR GETTING THE GAMES');
                            } else if (snapshot.hasData) {
                              if(snapshot.data == null) {
                                return Text('DATA IS NULL');
                              } else if (snapshot.data!.isEmpty) {
                                return Text('BUT NOBODY COMES...');
                              } else {
                                return Column(
                                  children: snapshot.data!.map((comment) => Column(
                                    children: [
                                      ShowCommentComponent(comment: comment),
                                      SizedBox(height: 20,),
                                    ],
                                  ),
                                  ).toList(),
                                );
                              }
                            } else {
                              return Text('THERE WAS A UNEXPECTED ERROR');
                            }
                          },
                        ),
                      ],
                      if (_searchStatus) ...[
                        FutureBuilder<List<Map<String, dynamic>>?>(
                          future: _searchComments(_searchText),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Search result has errors');
                            } else if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                return Text('BUT NOBODY COMES...');
                              } else {
                                return Column(
                                  children: snapshot.data!.map((comment) => Column(
                                    children: [
                                      if (comment.isNotEmpty)
                                        ShowCommentComponent(comment: comment),
                                      SizedBox(height: 20,),
                                    ],
                                  ),
                                  ).toList(),
                                );
                              }
                            } else {
                              return Text('Search has unexpected error');
                            }
                          },
                        ),
                      ],
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