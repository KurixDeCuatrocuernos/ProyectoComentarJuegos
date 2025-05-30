import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/viewModels/PageViewModel.dart';
import 'package:game_box/viewModels/UserViewModel.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../components/SearchPlaceholder.dart';
import '../components/SearchResults.dart';
import '../components/ShowCommentComponent.dart';
import '../components/ToolBar.dart';
import '../components/UserImage.dart';
import '../components/UserName.dart';
import '../routes/AppRoutes.dart';
import '../viewModels/AdminViewModel.dart';
import '../viewModels/AuthViewModel.dart';

class CommentsManagePage extends StatefulWidget {
  const CommentsManagePage({super.key});

  @override
  State<CommentsManagePage> createState() => _CommentsManagePageState();
}

class _CommentsManagePageState extends State<CommentsManagePage> {

  bool _searchStatus = false;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AdminViewModel>().loadComments();
      context.read<AuthViewModel>().checkRole();
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
                // leading: IconButton(
                //   onPressed: () {
                //     Get.back();
                //   },
                //   color: Colors.white,
                //   icon: Icon(Icons.arrow_back),
                // ),
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

              /// CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 50,),
                      Text(
                        'COMMENTS MANAGE PAGE',
                        style: TextStyle(
                          color: Color(0xFF750202),
                          fontSize: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * 0.08 : MediaQuery.of(context).size.height *0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 50,),
                      Row(
                        children: [
                          SizedBox(width: 20,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * 0.2 : MediaQuery.of(context).size.height * 0.08,
                            child: SearchBar(
                              backgroundColor: WidgetStatePropertyAll(Color(0xFFDDDBDB)),
                              hintText: "Search User's or Game's commentary...",
                              hintStyle: WidgetStatePropertyAll(
                                TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.width * 0.035,
                                ),
                              ),
                              leading: Icon(Icons.search, size: MediaQuery.of(context).size.width * 0.035,),
                              onChanged: (text) {
                                setState(() {
                                  _searchText = text;
                                  _searchStatus = text.isNotEmpty;
                                });
                                context.read<AdminViewModel>().searchComments(text);
                              },
                            ),
                          ),
                          /// SE PODRÍA AÑADIR UN BOTÓN PARA AÑADIR JUEGOS
                        ],
                      ),
                      SizedBox(height: 40,),
                      if (!_searchStatus) ...[
                        Consumer<AdminViewModel>(
                          builder: (context, commentVM, child) {
                            if (commentVM.isLoading) {
                              return CircularProgressIndicator();
                            } else if (commentVM.hasError) {
                              return Text('THERE WAS AN ERROR GETTING THE COMMENTS');
                            } else if (commentVM.comments.isEmpty) {
                              return Text('BUT NOBODY COMES...');
                            } else {
                              return Column(
                                children: commentVM.comments.map((comment) => Column(
                                  children: [
                                    ShowCommentComponent(comment: comment),
                                    SizedBox(height: 20),
                                  ],
                                )).toList(),
                              );
                            }
                          },
                        ),
                      ],
                      if (_searchStatus) ...[
                        Consumer<AdminViewModel>(
                          builder: (context, commentVM, child) {
                            if (commentVM.isLoading) {
                              return CircularProgressIndicator();
                            } else if (commentVM.hasError) {
                              return Text('THERE WAS AN ERROR GETTING THE COMMENTS');
                            } else if (commentVM.filteredComments.isEmpty) {
                              return Text('BUT NOBODY COMES...');
                            } else {
                              return Column(
                                children: commentVM.filteredComments.map((comment) => Column(
                                  children: [
                                    ShowCommentComponent(comment: comment),
                                    SizedBox(height: 20),
                                  ],
                                )).toList(),
                              );
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