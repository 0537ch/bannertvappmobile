import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bannertvapp/presentation/display/providers/display_provider.dart';
import 'package:bannertvapp/presentation/display/widgets/image_banner.dart';
import 'package:bannertvapp/presentation/display/widgets/video_banner.dart';
import 'package:bannertvapp/presentation/display/widgets/banner_overlays.dart';
import 'package:bannertvapp/presentation/display/widgets/floating_settings_button.dart';
import 'package:bannertvapp/presentation/settings/screens/settings_screen.dart';
import 'package:bannertvapp/data/models/location_model.dart';

class DisplayScreen extends StatefulWidget {
  final LocationModel location;

  const DisplayScreen({super.key, required this.location});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> with WidgetsBindingObserver {
  late final DisplayProvider _displayProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ALWAYS reset instance first, then create new
    print('DisplayScreen initState - resetting provider');
    DisplayProvider.resetInstance();
    _displayProvider = DisplayProvider.instance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _displayProvider.loadBanners(widget.location.slug);
    });
  }

  // No longer needed - handled in initState/dispose

  @override
  void dispose() {
    print('DisplayScreen dispose - resetting provider');
    WidgetsBinding.instance.removeObserver(this);
    DisplayProvider.resetInstance();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListenableBuilder(
        listenable: _displayProvider,
        builder: (context, child) {
          final state = _displayProvider.state;

          return state.banners.isEmpty
              ? _buildEmptyState(state)
              : _buildBannerCarousel(state);
        },
      ),
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
          _displayProvider.loadBanners(widget.location.slug);
        },
      );
    }

    return ImageBanner(banner: banner);
  }
}
