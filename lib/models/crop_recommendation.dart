/*
GREENGROW APP - CROP RECOMMENDATION MODEL

This file defines the CropRecommendation class which provides farming advice based on soil analysis.

SIMPLE EXPLANATION:
- This is like a farming advisor that suggests what plants will grow best in your soil
- It gives you a main recommendation plus backup options if the first choice doesn't work
- It includes scores showing how well each crop should grow in your specific conditions
- It provides special growing instructions for each crop (like when to plant, how to care for it)

TECHNICAL EXPLANATION:
- Class implements a data model for storing crop prediction results
- Contains primary recommendation (recommendedCrop) and alternative options (alternativeCrops)
- Uses Map<String, double> structure to store numerical suitability ratings for each crop
- Uses Map<String, String> structure to store text-based growing instructions for each crop
- Implements JSON serialization (toJson) for data export
- Implements factory constructor fromJson for deserialization with null-safety fallbacks
- All fields are final, following immutable data pattern for predictable state management

This model is typically populated with results from the machine learning crop prediction
system and displayed to users to help them make informed planting decisions.
*/

// This class holds information about what crops would grow best in your field
// It's like getting advice from a farming expert about what to plant
class CropRecommendation {
  // These are the different pieces of information in our recommendation
  final String recommendedCrop;          // The best crop to grow (like "tomatoes" or "wheat")
  final List<String> alternativeCrops;   // Other crops that could grow well too (like a backup plan)
  final Map<String, double> suitabilityScores;  // Numbers that show how good each crop would grow (like grades in school)
  final Map<String, String> growingConditions;  // Special instructions for growing each crop (like a recipe)

  // This is the recipe for creating a new crop recommendation
  // It lists everything we need to make a complete recommendation
  CropRecommendation({
    required this.recommendedCrop,       // Must have a best crop
    required this.alternativeCrops,      // Must have backup crops
    required this.suitabilityScores,     // Must have scores for each crop
    required this.growingConditions,     // Must have growing instructions
  });

  // This special function creates a recommendation from data we got from our farming expert system
  // It's like translating the expert's notes into something our app can understand
  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      recommendedCrop: json['recommended_crop'] ?? '',  // Get the best crop (or use empty string if missing)
      alternativeCrops: List<String>.from(json['alternative_crops'] ?? []),  // Get backup crops (or use empty list if missing)
      suitabilityScores: Map<String, double>.from(json['suitability_scores'] ?? {}),  // Get crop scores (or use empty map if missing)
      growingConditions: Map<String, String>.from(json['growing_conditions'] ?? {}),  // Get growing instructions (or use empty map if missing)
    );
  }

  // This function converts our recommendation into a format that can be saved or sent
  // It's like writing down the advice so we can share it with others
  Map<String, dynamic> toJson() {
    return {
      'recommended_crop': recommendedCrop,      // Store the best crop
      'alternative_crops': alternativeCrops,    // Store the backup crops
      'suitability_scores': suitabilityScores,  // Store the scores for each crop
      'growing_conditions': growingConditions,  // Store the growing instructions
    };
  }
} 