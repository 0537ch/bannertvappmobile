import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:bannertvapp/data/models/banner_model.dart';
import 'package:bannertvapp/data/repositories/banner_repository_impl.dart';

class DisplayState {
  final List<BannerModel> banners;
  final int currentIndex;
  final bool loading;
  final bool refreshing;
  final bool hasLoadedOnce;
  final String? errorMessage;

  DisplayState({
    this.banners = const [],
    this.currentIndex = 0,
    this.loading = true,
    this.refreshing = false,
    this.hasLoadedOnce = false,
    this.errorMessage,
  });

  DisplayState copyWith({
    List<BannerModel>? banners,
    int? currentIndex,
    bool? loading,
    bool? refreshing,
    bool? hasLoadedOnce,
    String? errorMessage,
  }) {
    return DisplayState(
      banners: banners ?? this.banners,
      currentIndex: currentIndex ?? this.currentIndex,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DisplayProvider extends ChangeNotifier {
  final BannerRepositoryImpl _repository = BannerRepositoryImpl();
  DisplayState _state = DisplayState();

  DisplayState get state => _state;

  Timer? _rotationTimer;
  Timer? _retryTimer;
  int _retryAttempts = 0;
  String? _currentSlug;
  StreamSubscription? _sseSubscription;

  DisplayProvider._internal() {
    _listenToSse();
  }

  static DisplayProvider? _instance;

  static DisplayProvider get instance {
    if (_instance != null) {
      print('DisplayProvider instance already exists, reusing...');
      return _instance!;
    }
    print('Creating NEW DisplayProvider instance');
    _instance = DisplayProvider._internal();
    return _instance!;
  }

  static void resetInstance() {
    if (_instance != null) {
      print('Disposing DisplayProvider instance ${_instance.hashCode}');
      _instance!.dispose();
      _instance = null;
    }
  }

  void _updateState(DisplayState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadBanners(String slug) async {
    print('Loading banners for slug: $slug (instance: ${hashCode})');
    _currentSlug = slug;

    if (!_state.hasLoadedOnce) {
      _updateState(_state.copyWith(loading: true, errorMessage: null));
    } else {
      print('Refreshing banners...');
      _updateState(_state.copyWith(refreshing: true));

      // Delay untuk memastikan refreshing indicator terlihat
      await Future.delayed(Duration(milliseconds: 500));
    }

    try {
      final banners = await _repository.getBanners(slug);
      print('Loaded ${banners.length} banners (instance: ${hashCode})');

      if (banners.isEmpty) {
        _updateState(_state.copyWith(
          banners: banners,
          loading: false,
          refreshing: false,
          hasLoadedOnce: true,
        ));
        return;
      }

      _updateState(_state.copyWith(
        banners: banners,
        loading: false,
        refreshing: false,
        hasLoadedOnce: true,
        errorMessage: null,
      ));

      _resetRetryCount();
      _startRotation();
    } catch (e) {
      print('Error loading banners: $e');
      if (!_state.hasLoadedOnce) {
        _updateState(_state.copyWith(
          loading: false,
          errorMessage: 'Failed to load banners',
        ));
        _autoRetry();
      } else {
        _updateState(_state.copyWith(refreshing: false));
        _autoRetry();
      }
    }
  }

  void _startRotation() {
    _rotationTimer?.cancel();

    if (_state.banners.isEmpty) return;

    final currentBanner = _state.banners[_state.currentIndex];

    if (currentBanner.type == 'video') {
      return;
    }

    final duration = currentBanner.duration > 0 ? currentBanner.duration : 10;

    _rotationTimer = Timer(Duration(seconds: duration), () {
      _nextSlide();
    });
  }

  void _nextSlide() {
    if (_state.banners.isEmpty) return;

    final nextIndex = (_state.currentIndex + 1) % _state.banners.length;
    _updateState(_state.copyWith(currentIndex: nextIndex));
    _startRotation();
  }

  void _autoRetry() {
    _retryTimer?.cancel();

    final delay = min(pow(2, _retryAttempts).toInt(), 30);

    _retryTimer = Timer(Duration(seconds: delay), () {
      _retryAttempts++;
      if (_currentSlug != null) {
        loadBanners(_currentSlug!);
      }
    });
  }

  void _resetRetryCount() {
    _retryAttempts = 0;
    _retryTimer?.cancel();
  }

  void _listenToSse() {
    print('Listening to SSE events... (instance: ${hashCode})');
    _sseSubscription = _repository.getSyncEvents().listen(
      (_) {
        print('SSE event received, reloading banners... (instance: ${hashCode})');
        if (_currentSlug != null) {
          loadBanners(_currentSlug!);
        }
      },
      onError: (error) {
        print('SSE error: $error, reconnecting in 5 seconds... (instance: ${hashCode})');
        // Auto-reconnect after delay
        Future.delayed(Duration(seconds: 5), () {
          if (_currentSlug != null) {
            print('Reconnecting SSE...');
            _listenToSse();
          }
        });
      },
      onDone: () {
        print('SSE connection closed, reconnecting in 5 seconds... (instance: ${hashCode})');
        // Connection closed, reconnect
        Future.delayed(Duration(seconds: 5), () {
          if (_currentSlug != null) {
            print('Reconnecting SSE...');
            _listenToSse();
          }
        });
      },
    );
  }

  @override
  void dispose() {
    print('Disposing DisplayProvider (instance: ${hashCode})');
    _rotationTimer?.cancel();
    _retryTimer?.cancel();
    _sseSubscription?.cancel();
    super.dispose();
  }
}
