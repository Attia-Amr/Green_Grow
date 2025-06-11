/*
GREENGROW APP - USER AUTHENTICATION MODEL

This file defines the AuthUser class which manages all user account data in the app.

SIMPLE EXPLANATION:
- This is like a digital ID card for each user of our farming app
- It stores personal info (name, email, password) and app status (logged in or not)
- It has special methods to save user data and load it back when needed
- The copyWith method lets us update just parts of a user profile without changing everything

TECHNICAL EXPLANATION:
- Class implements a data model for user authentication and profile information
- Uses named parameters in constructor with required/optional designations
- Implements JSON serialization/deserialization for persistence
- Immutable design pattern with copyWith for state modifications
- Contains core user identity fields (id, username, email, password)
- Contains optional profile data (phone, location, profile image)
- Tracks authentication state via isLoggedIn boolean flag
- Overrides toString() for debugging and logging purposes

The AuthUser objects are used throughout the app to manage login sessions, 
display user information, and maintain user preferences.
*/

// This brings in tools that help us convert data between different formats
// Like a translator that helps us change information from one language to another
import 'dart:convert';

// This is our container for all information about a user of our app
// Think of it like a form that holds all the details about a person who uses our app
class AuthUser {
  // These are all the pieces of information we store about each user
  final String id;           // A unique ID number for each user, like their special code
  final String username;     // The name they use in our app, like a nickname
  final String email;        // Their email address, so we can contact them
  final String password;     // Their secret word to log in (in a real app, this would be scrambled for safety)
  final String? phone;       // Their phone number (the ? means this might be empty)
  final String? location;    // Where they live or farm (might be empty)
  final String? imagePath;   // Where their profile picture is stored (might be empty)
  final bool isLoggedIn;     // Whether they're currently using the app (true) or not (false)
  final bool darkMode;       // Whether the user prefers dark mode (true) or light mode (false)

  // This is the recipe for creating a new user
  // It tells us what information we need to make a user account
  AuthUser({
    required this.id,        // Must have an ID
    required this.username,  // Must have a username
    required this.email,     // Must have an email
    required this.password,  // Must have a password
    this.phone,              // Phone is optional
    this.location,           // Location is optional
    this.imagePath,          // Profile picture is optional
    this.isLoggedIn = false, // By default, a new user is not logged in
    this.darkMode = false,   // By default, dark mode is turned off
  });

  // This function makes a copy of a user but can change some details
  // It's like copying someone's form but changing just their phone number
  AuthUser copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? phone,
    String? location,
    String? imagePath,
    bool? isLoggedIn,
    bool? darkMode,
  }) {
    return AuthUser(
      id: id ?? this.id,                     // Use the new ID if provided, otherwise keep the old one
      username: username ?? this.username,   // Same for username
      email: email ?? this.email,            // And email
      password: password ?? this.password,   // And password
      phone: phone ?? this.phone,            // And phone
      location: location ?? this.location,   // And location
      imagePath: imagePath ?? this.imagePath, // And profile picture
      isLoggedIn: isLoggedIn ?? this.isLoggedIn, // And login status
      darkMode: darkMode ?? this.darkMode,   // And dark mode preference
    );
  }

  // This function converts user information into a format that can be saved
  // It's like turning a filled-out form into a list that a computer can easily store
  Map<String, dynamic> toJson() {
    return {
      'id': id,              // Store the ID with label 'id'
      'username': username,  // Store the username with label 'username'
      'email': email,        // Store the email with label 'email'
      'password': password,  // Store the password with label 'password'
      'phone': phone,        // Store the phone with label 'phone'
      'location': location,  // Store the location with label 'location'
      'imagePath': imagePath, // Store the profile picture path with label 'imagePath'
      'isLoggedIn': isLoggedIn, // Store whether they're logged in with label 'isLoggedIn'
      'darkMode': darkMode,  // Store whether dark mode is enabled with label 'darkMode'
    };
  }

  // This factory creates a new user from saved information
  // It's like taking a stored form and turning it back into a user account
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],                // Get the ID from the stored data
      username: json['username'],    // Get the username from the stored data
      email: json['email'],          // Get the email from the stored data
      password: json['password'],    // Get the password from the stored data
      phone: json['phone'],          // Get the phone from the stored data
      location: json['location'],    // Get the location from the stored data
      imagePath: json['imagePath'],  // Get the profile picture from the stored data
      isLoggedIn: json['isLoggedIn'] ?? false, // Get logged in status, or use false if not found
      darkMode: json['darkMode'] ?? false, // Get dark mode preference, or use false if not found
    );
  }

  // This function creates a simple text version of the user information
  // It's like taking the most important parts of the form and writing them in a sentence
  @override
  String toString() {
    return 'AuthUser(id: $id, username: $username, email: $email, isLoggedIn: $isLoggedIn)';
  }
} 