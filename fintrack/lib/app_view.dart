import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/transaction/view/add_transaction_screen.dart';
import 'package:fintrack/features/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintrack/features/auth/view/login_screen.dart';
import 'package:fintrack/features/auth/view/register_screen.dart';

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
        scaffoldBackgroundColor: ColorPallete.black,
        colorScheme: ColorScheme.dark(
          primary: ColorPallete.green,
          secondary: ColorPallete.greenLight,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],

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
