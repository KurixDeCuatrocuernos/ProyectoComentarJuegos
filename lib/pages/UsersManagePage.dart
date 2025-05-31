import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/ShowUserComponent.dart';
import 'package:game_box/viewModels/AdminViewModel.dart';
import 'package:game_box/viewModels/AuthViewModel.dart';
import 'package:game_box/viewModels/PageViewModel.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../components/SearchPlaceholder.dart';
import '../components/SearchResults.dart';
import '../components/ToolBar.dart';
import '../components/UserImage.dart';
import '../components/UserName.dart';
import '../routes/AppRoutes.dart';
import '../viewModels/UserViewModel.dart';

class UsersManagePage extends StatefulWidget {
  const UsersManagePage({super.key});

  @override
  State<UsersManagePage> createState() => _UsersManagePageState();
}

class _UsersManagePageState extends State<UsersManagePage> {

  String _searchText = '';
  bool _searchStatus = false;

  @override
  void initState() {
    super.initState();
    /// Esto asegura que el widget esté montado antes de ejecutar viewModel
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AuthViewModel>().checkRole();
      await context.read<AdminViewModel>().loadUsers();
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
                await context.watch<AuthViewModel>().signOut();// Llama a la función para cerrar sesión
                Get.offAllNamed(Routes.login);
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
    // print("UserManagePage montado");
    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: ToolBar(onMenuPressed:_pageVM.toggleSidebar),
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
                        'USERS MANAGE PAGE',
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
                              backgroundColor: WidgetStatePropertyAll(Color(
                                  0xFFDDDBDB)),
                              hintText: 'Search a User...',
                              hintStyle: WidgetStatePropertyAll(
                                TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                ),
                              ),
                              leading: Icon(Icons.search),
                              onChanged: (text) async {
                                setState(() {
                                  _searchText = text;
                                  _searchStatus = text.isNotEmpty;
                                });
                                context.read<AdminViewModel>().searchUser(text);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40,),
                      if (!_searchStatus) ...[
                        Consumer<AdminViewModel>(
                          builder: (context, adminVM, child) {
                            if (adminVM.isLoading) {
                              return CircularProgressIndicator();
                            } else if (adminVM.hasError) {
                              return Text('THERE WAS AN ERROR GETTING THE USERS');
                            } else if (adminVM.users.isEmpty) {
                              return Text('BUT NOBODY COMES...');
                            } else {
                              return Column(
                                children: adminVM.users.map((user) => Column(
                                  children: [
                                    ShowUserComponent(user: user),
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
                          builder: (context, adminVM, child) {
                            if (adminVM.isLoading) {
                              return CircularProgressIndicator();
                            } else if (adminVM.hasError) {
                              return Text('THERE WAS AN ERROR GETTING THE USERS');
                            } else if (adminVM.users.isEmpty) {
                              return Text('BUT NOBODY COMES...');
                            } else {
                              return Column(
                                children: adminVM.filteredUsers.map((user) => Column(
                                  children: [
                                    ShowUserComponent(user: user),
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
