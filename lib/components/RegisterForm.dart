
import 'package:flutter/material.dart';
import 'package:game_box/auth/structure/controllers/AuthController.dart';
import 'package:game_box/auth/utils/PasswordToggler.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../auth/utils/FormValidator.dart';
import '../routes/AppRoutes.dart';

class RegisterForm extends StatelessWidget{
  RegisterForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final passwordToggler = Get.put(PasswordToggler());

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
          width: double.infinity,
          height: double.infinity,
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
              height: 30,
            ),
            Text(
              "SIGN UP",
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize:20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            // Form fields
            Flexible(
              child: TextFormField(
                validator: formValidator.isValidName,
                controller: authController.nameController,
                decoration: const InputDecoration(hintText: "Insert your UserName"),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: TextFormField(
                validator: formValidator.isValidEmail,
                controller: authController.emailController,
                decoration: const InputDecoration(hintText: "Insert your Email"),
              ),
            ),
            SizedBox(
              height: 20,
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
              ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: Obx( () => TextFormField(
                validator: (String? value){
                  return formValidator.isValidRepeatedPass(value, authController.passwordController.text);
                },
                obscureText: passwordToggler.isObscure2.value,
                decoration: InputDecoration(
                hintText: "Repeat your Password",
                suffixIcon: IconButton(
                  icon: Icon(passwordToggler.isObscure2.value
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    passwordToggler.togglePasswordVisibility(2);
                  },
                  ),
                ),
              ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            ///Button to login
            TextButton(
              onPressed: (){
                if(_formKey.currentState!.validate()) {
                  authController.registerWithEmailAndPassword();
                  print("This form is correct");
                  Get.offAllNamed(Routes.loading);
                } else {
                  print("Try again!"); /// mostrar mensaje de aviso
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color(0xFF0097FF)),
                minimumSize: WidgetStatePropertyAll(Size(60,40)),
              ),
              child: Text(
                "REGISTER",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            /// moves to the end of the Column
            Expanded(
              child: SizedBox(
                height: 20,
              ),
            ),

            /// Redirects to Register
            TextButton(
              onPressed: () {
                Get.offAllNamed(Routes.login);
              },
              child: Text(
                "You have account? Log in here!",
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}