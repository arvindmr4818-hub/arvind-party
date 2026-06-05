import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'core/services/socket_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Portrait only (jaise TikTok Live, BIGO Live karta hai)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Get.putAsync(() => StorageService().init());

  // SocketService ko GetxService ki tarah register karo
  // (yeh app ke poore lifecycle mein alive rahega)
  await Get.putAsync<SocketService>(() async {
    final service = SocketService();
    return service;
  });

  runApp(const ArvindPartyApp());
}

class ArvindPartyApp extends StatelessWidget {
  const ArvindPartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ARVIND PARTY',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.darkTheme,

      // Initial Route - Splash se start
      initialRoute: AppRoutes.splash,

      // All Pages with Bindings
      getPages: AppPages.pages,

      // Default Transitions
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
