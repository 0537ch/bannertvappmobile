import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bannertvapp/data/models/location_model.dart';
import 'package:bannertvapp/data/repositories/banner_repository_impl.dart';

class LocationSelectionState {
  final List<LocationModel> locations;
  final LocationModel? selectedLocation;
  final bool loading;
  final String? errorMessage;

  LocationSelectionState({
    this.locations = const [],
    this.selectedLocation,
    this.loading = true,
    this.errorMessage,
  });

  LocationSelectionState copyWith({
    List<LocationModel>? locations,
    LocationModel? selectedLocation,
    bool? loading,
    String? errorMessage,
  }) {
    return LocationSelectionState(
      locations: locations ?? this.locations,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LocationSelectionNotifier extends Notifier<LocationSelectionState> {
  final BannerRepositoryImpl _repository = BannerRepositoryImpl();

  @override
  LocationSelectionState build() {
    debugPrint('LocationSelectionNotifier.build() called');
    return LocationSelectionState();
  }

  Future<void> loadLocations() async {
    debugPrint('loadLocations() started');
    state = state.copyWith(loading: true, errorMessage: null, selectedLocation: null);

    try {
      debugPrint('Fetching locations from repository...');
      final locations = await _repository.getLocations();
      debugPrint('Got ${locations.length} locations');
      state = state.copyWith(
        locations: locations,
        loading: false,
      );
    } catch (e) {
      debugPrint('Error loading locations: $e');
      state = state.copyWith(
        loading: false,
        errorMessage: 'Failed to load locations: $e',
      );
    }
  }

  void selectLocation(LocationModel location) {
    state = state.copyWith(selectedLocation: location);
  }
}

final locationSelectionProvider = NotifierProvider<LocationSelectionNotifier, LocationSelectionState>(LocationSelectionNotifier.new);
