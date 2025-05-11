

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../repository/GameRepository.dart';
import '../repository/UserRepository.dart';
import '../routes/AppRoutes.dart';

class PageViewModel extends ChangeNotifier {

  final  GameRepository _gameRepo = GameRepository();

  bool _isSidebarOpen = false;
  bool _searchStatus = false;
  String _searchText = '';

  bool get isSidebarOpen => _isSidebarOpen;
  bool get searchStatus => _searchStatus;
  String get searchText => _searchText;

  void toggleSearch() {
    _searchStatus = true;
    notifyListeners();
  }

  void closeSearch() {
    _searchStatus = false;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void closeSidebar() {
    _isSidebarOpen = false;
    notifyListeners();
  }

  void checkAdminRoleFromRepository() async {
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

  Future<void>? redirectToGameById(int gameId) async {
    try {
      Map<String, dynamic>? game = {};
      game = await _gameRepo.getGameById(gameId);
      if (game != null) {
        Get.toNamed(Routes.game, arguments: game);
      } else {
        print("EL JUEGO RECIBIDO ESTABA VACÍO");
      }
    } catch (error) {
      print("HUBO UN ERROR AL BUSCAR EL JUEGO");
    }
  }
}