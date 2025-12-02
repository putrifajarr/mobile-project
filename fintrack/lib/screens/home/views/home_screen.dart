import 'package:fintrack/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // <--- fix CupertinoIcons
import 'package:provider/provider.dart';

import 'main_screen.dart';
import 'stat.dart';
import 'anggaran.dart';
import 'profile.dart';

import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';

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
    // Fix use_build_context_synchronously warning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) {
        context.read<TransactionProvider>().loadLatest();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TransactionProvider>(); // listen update

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: ColorPallete.black,
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.only(top: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => setState(() => index = 0),
              icon: Icon(
                CupertinoIcons.home,
                color: index == 0 ? ColorPallete.green : ColorPallete.white,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => index = 1),
              icon: Icon(
                CupertinoIcons.graph_square,
                color: index == 1 ? ColorPallete.green : ColorPallete.white,
              ),
            ),
            const SizedBox(width: 48),
            IconButton(
              onPressed: () => setState(() => index = 2),
              icon: Icon(
                Icons.attach_money,
                color: index == 2 ? ColorPallete.green : ColorPallete.white,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => index = 3),
              icon: Icon(
                Icons.person_2_outlined,
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
            onPressed: () => Navigator.pushNamed(context, "/add"),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),
      body: widgetList[index],
    );
  }
}
