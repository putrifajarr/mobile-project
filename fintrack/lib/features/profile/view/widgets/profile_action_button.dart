import 'package:fintrack/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ColorPallete.blackLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromARGB(255, 59, 59, 59)),
        ),
        child: Column(
          children: [
            Icon(icon, color: ColorPallete.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: ColorPallete.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
