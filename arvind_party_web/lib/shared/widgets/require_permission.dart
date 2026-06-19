import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/auth_controller.dart';

// ============================================================
// ARVIND PARTY WEB — RequirePermission (Obx Conditional Renderer)
// ============================================================
// Wraps a widget and conditionally renders it based on the user's
// assigned permission level for a given module.
//
// Usage:
//   RequirePermission(
//     module: 'user',
//     allowedLevels: ['viewOnly', 'edit', 'fullControl'],
//     child: UserManagementPanel(),
//   )
//
//   RequirePermission(
//     module: 'system',
//     allowedLevels: ['fullControl'],  // Only fullControl
//     fallback: Text('No Access'),
//     child: SystemSettingsPanel(),
//   )
// ============================================================

class RequirePermission extends StatelessWidget {
  final String module;
  final List<String> allowedLevels;
  final Widget child;
  final Widget? fallback;

  const RequirePermission({
    super.key,
    required this.module,
    this.allowedLevels = const ['viewOnly', 'edit', 'fullControl'],
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    // Use Obx to reactively rebuild when permissions change
    return Obx(() {
      final auth = AuthController.to;
      final hasAccess = auth.hasPermission(
        module,
        allowedLevels: allowedLevels,
      );

      if (hasAccess) {
        return child;
      }

      // Return the fallback widget if provided, otherwise SizedBox.shrink
      return fallback ?? const SizedBox.shrink();
    });
  }
}