import 'package:game_box/auth/structure/controllers/AuthController.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

import '../controllers/CommentaryController.dart';

class AuthBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut <CommentaryController> (
          () => CommentaryController(),
    );
  } //dependencies
} //AuthBi