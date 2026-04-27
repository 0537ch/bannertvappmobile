import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:bannertvapp/data/models/banner_model.dart';

class VideoBanner extends StatefulWidget {
  final BannerModel banner;
  final VoidCallback onEnded;

  const VideoBanner({super.key, required this.banner, required this.onEnded});

  @override
  State<VideoBanner> createState() => _VideoBannerState();
}

class _VideoBannerState extends State<VideoBanner> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.banner.url),
    );

    try {
      await _controller.initialize();
      setState(() => _initialized = true);
      await _controller.play();
      _controller.setLooping(false);

      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          widget.onEnded();
        }
      });
    } catch (e) {
      setState(() => _initialized = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        if (kDebugMode)
          Positioned(
            bottom: 60,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.fast_forward, color: Colors.white),
                onPressed: () {
                  _controller.seekTo(_controller.value.duration);
                },
                tooltip: 'Skip to end',
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
