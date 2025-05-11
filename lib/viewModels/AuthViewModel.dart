
import 'package:flutter/material.dart';
import 'package:game_box/auth/structure/controllers/AuthController.dart';

class AuthViewModel extends ChangeNotifier {
  AuthController _authController = AuthController();

  Future<void> signOut() async {
    await _authController.signOut();
  }

}