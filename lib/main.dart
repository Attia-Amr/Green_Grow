import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hellow/main_app.dart';
import 'package:hellow/services/analysis_provider.dart';
import 'package:hellow/services/analysis_service.dart';
import 'package:hellow/services/ml_service.dart';
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  Firebase.initializeApp();
  // Force portrait orientation for consistent UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize ML service for predictions
  final mlService = MLService();
  await mlService.initialize();

  // Initialize analysis service
  final analysisService = AnalysisService();
  bool isInitialized = false;
  try {
    await analysisService.initialize();
    isInitialized = true;
  } catch (e) {
    print('Error initializing AnalysisService: $e');
    // Continue with initialization false - the app will handle this state
  }

  // Run app with analysis provider wrapper
  runApp(
    AnalysisProvider(
      analysisService: analysisService,
      isInitialized: isInitialized,
      child: const MyApp(),
    ),
  );
}


//Color.fromARGB(255, 243, 242, 242)