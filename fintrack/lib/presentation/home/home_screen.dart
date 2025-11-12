import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/core/widgets/line_chart.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.black,
      appBar: AppBar(
        backgroundColor: ColorPallete.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: AssetImage('assets/profile.jpeg'),
                ),
                SizedBox(width: 12.0),
                Text(
                  "Putri",
                  style: TextStyle(
                    color: ColorPallete.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.notifications_none_outlined,
              size: 28,
              color: ColorPallete.white,
            ),
          ],
        ),
      ),
    body: ListView(
      children: [
        Container(
          margin: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 168, 239, 123), const Color.fromARGB(255, 140, 238, 84), const Color.fromARGB(255, 140, 238, 84),const Color.fromARGB(255, 187, 241, 139)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
            ),
            borderRadius: BorderRadius.circular(12)
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4.2,
            children: [
              Text(
                "Total uang",
                style: TextStyle(
                  fontSize: 18.0,
                  color: ColorPallete.black
                ),
              ),
              Text(
                "RP120.000.000",
                style: TextStyle(
                  color: ColorPallete.black,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600
                ),
              )
            ],
          ),
        ),
        
        // grafik
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: ColorPallete.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tren Keuangan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                DoubleLineChart(), // 🟩 panggil widget grafik di sini
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }
}