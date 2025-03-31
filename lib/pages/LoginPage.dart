
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
          width: double.infinity,
          height: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 40,
          ),
          child: Column(children: [
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: LoginForm(),
            ),
            const SizedBox(
              height: 40,
            ),
          ],),
        ),
      ),
    );
  }
}