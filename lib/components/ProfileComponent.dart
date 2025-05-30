import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/auth/structure/controllers/AuthController.dart';
import 'package:game_box/auth/utils/FormValidator.dart';
import 'package:game_box/auth/utils/PasswordToggler.dart';
import 'package:game_box/viewModels/UserViewModel.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:provider/provider.dart';

import '../auth/models/UserModel.dart';
import '../routes/AppRoutes.dart';

class ProfileComponent extends StatefulWidget {
  const ProfileComponent({super.key});

  @override
  _ProfileComponentState createState() => _ProfileComponentState();

}

class _ProfileComponentState extends State<ProfileComponent> {

  String gravatarAttr = 'mp';
  String? username;
  String? usermail;
  final double _size = 90;
  final _formImage = GlobalKey<FormState>();
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _setModelData();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _setModelData() async {
    gravatarAttr = await context.read<UserViewModel>().loadCurrentUserImage();
    UserModel? user = await context.read<UserViewModel>().getUserDataById();
    if(user != null && mounted) {
      setState(() {
        username = user.name;
        usermail = user.email;
      });
    }
  }

  bool isValidImageUrl(String url) {
    final uri = Uri.tryParse(url);
    final imageRegex = RegExp(r"\.(jpg|jpeg|png|gif|bmp|webp|svg)$", caseSensitive: false);
    return uri != null &&
        (uri.isScheme("http") || uri.isScheme("https")) &&
        imageRegex.hasMatch(uri.path);
  }

  String _generateGravatarUrl(String email, String gravatarAttr) {
    // print('ATRIBUTO PARA GRAVATAR: $gravatarAttr');
    final bytes = utf8.encode(email.trim().toLowerCase());
    final digest = md5.convert(bytes);
    print("IMAGEN GUARDADA: https://www.gravatar.com/avatar/${digest.toString()}?s=${_size}&d=$gravatarAttr");
    return 'https://www.gravatar.com/avatar/${digest.toString()}?s=${_size}&d=$gravatarAttr';
  }

  Widget takeUserImage(String gravatarAttr, double sizes) {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      String gravatarUrl = _generateGravatarUrl(email, gravatarAttr);
      return ClipOval(
        child: Image.network(
          gravatarUrl,
          width: sizes,
          height: sizes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.account_circle, size: sizes);
          },
        ),
      );
    } else {
      return Icon(Icons.account_circle, size: sizes);
    }
  }

  void showConfirmText(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.black,
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20,),
                Text(
                  'Datos actualizados con éxito',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10,),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.offAllNamed(Routes.home);
                    },
                  style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Color(0xE8A5A3A3),
                  ), // tu color
                  padding: WidgetStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                ),
              ],
            ),
          );
        }
    );
  }

  void showErrorText(String? error, BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.black,
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20,),
                Text(
                  error ?? 'Unknown error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 10,),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Color(0xE8A5A3A3),
                    ), // tu color
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                ),
              ],
            ),
          );
        }
    );
  }

  void _changeImage(BuildContext context) {

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text(
                'CHOOSE AN IMAGE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF630000),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var attr in ['mp', 'retro', 'identicon', 'wavatar', 'robohash'])
                    IconButton(
                      onPressed: () {
                        setState(() {
                          gravatarAttr = attr;
                        });
                        Navigator.of(context).pop();
                      },
                      icon: takeUserImage(attr, 32.0),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Text('or use a URL as fallback image:'),
              Form(
                key: _formImage,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      child: TextFormField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: 'Use a image URL like: https://www.picture.com/image.png',
                        ),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Color(0xFF006317),
                        ), // tu color
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                        onPressed: () {
                          final url = _urlController.text.trim();
                          if (isValidImageUrl(url)) {
                            setState(() {
                              gravatarAttr = Uri.encodeComponent(url);
                            });
                            Navigator.of(context).pop(); // cerrar diálogo
                            print('URL GUARDADA: $url');
                          } else {
                            setState(() {
                              gravatarAttr = 'mp';
                            });
                            print("URL NO VÁLIDA O NO ES UNA IMAGEN");
                          }
                        },
                        child: Text(
                          'TRY IMAGE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthController authController = AuthController();
    FormValidator formValidator = FormValidator();
    final _formName = GlobalKey<FormState>();
    final _formPassword = GlobalKey<FormState>();
    final passwordToggler = Get.put(PasswordToggler());

    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'USER DATA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF630000),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: Text(
                      'Your current Username: \n$username' ?? 'Your Username',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 40,
                ),
                child: Form(
                  key: _formName,
                  child: TextFormField(
                    controller: authController.nameController,
                    validator: formValidator.isValidName,
                    decoration: const InputDecoration(hintText: 'Your new user name'),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: Text(
                      'Your Current Email: \n$usermail' ?? 'Your Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Form(
                key: _formPassword,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
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
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
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
                  ],
                ),
              ),
              SizedBox(height: 40,),
              Text(
                'USER PICTURE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF630000),
                ),
              ),
              SizedBox(height: 20,),

              IconButton(
                onPressed: () {
                  _changeImage(context);
                },
                icon: takeUserImage(gravatarAttr, _size),
                iconSize: _size + 10.0,
              ),

              SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async {
                      final name = authController.nameController.text.trim();
                      final pass = authController.passwordController.text.trim();

                      bool isValid = true;

                      if (name.isNotEmpty && !_formName.currentState!.validate()) isValid = false;
                      if (pass.isNotEmpty && !_formPassword.currentState!.validate()) isValid = false;

                      if (name.isEmpty && pass.isEmpty && gravatarAttr == 'mp') {
                        print("NINGÚN CAMPO SE HA MODIFICADO");
                        return;
                      }

                      if (!isValid) {
                        print("CHECK THE DATA");
                        return;
                      }

                      Map<String, dynamic> data = {};

                      if (name.isNotEmpty) data['name'] = name;
                      if (pass.isNotEmpty) data['pass'] = pass;
                      if (gravatarAttr != 'mp') data['image'] = gravatarAttr;

                      String? result = await context.read<UserViewModel>().updateData(data);

                      if (result == null) {
                        showConfirmText(context);
                      } else {
                        showErrorText(result, context);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        Color(0xFF006317),
                      ), // tu color
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    child: Text(
                      'SAVE DATA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      authController.nameController.text="";
                      authController.passwordController.text="";
                      print("SAVE CANCELADO");
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        Color(0xFF750202),
                      ), // tu color
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
