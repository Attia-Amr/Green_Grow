import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellow/pages/register_page.dart';
import 'package:hellow/main_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  // Load saved 'remember me' status and credentials
  Future<void> _loadRememberMe() async {
    String? rememberMe = await _secureStorage.read(key: 'rememberMe');
    if (rememberMe == 'true') {
      setState(() {
        _rememberMe = true;
      });
      _emailController.text = await _secureStorage.read(key: 'email') ?? '';
      _passwordController.text = await _secureStorage.read(key: 'password') ?? '';
    }
  }

  // Save 'remember me' status and credentials to secure storage
  Future<void> _saveRememberMe() async {
    await _secureStorage.write(key: 'rememberMe', value: _rememberMe ? 'true' : 'false');
    if (_rememberMe) {
      await _secureStorage.write(key: 'email', value: _emailController.text);
      await _secureStorage.write(key: 'password', value: _passwordController.text);
    } else {
      await _secureStorage.delete(key: 'email');
      await _secureStorage.delete(key: 'password');
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 230,
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              "images/sio.jpg",
              fit: BoxFit.cover,

            ),
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.6,
          maxChildSize: 0.70,
          builder: (context, scrollController) {
            return ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: Color.fromARGB(255, 41, 73, 43),
                              shadows: [Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.black)],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField("Email", controller: _emailController),
                      const SizedBox(height: 20),
                      _buildTextField("Password", controller: _passwordController, isPassword: true),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val!;
                                  });
                                },
                                activeColor: Color.fromARGB(255, 15, 77, 48),
                              ),
                              const Text(
                                "Remember me",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 15, 77, 48),
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _resetPassword,
                            child: const Text(
                              "Forget password?",
                              style: TextStyle(
                                color: Color.fromARGB(255, 15, 77, 48),
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 41, 73, 43),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              shadows: [
                                Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            "Don't Have An Acc? Register",
                            style: TextStyle(
                              color: Color.fromARGB(255, 28, 70, 50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}




  Widget _buildTextField(String hint, {bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 108, 114, 112), fontStyle: FontStyle.italic),
        filled: true,
        fillColor: const Color.fromARGB(255, 118, 163, 108).withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Login function
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please fill in both fields")),
      );
      return;
    }

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        _saveRememberMe();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const NavigationScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Login Failed. Check your credentials")),
      );
    }
  }

  // Reset password function
  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please enter your email to reset your password")),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Password reset link sent to your email")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to send reset link. Please check the email")),
      );
    }
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 50);
    path.quadraticBezierTo(size.width / 4, 0, size.width / 2, 30);
    path.quadraticBezierTo(3 * size.width / 4, 60, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
