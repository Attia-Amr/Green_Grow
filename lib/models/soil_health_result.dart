/*
GREENGROW APP - SOIL HEALTH RESULT MODEL

This file defines the SoilHealthResult class which evaluates and reports on soil quality metrics.

SIMPLE EXPLANATION:
- This is like a soil report card that grades how healthy your farm's dirt is
- It gives an overall score (like 85/100) to quickly show soil quality
- It provides a simple status label (like "Good" or "Poor") that anyone can understand
- It breaks down different aspects of soil health (like nutrients, pH, texture) with individual scores
- It includes personalized recommendations to improve your soil's health

TECHNICAL EXPLANATION:
- Class implements a data model for soil analysis results
- Contains a numerical health metric (score) and categorical classification (status)
- Uses Map<String, double> structure to store component-specific metrics (componentScores)
- Includes textual recommendation field for actionable feedback
- Implements JSON serialization (toJson) for data export
- Provides factory constructor fromJson with null-safety fallbacks for deserialization
- Follows immutable design pattern with all fields marked as final

This model is typically populated from soil testing algorithms and displayed in the soil
health dashboard to help farmers understand and improve their soil conditions.
*/

// This class holds information about how healthy your soil is
// It's like a report card for your garden's dirt!
class SoilHealthResult {
  // These are the different pieces of information about your soil's health
  final double score;               // The overall health score from 0-100 (like a grade in school)
  final String status;              // A simple description like "Good", "Poor", or "Excellent"
  final String recommendation;      // Advice on how to make your soil healthier
  final Map<String, double> componentScores;  // Scores for different parts of soil health (like nutrients, pH, etc.)

  // This is the recipe for creating a new soil health result
  // It lists everything we need to make a complete soil health report
  SoilHealthResult({
    required this.score,            // Must have an overall score
    required this.status,           // Must have a status description
    required this.recommendation,   // Must have some advice
    required this.componentScores,  // Must have detailed scores for different aspects
  });

  // This special function creates a soil health result from data we got from our soil testing system
  // It's like translating a laboratory report into something our app can understand
  factory SoilHealthResult.fromJson(Map<String, dynamic> json) {
    return SoilHealthResult(
      score: json['score']?.toDouble() ?? 0.0,  // Get the overall score (or use 0.0 if missing)
      status: json['status'] ?? 'Unknown',      // Get the status (or use "Unknown" if missing)
      recommendation: json['recommendation'] ?? '',  // Get the advice (or use empty string if missing)
      componentScores: Map<String, double>.from(json['component_scores'] ?? {}),  // Get detailed scores (or use empty map if missing)
    );
  }

  // This function converts our soil health result into a format that can be saved or sent
  // It's like taking our soil report and putting it in an envelope to mail to someone
  Map<String, dynamic> toJson() {
    return {
      'score': score,                     // Store the overall score
      'status': status,                   // Store the status description
      'recommendation': recommendation,   // Store the advice
      'component_scores': componentScores,  // Store the detailed scores
    };
  }
} 