import 'package:flutter/foundation.dart';
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

class LocationSelectionProvider extends ChangeNotifier {
  final BannerRepositoryImpl _repository = BannerRepositoryImpl();
  LocationSelectionState _state = LocationSelectionState();

  LocationSelectionState get state => _state;

  LocationSelectionProvider._internal() {
    loadLocations();
  }

  static LocationSelectionProvider? _instance;

  static LocationSelectionProvider get instance {
    _instance ??= LocationSelectionProvider._internal();
    return _instance!;
  }

  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }

  void _updateState(LocationSelectionState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadLocations() async {
    _updateState(_state.copyWith(loading: true, errorMessage: null));

    try {
      final locations = await _repository.getLocations();
      _updateState(_state.copyWith(
        locations: locations,
        loading: false,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        loading: false,
        errorMessage: 'Failed to load locations',
      ));
    }
  }

  void selectLocation(LocationModel location) {
    _updateState(_state.copyWith(selectedLocation: location));
  }
}
