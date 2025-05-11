
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_box/auth/models/UserModel.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../repository/UserRepository.dart';
import '../routes/AppRoutes.dart';

class UserViewModel extends ChangeNotifier{
  final List<UserModel> _users = [];
  List<UserModel> get users => List.unmodifiable(_users);
  UserRepository _userRepo = UserRepository();


  void addUser(UserModel user) {
    _users.add(user);
    notifyListeners();
  }

  void addAllUsers(List<UserModel> users) {
    for (UserModel user in users) {
      _users.add(user);
    }
    notifyListeners();
  }

  void updateUser(String id, UserModel userUpdated) {
    final index = _users.indexWhere((user) => user.uid == id);
    if (index != -1) {
      _users[index] = userUpdated;
      notifyListeners();
    }
  }

  void removeUser(String id) {
    _users.removeWhere((user) => user.uid == id);
    notifyListeners();
  }

  UserModel? getById(String id) {
    try{
      return _users.firstWhere((user) => user.uid == id);
    } catch (error) {
      return null;
    }
  }

  void clear() {
    _users.clear();
    notifyListeners();
  }

  Future<bool> tryUserRoleFromRepository() async {
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

  Future<UserModel?> getUserByIdFromRepository(String id) async {
    try {
      UserModel? user = await _userRepo.getUserByUid(id);
      return user;
    } catch (error) {
      print("HUBO UN ERROR AL RECOGER LOS DATOS DEL USUARIO");
      return null;
    }
  }

}