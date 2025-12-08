import 'dart:io';
import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/auth/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

void showEditPhotoBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: ColorPallete.blackLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Ubah Foto Profil",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Pilih sumber foto",
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildBottomSheetOption(
              icon: Icons.camera_alt_rounded,
              label: "Ambil Foto",
              onTap: () => _pickImage(context, ImageSource.camera),
            ),
            const SizedBox(height: 16),
            _buildBottomSheetOption(
              icon: Icons.photo_library_rounded,
              label: "Pilih dari Galeri",
              onTap: () => _pickImage(context, ImageSource.gallery),
            ),
            const SizedBox(height: 16),
            _buildBottomSheetOption(
              icon: Icons.delete_outline_rounded,
              label: "Hapus Foto",
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).removeProfilePhoto();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Foto profil dihapus"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildBottomSheetOption({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  bool isDestructive = false,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive
              ? Colors.redAccent.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? Colors.redAccent : ColorPallete.green,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.redAccent : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.withOpacity(0.5),
            size: 20,
          ),
        ],
      ),
    ),
  );
}

Future<void> _pickImage(BuildContext context, ImageSource source) async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null && context.mounted) {
      Navigator.pop(context);
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).updateProfilePhoto(File(image.path));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Foto profil berhasil diperbarui!",
            style: TextStyle(
              color: ColorPallete.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Color(0xFFA4FC74),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    debugPrint('Error picking image: $e');
  }
}
