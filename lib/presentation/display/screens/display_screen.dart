import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bannertvapp/presentation/display/providers/display_provider.dart';
import 'package:bannertvapp/presentation/display/widgets/image_banner.dart';
import 'package:bannertvapp/presentation/display/widgets/video_banner.dart';
import 'package:bannertvapp/presentation/display/widgets/banner_overlays.dart';
import 'package:bannertvapp/presentation/display/widgets/floating_settings_button.dart';
import 'package:bannertvapp/presentation/display/widgets/event_banner.dart';
import 'package:bannertvapp/presentation/settings/screens/settings_screen.dart';
import 'package:bannertvapp/data/models/location_model.dart';
import 'package:bannertvapp/data/models/banner_model.dart';

class DisplayScreen extends ConsumerStatefulWidget {
  final LocationModel location;

  const DisplayScreen({super.key, required this.location});

  @override
  ConsumerState<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends ConsumerState<DisplayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(displayProvider.notifier).loadBanners(widget.location.slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ref.watch(displayProvider).banners.isEmpty
          ? _buildEmptyState(ref.watch(displayProvider))
          : _buildBannerCarousel(ref.watch(displayProvider)),
    );
  }

  Widget _buildEmptyState(DisplayState state) {
    if (state.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              'Retrying...',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Content',
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
          SizedBox(height: 8),
          Text(
            widget.location.name,
            style: TextStyle(color: Colors.grey, fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel(DisplayState state) {
    final currentSlide = state.slides[state.currentIndex];
    final currentBannerIndex = _findBannerIndex(state, state.currentIndex);
    final banner = state.banners[currentBannerIndex];

    return Stack(
      children: [
        Positioned.fill(
          child: _buildBanner(currentSlide, banner),
        ),
        BannerOverlays(
          locationName: widget.location.name,
          state: state,
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingSettingsButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  int _findBannerIndex(DisplayState state, int slideIndex) {
    int bannerIdx = 0;
    int slideCount = 0;
    for (int i = 0; i < state.banners.length; i++) {
      final b = state.banners[i];
      int count = 1;
      if (b.type == 'event' && b.eventEntries != null && b.eventEntries!.isNotEmpty) {
        count = b.eventEntries!.length;
      }
      if (slideIndex < slideCount + count) return i;
      slideCount += count;
    }
    return 0;
  }

  Widget _buildBanner(BannerModel slide, BannerModel originalBanner) {
    if (slide.type == 'event') {
      return EventBanner(
        entries: originalBanner.eventEntries ?? [],
        currentIndex: _findEntryIndex(originalBanner, slide.eventEntryId),
      );
    }
    if (slide.type == 'video') {
      return VideoBanner(
        banner: slide,
        onEnded: () {
          ref.read(displayProvider.notifier).loadBanners(widget.location.slug);
        },
      );
    }
    return ImageBanner(banner: slide);
  }

  int _findEntryIndex(BannerModel banner, int? eventEntryId) {
    if (banner.eventEntries == null || eventEntryId == null) return 0;
    for (int i = 0; i < banner.eventEntries!.length; i++) {
      if (banner.eventEntries![i].id == eventEntryId) return i;
    }
    return 0;
  }
}
