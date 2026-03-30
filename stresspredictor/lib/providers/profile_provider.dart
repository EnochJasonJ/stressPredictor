import 'package:flutter/foundation.dart';
import 'package:stresspredictor/models/user_profile.dart';
import 'package:stresspredictor/services/local_storage_service.dart';

/// Manages user profile state including name, email, and settings.
class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile.defaultProfile();
  bool _isLoaded = false;

  UserProfile get profile => _profile;
  bool get isLoaded => _isLoaded;

  /// Loads profile from local storage (called on app start).
  Future<void> loadProfile() async {
    _profile = await LocalStorageService.instance.loadProfile();
    _isLoaded = true;
    notifyListeners();
  }

  /// Updates the user's name and email.
  Future<void> updateProfile({required String name, required String email}) async {
    _profile = _profile.copyWith(name: name, email: email);
    await LocalStorageService.instance.saveProfile(_profile);
    notifyListeners();
  }

  /// Toggles the notifications setting.
  Future<void> toggleNotifications() async {
    _profile = _profile.copyWith(
      notificationsEnabled: !_profile.notificationsEnabled,
    );
    await LocalStorageService.instance.saveProfile(_profile);
    notifyListeners();
  }

  /// Clears profile and resets to defaults (used on logout).
  Future<void> logout() async {
    await LocalStorageService.instance.clearProfile();
    _profile = UserProfile.defaultProfile();
    _isLoaded = false;
    notifyListeners();
  }
}
