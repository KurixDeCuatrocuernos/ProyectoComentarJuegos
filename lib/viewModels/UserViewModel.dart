
import 'package:flutter/cupertino.dart';
import 'package:game_box/auth/models/UserModel.dart';

class UserViewModel extends ChangeNotifier{
  final List<UserModel> _users = [];
  List<UserModel> get users => List.unmodifiable(_users);

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
}