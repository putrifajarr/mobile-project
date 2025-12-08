import 'dart:io';
import 'package:flutter/material.dart';

import 'package:fintrack/core/supabase_config.dart';

class UserProvider extends ChangeNotifier {
  String _username = "Hamba Allah";
  String _email = "";
  File? _profilePhoto;
  String? _profilePhotoUrl;

  String get username => _username;
  String get email => _email;
  File? get profilePhoto => _profilePhoto;
  String? get profilePhotoUrl => _profilePhotoUrl;

  Future<void> loadUserData() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user != null) {
      _email = user.email ?? "";

      try {
        final data = await SupabaseConfig.client
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle(); // Use maybeSingle to avoid exception if row missing

        if (data != null) {
          _username = data['name'] ?? "User";
          _profilePhotoUrl = data['photo_url'];
          _profilePhoto = null;
        } else {
          // Row missing. Could maintain default "Hamba Allah" or try to create it?
          // Let's keep defaults. The upsert methods will create it on first edit.
          print("DEBUG: User row not found in table. Using defaults.");
        }
      } catch (e) {
        print("DEBUG: Failed to load user data: $e");
      }
      notifyListeners();
    }
  }

  Future<void> updateUsername(String newUsername) async {
    final user = SupabaseConfig.client.auth.currentUser;
    print(
      "DEBUG: updateUsername called. User: ${user?.id}, New Name: $newUsername",
    );

    if (user != null) {
      try {
        print("DEBUG: Attempting to UPSERT users table...");
        await SupabaseConfig.client.from('users').upsert({
          'id': user.id,
          'email': user.email, // Ensure email is present
          'name': newUsername,
        });

        print("DEBUG: Supabase upsert success. Updating local state.");
        _username = newUsername;
        notifyListeners();
      } catch (e) {
        print("DEBUG: Failed to update username: $e");
        rethrow;
      }
    } else {
      print("DEBUG: User is null! Cannot update.");
    }
  }

  Future<void> updateProfilePhoto(File newPhoto) async {
    final user = SupabaseConfig.client.auth.currentUser;
    print("DEBUG: updateProfilePhoto called. User: ${user?.id}");

    if (user != null) {
      try {
        final fileName =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        print("DEBUG: Uploading file to avatars/$fileName");

        await SupabaseConfig.client.storage
            .from('avatars')
            .upload(fileName, newPhoto);

        // Get Public URL
        final imageUrl = SupabaseConfig.client.storage
            .from('avatars')
            .getPublicUrl(fileName);

        print("DEBUG: File uploaded. URL: $imageUrl");
        print("DEBUG: Updating photo_url in users table (UPSERT)...");

        final Map<String, dynamic> data = {
          'id': user.id,
          'email': user.email,
          'photo_url': imageUrl,
        };

        if (_username.isNotEmpty && _username != "Hamba Allah") {
          data['name'] = _username;
        }

        // Update user table
        await SupabaseConfig.client.from('users').upsert(data);

        print("DEBUG: Supabase upsert success. Updating local state.");
        _profilePhoto = newPhoto;
        _profilePhotoUrl = imageUrl;
        notifyListeners();
      } catch (e) {
        print("DEBUG: Failed to update profile photo: $e");
      }
    } else {
      print("DEBUG: User is null! Cannot update photo.");
    }
  }

  Future<void> removeProfilePhoto() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user != null) {
      try {
        await SupabaseConfig.client
            .from('users')
            .update({'photo_url': null}) // Use photo_url
            .eq('id', user.id);

        _profilePhoto = null;
        _profilePhotoUrl = null;
        notifyListeners();
      } catch (e) {
        print("DEBUG: Failed to remove profile photo: $e");
      }
    }
  }
}
