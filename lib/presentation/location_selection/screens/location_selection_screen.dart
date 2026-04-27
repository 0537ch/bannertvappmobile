import 'package:flutter/material.dart';
import 'package:bannertvapp/presentation/location_selection/providers/location_selection_provider.dart';
import 'package:bannertvapp/presentation/location_selection/widgets/location_dropdown.dart';
import 'package:bannertvapp/presentation/display/screens/display_screen.dart';
import 'package:bannertvapp/presentation/display/providers/display_provider.dart';
import 'package:bannertvapp/core/services/storage_service.dart';
import 'package:bannertvapp/data/models/location_model.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late final LocationSelectionProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = LocationSelectionProvider.instance;
  }

  @override
  void dispose() {
    // JANGAN dispose singleton!
    super.dispose();
  }

  Future<void> _saveLocationSlug(String slug) async {
    await storageService.setString('location_slug', slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Location')),
      body: ListenableBuilder(
        listenable: _provider,
        builder: (context, child) {
          final state = _provider.state;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.all(24),
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
                        selectedLocation: state.selectedLocation,
                        onSelected: (location) {
                          _provider.selectLocation(location);
                        },
                      ),
                    SizedBox(height: 24),
                    FilledButton(
                      onPressed: state.selectedLocation != null
                          ? () async {
                              await _saveLocationSlug(state.selectedLocation!.slug);
                              // Reset singleton saat pindah screen
                              DisplayProvider.resetInstance();
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DisplayScreen(
                                      location: state.selectedLocation!,
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
          );
        },
      ),
    );
  }
}
