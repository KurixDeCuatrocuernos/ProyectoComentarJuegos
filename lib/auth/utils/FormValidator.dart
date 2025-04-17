
import 'package:game_box/auth/services/AuthFirebaseRepository.dart';
import 'package:get/get.dart';

class FormValidator {

  String? isValidName(String? text) {
    if (text == null || text.isEmpty || text.length<5) {
      return "This name is not valid";
    } else {
      return null;
    }

  } //isValidName

  String? isValidEmail(String? text) {
    return (text ?? "").isEmail ? null : "This is not valid email";
  } //isValidEmailToRegister

  String? isValidPass(String? text) {
    if (text == null || text.length<6) {
      return "This password is too short";
    } else {
      return null;
    }
  } //isValidPass

  String? isValidRepeatedPass(String? value, String? pass){
    if (value == null || value.length<6) {
      return "This password is too short";
    } else if (value != pass) {
      return "Passwords don't match!";
    } else {
      return null;
    }
  }


} //FormValidator