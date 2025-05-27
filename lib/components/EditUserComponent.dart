import 'package:flutter/material.dart';
import 'package:game_box/auth/models/UserModel.dart';
import 'package:game_box/viewModels/AdminViewModel.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../auth/structure/controllers/AuthController.dart';
import '../auth/utils/FormValidator.dart';

class EditUserComponent extends StatefulWidget {
  final UserModel user;
  const EditUserComponent({super.key, required this.user});

  @override
  State<EditUserComponent> createState() => _EditUserComponentState();
}

class _EditUserComponentState extends State<EditUserComponent> {
  final _formKey = GlobalKey<FormState>();
  FormValidator _formValidator = FormValidator();
  AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _setFormData();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  Future<bool> _submitForm() async {
    try {
      UserModel newUser = UserModel(
        uid: widget.user.uid.toString(),
        name: _authController.nameController.text,
        email: _authController.emailController.text,
        role: _authController.roleController.text,
        weight: double.parse(_authController.weightController.text),
        status: int.parse(_authController.statusController.text),
        image: _authController.imagePathController.text,
      );
      bool cell = await context.read<AdminViewModel>().updateUser(newUser);
      return cell;
    } catch (error) {
      print("Hubo un error al actualizar los datos: $error");
      return false;
    }
  }

  void _setFormData() {
    _authController.nameController.text = widget.user.name.toString();
    _authController.emailController.text = widget.user.email.toString();
    _authController.roleController.text = widget.user.role.toString();
    _authController.weightController.text = widget.user.weight.toString();
    _authController.statusController.text = widget.user.status.toString();
    _authController.imagePathController.text = widget.user.image.toString();
  }

  @override
  Widget build(BuildContext context) {
    double _textSize = MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * 0.06 : MediaQuery.of(context).size.height * 0.017;
    TextStyle formTitleStyle = TextStyle(color: Colors.white, fontSize: _textSize, fontWeight: FontWeight.bold,);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFF120B0B),
          borderRadius: BorderRadius.circular(15),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /// Boton para cerrar el dialog
                  IconButton(
                    onPressed: () {Get.back();},
                    icon: Icon(
                      Icons.close,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10,),
                ],
              ),
              Text(
                "USER'S DATA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * 0.08 : MediaQuery.of(context).size.height * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 50,),
                    Row(
                      children: [
                        SizedBox(width: 50,),
                        Text('Username', style: formTitleStyle,),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: TextFormField(
                        controller: _authController.nameController,
                        validator: _formValidator.isValidName,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey,
                          hintText: 'New Username...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: _textSize ,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),

                    Row(
                      children: [
                        SizedBox(width: 50,),
                        Text('Email', style: formTitleStyle,),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: TextFormField(
                        controller: _authController.emailController,
                        validator: _formValidator.isValidEmail,
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey,
                          hintText: 'New Email...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: _textSize,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),

                    Row(
                      children: [
                        SizedBox(width: 50,),
                        Text('Role', style: formTitleStyle,),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: TextFormField(
                        controller: _authController.roleController,
                        validator: _formValidator.isValidRole,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey,
                          hintText: 'New Role...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: _textSize,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),

                    Row(
                      children: [
                        SizedBox(width: 50,),
                        Text('Weight', style: formTitleStyle,),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _authController.weightController,
                        validator: _formValidator.isValidWeight,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey,
                          hintText: 'New Weight...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: _textSize,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),

                    Row(
                      children: [
                        SizedBox(width: 50,),
                        Text('Status', style: formTitleStyle,),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: TextFormField(
                        controller: _authController.statusController,
                        validator: _formValidator.isValidStatus,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey,
                          hintText: 'New Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: _textSize,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),

                    Row(
                      children: [
                        SizedBox(width: 50,),
                        Text('Image path', style: formTitleStyle,),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: TextFormField(
                        controller: _authController.imagePathController,
                        validator: _formValidator.isValidPath,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey,
                          hintText: 'New Image path...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: _textSize,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 40,),

                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Color(0xF71D7509)),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _textSize* 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        if(_formKey.currentState!.validate()) {
                          bool cell = await _submitForm();
                          Navigator.of(context).pop();
                          if (!cell) {
                            /// Mensaje de error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content:
                              Text(
                                'Error Updating the data',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
