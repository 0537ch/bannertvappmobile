import 'package:flutter/material.dart';
import 'package:bannertvapp/presentation/location_selection/screens/location_selection_screen.dart';
import 'package:bannertvapp/presentation/display/providers/display_provider.dart';
import 'package:bannertvapp/core/services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearLocationSlug() async {
    await storageService.remove('location_slug');
    DisplayProvider.resetInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Change Location'),
            subtitle: Text('Select a different display location'),
            leading: Icon(Icons.location_on),
            onTap: () async {
              await _clearLocationSlug();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationSelectionScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
