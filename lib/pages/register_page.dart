// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'login_page.dart';
// import 'package:hellow/main_app.dart'; // ✅ استيراد NavigationScreen
// import 'package:firebase_auth/firebase_auth.dart';

// class RegisterPage extends StatefulWidget {    
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//  void _register() async {
//   final name = _nameController.text.trim();
//   final email = _emailController.text.trim();
//   final password = _passwordController.text.trim();
//   final confirmPassword = _confirmPasswordController.text.trim();

//   if (password != confirmPassword) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Passwords do not match")),
//     );
//     return;
//   }

//   try {
//     final userCredential = await _auth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );

//     if (userCredential.user != null) {
//       // ✅ رجّع المستخدم إلى صفحة تسجيل الدخول
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Registration successful. Please log in.")),
//       );
// Navigator.of(context).pushAndRemoveUntil(
//   MaterialPageRoute(builder: (context) => const NavigationScreen()),
//   (Route<dynamic> route) => false,
// );

//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Registration failed: ${e.toString()}")),
//     );
//   }
// }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     resizeToAvoidBottomInset: true,
//     body: Stack(
//       children: [
//         Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("images/Register.jpg"),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Register",
//                   style: TextStyle(
//                     fontSize: 63,
//                     fontWeight: FontWeight.bold,
//                     fontStyle: FontStyle.italic,
//                     color: Color.fromARGB(255, 41, 73, 43),
//                     shadows: [Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.black)],
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 const Text(
//                   "Create your new account",
//                   style: TextStyle(
//                     fontSize: 17,
//                     color: Color.fromARGB(121, 8, 8, 8),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 60),
//                 _buildTextField("Name", controller: _nameController),
//                 const SizedBox(height: 20),
//                 _buildTextField("Email", controller: _emailController),
//                 const SizedBox(height: 20),
//                 _buildTextField("Password", isPassword: true, controller: _passwordController),
//                 const SizedBox(height: 20),
//                 _buildTextField("Confirm Password", isPassword: true, controller: _confirmPasswordController),
//                 const SizedBox(height: 50),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _register,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 41, 73, 43),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                     ),
//                     child: const Text(
//                       "Register",
//                       style: TextStyle(
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         fontStyle: FontStyle.italic,
//                         shadows: [Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black)],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Already Have An Account? ",
//                         style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamed(context, '/login');
//                       },
//                       child: const Text(
//                         "Sign In",
//                         style: TextStyle(
//                           color: Color.fromARGB(210, 48, 98, 49),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }


//   Widget _buildTextField(String hint, {bool isPassword = false, required TextEditingController controller}) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword,
//       style: const TextStyle(color: Color.fromARGB(255, 30, 63, 48)),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Color.fromARGB(255, 108, 114, 112), fontStyle: FontStyle.italic),
//         filled: true,
//         fillColor: const Color.fromARGB(255, 118, 163, 108).withOpacity(0.4),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(25),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellow/main_app.dart'; // ✅ استيراد NavigationScreen
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // ✅ إضافة كنترولر للهاتف
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _register() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim(); // ✅ التقاط رقم الهاتف
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // ✅ تحديث بيانات المستخدم (اسم فقط بدون محاولة تحديث رقم الهاتف)
        await userCredential.user!.updateDisplayName(name);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful. Please log in.")),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()), // ✅ تعديل: رجوع للوجن بدل الهوم
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Register.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 63,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 41, 73, 43),
                      shadows: [Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "Create your new account",
                    style: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(121, 8, 8, 8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 60),
                  _buildTextField("Name", controller: _nameController),
                  const SizedBox(height: 20),
                  _buildTextField("Phone Number", controller: _phoneController), // ✅ إضافة حقل الهاتف
                  const SizedBox(height: 20),
                  _buildTextField("Email", controller: _emailController),
                  const SizedBox(height: 20),
                  _buildTextField("Password", isPassword: true, controller: _passwordController),
                  const SizedBox(height: 20),
                  _buildTextField("Confirm Password", isPassword: true, controller: _confirmPasswordController),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 41, 73, 43),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          shadows: [Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already Have An Account? ",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Color.fromARGB(210, 48, 98, 49),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Color.fromARGB(255, 30, 63, 48)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 108, 114, 112), fontStyle: FontStyle.italic),
        filled: true,
        fillColor: const Color.fromARGB(255, 133, 170, 125).withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
