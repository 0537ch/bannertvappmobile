import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bannertvapp/data/models/banner_model.dart';
import 'package:bannertvapp/data/repositories/banner_repository_impl.dart';

class DisplayState {
  final List<BannerModel> slides;
  final List<BannerModel> banners;
  final int currentIndex;
  final int bannerCount;
  final bool loading;
  final bool refreshing;
  final bool hasLoadedOnce;
  final String? errorMessage;

  DisplayState({
    this.slides = const [],
    this.banners = const [],
    this.currentIndex = 0,
    this.bannerCount = 0,
    this.loading = true,
    this.refreshing = false,
    this.hasLoadedOnce = false,
    this.errorMessage,
  });

  DisplayState copyWith({
    List<BannerModel>? slides,
    List<BannerModel>? banners,
    int? currentIndex,
    int? bannerCount,
    bool? loading,
    bool? refreshing,
    bool? hasLoadedOnce,
    String? errorMessage,
  }) {
    return DisplayState(
      slides: slides ?? this.slides,
      banners: banners ?? this.banners,
      currentIndex: currentIndex ?? this.currentIndex,
      bannerCount: bannerCount ?? this.bannerCount,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DisplayNotifier extends Notifier<DisplayState> {
  Timer? _rotationTimer;
  Timer? _retryTimer;
  int _retryAttempts = 0;
  String? _currentSlug;
  StreamSubscription? _sseSubscription;

  final BannerRepositoryImpl _repository = BannerRepositoryImpl();

  @override
  DisplayState build() {
    debugPrint('DisplayNotifier.build() START (hashCode: $hashCode)');
    ref.onDispose(() {
      debugPrint('ref.onDispose() CALLED (hashCode: $hashCode)');
      _rotationTimer?.cancel();
      debugPrint('  Rotation timer cancelled');
      _retryTimer?.cancel();
      debugPrint('  Retry timer cancelled');
      _sseSubscription?.cancel();
      debugPrint('  SSE subscription cancelled');
      debugPrint('DISPOSE COMPLETE (hashCode: $hashCode)');
    });
    _listenToSse();
    return DisplayState();
  }

  List<BannerModel> _expandBanners(List<BannerModel> banners) {
    final slides = <BannerModel>[];
    for (final banner in banners) {
      if (banner.type == 'event' && banner.eventEntries != null && banner.eventEntries!.isNotEmpty) {
        for (final entry in banner.eventEntries!) {
          slides.add(BannerModel(
            id: int.parse('${banner.id}${entry.id}'),
            type: 'event',
            url: entry.pictureUrl,
            duration: entry.duration ?? banner.duration,
            title: entry.name,
            description: null,
            imageSource: null,
            position: 0,
            active: true,
            eventEntries: null,
            eventEntryId: entry.id,
          ));
        }
      } else {
        slides.add(banner);
      }
    }
    return slides;
  }

  Future<void> loadBanners(String slug) async {
    debugPrint('Loading banners for slug: $slug (instance: $hashCode)');
    _currentSlug = slug;

    if (!state.hasLoadedOnce) {
      state = state.copyWith(loading: true, errorMessage: null);
    } else {
      debugPrint('Refreshing banners...');
      state = state.copyWith(refreshing: true);
      await Future.delayed(Duration(milliseconds: 500));
    }

    try {
      final banners = await _repository.getBanners(slug);
      debugPrint('Loaded ${banners.length} banners (instance: $hashCode)');

      if (banners.isEmpty) {
        state = state.copyWith(
          banners: [],
          slides: [],
          currentIndex: 0,
          bannerCount: 0,
          loading: false,
          refreshing: false,
          hasLoadedOnce: true,
        );
        return;
      }

      final slides = _expandBanners(banners);
      final safeIndex = state.currentIndex < slides.length ? state.currentIndex : 0;

      state = state.copyWith(
        banners: banners,
        slides: slides,
        currentIndex: safeIndex,
        bannerCount: banners.length,
        loading: false,
        refreshing: false,
        hasLoadedOnce: true,
        errorMessage: null,
      );

      _resetRetryCount();
      _startRotation();
    } catch (e) {
      debugPrint('Error loading banners: $e');
      if (!state.hasLoadedOnce) {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Failed to load banners',
        );
        _autoRetry();
      } else {
        state = state.copyWith(refreshing: false);
        _autoRetry();
      }
    }
  }

  void _startRotation() {
    _rotationTimer?.cancel();

    if (state.slides.isEmpty) return;

    final currentSlide = state.slides[state.currentIndex];

    if (currentSlide.type == 'video') {
      return;
    }

    final duration = currentSlide.duration > 0 ? currentSlide.duration : 10;

    _rotationTimer = Timer(Duration(seconds: duration), () {
      _nextSlide();
    });
  }

  void _nextSlide() {
    if (state.slides.isEmpty) return;

    final nextIndex = (state.currentIndex + 1) % state.slides.length;
    state = state.copyWith(currentIndex: nextIndex);
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

  void _listenToSse() async {
    debugPrint('STARTING SSE CONNECTION (hashCode: $hashCode)');
    final stream = await _repository.getSyncEvents();
    _sseSubscription = stream.listen(
      (_) {
        debugPrint('SSE EVENT RECEIVED (hashCode: $hashCode)');
        if (_currentSlug != null) {
          loadBanners(_currentSlug!);
        }
      },
      onError: (error) {
        debugPrint('SSE ERROR: $error (hashCode: $hashCode)');
        debugPrint('Reconnecting in 5 seconds...');
        Future.delayed(Duration(seconds: 5), () {
          if (_currentSlug != null) {
            debugPrint('SSE RECONNECTING...');
            _listenToSse();
          }
        });
      },
      onDone: () {
        debugPrint('SSE CONNECTION CLOSED (hashCode: $hashCode)');
        debugPrint('Reconnecting in 5 seconds...');
        Future.delayed(Duration(seconds: 5), () {
          if (_currentSlug != null) {
            debugPrint('SSE RECONNECTING...');
            _listenToSse();
          }
        });
      },
    );
    debugPrint('SSE LISTENER ATTACHED (hashCode: $hashCode)');
  }

}

final displayProvider = NotifierProvider<DisplayNotifier, DisplayState>(DisplayNotifier.new);
