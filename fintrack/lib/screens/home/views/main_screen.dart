import 'dart:math' as math;

import 'package:fintrack/constants/constants.dart';
import 'package:fintrack/data/data.dart';
import 'package:fintrack/utils/format_rupiah.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                          "Putri",
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
                Icon(
                  Icons.notifications_none_outlined,
                  size: 34,
                  color: ColorPallete.white,
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
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),
                ),
                Text(
                  "Lihat semua",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: ColorPallete.green,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: transaksi.isEmpty
                  ? Text("Belum ada transaksi")
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
    );
  }
}
