import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bannertvapp/presentation/location_selection/providers/location_selection_provider.dart';
import 'package:bannertvapp/presentation/location_selection/widgets/location_dropdown.dart';
import 'package:bannertvapp/presentation/display/screens/display_screen.dart';
import 'package:bannertvapp/core/services/storage_service.dart';

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  ConsumerState<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends ConsumerState<LocationSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationSelectionProvider.notifier).loadLocations();
    });
  }

  Future<void> _saveLocationSlug(String slug) async {
    await storageService.setString('location_slug', slug);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('LocationSelectionScreen.build() called');
    final state = ref.watch(locationSelectionProvider);
    debugPrint('State: loading=${state.loading}, error=${state.errorMessage}, locations=${state.locations.length}');

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: isKeyboardOpen ? null : AppBar(title: Text('Select Location')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Banner TV Display',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 48),
                  if (state.loading)
                    CircularProgressIndicator()
                  else if (state.errorMessage != null)
                    Text(
                      state.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    )
                  else
                    LocationDropdown(
                      locations: state.locations,
                      selectedLocation: state.locations.any((loc) => loc.slug == state.selectedLocation?.slug)
                          ? state.selectedLocation
                          : null,
                      onSelected: (location) {
                        ref.read(locationSelectionProvider.notifier).selectLocation(location);
                      },
                    ),
                  SizedBox(height: 24),
                  FilledButton(
                    onPressed: state.selectedLocation != null
                        ? () async {
                            final navigator = Navigator.of(context);
                            final selectedLocation = state.selectedLocation!;
                            await _saveLocationSlug(selectedLocation.slug);
                            if (mounted) {
                              navigator.pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => DisplayScreen(
                                    location: selectedLocation,
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text('Start Display'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
