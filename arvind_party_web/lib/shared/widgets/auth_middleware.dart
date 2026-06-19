import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/auth_controller.dart';
import '../../routes/app_routes.dart';

// ============================================================
// ARVIND PARTY WEB — Authentication Middleware (Route Guard)
// ============================================================
// Checks if user is logged in. If not, redirects to /login.
// Attach to any route that requires authentication.
// ============================================================

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Make sure AuthController is initialized
    final auth = Get.isRegistered<AuthController>()
        ? AuthController.to
        : Get.put(AuthController());

    // If not logged in, redirect to login
    if (!auth.isLoggedIn.value) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // Allow access to the requested route
    return null;
  }
}