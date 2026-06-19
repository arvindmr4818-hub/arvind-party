import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/auth_controller.dart';
import '../../routes/app_routes.dart';

// ============================================================
// ARVIND PARTY WEB — Owner Guard Middleware (Route Guard)
// ============================================================
// Restricts access to only OWNER.WEB role.
// If the user is not the owner, redirects to /unauthorized.
// Must be placed AFTER AuthMiddleware in the middleware chain.
// ============================================================

class OwnerGuardMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    // Ensure AuthController is initialized
    final auth = Get.isRegistered<AuthController>()
        ? AuthController.to
        : Get.put(AuthController());

    // Check if the current user has the OWNER.WEB role
    if (!auth.isOwner) {
      return const RouteSettings(name: AppRoutes.unauthorized);
    }

    // Allow access to the requested route
    return null;
  }
}