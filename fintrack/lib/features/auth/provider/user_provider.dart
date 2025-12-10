import 'dart:io';
import 'package:flutter/material.dart';

import 'package:fintrack/core/supabase_config.dart';

class UserProvider extends ChangeNotifier {
  String _username = "User";
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
            .maybeSingle();

        if (data != null) {
          _username = data['name'] ?? "User";
          _profilePhotoUrl = data['photo_url'];
          _profilePhoto = null;
        } else {
          print("DEBUG: User row not found in table. Creating default row...");

          // GENERATE USERNAME FROM EMAIL
          // Example: "putrifajarromadhon@gmail.com" -> "Putrifajarromadhon"
          String defaultName = "User";
          if (_email.isNotEmpty) {
            final namePart = _email.split('@').first;
            // Capitalize first letter (optional, looks nicer)
            defaultName = namePart.isNotEmpty
                ? "${namePart[0].toUpperCase()}${namePart.substring(1)}"
                : "User";
          }

          try {
            await SupabaseConfig.client.from('users').upsert({
              'id': user.id,
              'email': user.email,
              'name': defaultName,
              'created_at': DateTime.now().toIso8601String(),
            });
            _username = defaultName;
            print(
              "DEBUG: User row created successfully with name: $defaultName",
            );
          } catch (insertError) {
            print("DEBUG: Failed to create user row: $insertError");

            // HANDLE CONFLICT: If Email exists but ID is different
            if (insertError.toString().contains("users_email_key")) {
              print(
                "DEBUG: Detected orphaned row with same email. Claiming it...",
              );
              try {
                // Update the EXISTING row with this email to have the NEW ID
                await SupabaseConfig.client
                    .from('users')
                    .update({'id': user.id}) // CLAIM THE ROW
                    .eq('email', user.email!);

                print("DEBUG: Orphaned row claimed successfully. Reloading...");
                return loadUserData();
              } catch (claimError) {
                print("DEBUG: Failed to claim orphaned row: $claimError");
              }
            }
          }
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
          'email': user.email,
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

        if (_username.isNotEmpty && _username != "User") {
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

  void resetState() {
    _username = "User";
    _email = "";
    _profilePhoto = null;
    _profilePhotoUrl = null;
    print("DEBUG: UserProvider state reset.");
    notifyListeners();
  }
}
