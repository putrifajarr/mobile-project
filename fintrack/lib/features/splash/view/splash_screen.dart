import 'dart:async';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/core/supabase_config.dart';
import 'package:fintrack/features/auth/provider/user_provider.dart';

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

  Future<void> _navigateAttempt() async {
    final session = SupabaseConfig.client.auth.currentSession;

    if (mounted) {
      if (session != null) {
        debugPrint("Session found! Loading user data...");
        await context.read<UserProvider>().loadUserData();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
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
      backgroundColor: Colors.black,
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const SizedBox(),
      ),
    );
  }
}
