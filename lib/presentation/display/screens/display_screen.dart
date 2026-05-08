import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bannertvapp/presentation/display/providers/display_provider.dart';
import 'package:bannertvapp/presentation/display/widgets/image_banner.dart';
import 'package:bannertvapp/presentation/display/widgets/video_banner.dart';
import 'package:bannertvapp/presentation/display/widgets/banner_overlays.dart';
import 'package:bannertvapp/presentation/display/widgets/floating_settings_button.dart';
import 'package:bannertvapp/presentation/settings/screens/settings_screen.dart';
import 'package:bannertvapp/data/models/location_model.dart';

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
    final currentBanner = state.banners[state.currentIndex];

    return Stack(
      children: [
        // Banner content
        Positioned.fill(
          child: _buildBanner(currentBanner),
        ),

        // Overlays
        BannerOverlays(
          locationName: widget.location.name,
          state: state,
        ),

        // Settings button (bottom-right)
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

  Widget _buildBanner(dynamic banner) {
    if (banner.type == 'video') {
      return VideoBanner(
        banner: banner,
        onEnded: () {
          ref.read(displayProvider.notifier).loadBanners(widget.location.slug);
        },
      );
    }

    return ImageBanner(banner: banner);
  }
}
