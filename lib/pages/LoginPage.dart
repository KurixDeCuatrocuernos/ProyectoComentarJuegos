
import 'package:flutter/material.dart';

import '../components/LoginForm.dart';

class LoginPage extends StatelessWidget{
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF750202),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 40,
          ),
          child: SingleChildScrollView(
            child: LoginForm(),
          ),
        ),
      ),
    );
  }
}