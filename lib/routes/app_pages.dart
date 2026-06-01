import 'package:get/get.dart';

import '../modules/splash/views/splash_screen.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/home/views/home_screen.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [

    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),

  ];
}
