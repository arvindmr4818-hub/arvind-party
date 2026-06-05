// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/routes/app_pages.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../modules/splash/views/splash_screen.dart';
import '../modules/splash/bindings/splash_binding.dart';

import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/phone_auth_screen.dart';
import '../modules/auth/bindings/auth_binding.dart';

import '../modules/home/views/home_screen.dart';
import '../modules/home/bindings/home_binding.dart';

import '../modules/profile/views/profile_screen.dart';
import '../modules/profile/bindings/profile_binding.dart';

import '../modules/wallet/views/wallet_screen.dart';
import '../modules/wallet/bindings/wallet_binding.dart';

import '../modules/room/views/room_screen.dart';
import '../modules/room/views/create_room_screen.dart';
import '../modules/room/bindings/room_binding.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.phoneAuth, // ← NEW
      page: () => const PhoneAuthScreen(),
      binding: PhoneAuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.voiceRoom,
      page: () => const RoomScreen(),
      binding: RoomBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.createRoom, // ← NEW
      page: () => const CreateRoomScreen(),
      binding: CreateRoomBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
