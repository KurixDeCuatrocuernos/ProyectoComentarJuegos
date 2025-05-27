
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_box/auth/models/UserModel.dart';

import '../repository/UserRepository.dart';


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

  Future<UserModel?> getUserDataById() async {
    String? id = FirebaseAuth.instance.currentUser?.uid;

    if (id != null) {
      try {
        UserModel? user =  await _userRepo.getUserByUid(id);
        if (user != null) {
          return user;
        } else {
          return null;
        }
      } catch (error) {
        print("Error getting the user profile data");
        return null;
      }
    } else {
      return null;
    }
  }

  Future<String?> updateData(Map<String, dynamic> data) async {
    String? retorno;
    try {
      User? _user = FirebaseAuth.instance.currentUser;
      if (_user != null) {
        if (data['name'] != null) {
          retorno = await _userRepo.updateName(_user.uid, data['name']);
        }
        if (data['pass'] != null) {
          retorno = await _userRepo.updatePassword(_user.uid, data['pass']);
        }
        if (data['image'] != null) {
          retorno = await _userRepo.updateImage(_user.uid, data['image']);
        }
        return retorno;
      } else {

        return "USUARIO NO AUTENTICADO";
      }
    } catch (error) {
      return '$error';
    }
  }

  Future<String> loadCurrentUserImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String? image = await _userRepo.getUserImageByUid(user.uid);
        return image ?? "";
      } catch (error) {
        print("NO SE ENCONTRÓ IMAGEN DE USUARIO: $error");
        return "";
      }
    } else {
      return "";
    }
  }

  Future<String?> loadUserImageById(String uid)  async {
    try {
      String? image = await _userRepo.getUserImageByUid(uid);
      return image;
    } catch (error) {
      return null;
    }


  }

  String? getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      final String? uid = user.uid;
      if (uid != null) {
        return uid;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<String?> getUserEmailById(String id) async {
    try {
      return await _userRepo.getUserEmailByUid(id);
    } catch (error) {
      print("No se encontró el email del usuario: $id");
      return null;
    }
  }

}