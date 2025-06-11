

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _facebookController = TextEditingController();
  TextEditingController _instagramController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUserProfile();
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

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final bio = prefs.getString('bio') ?? '';
    final email = prefs.getString('email') ?? '';
    final phone = prefs.getString('phone') ?? '';
    final dob = prefs.getString('dob') ?? '';
    final facebook = prefs.getString('facebook') ?? '';
    final instagram = prefs.getString('instagram') ?? '';

    _usernameController.text = username;
    _bioController.text = bio;
    _emailController.text = email;
    _phoneController.text = phone;
    _dobController.text = dob;
    _facebookController.text = facebook;
    _instagramController.text = instagram;
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image updated successfully.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied")),
      );
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // Save user info locally
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('bio', _bioController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('dob', _dobController.text);
    await prefs.setString('facebook', _facebookController.text);
    await prefs.setString('instagram', _instagramController.text);

    // Update email in Firebase
    await _updateEmail();

    // Update phone number in Firebase
    await _updatePhoneNumber();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully.")),
    );

    Navigator.pop(context);
  }

Future<void> _updateEmail() async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      String newEmail = _emailController.text.trim();

      if (newEmail.isNotEmpty && newEmail != user.email) {
        // تحديث البريد الإلكتروني في Firebase
        await user.updateEmail(newEmail);
        
        // إعادة تحميل المستخدم للحصول على البريد الإلكتروني المحدث
        await user.reload();

        // إرسال بريد إلكتروني للتحقق من البريد الإلكتروني الجديد
        await user.sendEmailVerification();

        // حفظ البريد الإلكتروني الجديد في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', newEmail);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم تحديث البريد الإلكتروني بنجاح. يرجى التحقق من بريدك الإلكتروني.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("البريد الإلكتروني الجديد هو نفسه البريد الإلكتروني الحالي.")),
        );
      }
    }
  } catch (e) {
    print('Error updating email: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("خطأ في تحديث البريد الإلكتروني: $e")),
    );
  }
}


  Future<void> _updatePhoneNumber() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        String newPhoneNumber = _phoneController.text.trim();

        if (newPhoneNumber.isNotEmpty) {
          await _auth.verifyPhoneNumber(
            phoneNumber: newPhoneNumber,
            verificationCompleted: (PhoneAuthCredential credential) async {
              await user.updatePhoneNumber(credential);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Phone number updated successfully.")),
              );
            },
            verificationFailed: (FirebaseAuthException e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to verify phone: ${e.message}")),
              );
            },
            codeSent: (String verificationId, int? resendToken) async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Verification code sent. Please verify manually.")),
              );
            },
            codeAutoRetrievalTimeout: (String verificationId) {},
          );
        }
      }
    } catch (e) {
      print('Error updating phone number: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating phone: $e")),
      );
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
                'EditProfile',
                style: TextStyle(
                  fontSize: 38,
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
        color: Color.fromARGB(255, 243, 242, 242),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 20, 51, 21).withOpacity(0.4),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(Icons.camera_alt, color: Colors.white, size: 40)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.edit, color: Color(0xFF0F4D30)),
                  label: const Text(
                    "Change Profile Image",
                    style: TextStyle(color: Color(0xFF0F4D30)),
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 3,
                  color: Color.fromARGB(255, 226, 226, 226),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: Color.fromARGB(255, 0, 0, 0),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            prefixIcon: Icon(Icons.person, color: Color(0xFF0F4D30)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _bioController,
                          decoration: InputDecoration(
                            labelText: "Bio",
                            prefixIcon: Icon(Icons.info_outline, color: Color(0xFF0F4D30)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email, color: Color(0xFF0F4D30)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: "Phone",
                            prefixIcon: Icon(Icons.phone, color: Color(0xFF0F4D30)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _dobController,
                          decoration: InputDecoration(
                            labelText: "Date of Birth",
                            prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF0F4D30)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _facebookController,
                          decoration: InputDecoration(
                            labelText: "Facebook",
                            prefixIcon: Icon(Icons.facebook, color: Color(0xFF0F4D30)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _instagramController,
                          decoration: InputDecoration(
                            labelText: "Instagram",
                            prefixIcon: Icon(Icons.camera_alt, color: Color(0xFF0F4D30)),  

                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 18, 59, 40),
                              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
child: const Text(
  "Save Profile",
  style: TextStyle(fontSize: 18, color: Colors.white), 
),
                          ),
                        ),
                      ],
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
}



