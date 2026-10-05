import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';

/// Authentication and driver profile state manager
class AuthController extends ChangeNotifier {
  UserProfileModel _user = const UserProfileModel();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptedTerms = false;

  UserProfileModel get user => _user;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
  bool get acceptedTerms => _acceptedTerms;
  bool get isLoggedIn => _user.isLoggedIn;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setAcceptedTerms(bool value) {
    _acceptedTerms = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _user = UserProfileModel(
      uid: 'usr_101',
      email: email.isEmpty ? 'driver@waypoint.bd' : email,
      name: 'Rahim Ahmed',
      nickname: 'Bengal Navigator',
      isLoggedIn: true,
      isProfileComplete: true,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _user = UserProfileModel(
      uid: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      nickname: name.split(' ').first,
      isLoggedIn: true,
      isProfileComplete: false,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _user = const UserProfileModel(
      uid: 'usr_google_202',
      email: 'explorer@gmail.com',
      name: 'Tamim Hossain',
      nickname: 'Tamim',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      isLoggedIn: true,
      isProfileComplete: true,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> loginWithFacebook() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _user = const UserProfileModel(
      uid: 'usr_fb_303',
      email: 'explorer.fb@facebook.com',
      name: 'Anika Rahman',
      nickname: 'Anika',
      isLoggedIn: true,
      isProfileComplete: true,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void updateProfile({
    required String nickname,
    required String avatarUrl,
    required String emergencyContact,
  }) {
    _user = _user.copyWith(
      nickname: nickname,
      avatarUrl: avatarUrl,
      emergencyContact: emergencyContact,
      isProfileComplete: true,
    );
    notifyListeners();
  }

  void logout() {
    _user = const UserProfileModel();
    notifyListeners();
  }
}
