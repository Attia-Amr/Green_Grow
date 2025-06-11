/*
GREENGROW APP - FERTILIZER RECOMMENDATION MODEL

This file defines the FertilizerRecommendation class which suggests the optimal plant nutrients for crops.

SIMPLE EXPLANATION:
- This is like a plant nutrition expert that tells you what vitamins your plants need
- It suggests the best fertilizer for your specific soil and crop type
- It provides backup options if you can't find the main recommended fertilizer
- It tells you exactly what nutrients your soil is missing (like nitrogen or phosphorus)
- It explains how to apply the fertilizer (amount, frequency, method) and why it works

TECHNICAL EXPLANATION:
- Class implements a data model for fertilizer prediction results
- Contains primary recommendation (recommendedFertilizer) and alternatives (alternativeFertilizers)
- Uses Map<String, double> to store quantified soil nutrient deficiencies
- Stores textual application instructions and descriptive content as String fields
- Implements JSON serialization (toJson) for data persistence
- Provides factory constructor fromJson with null-safety fallbacks for deserialization
- Uses immutable design pattern with all final fields for consistency

This model is populated with results from the fertilizer recommendation algorithm and
displays actionable nutrient management advice to farmers based on their soil test data.
*/

// This class holds information about what plant food (fertilizer) would be best for your crops
// It's like getting advice from a garden expert about what vitamins to give your plants
class FertilizerRecommendation {
  // These are the different pieces of information in our fertilizer advice
  final String recommendedFertilizer;     // The best plant food to use (like "Super Grow" or "Plant Boost")
  final List<String> alternativeFertilizers; // Other plant foods that would work well too (backup options)
  final Map<String, double> soilDeficiencies; // What nutrients your soil is missing (like vitamins your plants need)
  final String applicationInstructions;   // How to use the plant food (like "sprinkle 1 cup every week")
  final String description;               // More details about the plant food and why it's good

  // This is the recipe for creating a new fertilizer recommendation
  // It lists everything we need to make a complete recommendation about plant food
  FertilizerRecommendation({
    required this.recommendedFertilizer,    // Must have a best fertilizer
    required this.alternativeFertilizers,   // Must have backup fertilizers
    required this.soilDeficiencies,         // Must know what nutrients are missing
    required this.applicationInstructions,  // Must know how to use it
    required this.description,              // Must have details about it
  });

  // This special function creates a recommendation from data we got from our garden expert system
  // It's like translating the expert's advice into something our app can understand
  factory FertilizerRecommendation.fromJson(Map<String, dynamic> json) {
    return FertilizerRecommendation(
      recommendedFertilizer: json['recommended_fertilizer'] ?? '',  // Get the best fertilizer (or use empty string if missing)
      alternativeFertilizers: List<String>.from(json['alternative_fertilizers'] ?? []),  // Get backup fertilizers (or use empty list if missing)
      soilDeficiencies: Map<String, double>.from(json['soil_deficiencies'] ?? {}),  // Get missing nutrients (or use empty map if missing)
      applicationInstructions: json['application_instructions'] ?? '',  // Get usage instructions (or use empty string if missing)
      description: json['description'] ?? '',  // Get details (or use empty string if missing)
    );
  }

  // This function converts our recommendation into a format that can be saved or sent
  // It's like writing down the advice so we can share it with other farmers
  Map<String, dynamic> toJson() {
    return {
      'recommended_fertilizer': recommendedFertilizer,      // Store the best fertilizer name
      'alternative_fertilizers': alternativeFertilizers,    // Store the backup fertilizer names
      'soil_deficiencies': soilDeficiencies,                // Store what nutrients are missing
      'application_instructions': applicationInstructions,  // Store how to use it
      'description': description,                           // Store details about it
    };
  }
} 