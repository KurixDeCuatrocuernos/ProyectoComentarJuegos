import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:game_box/viewModels/AuthViewModel.dart';
import 'package:game_box/viewModels/UserViewModel.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../routes/AppRoutes.dart';

class UserName extends StatelessWidget {
  UserName({super.key});

  void _profileRedirection() {
    Get.offAllNamed(Routes.home);
  }

  Future<String> _userName(BuildContext context) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    try {
      String? name = await context.read<UserViewModel>().getCurrentUserNameById(uid!);
      return name ?? 'UserName';
    } catch (error) {
      print('Couldn´t get the User name: $error');
      return 'UserName';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: _profileRedirection,
        child: FutureBuilder<String?>(
          future: _userName(context), //Here we call the asynchronous method
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();  // if it delays enough we shows a circular progress indicator
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * 0.07 : MediaQuery.of(context).size.width * 0.04,
                  ),
              );
            } else if (snapshot.hasData) {
              return Text(
                snapshot.data ?? 'UserName', // Shows the username or the default name
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * 0.07 : MediaQuery.of(context).size.width * 0.04,
                ),
              );
            } else {
              return Text(
                  'UserName',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * 0.07 : MediaQuery.of(context).size.width * 0.04,
                  ),
              );
            }
          },
        ),
    );
  }
}
