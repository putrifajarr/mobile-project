import 'dart:math' as math;

import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/auth/provider/user_provider.dart';
import 'package:fintrack/features/transaction/view/history/history_screen.dart';
import 'package:fintrack/features/notification/view/notification_screen.dart';
import 'package:fintrack/core/utils/format_rupiah.dart';
import 'package:fintrack/core/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<TransactionProvider>().loadLatest();
      // Load User Data (Profile)
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final totalUang = provider.totalBalance;
    final totalIncome = provider.totalIncome;
    final totalExpense = provider.totalExpense;
    final transaksi = provider.transactions;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromRGBO(52, 89, 9, 1),
              Color.fromRGBO(30, 50, 9, 0.6),
              Color.fromRGBO(18, 29, 6, 0.4),
              Color.fromRGBO(18, 29, 6, 0.2),
              Color.fromRGBO(10, 16, 3, 0.2),
              Color.fromRGBO(10, 16, 3, 0.0),
            ],
            transform: GradientRotation(6 * (math.pi / 180)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 52.0, left: 16.0, right: 16.0),
          child: Column(
            children: [
              Row(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.watch<UserProvider>().username,
                            style: TextStyle(
                              color: ColorPallete.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Otw kaya",
                            style: TextStyle(
                              color: ColorPallete.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.notifications_none_outlined,
                      size: 34,
                      color: ColorPallete.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),

              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(255, 233, 254, 220),
                      const Color.fromARGB(255, 179, 255, 116),
                      const Color.fromARGB(255, 166, 255, 103),
                      const Color.fromARGB(255, 218, 255, 177),
                    ],
                    transform: GradientRotation(200 * (math.pi / 180)),
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  spacing: 4,
                  children: [
                    Text(
                      "Total Uang",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: ColorPallete.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formatRupiah(totalUang),
                      // "Rp0",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w600,
                        color: ColorPallete.black,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD8F5C7),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.arrow_down,
                                  color: const Color(0xFF2D4C2D),
                                  size: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(
                                  "Pendapatan",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: ColorPallete.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  formatRupiah(totalIncome),
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: ColorPallete.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD8F5C7),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.arrow_up,
                                  color: const Color(0xFFD84747),
                                  size: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(
                                  "Pengeluaran",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: ColorPallete.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  formatRupiah(totalExpense),
                                  // "Rp0",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: ColorPallete.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Transaksi Terbaru",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Lihat semua",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: ColorPallete.green,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: transaksi.isEmpty
                    ? EmptyState()
                    : ListView.builder(
                        itemCount: transaksi.length,
                        itemBuilder: (context, index) {
                          final t = transaksi[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: ColorPallete.black,
                              borderRadius: BorderRadius.circular(12.0),
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      t.category,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      t.description,
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),

                                Text(
                                  "Rp ${t.amount}",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: t.type == "income"
                                        ? ColorPallete.greenLight
                                        : ColorPallete.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
