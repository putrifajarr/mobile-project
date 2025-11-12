import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on_outlined)
        )
      ],
    );
  }
}