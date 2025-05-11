import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/comments/models/CommentaryModel.dart';
import 'package:game_box/pages/CommentsPage.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:game_box/viewModels/CommentViewModel.dart';
import 'package:game_box/viewModels/PageViewModel.dart';
import 'package:game_box/viewModels/UserViewModel.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../auth/structure/controllers/AuthController.dart';
import '../components/SearchPlaceholder.dart';
import '../components/SearchResults.dart';
import '../components/ShowCommentComponent.dart';
import '../components/ToolBar.dart';
import '../components/UserImage.dart';
import '../components/UserName.dart';
import '../repository/UserRepository.dart';
import '../routes/AppRoutes.dart';
import '../viewModels/AuthViewModel.dart';

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
    context.read<PageViewModel>().checkAdminRoleFromRepository();
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
    final _commentViewModel = context.watch<CommentViewModel>();
    final _userViewModel = context.watch<UserViewModel>();
    final _pageViewModel = context.watch<PageViewModel>();
    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: ToolBar(onMenuPressed: _pageViewModel.toggleSidebar),
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
                                    _pageViewModel.closeSearch;
                                  } else {
                                    _pageViewModel.toggleSearch;
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
                        FutureBuilder<List<CommentaryModel>?>(
                          future: _commentViewModel.getAllCommentsFromRepository(),
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
                        FutureBuilder<List<CommentaryModel>?>(
                          future: _commentViewModel.searchCommentsFromRepository(_searchText),
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
              onTap: _pageViewModel.closeSidebar,
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
                    future: _userViewModel.tryUserRoleFromRepository(),
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