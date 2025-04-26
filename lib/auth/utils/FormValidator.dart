
import 'package:game_box/auth/services/AuthFirebaseRepository.dart';
import 'package:get/get.dart';

class FormValidator {

  bool _containsSQLExpression(String text){
    RegExp regExp = RegExp(r'\b(select|delete|truncate|drop|update|insert|create|alter|union)\b', caseSensitive: false);
    return regExp.hasMatch(text);
  }

  String? isValidName(String? text) {
    if (text == null || text.isEmpty) {
      return "This name is not valid";
    } else if (text.length<5) {
      return "This name is too short";
    } else if (text.length>20) {
      return "This name is too long";
    } else {
      return null;
    }

  } //isValidName

  String? isValidEmail(String? text) {
    if (text==null || text.length<10){
      return "This email is too short";
    } else if (text.length>40) {
      return "This email is too long";
    } else {
      return (text ?? "").isEmail ? null : "This is not valid email";
    }
  } //isValidEmailToRegister

  String? isValidPass(String? text) {
    if (text == null || text.length<6) {
      return "This password is too short";
    } else if (text.length>20) {
      return "This password is too long";
    } else {
      return null;
    }
  } //isValidPass

  String? isValidRepeatedPass(String? value, String? pass){
    if (value == null || value.length<6) {
      return "This password is too short";
    } else if (value != pass) {
      return "Passwords don't match!";
    } else if (value.length>20) {
      return "This password is too long";
    } else {
      return null;
    }
  }

  String? isValidWeight(String? number) {
    if (number == null || number.isEmpty)  {
      return "User must have a weight";
    } else if (number.length > 15){
      return "This number is too long";
    } else if (double.tryParse(number) == null) {
      return "Invalid number";
    } else if (double.tryParse(number)!.isNegative){
      return "Invalid negative number";
    } else {
      return null;
    }
  }

  String? isValidRole(String? text) {
    if (text == null || text.isEmpty) {
      return "User must have any role";
    } else if (text.length > 20) {
      return "That role is too long, what are you trying?";
    } else if (text.length < 2) {
      return "That role is too short";
    } else {
      return null;
    }
  }

  String? isValidStatus(String? number) {
    if (number == null || number.isEmpty)  {
      return "User must have any status";
    } else if (number.length > 15){
      return "This number is too long";
    } else if (int.tryParse(number) == null) {
      return "Invalid number";
    } else if (int.tryParse(number)!.isNegative){
      return "Invalid negative number";
    } else {
      return null;
    }
  }

  String? isValidPath(String? text) {
    if (text != null && _containsSQLExpression(text)) {
      return "Invalid word found in path";
    } else {
      return null;
    }
  }


} //FormValidator