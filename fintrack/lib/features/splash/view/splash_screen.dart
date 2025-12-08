import 'dart:async';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:fintrack/core/supabase_config.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/spalsh_screen.mp4')
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
        _controller.setLooping(false);
      });

    // Listen for video end
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        _navigateAttempt();
      }
    });
  }

  void _navigateAttempt() async {
    // Only navigate once video is done.
    // Also we need to know WHERE to navigate (Home or Login)

    // Check Supabase Session
    final session = SupabaseConfig.client.auth.currentSession;

    if (mounted) {
      if (session != null) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Match app theme
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const SizedBox(), // Or a loader/logo image while video prepares
      ),
    );
  }
}
