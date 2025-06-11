/*
GREENGROW APP - HELP AND SUPPORT SCREEN

This file implements the help center where users can find answers to common questions.

SIMPLE EXPLANATION:
- This is like a digital instruction manual for the farming app
- It contains frequently asked questions with tap-to-expand answers
- It provides contact information for getting additional support
- It includes guides on how to use different features of the app
- It's organized into clear sections to help you find information quickly
- It works in multiple languages thanks to the language service

TECHNICAL EXPLANATION:
- Implements an expandable FAQ interface using ExpansionTile widgets
- Organized in a section-based architecture for better information hierarchy
- Uses AutomaticKeepAliveClientMixin to preserve expansion state during navigation
- Implements LanguageService for internationalization of help content
- Contains custom styling with themed headers and card-based content areas
- Uses stack-based layout for custom header with proper status bar integration
- Maintains navigation context with CustomBottomNav implementation
- Contains specialized handling for contact information vs. translated content
- Uses responsive layout principles for cross-device compatibility
- Serves as a central knowledge repository for application features

This screen helps reduce support requests by providing self-service information
while improving user confidence through clear documentation of app features.
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/language_service.dart';
import '../services/theme_service.dart';


import 'profile_screen.dart';
import '../utils/page_transition.dart';

/// HelpScreen provides users with FAQ, support information, and usage guides
/// This screen serves as the central knowledge base for users to learn about app features
class HelpScreen extends StatefulWidget {
  // Simple constructor with no additional parameters needed
  const HelpScreen({super.key});

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

/// State class for the HelpScreen that manages UI state and expandable sections
class _HelpScreenState extends State<HelpScreen> with AutomaticKeepAliveClientMixin {
  // Add keep alive override
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    // Wrap entire screen with directional widget to support RTL languages
    return LanguageService.wrapWithDirectional(
      context: context,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Header container that extends behind status bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      LanguageService.translate(context, 'help'),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 40), // Balance for back button
                  ],
                ),
              ),
            ),
            // Main content
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Frequently Asked Questions section
                      _buildSection(
                        context,
                        'faq',
                        [
                          // FAQ about plant prediction feature
                          {
                            'question': 'faq_plant_prediction',
                            'answer': 'faq_plant_prediction_answer'
                          },
                          // FAQ about irrigation recommendations
                          {
                            'question': 'faq_irrigation',
                            'answer': 'faq_irrigation_answer'
                          },
                          // FAQ about fertilizer recommendations
                          {
                            'question': 'faq_fertilizer',
                            'answer': 'faq_fertilizer_answer'
                          },
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Contact Support information section
                      _buildSection(
                        context,
                        'contact_support',
                        [
                          // Support email address
                          {
                            'question': 'email',
                            'answer': 'support@greengrow.com'
                          },
                          // Support phone number
                          {
                            'question': 'phone',
                            'answer': '+1 (555) 123-4567'
                          },
                        ],
                      ),
                      const SizedBox(height: 24),
                      // User Guide section with how-to information
                      _buildSection(
                        context,
                        'user_guide',
                        [
                          // Getting started guide for new users
                          {
                            'question': 'getting_started',
                            'answer': 'getting_started_guide'
                          },
                          // Guide for managing plant records
                          {
                            'question': 'managing_plants',
                            'answer': 'managing_plants_guide'
                          },
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }

  /// Creates a help section with a title and list of expandable items
  /// Each section groups related help topics for better organization
  Widget _buildSection(BuildContext context, String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with emphasized styling
        Text(
          LanguageService.translate(context, title),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Map each item in the section to an expansion tile
        ...items.map((item) {
          // Special handling for contact information (don't translate email/phone)
          final answer = item['answer']!;
          final isContact = answer.contains('@') || answer.contains('+');
          
          return _buildExpansionTile(
            LanguageService.translate(context, item['question']!),
            isContact ? answer : LanguageService.translate(context, answer),
          );
        }),
      ],
    );
  }

  /// Creates an expandable card for each question/answer pair
  /// Users can tap to expand and view the detailed answer
  Widget _buildExpansionTile(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(title), // Question or topic title
        children: [
          // Answer content revealed when expanded
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content),
          ),
        ],
      ),
    );
  }
} 