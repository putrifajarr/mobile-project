import 'dart:io';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _username = "Putri";
  File? _profilePhoto;

  String get username => _username;
  File? get profilePhoto => _profilePhoto;

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
