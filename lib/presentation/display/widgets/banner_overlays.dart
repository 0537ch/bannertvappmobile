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
    if (state.slides.isEmpty) return SizedBox.shrink();

    return Stack(
      children: [
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
              '${state.currentIndex + 1}/${state.bannerCount}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
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
