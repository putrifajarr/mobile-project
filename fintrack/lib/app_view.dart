import 'dart:math' as math;

import 'package:fintrack/constants/constants.dart';
import 'package:fintrack/screens/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FinTrack",
      theme: ThemeData(
        textTheme: GoogleFonts.ubuntuTextTheme().apply(
          bodyColor: Colors.white,   // warna default teks
          displayColor: Colors.white, // warna untuk heading/title
        ),
        scaffoldBackgroundColor: Colors.transparent, 
        colorScheme: ColorScheme.dark(
          primary: ColorPallete.green,
          secondary: ColorPallete.greenLight,
          onSurface: Colors.white, 
        ),
      ),
    
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                 Color.fromRGBO(52, 89, 9, 1), 
                 Color.fromRGBO(30, 50, 9, 0.6), 
                 Color.fromRGBO(18, 29, 6, 0.4), 
                 Color.fromRGBO(18, 29, 6, 0.2),  
                 Color.fromRGBO(10, 16, 3, 0.2),  
                 Color.fromRGBO(10, 16, 3, 0.0),  
              ],
              transform: GradientRotation(1 * (math.pi / 180)),
            ),
          ),
          child: child,
        );
      },
      home: const HomeScreen(),
    );
  }
}