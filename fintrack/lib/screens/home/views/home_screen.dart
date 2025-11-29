import 'package:fintrack/constants/constants.dart';
import 'package:fintrack/screens/home/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    context.watch<TransactionProvider>();

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: ColorPallete.black,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home, color: ColorPallete.green),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.history, color: ColorPallete.white),
            ),
            const SizedBox(width: 48),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.attach_money, color: ColorPallete.white),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person, color: ColorPallete.white),
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
              
              onPressed:(){
                Navigator.pushNamed(context, "/add");
              }, 
              child: const Icon(Icons.add, size: 28), 
            ),
          ),
        ),
      
      body: const MainScreen(),
    );
  }
}
