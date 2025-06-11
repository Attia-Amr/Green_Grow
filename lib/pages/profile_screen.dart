/*
GREENGROW APP - PROFILE SCREEN

This file implements the user profile management and app settings configuration.

SIMPLE EXPLANATION:
- This is like your personal control center for the app
- It shows your profile picture, name, and account information
- It lets you change app settings like language and dark mode
- It includes easy toggles for turning notifications on and off
- It provides access to help pages and information about the app
- It has a logout button when you want to sign out
- It lets you edit your personal information and change your password

TECHNICAL EXPLANATION:
- Implements a comprehensive settings management interface
- Contains user profile management with image picker integration
- Implements language switching with immediate UI updates
- Contains theme switching between light and dark modes
- Implements permission management for location and notifications
- Contains sectioned settings display with custom styling and icons
- Implements dialog-based field editing with validation
- Contains authentication state management through AuthService
- Uses platform-specific design patterns and responsive layouts
- Implements deep linking to related screens like help center

This screen serves as the central configuration hub for the application,
allowing users to customize their experience and manage their account settings.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/language_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../models/auth_user.dart';
import 'help_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/page_transition.dart';
import 'package:flutter/rendering.dart';

// ProfileScreen is a StatefulWidget that manages user profile settings and preferences
// It provides functionality for:
// - Viewing and editing user profile information
// - Managing app settings (language, notifications, dark mode)
// - Handling user authentication (logout)
// - Managing app permissions (location)
// - Accessing help and about information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// State class for ProfileScreen that manages:
// - User profile data and settings
// - Language preferences
// - Permission states
// - UI state for loading and error conditions
class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  // State variables for user preferences and settings
  bool _notificationsEnabled = true;  // Tracks notification permission state
  bool _darkModeEnabled = false;      // Tracks dark mode preference
  AuthUser? _userData;                // Stores current user profile data
  bool _isLoading = true;             // Tracks loading state for async operations
  bool _isEnglish = true;             // Tracks current language preference
  bool _keepAnalysis = true;          // Tracks analysis history retention preference
  late ThemeService _themeService;    // Theme service for managing app-wide theme

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadUserData();
    _initLanguage();
    _initTheme();
    LanguageService.addListener(_onLanguageChanged);
  }

  // Initializes the current language preference
  // Called during screen initialization to set the correct language state
  Future<void> _initLanguage() async {
    _isEnglish = LanguageService.getCurrentLanguageCode() == 'en';
    setState(() {});
  }

  // Initializes the theme service and sets the local dark mode state
  void _initTheme() {
    _themeService = ThemeService();
    _darkModeEnabled = _themeService.isDarkMode;
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    // Clean up language change listener when screen is disposed
    LanguageService.removeListener(_onLanguageChanged);
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  // Handles language preference changes
  // Updates UI when language is changed through the app
  void _onLanguageChanged() {
    setState(() {
      _isEnglish = LanguageService.getCurrentLanguageCode() == 'en';
    });
  }

  // Updates UI when theme is changed
  void _onThemeChanged() {
    setState(() {
      _darkModeEnabled = _themeService.isDarkMode;
    });
  }

  // Checks and requests location permission if needed
  // Required for location-based features in the app
  Future<void> _checkPermissions() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      await _requestLocationPermission();
    }
  }

  // Requests location permission from the user
  // Shows a dialog explaining why the permission is needed
  // Provides options to open settings or cancel
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(LanguageService.translate(context, 'location_permission_required')),
            content: Text(LanguageService.translate(context, 'location_permission_message')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text(LanguageService.translate(context, 'open_settings')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LanguageService.translate(context, 'cancel')),
              ),
            ],
          ),
        );
      }
    }
  }

  // Loads the current user's profile data from the authentication service
  // Handles loading states and error conditions
  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService.getCurrentUser();
      
      // Create default user if none exists
      if (userData == null) {
        await _createDefaultUser();
        final defaultUser = await AuthService.getCurrentUser();
        setState(() {
          _userData = defaultUser;
          _isLoading = false;
          if (defaultUser != null) {
            _darkModeEnabled = defaultUser.darkMode;
          }
        });
        return;
      }
      
      setState(() {
        _userData = userData;
        _isLoading = false;
        // Update dark mode from user data
        if (userData != null) {
          _darkModeEnabled = userData.darkMode;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageService.translate(context, 'error_loading')),
            action: SnackBarAction(
              label: LanguageService.translate(context, 'retry'),
              onPressed: _loadUserData,
            ),
          ),
        );
      }
    }
  }

  // Creates a default user with sample data
  // This ensures the profile screen works properly on initial launch
  Future<void> _createDefaultUser() async {
    try {
      await AuthService.register(
        username: 'Yasmine',
        email: 'yasmine@greengrow.com',
        password: 'password123',
        phone: '+20 123 456 7890',
        location: 'Cairo, Egypt',
      );
      
      // Set dark mode to match current theme
      await AuthService.setDarkMode(_themeService.isDarkMode);
      
      debugPrint('Default user created successfully');
    } catch (e) {
      // If registration fails due to existing email, try to login
      if (e.toString().contains('email_already_registered')) {
        try {
          await AuthService.login(
            email: 'yasmine@greengrow.com',
            password: 'password123',
            rememberMe: true,
          );
          debugPrint('Logged in with default user');
        } catch (loginError) {
          debugPrint('Error logging in default user: $loginError');
        }
      } else {
        debugPrint('Error creating default user: $e');
      }
    }
  }

  // Handles user logout process
  // Clears authentication state and navigates to login screen
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Logout user
      await AuthService.logout();
      // Create a new default user
      await _createDefaultUser();
      // Reload user data
      await _loadUserData();
    } catch (e) {
      debugPrint('Error during logout: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Toggles between English and Arabic languages
  // Updates UI to reflect language change
  Future<void> _toggleLanguage() async {
    await LanguageService.toggleLanguage();
    setState(() {
      _isEnglish = !_isEnglish;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    // Show loading indicator while data is being fetched
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Main screen layout with:
    // - Header with profile image and name
    // - Settings cards with various options
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LanguageService.wrapWithDirectional(
          context: context,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Settings Header with Background
                Stack(
                  children: [
                    // Background Image with decorative header
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/topheader.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Dark Overlay

                    // Settings Title and Profile section
                    Positioned(
                      top: 16,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            LanguageService.translate(context, 'settings'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile Info section with avatar and username
                    Positioned(
                      bottom: 45,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              backgroundImage: _userData?.imagePath != null
                                  ? FileImage(File(_userData!.imagePath!))
                                  : null,
                              child: _userData?.imagePath == null
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _userData?.username ?? 'Yasmine',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Settings Card with rounded top corners and shadow
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 25,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Account Settings Section
                          Text(
                            LanguageService.translate(context, 'account_settings'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C2C1E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Language preference toggle
                          _buildSettingItem(
                            icon: Icons.language,
                            title: LanguageService.translate(context, 'language'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'AR',
                                  style: TextStyle(
                                    fontWeight: _isEnglish ? FontWeight.normal : FontWeight.bold,
                                    color: _isEnglish ? Colors.grey : const Color(0xFF0C2C1E),
                                  ),
                                ),
                                const Text(' | '),
                                Text(
                                  'ENG',
                                  style: TextStyle(
                                    fontWeight: _isEnglish ? FontWeight.bold : FontWeight.normal,
                                    color: _isEnglish ? const Color(0xFF0C2C1E) : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Switch.adaptive(
                                  value: _isEnglish,
                                  activeColor: const Color(0xFF0C2C1E),
                                  onChanged: (value) => _toggleLanguage(),
                                ),
                              ],
                            ),
                          ),
                          // Profile editing options
                          _buildSettingItem(
                            icon: Icons.edit,
                            title: LanguageService.translate(context, 'edit_profile'),
                            onTap: () => _editField('username', _userData?.username ?? ''),
                          ),
                          _buildSettingItem(
                            icon: Icons.lock,
                            title: LanguageService.translate(context, 'change_password'),
                            onTap: () => _showChangePasswordDialog(),
                          ),
                          // Analysis history retention toggle
                          _buildSettingItem(
                            icon: Icons.analytics,
                            title: LanguageService.translate(context, 'keep_analysis'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _keepAnalysis = !_keepAnalysis;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Notification preferences
                          _buildSettingItem(
                            icon: Icons.notifications,
                            title: LanguageService.translate(context, 'push_notifications'),
                            trailing: Switch.adaptive(
                              value: _notificationsEnabled,
                              activeColor: const Color(0xFF0C2C1E),
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                            ),
                          ),
                          // Dark mode toggle
                          _buildSettingItem(
                            icon: Icons.dark_mode,
                            title: LanguageService.translate(context, 'dark_mode'),
                            trailing: Switch.adaptive(
                              value: _darkModeEnabled,
                              activeColor: const Color(0xFF0C2C1E),
                              onChanged: (value) async {
                                await _themeService.toggleTheme();
                                setState(() {
                                  _darkModeEnabled = value;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        LanguageService.translate(context, 'theme_changed'),
                                        style: TextStyle(
                                          color: _darkModeEnabled ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      backgroundColor: _darkModeEnabled 
                                          ? Colors.grey.shade800 
                                          : Colors.green.shade100,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const Divider(height: 32),
                          // Additional app features section
                          Text(
                            LanguageService.translate(context, 'more'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C2C1E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // About and help options
                          _buildSettingItem(
                            icon: Icons.info,
                            title: LanguageService.translate(context, 'about_us'),
                            onTap: () {},
                          ),
                          _buildSettingItem(
                            icon: Icons.help,
                            title: LanguageService.translate(context, 'help'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HelpScreen()),
                              );
                            },
                          ),
                          // Logout option with warning color
                          _buildSettingItem(
                            icon: Icons.logout,
                            title: LanguageService.translate(context, 'logout'),
                            textColor: Colors.red,
                            iconColor: Colors.red,
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }

  // Helper method to build consistent setting items
  // Creates a standardized list tile with icon, title, and optional trailing widget
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Color? textColor,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final defaultColor = Theme.of(context).textTheme.titleMedium?.color ?? const Color(0xFF0C2C1E);
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? defaultColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: iconColor ?? defaultColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: textColor ?? defaultColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? (onTap != null ? Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: defaultColor,
      ) : null),
      onTap: onTap,
    );
  }

  // Handles profile image selection from gallery
  // Updates user profile with new image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await AuthService.updateUserProfile(imagePath: pickedFile.path);
        await _loadUserData();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  // Handles editing of profile fields
  // Shows a dialog with current value and allows user to update
  // Supports different field types (username, email, phone, location)
  Future<void> _editField(String field, String currentValue) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageService.translate(context, 'edit_$field')),
        content: TextField(
          controller: TextEditingController(text: currentValue),
          decoration: InputDecoration(
            labelText: LanguageService.translate(context, field),
          ),
          onChanged: (value) => currentValue = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageService.translate(context, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, currentValue),
            child: Text(LanguageService.translate(context, 'save')),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        switch (field) {
          case 'username':
            await AuthService.updateUserProfile(username: result);
            break;
          case 'email':
            await AuthService.updateUserProfile(email: result);
            break;
          case 'phone':
            await AuthService.updateUserProfile(phone: result);
            break;
          case 'location':
            await AuthService.updateUserProfile(location: result);
            break;
        }
        await _loadUserData();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  // Shows a dialog for changing the user's password
  // Validates that current password is correct and new passwords match
  Future<void> _showChangePasswordDialog() async {
    String currentPassword = '';
    String newPassword = '';
    String confirmPassword = '';
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(LanguageService.translate(context, 'change_password')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Current password field
                    TextField(
                      obscureText: obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: LanguageService.translate(context, 'current_password'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureCurrentPassword = !obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) => currentPassword = value,
                    ),
                    const SizedBox(height: 16),
                    // New password field
                    TextField(
                      obscureText: obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: LanguageService.translate(context, 'new_password'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureNewPassword = !obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) => newPassword = value,
                    ),
                    const SizedBox(height: 16),
                    // Confirm password field
                    TextField(
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: LanguageService.translate(context, 'confirm_password'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) => confirmPassword = value,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(LanguageService.translate(context, 'cancel')),
                ),
                TextButton(
                  onPressed: () => _updatePassword(
                    currentPassword,
                    newPassword,
                    confirmPassword,
                  ),
                  child: Text(LanguageService.translate(context, 'save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Updates the user's password with validation
  Future<void> _updatePassword(String currentPassword, String newPassword, String confirmPassword) async {
    // Dismiss the dialog
    Navigator.pop(context);
    
    // Validate inputs
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar(LanguageService.translate(context, 'all_fields_required'));
      return;
    }
    
    if (newPassword != confirmPassword) {
      _showErrorSnackBar(LanguageService.translate(context, 'passwords_dont_match'));
      return;
    }
    
    if (newPassword.length < 6) {
      _showErrorSnackBar(LanguageService.translate(context, 'password_too_short'));
      return;
    }
    
    // Verify current password
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Verify the current password is correct
      if (_userData == null) {
        throw Exception('user_not_found');
      }
      
      // In a real app with backend, we would send a request to verify the current password
      // For this demo implementation, we'll check against the current user data
      if (_userData!.password != currentPassword) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar(LanguageService.translate(context, 'current_password_incorrect'));
        return;
      }
      
      // Update the password
      await AuthService.updateUserProfile(password: newPassword);
      await _loadUserData(); // Reload user data
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageService.translate(context, 'password_updated')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }
  
  // Helper method to show error messages
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add keep alive override
  @override
  bool get wantKeepAlive => true;
} 