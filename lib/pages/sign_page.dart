
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hellow/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:hellow/main_app.dart'; // ✅ استيراد NavigationScreen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellow/pages/register_page.dart'; 

class SignPage extends StatelessWidget {
  const SignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ صورة الخلفية
          Image.asset(
            "images/sio.jpg",
            fit: BoxFit.cover,
          ),

          // ✅ طبقة تغميق شفافة فوق الصورة
          Container(
         //   color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1), // يمكنك تقليل أو زيادة القيمة بين 0.1 و 0.6 حسب رغبتك
          ),

          // ✅ المحتوى الأمامي
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Text(
                    "The Best App For Your Agricultural Land",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 206, 216, 211),
                      shadows: [
                        Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black)
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 165),

                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 211, 226, 219).withOpacity(0.5),
                        fixedSize: const Size(280, 50),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Color.fromARGB(255, 210, 224, 217),
                          fontSize: 23,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(offset: Offset(4, 2), blurRadius: 4, color: Colors.black)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Create an account",
                        style: TextStyle(color: Color.fromARGB(255, 234, 247, 240), fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
