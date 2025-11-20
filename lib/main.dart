import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:personal_finance_manager/app/routes/app_pages.dart';
import 'package:personal_finance_manager/app/themes/app_theme.dart';
import 'package:personal_finance_manager/data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Storage Service
  await Get.putAsync(() => StorageService().init());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();
    return GetMaterialApp(
      title: 'Finance Manager',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storageService.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Routes
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
