import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bannertvapp/core/theme/app_theme.dart';
import 'package:bannertvapp/config/env.dart';
import 'package:bannertvapp/core/services/storage_service.dart';
import 'package:bannertvapp/presentation/location_selection/screens/location_selection_screen.dart';

void main() async {
  debugPrint('main() started');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('WidgetsFlutterBinding initialized');
  await storageService.init();
  debugPrint('storageService initialized');
  await Env.load();
  debugPrint('Env loaded');
  debugPrint('Starting app...');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _getInitialScreen() {
    final slug = storageService.getString('location_slug');

    if (slug == null) {
      return LocationSelectionScreen();
    }

    // For now, return location selection
    // TODO: Fetch location by slug and go to DisplayScreen
    return LocationSelectionScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banner TV Display',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: _getInitialScreen(),
    );
  }
}
