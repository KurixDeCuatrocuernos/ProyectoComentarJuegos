
import 'package:get/get.dart';

class PasswordToggler extends GetxController{
  var isObscure1 = true.obs;
  var isObscure2 = true.obs;

  void togglePasswordVisibility(int fieldNumber) {
    if (fieldNumber == 1) {
      isObscure1.value = !isObscure1.value;
    } else if (fieldNumber == 2) {
      isObscure2.value = !isObscure2.value;
    }
  }
}