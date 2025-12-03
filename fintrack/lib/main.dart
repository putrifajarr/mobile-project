// import 'package:fintrack/home_screen.dart';
import 'package:fintrack/app.dart';
import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}
