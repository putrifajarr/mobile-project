import 'package:fintrack/features/auth/view/login_screen.dart';
import 'package:fintrack/core/supabase_config.dart';
import 'package:flutter/material.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF0C0C0C),
      elevation: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color.fromARGB(255, 89, 89, 89).withOpacity(0.6),
        ),
      ),
      title: const Column(
        children: [
          SizedBox(height: 8),
          Icon(Icons.logout_rounded, color: Color(0xFFEE3E3E), size: 48),
          SizedBox(height: 16),
          Text(
            "Konfirmasi Keluar",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: const Text(
        "Apakah Anda yakin ingin mengakhiri sesi dan keluar dari aplikasi?",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 25, 25, 25),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await SupabaseConfig.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 199, 52, 52),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Keluar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
