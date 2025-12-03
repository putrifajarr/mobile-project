import 'dart:math' as math;

import 'package:fintrack/constants/constants.dart';

import 'package:fintrack/screens/history/history_screen.dart';
import 'package:fintrack/screens/history/widgets/history_item.dart';
import 'package:fintrack/screens/notification/notification_screen.dart';
import 'package:fintrack/utils/format_rupiah.dart';
import 'package:fintrack/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/features/transaction/views/add_transaction_screen.dart';
import 'package:fintrack/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return CircleAvatar(
                            radius: 20.0,
                            backgroundImage: userProvider.profilePhoto != null
                                ? FileImage(userProvider.profilePhoto!)
                                : const AssetImage('assets/profile.jpeg')
                                      as ImageProvider,
                          );
                        },
                      ),
                      SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              return Text(
                                userProvider.username,
                                style: const TextStyle(
                                  color: ColorPallete.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
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
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      size: 34,
                      color: ColorPallete.white,
                    ),
                    onPressed: () {
                      // Navigasi ke halaman Notifikasi
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
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
                      const Color.fromARGB(255, 210, 247, 186),
                      const Color.fromARGB(255, 184, 253, 131),
                      const Color.fromRGBO(158, 250, 88, 1),
                      const Color.fromARGB(255, 209, 255, 156),
                    ],
                    transform: GradientRotation(220 * (math.pi / 180)),
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
                          builder: (context) => HistoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Lihat semua",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: ColorPallete.grey,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),

              Expanded(
                child: transaksi.isEmpty
                    ? const EmptyState(message: 'Belum ada transaksi')
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: transaksi.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final t = transaksi[index];
                          return HistoryItem(
                            transaction: t,
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTransactionScreen(
                                    isEdit: true,
                                    existing: t,
                                  ),
                                ),
                              );
                            },
                            onDelete: () => provider.deleteTransaction(t.id),
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
