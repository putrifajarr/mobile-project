import 'dart:io';
import 'package:flutter/material.dart';

import 'package:fintrack/core/supabase_config.dart';

class UserProvider extends ChangeNotifier {
  String _username = "Hamba Allah";
  String _email = "";
  File? _profilePhoto;

  String get username => _username;
  String get email => _email;
  File? get profilePhoto => _profilePhoto;

  Future<void> loadUserData() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user != null) {
      _email = user.email ?? "";

      try {
        final data = await SupabaseConfig.client
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        _username = data['name'] ?? "User";
      } catch (e) {
        print("DEBUG: Failed to load user data: $e");
      }
      notifyListeners();
    }
  }

  void updateUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void updateProfilePhoto(File newPhoto) {
    _profilePhoto = newPhoto;
    notifyListeners();
  }

  void removeProfilePhoto() {
    _profilePhoto = null;
    notifyListeners();
  }
}
