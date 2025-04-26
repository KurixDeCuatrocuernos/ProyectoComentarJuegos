
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/AppRoutes.dart';
import '../../services/AuthFirebaseRepository.dart';

class AuthController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController imagePathController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  Rxn<User?> firebaseUser = Rxn<User?>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get user => _auth.authStateChanges();

  @override
  void onReady() {
    ever(firebaseUser, handleAuthChanged);
    firebaseUser.bindStream(user);
    super.onReady();
  }

  handleAuthChanged(User? firebaseUser) async {
    if (firebaseUser?.isAnonymous == false && firebaseUser?.uid != null){
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  registerWithEmailAndPassword() async {
    
    firebaseUser.value =
        await AuthFirebaseRepository().registerWithEmailAndPassword (
          email: emailController.value.text,
          password: passwordController.value.text,
          name: nameController.value.text,
        );
  }

  loginWithEmailAndPassword() async {
    firebaseUser.value =
        await AuthFirebaseRepository().loginWithEmailAndPassword(
          email: emailController.value.text,
          password:passwordController.value.text,
        );
  }

  loginWithGoogle() async {
    print("Singing with google...");
    firebaseUser.value = await AuthFirebaseRepository().signInWithGoogle();
  }

  Future<void> signOut() async {
    print('You have been logged out');
    return _auth.signOut();
  }

}