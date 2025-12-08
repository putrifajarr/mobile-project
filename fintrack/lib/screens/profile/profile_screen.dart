import 'package:fintrack/constants/constants.dart';
import 'package:fintrack/providers/user_provider.dart';
import 'package:fintrack/screens/profile/widgets/edit_photo_bottom_sheet.dart';
import 'package:fintrack/screens/profile/widgets/edit_username_dialog.dart';
import 'package:fintrack/screens/profile/widgets/logout_dialog.dart';
import 'package:fintrack/screens/profile/widgets/profile_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Profil Saya",
                  style: TextStyle(
                    color: ColorPallete.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40.0),

            Column(
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return CircleAvatar(
                      radius: 50.0,
                      backgroundImage: userProvider.profilePhoto != null
                          ? FileImage(userProvider.profilePhoto!)
                          : const AssetImage('assets/profile.jpeg')
                                as ImageProvider,
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return Text(
                      userProvider.username,
                      style: const TextStyle(
                        color: ColorPallete.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  "Putribaikhati@gmail.com",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40.0),

            Row(
              children: [
                Expanded(
                  child: ProfileActionButton(
                    icon: Icons.camera_alt_outlined,
                    label: "Ubah Foto Profil",
                    onTap: () => showEditPhotoBottomSheet(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ProfileActionButton(
                    icon: Icons.alternate_email,
                    label: "Edit Username",
                    onTap: () => showEditUsernameDialog(context),
                  ),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.14),
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Keluar",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 68),
          ],
        ),
      ),
    );
  }
}
