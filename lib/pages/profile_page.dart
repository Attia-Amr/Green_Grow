

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellow/pages/balance_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hellow/pages/EditProfilePage.dart'; // Import EditProfilePage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isNotificationOn = true;
  bool isDarkMode = false;
  String? username;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadProfileImage();
  }

  void _loadUsername() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      setState(() {
        username = user.email!.split('@')[0];
      });
    } else {
      username = 'User';
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', pickedFile.path);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 242, 242),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/profile.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Transform.translate(
                      offset: const Offset(0, -20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            username ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 243, 242, 242),
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
                        const Text(
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C2C1E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingItem(
                          icon: Icons.language,
                          title: 'Language',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('AR', style: TextStyle(color: Colors.grey)),
                              const Text(' | '),
                              const Text(
                                'ENG',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0C2C1E),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Switch.adaptive(
                                value: true,
                                activeColor: const Color(0xFF0C2C1E),
                                onChanged: (val) {
                                  // Change language
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingItem(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(), // Navigate to EditProfilePage
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildSettingItem(
                          icon: Icons.lock,
                          title: 'Change Password',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChangePasswordPage(), // Navigate to ChangePasswordPage
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildSettingItem(
                          icon: Icons.analytics,
                          title: 'Keep Analysis',
                          trailing: IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Analysis button clicked")),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingItem(
                          icon: Icons.notifications,
                          title: 'Push Notifications',
                          trailing: Switch.adaptive(
                            value: isNotificationOn,
                            activeColor: const Color(0xFF0C2C1E),
                            onChanged: (value) {
                              setState(() {
                                isNotificationOn = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingItem(
                          icon: Icons.dark_mode,
                          title: 'Dark Mode',
                          trailing: Switch.adaptive(
                            value: isDarkMode,
                            activeColor: const Color(0xFF0C2C1E),
                            onChanged: (value) {
                              setState(() {
                                isDarkMode = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
_buildSettingItem(
  icon: Icons.account_balance_wallet,
  title: 'Account Balance',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BalancePage(balance: 10,),
      ),
    );
  },
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
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Color textColor = const Color(0xFF0C2C1E),
    Color iconColor = const Color(0xFF0C2C1E),
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF0C2C1E),
          ),
      onTap: onTap,
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isObscureCurrent = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  // إنشاء نسخة من FlutterSecureStorage
  final _storage = FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  void initState() {
    super.initState();
  }

  // التحقق من كلمة المرور القديمة
  _verifyCurrentPassword(String currentPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // محاولة تسجيل الدخول باستخدام كلمة المرور الحالية
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // تغيير كلمة المرور في Firebase
  _changePasswordInFirebase(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
      } catch (e) {
        print('Error updating password: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(85),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 238, 241, 240),
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black)
                  ],
                ),
              ),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 15, 77, 48),
                    Color.fromARGB(255, 5, 14, 8),
                  ],
                  stops: [0.3, 6.0],
                  end: Alignment.topLeft,
                  begin: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 243, 242, 242),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
Center(
  child: const Text(
    'Secure your account',
    style: TextStyle(
      fontSize: 22,  
      fontWeight: FontWeight.w700, 
      letterSpacing: 1.0,  
      color: Color(0xFF0F4D30),
    ),
  ),
),

                    const SizedBox(height: 40),
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Current Password',
                      icon: Icons.lock,
                      isObscure: _isObscureCurrent,
                      onTap: () {
                        setState(() {
                          _isObscureCurrent = !_isObscureCurrent;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      icon: Icons.lock_outline,
                      isObscure: _isObscureNew,
                      onTap: () {
                        setState(() {
                          _isObscureNew = !_isObscureNew;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      icon: Icons.lock_outline,
                      isObscure: _isObscureConfirm,
                      onTap: () {
                        setState(() {
                          _isObscureConfirm = !_isObscureConfirm;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4D30),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          // التحقق من كلمة المرور القديمة
                          bool isPasswordCorrect = await _verifyCurrentPassword(_currentPasswordController.text);

                          if (!isPasswordCorrect) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Current password is incorrect')),
                            );
                            return;
                          }

                          // قم بتغيير كلمة المرور في Firebase
                          await _changePasswordInFirebase(_newPasswordController.text);

                          // إظهار رسالة تأكيد للمستخدم
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password changed successfully')),
                          );

                          // العودة إلى الصفحة السابقة بعد تغيير كلمة المرور
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Change Password',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isObscure,
    required VoidCallback onTap,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.black54),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF0F4D30), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.black54,
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
