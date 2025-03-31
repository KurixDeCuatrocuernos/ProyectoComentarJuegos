
import 'package:flutter/material.dart';

import '../components/RegisterForm.dart';

class RegisterPage extends StatelessWidget{
  const RegisterPage({super.key});

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
              child: RegisterForm(),
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