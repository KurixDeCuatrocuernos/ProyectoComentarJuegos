
import 'package:game_box/auth/structure/bindings/AuthBinding.dart';
import 'package:game_box/pages/CommentsManagePage.dart';
import 'package:game_box/pages/CommentsPage.dart';
import 'package:game_box/pages/GamesManagePage.dart';
import 'package:game_box/pages/HomePage.dart';
import 'package:game_box/pages/LoadingPage.dart';
import 'package:game_box/pages/UsersManagePage.dart';
import 'package:get/get.dart';
import '../pages/GamePage.dart';
import '../pages/LoginPage.dart';
import '../pages/ProfilePage.dart';
import '../pages/RegisterPage.dart';
import 'AppRoutes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.loading,
      page: () => const LoadingPage(),
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
    GetPage(
      name: Routes.game,
      page: () => const GamePage(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: Routes.comments,
      page: () => const CommentsPage(),
    ),
    GetPage(
      name: Routes.manageUsers,
      page: () => const UsersManagePage(),
    ),
    GetPage(
      name: Routes.manageGames,
      page: () => const GamesManagePage(),
    ),
    GetPage(
      name: Routes.manageComments,
      page: () => const CommentsManagePage(),
    ),
  ];
}