// import 'package:flutter/material.dart';

// class AboutUsPage extends StatelessWidget {
//   const AboutUsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(85),
      //   child: ClipRRect(
      //     borderRadius: BorderRadius.only(
      //       bottomLeft: Radius.circular(20),
      //       bottomRight: Radius.circular(20),
      //     ),
      //     child: AppBar(
      //       leading: Padding(
      //         padding: const EdgeInsets.only(top: 15),
      //         child: IconButton(
      //           icon: const Icon(Icons.arrow_back),
      //           onPressed: () {
      //             Navigator.pop(context);
      //           },
      //           color: Colors.white,
      //         ),
      //       ),
      //       title: Padding(
      //         padding: const EdgeInsets.only(top: 20),
      //         child: const Text(
      //           'About Us',
      //           style: TextStyle(
      //             fontSize: 38,
      //             fontWeight: FontWeight.bold,
      //             fontStyle: FontStyle.italic,
      //             color: Color.fromARGB(255, 238, 241, 240),
      //             shadows: [
      //               Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black)
      //             ],
      //           ),
      //         ),
      //       ),
      //       flexibleSpace: Container(
      //         decoration: BoxDecoration(
      //           gradient: LinearGradient(
      //             colors: [
      //               Color.fromARGB(255, 15, 77, 48),
      //               Color.fromARGB(255, 5, 14, 8),
      //             ],
      //             stops: [0.3, 6.0],
      //             end: Alignment.topLeft,
      //             begin: Alignment.bottomRight,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Container(
//           color: Color.fromARGB(255, 250, 248, 248),  // تعيين لون الخلفية هنا
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [
//               SizedBox(height: 10),
//               Text(
//                 'Welcome to GreenGrow 🌱',
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Cairo',
//                   color: Color(0xFF2A612E),
//                 ),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'GreenGrow is your smart farming companion. Our goal is to empower farmers, agricultural engineers, and enthusiasts with a digital solution that revolutionizes how agriculture is practiced through modern technologies.',
//                 style: TextStyle(
//                   fontSize: 17,
//                   height: 1.6,
//                   fontFamily: 'Cairo',
//                   color: Color(0xFF4E4E4E),
//                 ),
//               ),
//               SizedBox(height: 30),
//               Text(
//                 '📌 What We Offer',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Cairo',
//                   color: Color(0xFF2A612E),
//                 ),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 '• **Soil Analysis & Crop Recommendations:**\n  Enter your soil properties (e.g., pH, moisture, texture), and we’ll suggest the best crops for your land.\n\n'
//                 '• **Smart Irrigation Planning:**\n  Use sensor-based irrigation recommendations to optimize water usage and save resources.\n\n'
//                 '• **Growth Tracking:**\n  Log and monitor your crop growth stages, including fertilizers, pesticides, and harvests.\n\n'
//                 '• **Shopping Section:**\n  Buy and sell crops, fertilizers, and agricultural tools directly from the app.\n\n'
//                 '• **Expert Chat:**\n  Need help? Chat directly with agricultural experts for real-time advice.\n\n'
//                 '• **Community Hub:**\n  Share photos, tips, and experiences with other farmers in a dedicated social space.',
//                 style: TextStyle(
//                   fontSize: 16,
//                   height: 1.7,
//                   fontFamily: 'Cairo',
//                   color: Color(0xFF4E4E4E),
//                 ),
//               ),
//               SizedBox(height: 30),
//               Text(
//                 '🎯 Our Mission',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Cairo',
//                   color: Color(0xFF2A612E),
//                 ),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 'We aim to build a future where agriculture is more efficient, sustainable, and accessible to everyone. With GreenGrow, we bridge the gap between traditional farming and modern smart agriculture through innovation, data, and community.',
//                 style: TextStyle(
//                   fontSize: 16,
//                   height: 1.7,
//                   fontFamily: 'Cairo',
//                   color: Color(0xFF4E4E4E),
//                 ),
//               ),
//               SizedBox(height: 30),
//               Text(
//                 '📞 Get in Touch',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Cairo',
//                   color: Color(0xFF2A612E),
//                 ),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 '• Email: support@greengrow.com\n'
//                 '• Phone: +20 123-456-7890\n'
//                 '• Address: Smart Agriculture Center, Cairo University, Egypt\n'
//                 '• Instagram: @greengrow_app\n'
//                 '• Facebook: GreenGrow App',
//                 style: TextStyle(
//                   fontSize: 16,
//                   height: 1.6,
//                   fontFamily: 'Cairo',
//                   color: Color(0xFF4E4E4E),
//                 ),
//               ),
//               SizedBox(height: 40),
//               Center(
//                 child: Text(
//                   '© 2025 GreenGrow Team – All rights reserved.',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontFamily: 'Cairo',
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
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
                'About Us',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildCard(
              icon: Icons.eco,
              title: 'Welcome to GreenGrow 🌱',
              content:
                  'GreenGrow is your smart farming companion. Our goal is to empower farmers, engineers, and enthusiasts with a digital solution that modernizes agriculture using technology.',
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.handshake,
              title: 'What We Offer',
              content:
                  '• Soil Analysis & Crop Recommendations\n'
                  '• Smart Irrigation Planning\n'
                  '• Growth Tracking\n'
                  '• Shopping Section\n'
                  '• Expert Chat\n'
                  '• Community Hub',
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.flag,
              title: 'Our Mission 🎯',
              content:
                  'We aim to build a future where agriculture is efficient, sustainable, and accessible. GreenGrow bridges the gap between traditional farming and smart agriculture.',
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.contact_mail,
              title: 'Get in Touch 📞',
              content:
                  '• Email: support@greengrow.com\n'
                  '• Phone: +20 123-456-7890\n'
                  '• Address: Cairo University, Egypt\n'
                  '• Instagram: @greengrow_app\n'
                  '• Facebook: GreenGrow App',
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                '© 2025 GreenGrow Team – All rights reserved.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black12,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A612E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 26, color: const Color(0xFF2A612E)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.6,
                fontFamily: 'Cairo',
                color: Color(0xFF4E4E4E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
