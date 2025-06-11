import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellow/pages/login_page.dart';
import 'package:hellow/main_app.dart';
import 'package:hellow/pages/sign_page.dart'; // تأكد إنه يحتوي على NavigationScreen


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const SignPage(); // دايمًا يفتح صفحة تسجيل الدخول
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("❌ حدث خطأ في الاتصال بـ Firebase")),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // تحميل
          );
        }
      },
    );
  }
}