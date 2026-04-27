import 'package:flutter/material.dart';
import 'package:bannertvapp/presentation/display/providers/display_provider.dart';

class BannerOverlays extends StatelessWidget {
  final String locationName;
  final DisplayState state;

  const BannerOverlays({
    super.key,
    required this.locationName,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.banners.isEmpty) return SizedBox.shrink();

    final currentBanner = state.banners[state.currentIndex];

    return Stack(
      children: [
        // Location name (top-left)
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              locationName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),

        // Counter (bottom-left)
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${state.currentIndex + 1}/${state.banners.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),

        // Title and description (for images only)
        if (currentBanner.type == 'image' &&
            (currentBanner.title != null || currentBanner.description != null))
          Positioned(
            bottom: 16,
            left: 100,
            child: Container(
              padding: EdgeInsets.all(16),
              constraints: BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentBanner.title != null)
                    Text(
                      currentBanner.title!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (currentBanner.description != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        currentBanner.description!,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Refreshing indicator
        if (state.refreshing)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Refreshing...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
