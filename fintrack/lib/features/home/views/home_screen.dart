import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/budget/view/anggaran_screen.dart';
import 'package:fintrack/features/home/views/main_screen.dart';
import 'package:fintrack/features/profile/view/profile_screen.dart';
import 'package:fintrack/features/statistic/view/stat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/features/auth/provider/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  var widgetList = [
    const MainScreen(),
    const StatScreen(),
    const AnggaranScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionProvider>().loadLatest();
        context.read<UserProvider>().loadUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TransactionProvider>(); // listen update

    return Scaffold(
      bottomNavigationBar: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color.fromARGB(255, 44, 44, 44), width: 0.8),
          ),
        ),
        child: BottomAppBar(
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
                  CupertinoIcons.home,
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
                  CupertinoIcons.graph_square,
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
                  Icons.person_2_outlined,
                  color: index == 3 ? ColorPallete.green : ColorPallete.white,
                ),
              ),
            ],
          ),
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
            onPressed: () => Navigator.pushNamed(context, "/add"),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),
      body: widgetList[index],
    );
  }
}
