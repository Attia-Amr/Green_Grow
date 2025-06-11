/*
GREENGROW APP - THEME SERVICE

This file implements the theme management system for the application.

SIMPLE EXPLANATION:
- This is like the visual stylist for the app that controls light and dark modes
- It provides consistent colors and styles across all screens
- It remembers your preference for light or dark mode
- It lets you switch between themes with a single toggle
- It automatically updates all screens when you change the theme
- It ensures good readability in both light and dark environments
- It reduces eye strain by offering a dark mode option for nighttime use

TECHNICAL EXPLANATION:
- Implements a global theme management system with light and dark themes
- Contains a listener pattern for real-time theme updates
- Implements theme persistence through AuthService integration
- Contains predefined color palettes and text styles for consistent UX
- Implements ThemeData generation for light and dark themes
- Contains standardized global application of theme settings
- Implements proper state management with change notifications
- Contains static accessor methods for convenient theme components
- Implements proper disposal of listeners to prevent memory leaks

This service provides the visual foundation for the application, ensuring
consistent styling and a polished look across all screens.
*/

import 'package:flutter/material.dart';
import 'auth_service.dart';

/// ThemeService manages application theming and provides:
/// - Light and dark theme definitions
/// - Theme state management
/// - Theme persistence
/// - Real-time theme updates
class ThemeService extends ChangeNotifier {
  // Singleton instance
  static final ThemeService _instance = ThemeService._internal();
  
  // Factory constructor to return the same instance
  factory ThemeService() => _instance;
  
  // Private constructor for singleton implementation
  ThemeService._internal();
  
  // Current theme mode
  ThemeMode _themeMode = ThemeMode.light;
  
  // Listeners for theme changes
  final List<Function()> _listeners = [];
  
  /// Initialize the theme service from user preferences
  /// Should be called at app startup
  Future<void> init() async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      _themeMode = currentUser?.darkMode == true ? ThemeMode.dark : ThemeMode.light;
      _notifyListeners();
    } catch (e) {
      // Default to light theme if any issues
      _themeMode = ThemeMode.light;
    }
  }
  
  /// Get the current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Check if dark mode is currently enabled
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Toggle between light and dark themes
  /// Returns the new theme mode after toggling
  Future<ThemeMode> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
    return _themeMode;
  }
  
  /// Set a specific theme mode and persist the setting
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    
    try {
      // Save the preference to user profile
      await AuthService.setDarkMode(_themeMode == ThemeMode.dark);
    } catch (e) {
      // Handle error but continue with in-memory change
      print('Error saving theme preference: $e');
    }
    
    _notifyListeners();
  }
  
  /// Add a listener to be notified when theme changes
  void addListener(Function() listener) {
    _listeners.add(listener);
  }
  
  /// Remove a previously added listener
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }
  
  /// Notify all listeners of theme changes
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
    notifyListeners();
  }
  
  /// Light theme definition
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF0C2C1E),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0C2C1E),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF0C2C1E)),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Color(0xFF0C2C1E), fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Color(0xFF0C2C1E), fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Color(0xFF333333)),
        bodyMedium: TextStyle(color: Color(0xFF555555)),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: const Color(0xFF0C2C1E),
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF0C2C1E),
        secondary: const Color(0xFF4CAF50),
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
        error: Colors.red.shade700,
      ),
    );
  }
  
  /// Dark theme definition
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF0C2C1E),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardTheme(
        color: Colors.grey.shade800,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      iconTheme: IconThemeData(color: Colors.green.shade200),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: Colors.green.shade200, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.green.shade200, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: Colors.white),
        bodyMedium: const TextStyle(color: Colors.grey),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.green.shade700,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      colorScheme: ColorScheme.dark(
        primary: Colors.green.shade700,
        secondary: Colors.green.shade300,
        surface: Colors.grey.shade800,
        background: const Color(0xFF121212),
        error: Colors.red.shade300,
      ),
    );
  }
} 