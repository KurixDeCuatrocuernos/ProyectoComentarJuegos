
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/auth/structure/controllers/AuthController.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../routes/AppRoutes.dart';

class AuthViewModel extends ChangeNotifier {

  AuthController _authController = AuthController();
  UserRepository _userRepo = UserRepository();

  /// Este metodo sirve para cerrar sesion
  Future<void> signOut() async {
    await _authController.signOut();
  }

  /// Este metodo redirige a la página de inicio si el role del usuario no es ADMIN (si lo es no hace nada)
  Future<void> checkRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      final role = await _userRepo.getUserRoleByUid(user.uid);
      if (role != "ADMIN") {
        print("User is not an Admin");
        Get.offAllNamed(Routes.home);
      }
    } else {
      print("User is Unknown or database error");
      Get.offAllNamed(Routes.home);
    }
  }

  /// Este metodo devuelve true si el role del usuario es ADMIN y false si tiene otro role
  Future<bool> tryRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      final role = await _userRepo.getUserRoleByUid(user.uid);
      return role == "ADMIN";
    }
    return false;
  }

}