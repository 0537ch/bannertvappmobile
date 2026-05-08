import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bannertvapp/presentation/location_selection/screens/location_selection_screen.dart';
import 'package:bannertvapp/presentation/display/providers/display_provider.dart';
import 'package:bannertvapp/core/services/storage_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _clearLocationSlug(WidgetRef ref) async {
    await storageService.remove('location_slug');
    // Invalidate provider to force refresh
    ref.invalidate(displayProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Change Location'),
            subtitle: Text('Select a different display location'),
            leading: Icon(Icons.location_on),
            onTap: () async {
              await _clearLocationSlug(ref);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationSelectionScreen(),
                  ),
                  (route) => false, // Remove all routes
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
