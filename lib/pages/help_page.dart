

import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  final Color _primaryColor = const Color.fromARGB(255, 20, 71, 24);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                'Help',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTimelineStep(
            icon: Icons.lock_reset,
            title: 'How can I reset my password?',
            content: 'To reset your password:\n'
                '• Open the app and go to "Settings"\n'
                '• Tap on "Account"\n'
                '• Select "Reset Password"\n'
                '• Follow the instructions sent to your email\n\n'
                'Note: If you don’t receive the email, check your spam folder or contact support.',
          ),
          _buildTimelineStep(
            icon: Icons.add_circle_outline,
            title: 'How do I add a new product?',
            content: 'To add a new product:\n'
                '• Go to the Home page\n'
                '• Tap the "+" floating button in the bottom corner\n'
                '• Fill in product name, description, quantity, and price\n'
                '• Upload a photo of the product (optional)\n'
                '• Press "Submit" to add it to your list\n\n'
                'You can always edit or delete products from your profile later.',
          ),

          _buildTimelineStep(
            icon: Icons.book_outlined,
            title: 'Where can I find user guides?',
            content: 'User guides and tutorials are available in-app:\n'
                '• Open the side menu and tap on "User Guide"\n'
                '• Explore topics like "Setting up your profile", "Managing your farm", and "Irrigation Tips"\n'
                '• All guides include step-by-step instructions and screenshots\n\n'
                'Coming soon: Video tutorials!',
          ),
          _buildTimelineStep(
            icon: Icons.lock,
            title: 'Is my data safe?',
            content: 'Absolutely. GreenGrow takes privacy seriously:\n'
                '• All data is encrypted using secure protocols\n'
                '• No personal information is shared without consent\n'
                '• You can delete your account anytime from Settings\n\n'
                'See our full Privacy Policy under the "Legal" section in the app.',
          ),
          _buildTimelineStep(
            icon: Icons.lightbulb_outline,
            title: 'Tips for getting the most out of the app',
            content: '• Enable notifications for crop reminders and weather alerts\n'
                '• Use the calendar to schedule planting and irrigation\n'
                '• Join the community forum for tips from other farmers\n'
                '• Update your app regularly to enjoy new features',
          ),
                    _buildTimelineStep(
            icon: Icons.support_agent,
            title: 'How do I contact support?',
            content: 'We’re here to help you in multiple ways:\n'
                '• 📧 Email: support@greengrow.com (24/7)\n'
                '• 📞 Phone: +123-456-7890 (Weekdays 9AM–6PM)\n'
                '• 💬 Live Chat: Available in-app under "Contact Us"\n\n'
                'Live agents are online Monday–Friday to assist you in real-time.',
          ),
          const SizedBox(height: 30),
          _buildFooterNote(),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                backgroundColor: _primaryColor,
                radius: 20,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Container(
                width: 2,
                height: 80,
                color: Colors.grey[400],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(content, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Center(
      child: Text(
        '© 2025 GreenGrow. All rights reserved.',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
    );
  }
}
