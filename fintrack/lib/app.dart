import 'package:fintrack/app_view.dart';
import 'package:fintrack/features/budget/controllers/budget_provider.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/features/auth/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
      ],
      child: const MyAppView(),
    );
  }
}
