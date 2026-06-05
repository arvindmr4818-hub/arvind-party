// arvind_party_web/lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/network/admin_api.dart';
import 'core/theme/web_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Get.putAsync<AdminApi>(() async => AdminApi());
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box       = GetStorage();
    final isLogged  = box.read<bool>('admin_logged_in') ?? false;

    return GetMaterialApp(
      title:                    'Arvind Party — Admin Panel',
      debugShowCheckedModeBanner: false,
      theme:                    WebTheme.theme,
      initialRoute:             isLogged ? AppRoutes.dashboard : AppRoutes.login,
      getPages:                 AppPages.pages,
      defaultTransition:        Transition.fadeIn,
      transitionDuration:       const Duration(milliseconds: 200),
    );
  }
}
