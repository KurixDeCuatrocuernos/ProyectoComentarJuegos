import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../routes/AppRoutes.dart';

class UserImage extends StatelessWidget {
  const UserImage({super.key});

  Widget _getUserImage() {
    return Image.asset(
      'user/userImage1.png',
      errorBuilder: (context, error, stackTrace) {
        print('User has not Image, charging default image');
        if (kIsWeb) {
          return Image.asset('google/dark/web_dark_rd_na.png');
        } else {
          return SvgPicture.asset('assets/google_android/dark/android_dark_rd_na.svg');
        }

      },
    );
  }

  void _profileRedirection() {
    Get.offAllNamed(Routes.home); /// Esto debe redirigir a la página de los datos del usuario
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _profileRedirection,
      icon: _getUserImage(),
      iconSize: 90,
    );
  }
}
