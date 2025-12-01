import 'package:fintrack/constants/constants.dart';
import 'package:fintrack/screens/anggaran/anggaran.dart';
import 'package:fintrack/screens/home/views/main_screen.dart';
import 'package:fintrack/screens/profile/profile.dart';
import 'package:fintrack/screens/stat/stat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var widgetList = [
    const MainScreen(),
    const StatScreen(),
    const AnggaranScreen(),
    const ProfileScreen(),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    context.watch<TransactionProvider>();

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: ColorPallete.black,
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.only(top: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  index = 0;
                });
              },
              icon: Icon(
                Icons.home,
                color: index == 0 ? ColorPallete.green : ColorPallete.white,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  index = 1;
                });
              },
              icon: Icon(
                Icons.history,
                color: index == 1 ? ColorPallete.green : ColorPallete.white,
              ),
            ),
            const SizedBox(width: 48),
            IconButton(
              onPressed: () {
                setState(() {
                  index = 2;
                });
              },
              icon: Icon(
                Icons.attach_money,
                color: index == 2 ? ColorPallete.green : ColorPallete.white,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  index = 3;
                });
              },
              icon: Icon(
                Icons.person,
                color: index == 3 ? ColorPallete.green : ColorPallete.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                ColorPallete.green,
                const Color(0xFFAEF26B),
                ColorPallete.greenLight,
              ],
            ),
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const CircleBorder(),

            onPressed: () {
              Navigator.pushNamed(context, "/add");
            },
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),

      body: widgetList[index],
    );
  }
}
