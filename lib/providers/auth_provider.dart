import 'dart:convert';
import 'package:dashboard_template_dribbble/providers/theme_provider.dart';
import 'package:dashboard_template_dribbble/view/screens/auth/login.dart';
import 'package:dashboard_template_dribbble/view/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart'; // Your API service

class User {
  final int id;
  final String name;
  final String? role;
  final String email;
  // final String? profilePhoto; 

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    // this.profilePhoto,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      // profilePhoto: map['profile_photo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      // 'profile_photo': profilePhoto,
    };
  }
}

// --- 2. Updated AuthProvider ---
class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Private state variables
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  User? _user;

  // Public getters to access the state from the UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;
  User? get user => _user;

  AuthProvider() {
    // When the app starts, try to load all auth data from storage.
    _loadAuthDataFromStorage();
  }

  get currentUser => null;

  /// Attempts to log in the user by calling the API.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.signIn(email, password);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // --- FIX: Access the nested 'data' object ---
        final Map<String, dynamic>? data = responseData['data'];

        if (data != null) {
          // --- FIX: Access token and user from within the 'data' object ---
          final String? receivedToken = data['access']?['token'];
          final Map<String, dynamic>? userData = data['user'];

          if (receivedToken != null && userData != null) {
            // --- SUCCESS ---
            _token = receivedToken;
            _user = User.fromMap(userData);
            // --- ADD THIS LINE ---
            print('AuthProvider: User set to ${_user?.name}');
            // Save both token and user data to the device.
            await _saveAuthDataToStorage();

            _isLoading = false;
            notifyListeners(); // This triggers the redirect in AuthWrapper
            return true;
          }
        }
        // If we reach here, the 'data' object or its contents were missing.
        _errorMessage =
            'Login successful, but auth data is missing from server response.';
      } else {
        final errorData = json.decode(response.body);
        _errorMessage =
            errorData['message'] ?? 'Invalid credentials or server error.';
      }
    } catch (e) {
      _errorMessage = 'A network error occurred. Please check your connection.';
      print('Login Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Saves both the token and user data to the device's local storage.
  Future<void> _saveAuthDataToStorage() async {
  final prefs = await SharedPreferences.getInstance();
  if (_token != null && _user != null) {
    await prefs.setString('auth_token', _token!);
    await prefs.setString('user_data', json.encode(_user!.toMap()));

    // --- ADD THIS LINE FOR DEBUGGING ---
    print('AuthProvider: Token and user data saved successfully!');
  }
}

  /// Loads auth data from storage when the app initializes.
  Future<void> _loadAuthDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      _user = User.fromMap(json.decode(userDataString));
    }

    notifyListeners();
  }

  /// Logs the user out by clearing state and local storage.
  Future<void> logout() async {
    try {
      if (_token != null) {
        await _apiService.logout();
      }
    } catch (e) {
      print("Error during API logout: $e");
    }

    // Clear state variables
    _token = null;
    _user = null;

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    notifyListeners();
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    // Use isLoading instead of isInitializing
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: themeProvider.currentTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: themeProvider.currentTheme.primaryColor,
          ),
        ),
      );
    }

    return authProvider.isAuthenticated ? const MainScreen() : const LoginScreen();
  }
}
