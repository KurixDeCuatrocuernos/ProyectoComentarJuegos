
import 'package:game_box/pages/HomePage.dart';
import 'package:game_box/pages/LoadingPage.dart';
import 'package:get/get.dart';
import '../pages/LoginPage.dart';
import '../pages/RegisterPage.dart';
import 'AppRoutes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.loading,
      page: () => const Loadingpage(),
    ),
    GetPage(
        name: Routes.login,
        page: () => const LoginPage(),
    ),
    GetPage(
        name: Routes.register,
        page: () => const RegisterPage(),
    ),
    GetPage(
        name: Routes.home,
        page: () => const HomePage(),
    ),
  ];
}