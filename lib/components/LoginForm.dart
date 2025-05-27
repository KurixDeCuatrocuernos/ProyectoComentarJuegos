import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_box/auth/utils/PasswordToggler.dart';
import 'package:get/get.dart';
import '../auth/structure/controllers/AuthController.dart';
import '../auth/utils/FormValidator.dart';
import '../routes/AppRoutes.dart';

class LoginForm extends StatelessWidget{
  LoginForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final passwordToggler = PasswordToggler();

  @override
  Widget build(BuildContext context) {
    FormValidator formValidator = FormValidator();
    AuthController authController = Get.find();
    return Form(
      key: _formKey,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,
          margin: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(children: [
            SizedBox(
              height: 10,
            ),
            Text(
              "LOGIN",
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize:20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
                child: TextFormField(
                  validator: formValidator.isValidEmail,
                  controller: authController.emailController,
                  decoration: const InputDecoration(hintText: "Insert your Email"),
                ),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
              child: Obx(() => TextFormField(
                validator: formValidator.isValidPass,
                controller: authController.passwordController,
                obscureText: passwordToggler.isObscure1.value,
                decoration: InputDecoration(
                  hintText: "Insert your Password",
                  suffixIcon: IconButton(
                    icon: Icon(passwordToggler.isObscure1.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      passwordToggler.togglePasswordVisibility(1);
                    },
                  ),
                ),
              )),
            ),
            SizedBox(
              height: 20,
            ),
            ///Button to login
            TextButton(
              onPressed: (){
                if(_formKey.currentState!.validate()) {
                  authController.loginWithEmailAndPassword();
                  print("This form is correct");
                  Get.offAllNamed(Routes.home);
                } else {
                  print("Try again!"); /// mostrar mensaje de aviso
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color(0xFF0097FF)),
                minimumSize: WidgetStatePropertyAll(Size(60,40)),
              ),
              child: Text(
                "LOGIN",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "OR",
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize:20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ///Button to SignIn with google
            IconButton(
                onPressed: () async {
                  print("Google Login button pressed");
                  await authController.loginWithGoogle();
                },
                icon: kIsWeb
                    ? Image.asset(
                  'google/light/web_light_rd_na.png',
                  width: 60,
                  height: 60,
                )
                    : SvgPicture.asset(
                  'assets/google_android/light/android_light_rd_na.svg',
                  width: 60,
                  height: 60,
                ),
            ),

            /// moves to the end of the Column
            Expanded(
              child: SizedBox(
                height: 10,
              ),
            ),

            /// Redirects to Register
            TextButton(
              onPressed: () {
                Get.offAllNamed(Routes.register);
              },
              child: Text(
                "Don't have account?, Register here!",
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],),
        ),
      ),
    );
  }
}