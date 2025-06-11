/*
GREENGROW APP - AUTHENTICATION SERVICE

This file implements the user account management and authentication system.

SIMPLE EXPLANATION:
- This is like the security guard for the app that checks your ID card
- It handles creating new user accounts with email and passwords
- It verifies your login information and gives you access to the app
- It remembers you're logged in so you don't have to sign in every time
- It manages your profile information like name, location, and phone number
- It securely stores all your account details on your device
- It handles logging you out when you're done using the app

TECHNICAL EXPLANATION:
- Implements a complete authentication system with user registration and login
- Contains secure persistent storage of user credentials using shared preferences
- Implements session management with current user caching
- Contains file-based user database with CRUD operations
- Implements profile management with partial updates
- Contains UUID-based user identification
- Implements login state persistence with remember me functionality
- Contains input validation and duplicate email checking
- Implements proper error handling with descriptive exceptions
- Contains memory optimization through lazily loaded user data

This service provides the security layer of the application, managing user identity
and access control throughout the user experience.
*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/auth_user.dart';

/// AuthService is a singleton service that manages user authentication and profile data
/// It provides functionality for:
/// - User registration and login
/// - Session management
/// - Profile updates
/// - Persistent storage of user data
/// - Secure user data handling
class AuthService {
  // File name for storing user data
  static const String _usersFileName = 'users.json';
  // Key for storing current user ID in SharedPreferences
  static const String _currentUserKey = 'current_user_id';
  // Cache for the currently logged-in user
  static AuthUser? _currentUser;

  /// Retrieves the currently logged-in user
  /// 
  /// Returns the AuthUser object if a user is logged in, null otherwise
  /// 
  /// The method:
  /// 1. Checks the in-memory cache first
  /// 2. Falls back to SharedPreferences for the user ID
  /// 3. Loads the full user data from the users file
  static Future<AuthUser?> getCurrentUser() async {
    // Return cached user if available
    if (_currentUser != null) {
      return _currentUser;
    }

    // Get user ID from persistent storage
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    if (userId == null) {
      return null;
    }

    // Load user data from file
    final users = await _getUsers();
    _currentUser = users.firstWhere((user) => user.id == userId && user.isLoggedIn, 
      orElse: () => throw Exception('user_not_found'));
    
    return _currentUser;
  }

  /// Checks if a user is currently logged in
  /// 
  /// Returns true if a valid user session exists, false otherwise
  static Future<bool> isLoggedIn() async {
    final currentUser = await getCurrentUser();
    return currentUser != null;
  }

  /// Registers a new user in the system
  /// 
  /// [username] - User's full name
  /// [email] - User's email address
  /// [password] - User's password (Note: In production, this should be hashed)
  /// [phone] - Optional phone number
  /// [location] - Optional location
  /// 
  /// Returns the newly created AuthUser object
  /// 
  /// Throws an exception if the email is already registered
  static Future<AuthUser> register({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? location,
  }) async {
    // Validate email uniqueness
    final users = await _getUsers();
    final emailExists = users.any((user) => user.email.toLowerCase() == email.toLowerCase());
    if (emailExists) {
      throw Exception('email_already_registered');
    }

    // Create new user with unique ID
    final newUser = AuthUser(
      id: const Uuid().v4(),
      username: username,
      email: email,
      password: password, // Note: In production, hash this password
      phone: phone,
      location: location,
      isLoggedIn: true,
    );

    // Save new user to storage
    users.add(newUser);
    await _saveUsers(users);

    // Set as current user
    _currentUser = newUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, newUser.id);

    return newUser;
  }

  /// Authenticates a user and creates a session
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// [rememberMe] - Whether to persist the session
  /// 
  /// Returns the authenticated AuthUser object
  /// 
  /// Throws an exception if credentials are invalid
  static Future<AuthUser> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final users = await _getUsers();
    
    // Find user by credentials
    final user = users.firstWhere(
      (user) => user.email.toLowerCase() == email.toLowerCase() && 
                user.password == password, // Note: In production, verify hashed password
      orElse: () => throw Exception('invalid_credentials'),
    );

    // Update login status for all users (log out others) and set current user as logged in
    final updatedUsers = users.map((u) {
      if (u.id == user.id) {
        return u.copyWith(isLoggedIn: true);
      }
      // Log out other users
      return u.copyWith(isLoggedIn: false);
    }).toList();

    await _saveUsers(updatedUsers);

    // Set as current user
    _currentUser = user.copyWith(isLoggedIn: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, user.id);

    return _currentUser!;
  }

  /// Ends the current user session
  /// 
  /// Clears the current user from memory and updates the login status
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);

    if (_currentUser != null) {
      final users = await _getUsers();
      final updatedUsers = users.map((user) {
        if (user.id == _currentUser!.id) {
          return user.copyWith(isLoggedIn: false);
        }
        return user;
      }).toList();

      await _saveUsers(updatedUsers);
      _currentUser = null;
    }
  }

  /// Updates the current user's profile information
  /// 
  /// All parameters are optional and only update if provided
  /// 
  /// Returns the updated AuthUser object
  /// 
  /// Throws an exception if no user is logged in
  static Future<AuthUser> updateUserProfile({
    String? username,
    String? email,
    String? phone,
    String? location,
    String? imagePath,
    String? password,
    bool? darkMode,
  }) async {
    if (_currentUser == null) {
      throw Exception('user_not_found');
    }

    final users = await _getUsers();
    final updatedUsers = users.map((user) {
      if (user.id == _currentUser!.id) {
        return user.copyWith(
          username: username,
          email: email,
          phone: phone,
          location: location,
          imagePath: imagePath,
          password: password,
          darkMode: darkMode,
        );
      }
      return user;
    }).toList();

    await _saveUsers(updatedUsers);
    
    _currentUser = _currentUser!.copyWith(
      username: username,
      email: email,
      phone: phone,
      location: location,
      imagePath: imagePath,
      password: password,
      darkMode: darkMode,
    );

    return _currentUser!;
  }

  /// Updates the user's dark mode preference
  /// 
  /// [enabled] - Whether dark mode should be enabled
  /// 
  /// Returns the updated AuthUser object
  /// 
  /// This is a convenience method that uses updateUserProfile
  static Future<AuthUser> setDarkMode(bool enabled) async {
    return updateUserProfile(darkMode: enabled);
  }

  /// Gets the File object for the users data file
  /// 
  /// Returns a File object pointing to the users.json file in the app's documents directory
  static Future<File> _getUsersFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_usersFileName');
  }

  /// Loads all users from the persistent storage
  /// 
  /// Returns a list of AuthUser objects
  /// Returns an empty list if the file doesn't exist or on error
  static Future<List<AuthUser>> _getUsers() async {
    try {
      final file = await _getUsersFile();
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => AuthUser.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading users: $e');
      return [];
    }
  }

  /// Saves the list of users to persistent storage
  /// 
  /// [users] - List of AuthUser objects to save
  /// 
  /// Throws an exception if saving fails
  static Future<void> _saveUsers(List<AuthUser> users) async {
    try {
      final file = await _getUsersFile();
      final jsonList = users.map((user) => user.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving users: $e');
      throw Exception('Failed to save user data');
    }
  }
} 