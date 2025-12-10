import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/transaction/view/add_transaction_screen.dart';
import 'package:fintrack/features/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintrack/features/auth/view/login_screen.dart';
import 'package:fintrack/features/auth/view/register_screen.dart';
import 'package:fintrack/features/splash/view/splash_screen.dart';
import 'package:fintrack/core/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/features/auth/provider/user_provider.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/features/budget/controllers/budget_provider.dart';

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        print("DEBUG: Auth Listener - User Signed Out. Resetting Providers...");
        if (mounted) {
          // Explicitly reset all providers to clear old user data
          // This prevents "Data Leak" where User B sees User A's data
          Provider.of<UserProvider>(context, listen: false).resetState();
          Provider.of<TransactionProvider>(context, listen: false).resetState();
          Provider.of<BudgetProvider>(context, listen: false).resetState();
        }
      }
    });
  }

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

      home: SupabaseConfig.client.auth.currentSession != null
          ? const HomeScreen()
          : const SplashScreen(),
    );
  }
}
