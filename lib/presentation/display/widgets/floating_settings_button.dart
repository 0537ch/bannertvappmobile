import 'package:flutter/material.dart';
import 'dart:async';

class FloatingSettingsButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FloatingSettingsButton({super.key, required this.onPressed});

  @override
  State<FloatingSettingsButton> createState() => _FloatingSettingsButtonState();
}

class _FloatingSettingsButtonState extends State<FloatingSettingsButton> {
  Timer? _fadeTimer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _startFadeTimer();
  }

  void _startFadeTimer() {
    _fadeTimer?.cancel();
    setState(() => _visible = true);

    _fadeTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  void _showAndReset() {
    _startFadeTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _visible
          ? () {
              widget.onPressed();
              _startFadeTimer();
            }
          : _showAndReset,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: Icon(
            Icons.settings,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }
}
