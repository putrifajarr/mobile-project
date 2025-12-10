import 'dart:math' as math;

import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/auth/provider/user_provider.dart';
import 'package:fintrack/features/transaction/view/history/history_screen.dart';
import 'package:fintrack/features/transaction/view/add_transaction_screen.dart';
import 'package:fintrack/features/transaction/view/history/widgets/history_item.dart';
import 'package:fintrack/features/notification/view/notification_screen.dart';
import 'package:fintrack/core/utils/format_rupiah.dart';
import 'package:fintrack/core/utils/snackbar_utils.dart';
import 'package:fintrack/core/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/core/messaging_service.dart';
import 'package:fintrack/features/notification/providers/notification_provider.dart';
// Tambahan untuk memperbaiki error: import yang tidak lengkap/kosong
// import 'package:fintrack/'; <--- BARIS INI DIHAPUS

// --- TAMBAHAN WAJIB (Mengatasi Anggaran tidak berubah) ---
import 'package:fintrack/features/budget/controllers/budget_provider.dart';
// --- END TAMBAHAN ---

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
      // 1. Memuat Transaksi (Memicu refresh Transaksi Terbaru)
      context.read<TransactionProvider>().loadLatest();

      // 2. Memuat Data Pengguna
      context.read<UserProvider>().loadUserData();

      // 3. Memuat Anggaran (Memastikan persentase Anggaran berubah)
      // Asumsi fungsi di BudgetProvider Anda adalah 'loadBudgets'
      context.read<BudgetProvider>().loadBudgets();

      // Fetch Notifications
      context.read<NotificationProvider>().fetchNotifications();

      // 4. FASE A & B: PANGGIL SERVICE NOTIFIKASI
      final messagingService = MessagingService();
      messagingService.saveFCMToken();
      messagingService.setupInteractions(context);
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
              const Color.fromRGBO(52, 89, 9, 1),
              const Color.fromRGBO(30, 50, 9, 0.6),
              const Color.fromRGBO(18, 29, 6, 0.4),
              const Color.fromRGBO(18, 29, 6, 0.2),
              const Color.fromRGBO(10, 16, 3, 0.2),
              const Color.fromRGBO(10, 16, 3, 0.0),
            ],
            transform: GradientRotation(6 * (math.pi / 180)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 52.0, left: 16.0, right: 16.0),
          child: SingleChildScrollView(
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
                            ImageProvider backgroundImage;
                            if (userProvider.profilePhoto != null) {
                              backgroundImage = FileImage(
                                userProvider.profilePhoto!,
                              );
                            } else if (userProvider.profilePhotoUrl != null &&
                                userProvider.profilePhotoUrl!.isNotEmpty) {
                              backgroundImage = NetworkImage(
                                userProvider.profilePhotoUrl!,
                              );
                            } else {
                              backgroundImage = const AssetImage(
                                'assets/profile.jpeg',
                              );
                            }
                            return CircleAvatar(
                              radius: 20.0,
                              backgroundImage: backgroundImage,
                            );
                          },
                        ),
                        const SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.watch<UserProvider>().username,
                              style: const TextStyle(
                                color: ColorPallete.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
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
                      child: Consumer<NotificationProvider>(
                        builder: (context, notifProvider, child) {
                          return Stack(
                            children: [
                              const Icon(
                                Icons.notifications_none_outlined,
                                size: 34,
                                color: ColorPallete.white,
                              ),
                              if (notifProvider.unreadCount > 0)
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 10,
                                      minHeight: 10,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),

                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 28,
                  ),
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
                    children: [
                      const Text(
                        "Total Uang",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: ColorPallete.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        formatRupiah(totalUang),
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.black,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD8F5C7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.arrow_down,
                                    color: Color(0xFF2D4C2D),
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Pendapatan",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: ColorPallete.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    formatRupiah(totalIncome),
                                    style: const TextStyle(
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
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD8F5C7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.arrow_up,
                                    color: Color(0xFFD84747),
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Pengeluaran",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: ColorPallete.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    formatRupiah(totalExpense),
                                    style: const TextStyle(
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
                const SizedBox(height: 36.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
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
                      child: const Text(
                        "Lihat semua",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: ColorPallete.grey,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                transaksi.isEmpty
                    ? const SizedBox(height: 300, child: EmptyState())
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: math.min(transaksi.length, 15),
                        itemBuilder: (context, index) {
                          final t = transaksi[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HistoryItem(
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
                              onDelete: () async {
                                final deletedTransaction = t;
                                await provider.deleteTransaction(t.id);
                                if (context.mounted) {
                                  showUndoSnackBar(
                                    context,
                                    message: 'Transaksi berhasil dihapus',
                                    onUndo: () {
                                      provider.add(deletedTransaction, context);
                                    },
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
