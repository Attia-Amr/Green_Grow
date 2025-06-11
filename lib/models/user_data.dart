/*
GREENGROW APP - USER DATA MODEL

This file defines the UserData class which stores user profile information in the app.

SIMPLE EXPLANATION:
- This is like a digital form that stores your personal information in the app
- It keeps track of your name, email, phone number, and location
- It remembers where your profile picture is stored
- All fields are optional so you can fill in only what you want to share
- It has special methods to save your profile and load it again next time

TECHNICAL EXPLANATION:
- Class implements a data model for storing user profile information
- Uses nullable String fields with optional parameters in constructor
- Contains common user identification fields (name, email, phone)
- Contains location data for region-specific recommendations
- Includes image path reference for profile photo storage
- Implements copyWith pattern for immutable updates
- Provides JSON serialization/deserialization for persistence
- Designed for flexibility with all nullable fields

This model works alongside AuthUser but focuses on profile information
rather than authentication details, allowing for separation of concerns.
*/

// This class holds information about the person using our app
// It's like a form that keeps track of your personal details
class UserData {
  // These are the different pieces of information we store about the user
  final String? name;       // The user's real name (might be empty)
  final String? email;      // The user's email address (might be empty)
  final String? phone;      // The user's phone number (might be empty)
  final String? location;   // Where the user lives or farms (might be empty)
  final String? imagePath;  // Where the user's profile picture is stored (might be empty)

  // This is the recipe for creating user information
  // All fields are optional (can be empty), as shown by the ? marks
  UserData({
    this.name,
    this.email,
    this.phone,
    this.location,
    this.imagePath,
  });

  // This function makes a copy of the user data but can change some parts
  // It's like filling out a new form but copying most information from an old one
  UserData copyWith({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? imagePath,
  }) {
    return UserData(
      name: name ?? this.name,             // Use new name if provided, otherwise keep old one
      email: email ?? this.email,          // Same for email
      phone: phone ?? this.phone,          // And phone
      location: location ?? this.location, // And location
      imagePath: imagePath ?? this.imagePath, // And profile picture
    );
  }

  // This function converts user data into a format that can be saved
  // It's like taking the form and putting all the answers in labeled envelopes
  Map<String, dynamic> toJson() {
    return {
      'name': name,         // Store name with label 'name'
      'email': email,       // Store email with label 'email'
      'phone': phone,       // Store phone with label 'phone'
      'location': location, // Store location with label 'location'
      'imagePath': imagePath, // Store profile picture with label 'imagePath'
    };
  }

  // This function creates user data from saved information
  // It's like taking information from labeled envelopes and filling out a form
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'] as String?,       // Get name from envelope labeled 'name'
      email: json['email'] as String?,     // Get email from envelope labeled 'email'
      phone: json['phone'] as String?,     // Get phone from envelope labeled 'phone'
      location: json['location'] as String?, // Get location from envelope labeled 'location'
      imagePath: json['imagePath'] as String?, // Get profile picture from envelope labeled 'imagePath'
    );
  }
} 