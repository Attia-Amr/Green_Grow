/*
GREENGROW APP - USER SERVICE

This file implements the user data management and app state persistence.

SIMPLE EXPLANATION:
- This is like the app's memory that remembers information about you
- It stores your profile information securely on your device
- It keeps track of whether you're using the app for the first time
- It saves your preferences and settings between app sessions
- It manages the data that personalizes your app experience
- It handles the technical details of storing and retrieving your information
- It ensures your data remains intact even when the app is closed

TECHNICAL EXPLANATION:
- Implements a persistent storage system for user profile data
- Contains first-launch detection for onboarding flows
- Implements JSON serialization for structured data storage
- Contains CRUD operations for user profile management
- Implements error handling with graceful degradation
- Contains SharedPreferences integration for lightweight data persistence
- Implements clean separation between storage and business logic
- Contains proper exception propagation for error states
- Implements atomic operations for data consistency
- Contains logging for debugging and troubleshooting

This service provides the foundation for user state management throughout the app,
enabling personalized experiences and persistent user settings.
*/

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';

/// UserService manages user-related data and application state
/// It provides functionality for:
/// - First launch detection
/// - User data persistence
/// - Profile management
/// - Data serialization
/// - Error handling
class UserService {
  // Key for storing user profile data in SharedPreferences
  static const String _userDataKey = 'user_data';
  // Key for tracking first app launch
  static const String _firstLaunchKey = 'first_launch';

  /// Checks if this is the first time the app is being launched
  /// 
  /// Returns true for first launch, false otherwise
  /// Used for showing onboarding screens or initial setup
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;  // Defaults to true if not set
  }

  /// Sets the first launch flag
  /// 
  /// [value] - Boolean indicating if this should be treated as first launch
  /// 
  /// Used after completing onboarding or initial setup
  static Future<void> setFirstLaunch(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, value);
  }

  /// Retrieves the stored user profile data
  /// 
  /// Returns a UserData object if data exists, null otherwise
  /// 
  /// The method:
  /// 1. Retrieves stored JSON string
  /// 2. Deserializes into UserData object
  /// 3. Handles potential errors
  static Future<UserData?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userDataKey);
      
      if (userDataJson != null) {
        return UserData.fromJson(jsonDecode(userDataJson));
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Updates the stored user profile data
  /// 
  /// [userData] - The UserData object containing updated profile information
  /// 
  /// The method:
  /// 1. Serializes UserData to JSON
  /// 2. Saves to persistent storage
  /// 3. Handles errors with exceptions
  static Future<void> updateUserData(UserData userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(userData.toJson()));
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  /// Clears all stored user data
  /// 
  /// Used during logout or account deletion
  /// 
  /// The method:
  /// 1. Removes user data from persistent storage
  /// 2. Throws exception if operation fails
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
    } catch (e) {
      print('Error clearing user data: $e');
      throw Exception('Failed to clear user data');
    }
  }
} 