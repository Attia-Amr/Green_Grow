/*
GREENGROW APP - ANALYSIS PROVIDER

This file implements a dependency injection system for making analysis services available throughout the app.

SIMPLE EXPLANATION:
- This is like a central broadcast system that shares the soil analysis tools with all parts of the app
- It makes sure every screen can access the same soil and plant analysis features
- It avoids having to pass the analysis tools manually to each screen
- It ensures all app features are using the same consistent analysis methods
- It provides quick access to important crop data like crop types and recommendations

TECHNICAL EXPLANATION:
- Implements the InheritedWidget pattern for dependency injection of AnalysisService
- Contains static accessor methods for service retrieval from any widget in the tree
- Implements specialized data access methods for common analysis operations
- Contains widget tree traversal optimization with context.dependOnInheritedWidgetOfExactType
- Implements proper update notifications with updateShouldNotify
- Provides type-safe service access with compile-time validation
- Handles initialization state tracking to prevent access to uninitialized services
- Contains defensive programming with null checking and error handling
- Implements widget rebuilding optimization by controlling when notifications are triggered

This provider serves as the central access point for all analysis capabilities,
ensuring consistent service availability throughout the widget tree.
*/

import 'package:flutter/material.dart';
import 'analysis_service.dart';

/// AnalysisProvider is an InheritedWidget that serves as a dependency injection container
/// for the AnalysisService throughout the application. It provides:
/// - Global access to analysis functionality
/// - Consistent service instance management
/// - Type-safe service retrieval
/// - Efficient widget tree traversal for service access
class AnalysisProvider extends InheritedWidget {
  /// The AnalysisService instance that will be made available to descendant widgets
  /// This service handles all plant analysis and prediction functionality
  final AnalysisService analysisService;
  
  /// Whether the service has been initialized
  final bool isInitialized;

  /// Creates a new AnalysisProvider
  /// 
  /// [key] - Optional widget key for identification
  /// [analysisService] - The AnalysisService instance to provide
  /// [isInitialized] - Whether the service has been initialized
  /// [child] - The widget subtree that will have access to the service
  const AnalysisProvider({
    Key? key,
    required this.analysisService,
    required this.isInitialized,
    required Widget child,
  }) : super(key: key, child: child);
  
  /// Static method to retrieve the AnalysisService from the nearest AnalysisProvider ancestor
  /// 
  /// [context] - The BuildContext to search for the provider
  /// 
  /// Returns the AnalysisService instance
  /// 
  /// Throws a FlutterError if no AnalysisProvider is found in the widget tree
  static AnalysisService of(BuildContext context) {
    // Find the nearest AnalysisProvider in the widget tree
    final AnalysisProvider? provider = context.dependOnInheritedWidgetOfExactType<AnalysisProvider>();
    if (provider == null) {
      throw FlutterError('No AnalysisProvider found in context');
    }
    return provider.analysisService;
  }

  /// Get available crop types from the service
  /// Returns an empty list if the service is not initialized
  static List<String> getCropTypes(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AnalysisProvider>();
    if (provider == null || !provider.isInitialized) {
      return [];
    }
    return provider.analysisService.availableCropTypes;
  }

  /// Check if a crop type is valid
  static bool isValidCropType(BuildContext context, String cropType) {
    final provider = context.dependOnInheritedWidgetOfExactType<AnalysisProvider>();
    if (provider == null || !provider.isInitialized) {
      return false;
    }
    return provider.analysisService.isValidCropType(cropType);
  }

  /// Get a default crop type
  static String? getDefaultCropType(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AnalysisProvider>();
    if (provider == null || !provider.isInitialized) {
      return null;
    }
    return provider.analysisService.getDefaultCropType();
  }
  
  /// Determines whether descendant widgets should be notified of changes
  @override
  bool updateShouldNotify(AnalysisProvider oldWidget) => 
      isInitialized != oldWidget.isInitialized ||
      analysisService != oldWidget.analysisService;
} 