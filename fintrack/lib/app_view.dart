import 'dart:math' as math;
import 'package:fintrack/constants/constants.dart';
import 'package:fintrack/features/transaction/views/add_transaction_screen.dart';
import 'package:fintrack/screens/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';


class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FinTrack",
      theme: ThemeData(
        useMaterial3: false,
        textTheme: GoogleFonts.ubuntuTextTheme().apply(
          displayColor: ColorPallete.white,
          bodyColor: ColorPallete.white,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.dark(
          primary: ColorPallete.green,
          secondary: ColorPallete.greenLight,
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
              transform: GradientRotation(6* (math.pi / 180)),
            ),
          ),
          child: child,
        );
      },

      // ROUTES WAJIB
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const HomeScreen(),
        '/add': (context) => const AddTransactionScreen(),
      },

      home: const LoginScreen(),
    );
  }
}
