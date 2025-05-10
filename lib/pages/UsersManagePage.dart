import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/ShowUserComponent.dart';
import 'package:game_box/viewModels/UserViewModel.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../auth/models/UserModel.dart';
import '../auth/structure/controllers/AuthController.dart';
import '../components/SearchPlaceholder.dart';
import '../components/SearchResults.dart';
import '../components/ToolBar.dart';
import '../components/UserImage.dart';
import '../components/UserName.dart';
import '../repository/UserRepository.dart';
import '../routes/AppRoutes.dart';

class UsersManagePage extends StatefulWidget {
  const UsersManagePage({super.key});

  @override
  State<UsersManagePage> createState() => _UsersManagePageState();
}

class _UsersManagePageState extends State<UsersManagePage> {

  AuthController _authController = AuthController();
  UserRepository _userRepo = UserRepository();
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
  /// Devuelve true si contiene caracteres no alfanumericos y false si no los contiene
  bool _containsCharNoAlfanumeric(String texto) {
    final alfanumerico = RegExp(r'^[a-zA-Z0-9 _\-\:\.\,áéíóúüÁÉÍÓÚÜñÑ]+$');
    return !alfanumerico.hasMatch(texto);
  }

  Future<List<UserModel>?> _searchUser(String query) async {
    if (_containsCharNoAlfanumeric(query) == true) {
      return [];
    } else {
      try {
        final List<UserModel>? users = await _userRepo.getUsersByQuery(query);
        if (users == null) {
          return [];
        } else {
          if (users.isNotEmpty) {
            return users;
          } else {
            return [];
          }
        }
      } catch (error) {
        print("Error in Search");
        return null;
      }
    }

  }

  Future<List<UserModel>?> _manageUsers() async {
    try {
      List<UserModel>? users = [];
      print("SE HA PASADO POR _manageUsers()");
      if (context.watch<UserViewModel>().users.isNotEmpty) {
        users = context.read<UserViewModel>().users;
        print("SE DEVOLVIÓ PROVIDER $users");
        return users;
      } else {
        print("SE BUSCÓ EN LA BASE DE DATOS");
        users = await _userRepo.getAllUsers();
        if (users != null) {
          if (users.isNotEmpty) {
            final userList = context.read<UserViewModel>();
            userList.addAllUsers(users);
            return users;
          } else {
            print("Se recibieron datos vacíos");
            return null;
          }
        } else {
          return null;
        }
      }
    } catch (error) {
      print("HUBO UN ERROR BUSCANDO USUARIOS $error");
      return null;
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
                        'USERS MANAGE PAGE',
                        style: TextStyle(
                          color: Color(0xFF000000),
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
                              backgroundColor: WidgetStatePropertyAll(Color(
                                  0xFFDDDBDB)),
                              hintText: 'Search a User...',
                              hintStyle: WidgetStatePropertyAll(
                                TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 20,
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
                        ],
                      ),
                      SizedBox(height: 40,),
                      if (!_searchStatus) ...[
                        FutureBuilder<List<UserModel>?>(
                          future: _manageUsers(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('THERE WAS AN ERROR GETTING THE USERS');
                            } else if (snapshot.hasData) {
                              if(snapshot.data == null) {
                                return Text('DATA IS NULL');
                              } else if (snapshot.data!.isEmpty) {
                                return Text('BUT NOBODY COMES...');
                              } else {
                                return Column(
                                  children: snapshot.data!.map((user) => Column(
                                    children: [
                                      ShowUserComponent(user: user),
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
                        FutureBuilder(
                          future: _searchUser(_searchText),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Search result has errors');
                            } else if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                return Text('Found no Users match');
                              } else {
                                return Column(
                                  children: snapshot.data!.map((user) => Column(
                                    children: [
                                      ShowUserComponent(user: user),
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
