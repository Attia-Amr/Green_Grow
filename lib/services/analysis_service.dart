/*
GREENGROW APP - ANALYSIS SERVICE

This file implements the core agricultural analysis and recommendation system.

SIMPLE EXPLANATION:
- This is the brain of the app that analyzes soil data and tells you what to grow
- It checks your soil nutrients (nitrogen, phosphorus, potassium) to recommend crops
- It suggests the best fertilizers based on what you're growing and your soil condition
- It rates your soil health and explains what's good or bad about it
- It predicts crop yields based on your soil and weather conditions
- It works offline when internet isn't available using stored data
- It calculates exactly what nutrients your soil is missing

TECHNICAL EXPLANATION:
- Implements a comprehensive agricultural analysis engine with multiple analysis modes
- Contains machine learning integration through MLService for crop and fertilizer prediction
- Implements soil health assessment algorithms with component-based scoring
- Contains offline fallback mechanisms using cached model data
- Implements batch processing capabilities for analyzing multiple samples
- Contains resource efficient caching using DataCacheService
- Implements detailed text formatting for human-readable result presentation
- Contains API integration with fallback to local calculation when API is unavailable
- Implements normalized data processing for machine learning compatibility
- Contains comprehensive error handling with graceful degradation

This service is the core domain logic component of the application, providing
all agricultural calculations and recommendations through various specialized methods.
*/

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/agricultural_data.dart';
import '../constants/api_constants.dart';
import '../models/crop_recommendation.dart';
import '../models/fertilizer_recommendation.dart';
import '../models/soil_health_result.dart';
import 'ml_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import '../services/data_cache_service.dart';

class AnalysisService {
  final MLService _mlService = MLService();
  static const String _modelDataPath = 'assets/models/model_data.json';
  static const String _cropDataPath = 'assets/models/crop_data.json';
  Map<String, dynamic>? _modelData;
  List<Map<String, dynamic>>? _cropData;
  
  // Add offline data storage
  static const String _offlineDataKey = 'offline_analysis_data';
  final Map<String, AgriculturalData> _offlineCache = {};

  // Cache for crop types
  List<String>? _availableCropTypes;

  /// Get available crop types from the loaded data
  List<String> get availableCropTypes {
    if (_availableCropTypes != null) return List.unmodifiable(_availableCropTypes!);
    
    if (_cropData == null) {
      throw Exception('Crop data not loaded. Call initialize() first.');
    }

    // Extract unique crop types from the data
    _availableCropTypes = _cropData!
        .map((entry) => entry['label'].toString())
        .where((label) => label.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return List.unmodifiable(_availableCropTypes!);
  }

  /// Initialize the service by loading required data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Starting AnalysisService initialization...');
      
      // Load crop data from cache
      print('Loading crop data...');
      _cropData = await DataCacheService.getCropData();
      print('Crop data loaded: ${_cropData?.length ?? 0} entries');

      // Extract crop types immediately after loading data
      if (_cropData != null) {
        _availableCropTypes = _cropData!
            .map((entry) => entry['label'].toString())
            .where((label) => label.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        print('Available crop types: ${_availableCropTypes?.length ?? 0}');
      }

      // Load fertilizer data from cache
      print('Loading fertilizer data...');
      _fertilizerData = await DataCacheService.getFertilizerData();
      print('Fertilizer data loaded: ${_fertilizerData.length} entries');

      _isInitialized = true;
      print('AnalysisService initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing AnalysisService: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Check if a crop type is valid (exists in our dataset)
  bool isValidCropType(String cropType) {
    return availableCropTypes.contains(cropType);
  }

  /// Get a default crop type (first available one)
  String getDefaultCropType() {
    return availableCropTypes.first;
  }

  // Add detailed soil health ranges
  static const Map<String, Map<String, dynamic>> _soilHealthRanges = {
    'ph': {
      'optimal': {'min': 6.0, 'max': 7.5},
      'acceptable': {'min': 5.5, 'max': 8.0},
      'status': {
        'poor': 'Soil pH needs adjustment',
        'fair': 'Soil pH is acceptable but could be improved',
        'good': 'Soil pH is in optimal range'
      }
    },
    'nitrogen': {
      'optimal': {'min': 50, 'max': 100},
      'acceptable': {'min': 30, 'max': 120},
      'status': {
        'poor': 'Nitrogen deficiency detected',
        'fair': 'Nitrogen levels are adequate',
        'good': 'Nitrogen levels are optimal'
      }
    },
    'phosphorus': {
      'optimal': {'min': 40, 'max': 80},
      'acceptable': {'min': 25, 'max': 100},
      'status': {
        'poor': 'Phosphorus deficiency detected',
        'fair': 'Phosphorus levels are adequate',
        'good': 'Phosphorus levels are optimal'
      }
    },
    'potassium': {
      'optimal': {'min': 40, 'max': 80},
      'acceptable': {'min': 25, 'max': 100},
      'status': {
        'poor': 'Potassium deficiency detected',
        'fair': 'Potassium levels are adequate',
        'good': 'Potassium levels are optimal'
      }
    }
  };

  // Service state
  bool _isInitialized = false;
  List<Map<String, dynamic>> _fertilizerData = [];

  Future<AgriculturalData> analyzeSoilParameters({
    required String soilType,
    required double phLevel,
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    required double temperature,
    required double humidity,
    required double rainfall,
  }) async {
    try {
      // Get soil health assessment
      final soilHealth = _assessSoilHealth({
        'ph': phLevel,
        'nitrogen': nitrogen,
        'phosphorus': phosphorus,
        'potassium': potassium,
      });

      return AgriculturalData(
        soilType: soilType,
        pH: phLevel,
        nitrogen: nitrogen,
        phosphorus: phosphorus,
        potassium: potassium,
        temperature: temperature,
        humidity: humidity,
        rainfall: rainfall,
        cropType: '',
        predictedCrop: '',
        analysisType: 'Soil Analysis',
        notes: _formatBasicSoilHealthResult(soilHealth),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      return AgriculturalData(
        soilType: soilType,
        pH: phLevel,
        nitrogen: nitrogen,
        phosphorus: phosphorus,
        potassium: potassium,
        temperature: temperature,
        humidity: humidity,
        rainfall: rainfall,
        cropType: '',
        predictedCrop: '',
        analysisType: 'Error',
        notes: 'Error analyzing soil parameters: $e',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Future<AgriculturalData> analyzeFertilizerNeeds({
    required String cropType,
    required double nitrogen,
    required double phosphorus,
    required double potassium,
  }) async {
    if (_modelData == null) {
      throw Exception('Model data not initialized');
    }

    try {
      // Normalize input values
      final normalizedData = {
        'crop_type': cropType.toLowerCase(),
        'nitrogen': _normalizeValue(nitrogen, 0, 140),
        'phosphorus': _normalizeValue(phosphorus, 0, 145),
        'potassium': _normalizeValue(potassium, 0, 205),
      };

      // Get fertilizer recommendations
      final recommendations = _getFertilizerRecommendations(normalizedData);
      final predictedFertilizer = recommendations.first;

      // Create agricultural data object
      return AgriculturalData(
        soilType: '',  // Not relevant for fertilizer analysis
        pH: 0,        // Not relevant for fertilizer analysis
        nitrogen: nitrogen,
        phosphorus: phosphorus,
        potassium: potassium,
        temperature: 0,  // Not relevant for fertilizer analysis
        humidity: 0,    // Not relevant for fertilizer analysis
        rainfall: 0,    // Not relevant for fertilizer analysis
        cropType: cropType,
        predictedCrop: cropType,
        predictedFertilizer: predictedFertilizer,
        analysisType: 'Fertilizer Analysis',
        notes: _formatBasicFertilizerRecommendation(predictedFertilizer, normalizedData),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      return AgriculturalData(
        soilType: '',
        pH: 0,
        nitrogen: nitrogen,
        phosphorus: phosphorus,
        potassium: potassium,
        temperature: 0,
        humidity: 0,
        rainfall: 0,
        cropType: cropType,
        predictedCrop: cropType,
        analysisType: 'Error',
        notes: 'Error analyzing fertilizer needs: $e',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  double _normalizeValue(double value, double min, double max) {
    return (value - min) / (max - min);
  }

  String _normalizeSoilType(String soilType) {
    return soilType.toLowerCase().replaceAll(' ', '_');
  }

  List<String> _getCropRecommendations(Map<String, dynamic> normalizedData) {
    // This is a placeholder implementation
    // In a real application, this would use the ML model
    return ['Rice', 'Wheat', 'Maize', 'Cotton'];
  }

  List<String> _getFertilizerRecommendations(Map<String, dynamic> normalizedData) {
    // This is a placeholder implementation
    // In a real application, this would use the ML model
    return ['NPK', 'Urea', 'DAP'];
  }

  Map<String, dynamic> _assessSoilHealth(Map<String, double> data) {
    final results = <String, dynamic>{};
    
    for (var nutrient in ['ph', 'nitrogen', 'phosphorus', 'potassium']) {
      final value = data[nutrient] ?? 0.0;
      final ranges = _soilHealthRanges[nutrient]!;
      
      String status;
      if (value >= ranges['optimal']['min'] && value <= ranges['optimal']['max']) {
        status = 'good';
      } else if (value >= ranges['acceptable']['min'] && value <= ranges['acceptable']['max']) {
        status = 'fair';
      } else {
        status = 'poor';
      }
      
      results['${nutrient}_status'] = status;
      results['${nutrient}_message'] = ranges['status'][status];
    }

    // Calculate overall health score
    final scores = {
      'good': 1.0,
      'fair': 0.5,
      'poor': 0.0
    };

    double totalScore = 0;
    for (var nutrient in ['ph', 'nitrogen', 'phosphorus', 'potassium']) {
      totalScore += scores[results['${nutrient}_status']] ?? 0;
    }

    results['overall_score'] = (totalScore / 4) * 100;
    return results;
  }

  String _formatBasicSoilHealthResult(Map<String, dynamic> result) {
    final buffer = StringBuffer();
    buffer.writeln('Soil Health Analysis:');
    buffer.writeln('Overall Health Score: ${result['overall_score'].toStringAsFixed(1)}%\n');
    
    for (var nutrient in ['ph', 'nitrogen', 'phosphorus', 'potassium']) {
      buffer.writeln('${nutrient.toUpperCase()}:');
      buffer.writeln('- Status: ${result['${nutrient}_status']}');
      buffer.writeln('- ${result['${nutrient}_message']}\n');
    }
    
    return buffer.toString();
  }

  String _formatBasicFertilizerRecommendation(String fertilizer, Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('Fertilizer Recommendation:');
    buffer.writeln('- Recommended: $fertilizer');
    buffer.writeln('- Based on:');
    buffer.writeln('  * Crop: ${data['crop_type']}');
    buffer.writeln('  * Current N-P-K levels:');
    buffer.writeln('    - Nitrogen: ${(data['nitrogen'] * 140).toStringAsFixed(1)} mg/kg');
    buffer.writeln('    - Phosphorus: ${(data['phosphorus'] * 145).toStringAsFixed(1)} mg/kg');
    buffer.writeln('    - Potassium: ${(data['potassium'] * 205).toStringAsFixed(1)} mg/kg');
    return buffer.toString();
  }

  // Analyze soil data and get crop recommendations
  Future<AgriculturalData> analyzeSoilData(AgriculturalData data) async {
    try {
      // Use MLService for prediction
      final mlService = MLService();
      final predictedCrop = await mlService.predictPlant(
        soilType: data.soilType,
        phLevel: data.pH,
        phosphorus: data.phosphorus,
        potassium: data.potassium,
        nitrogen: data.nitrogen,
        temperature: data.temperature,
        humidity: data.humidity,
        moisture: data.rainfall,
      );

      // Get alternative crops
      final alternatives = await mlService.predictPlants(
        soilType: data.soilType,
        phLevel: data.pH,
        phosphorus: data.phosphorus,
        potassium: data.potassium,
        nitrogen: data.nitrogen,
        temperature: data.temperature,
        humidity: data.humidity,
        moisture: data.rainfall,
      );

      // Remove the predicted crop from alternatives if present
      alternatives.remove(predictedCrop);

      // Get growing conditions
      final conditions = MLService.getCropConditions(predictedCrop);

      // Create recommendation
      final recommendation = CropRecommendation(
        recommendedCrop: predictedCrop,
        alternativeCrops: alternatives,
        suitabilityScores: {
          predictedCrop: 95.0,
          if (alternatives.isNotEmpty) alternatives[0]: 85.0,
          if (alternatives.length > 1) alternatives[1]: 75.0,
        },
        growingConditions: conditions,
      );

      return data.copyWith(
        predictedCrop: predictedCrop,
        alternativeCrops: alternatives,
        notes: _formatCropRecommendation(recommendation),
        analysisType: 'Crop Recommendation',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error analyzing soil data: $e');
      return _generateOfflineCropRecommendation(data);
    }
  }
  
  // Get fertilizer recommendations
  Future<AgriculturalData> getFertilizerRecommendation(AgriculturalData data, String cropType) async {
    try {
      // Use MLService for prediction using CSV data
      final recommendation = await _mlService.predictFertilizer(
        cropType: cropType,
        nitrogen: data.nitrogen,
        potassium: data.potassium,
        phosphorous: data.phosphorus,
        temperature: data.temperature,
        humidity: data.humidity,
        soilMoisture: data.rainfall,
        soilType: data.soilType,
      );

      // Get fertilizer description
      final description = MLService.getFertilizerDescription(recommendation.recommendedFertilizer);

      return data.copyWith(
        predictedFertilizer: recommendation.recommendedFertilizer,
        notes: _formatFertilizerRecommendation(recommendation),
        analysisType: 'Fertilizer Recommendation',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error getting fertilizer recommendation: $e');
      return data.copyWith(
        notes: 'Error getting fertilizer recommendation: $e',
        analysisType: 'Error',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
  
  // Get soil health assessment

  

  
  // Generate offline yield prediction when API is unavailable
  AgriculturalData _generateOfflineYieldPrediction(AgriculturalData data, String cropType) {
    double predictedYield;
    String yieldUnit = 'tons/hectare';
    List<String> suggestedPractices = [];
    
    // Simple calculation based on soil properties and crop type
    final double nutrientScore = (data.nitrogen + data.phosphorus + data.potassium) / 3;
    final double environmentScore = (data.rainfall + data.temperature) / 2;
    
    if (cropType.toLowerCase() == 'rice') {
      predictedYield = (nutrientScore * 0.4 + environmentScore * 0.6) / 30;
      suggestedPractices = [
        'Maintain proper water level during growth stages',
        'Apply nitrogen fertilizer in split doses',
        'Control weeds in early stages of growth'
      ];
    } else if (cropType.toLowerCase() == 'wheat') {
      predictedYield = (nutrientScore * 0.5 + environmentScore * 0.5) / 25;
      suggestedPractices = [
        'Ensure adequate irrigation at critical growth stages',
        'Apply balanced NPK fertilizer',
        'Control rust and mildew diseases'
      ];
    } else if (cropType.toLowerCase() == 'cotton') {
      predictedYield = (nutrientScore * 0.6 + environmentScore * 0.4) / 35;
      suggestedPractices = [
        'Control bollworms and other pests',
        'Apply potassium to improve fiber quality',
        'Ensure proper spacing between plants'
      ];
    } else {
      predictedYield = (nutrientScore * 0.5 + environmentScore * 0.5) / 40;
      suggestedPractices = [
        'Apply balanced fertilization',
        'Maintain optimal soil moisture',
        'Practice crop rotation'
      ];
    }
    
    // Format offline yield prediction
    final buffer = StringBuffer();
    buffer.writeln('Predicted Yield: ${predictedYield.toStringAsFixed(2)} $yieldUnit (Offline Estimate)');
    buffer.writeln();
    buffer.writeln('Note: This is an offline estimate based on limited data and may not be accurate.');
    buffer.writeln();
    
    if (suggestedPractices.isNotEmpty) {
      buffer.writeln('Suggested Practices to Improve Yield:');
      suggestedPractices.forEach((practice) => buffer.writeln('• $practice'));
    }
    
    return data.copyWith(
      notes: buffer.toString(),
      analysisType: 'Yield Prediction (Offline)',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
  
  // Format crop recommendation into user-friendly text
  String _formatCropRecommendation(CropRecommendation recommendation) {
    final buffer = StringBuffer();
    
    buffer.writeln('Recommended Crop: ${recommendation.recommendedCrop}');
    buffer.writeln();
    
    if (recommendation.alternativeCrops.isNotEmpty) {
      buffer.writeln('Alternative Crops:');
      recommendation.alternativeCrops.forEach((crop) => buffer.writeln('• $crop'));
      buffer.writeln();
    }
    
    if (recommendation.growingConditions.isNotEmpty) {
      buffer.writeln('Optimal Growing Conditions:');
      recommendation.growingConditions.forEach((key, value) {
        buffer.writeln('• ${key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}: $value');
      });
    }
    
    return buffer.toString();
  }
  
  // Format fertilizer recommendation into user-friendly text
  String _formatFertilizerRecommendation(FertilizerRecommendation recommendation) {
    final buffer = StringBuffer();
    
    buffer.writeln('Recommended Fertilizer: ${recommendation.recommendedFertilizer}');
    buffer.writeln();
    buffer.writeln(recommendation.description);
    buffer.writeln();
    
    if (recommendation.applicationInstructions.isNotEmpty) {
      buffer.writeln('Application Instructions:');
      buffer.writeln(recommendation.applicationInstructions);
      buffer.writeln();
    }
    
    if (recommendation.soilDeficiencies.isNotEmpty) {
      buffer.writeln('Soil Deficiencies:');
      recommendation.soilDeficiencies.forEach((nutrient, value) {
        final status = value < 30 ? 'Low' : (value < 60 ? 'Medium' : 'Adequate');
        buffer.writeln('• ${nutrient[0].toUpperCase() + nutrient.substring(1)}: $status (${value.toStringAsFixed(1)}%)');
      });
    }
    
    return buffer.toString();
  }
  
  // Format soil health result into user-friendly text
  String _formatSoilHealthResult(SoilHealthResult result) {
    final buffer = StringBuffer();
    
    buffer.writeln('Soil Health: ${result.status}');
    buffer.writeln('Overall Score: ${result.score.toStringAsFixed(1)}%');
    buffer.writeln();
    buffer.writeln(result.recommendation);
    buffer.writeln();
    
    if (result.componentScores.isNotEmpty) {
      buffer.writeln('Component Scores:');
      result.componentScores.forEach((component, score) {
        buffer.writeln('• ${component.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}: ${score.toStringAsFixed(1)}%');
      });
    }
    
    return buffer.toString();
  }
  
  // Local soil health calculation fallback
  AgriculturalData _calculateLocalSoilHealth(AgriculturalData data) {
    // Calculate soil health score (simplified algorithm)
    double nitrogenScore = (data.nitrogen / 140) * 100;
    double phosphorusScore = (data.phosphorus / 145) * 100;
    double potassiumScore = (data.potassium / 205) * 100;
    double phScore = data.pH >= 5.5 && data.pH <= 7.5 ? 100 : 60;
    
    double soilHealthScore = (nitrogenScore + phosphorusScore + potassiumScore + phScore) / 4;
    soilHealthScore = soilHealthScore > 100 ? 100 : soilHealthScore;
    soilHealthScore = soilHealthScore < 0 ? 0 : soilHealthScore;
    
    String soilHealthStatus;
    String recommendation;
    
    if (soilHealthScore >= 80) {
      soilHealthStatus = 'Excellent';
      recommendation = 'Your soil is in excellent condition. Continue with current practices.';
    } else if (soilHealthScore >= 60) {
      soilHealthStatus = 'Good';
      recommendation = 'Your soil is in good condition but could be improved with minor adjustments.';
    } else if (soilHealthScore >= 40) {
      soilHealthStatus = 'Fair';
      recommendation = 'Your soil needs attention. Consider adding organic matter and balanced fertilizers.';
    } else {
      soilHealthStatus = 'Poor';
      recommendation = 'Your soil requires significant improvement. Consider soil testing and expert consultation.';
    }
    
    final Map<String, double> componentScores = {
      'nitrogen': nitrogenScore,
      'phosphorus': phosphorusScore,
      'potassium': potassiumScore,
      'ph_balance': phScore,
    };
    
    final soilHealthResult = SoilHealthResult(
      score: soilHealthScore,
      status: soilHealthStatus,
      recommendation: recommendation,
      componentScores: componentScores,
    );
    
    return data.copyWith(
      notes: _formatSoilHealthResult(soilHealthResult),
      analysisType: 'Soil Health Assessment (Local)',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
  
  // Generate offline crop recommendation when API is unavailable
  AgriculturalData _generateOfflineCropRecommendation(AgriculturalData data) {
    if (_cropData == null || _cropData!.isEmpty) {
      throw Exception('Crop data not available for offline recommendations');
    }

    // Get available crop types
    final availableCrops = availableCropTypes;
    if (availableCrops.isEmpty) {
      throw Exception('No crop types available for recommendations');
    }

    // Find suitable crops based on soil properties
    List<String> suitableCrops = [];
    
    // Simple scoring based on soil conditions
    final scoredCrops = availableCrops.map((crop) {
      double score = 0;
      
      // Basic scoring based on NPK levels and pH
      if (data.nitrogen > 40) score += 1;
      if (data.phosphorus > 30) score += 1;
      if (data.potassium > 30) score += 1;
      if (data.pH >= 5.5 && data.pH <= 7.5) score += 1;
      
      return MapEntry(crop, score);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort by score descending

    // Take top 3 crops
    suitableCrops = scoredCrops.take(3).map((e) => e.key).toList();
    
    if (suitableCrops.isEmpty) {
      suitableCrops = availableCrops.take(3).toList(); // Fallback to first 3 crops
    }

    final predictedCrop = suitableCrops.first;
    final alternativeCrops = suitableCrops.skip(1).toList();

    // Create recommendation with actual data
    final recommendation = CropRecommendation(
      recommendedCrop: predictedCrop,
      alternativeCrops: alternativeCrops,
      suitabilityScores: {
        predictedCrop: 85.0,
        if (alternativeCrops.isNotEmpty) alternativeCrops[0]: 75.0,
        if (alternativeCrops.length > 1) alternativeCrops[1]: 65.0,
      },
      growingConditions: _getGrowingConditions(predictedCrop, data),
    );
    
    return data.copyWith(
      predictedCrop: predictedCrop,
      alternativeCrops: alternativeCrops,
      notes: _formatCropRecommendation(recommendation),
      analysisType: 'Crop Recommendation (Offline)',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Helper method to get growing conditions based on crop and data
  Map<String, String> _getGrowingConditions(String cropType, AgriculturalData data) {
    // Find optimal conditions from crop data if available
    final cropEntry = _cropData?.firstWhere(
      (entry) => entry['label'].toString().toLowerCase() == cropType.toLowerCase(),
      orElse: () => <String, dynamic>{},
    );

    if (cropEntry != null && cropEntry.isNotEmpty) {
      return {
        'temperature': '${cropEntry['temperature']}°C',
        'humidity': '${cropEntry['humidity']}%',
        'rainfall': '${cropEntry['rainfall']}mm',
        'soil_type': data.soilType,
      };
    }

    // Fallback to general conditions if specific data not found
    return {
      'temperature': '20-30°C',
      'humidity': '60-80%',
      'rainfall': '150-200mm',
      'soil_type': data.soilType,
    };
  }

  // Generate offline fertilizer recommendation when API is unavailable
  AgriculturalData _generateOfflineFertilizerRecommendation(AgriculturalData data, String cropType) {
    if (!isValidCropType(cropType)) {
      throw Exception('Invalid crop type for fertilizer recommendation');
    }

    // Find crop-specific fertilizer recommendations from our data
    final cropData = _cropData?.firstWhere(
      (entry) => entry['label'].toString().toLowerCase() == cropType.toLowerCase(),
      orElse: () => <String, dynamic>{},
    );

    String recommendedFertilizer;
    String description;
    String applicationInstructions;

    // Use NPK values from crop data if available
    if (cropData != null && cropData.isNotEmpty) {
      final nRequired = cropData['N']?.toString() ?? '0';
      final pRequired = cropData['P']?.toString() ?? '0';
      final kRequired = cropData['K']?.toString() ?? '0';

      // Determine fertilizer based on NPK requirements
      if (double.parse(nRequired) > 100) {
        recommendedFertilizer = 'Urea';
        description = 'High in nitrogen (46%). Best for leafy growth and overall plant development.';
        applicationInstructions = 'Apply 100-150 kg/ha in split applications based on soil test results.';
      } else if (double.parse(pRequired) > 50) {
        recommendedFertilizer = 'DAP';
        description = 'High in phosphorus. Good for root development and flowering.';
        applicationInstructions = 'Apply 150-200 kg/ha before planting.';
      } else {
        recommendedFertilizer = 'NPK 20-20';
        description = 'Balanced NPK ratio for general crop health.';
        applicationInstructions = 'Apply 200-250 kg/ha in split doses.';
      }
    } else {
      // Default balanced recommendation if no specific data available
      recommendedFertilizer = 'NPK 20-20';
      description = 'Balanced NPK ratio suitable for most crops.';
      applicationInstructions = 'Apply based on soil test results and crop stage.';
    }
    
    return data.copyWith(
      predictedFertilizer: recommendedFertilizer,
      notes: '$description\n\n$applicationInstructions',
      analysisType: 'Fertilizer Recommendation (Offline)',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
  
  // Add offline support methods
  Future<void> saveOfflineData(AgriculturalData data) async {
    _offlineCache[data.id] = data;
    await _saveOfflineCache();
  }

  Future<void> _saveOfflineCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = _offlineCache.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_offlineDataKey, jsonEncode(jsonData));
  }

  Future<void> loadOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_offlineDataKey);
    if (jsonString != null) {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      _offlineCache.clear();
      jsonData.forEach((key, value) {
        _offlineCache[key] = AgriculturalData.fromJson(value);
      });
    }
  }

  // Add batch processing
  Future<List<AgriculturalData>> analyzeBatch(List<AgriculturalData> dataList) async {
    final results = <AgriculturalData>[];
    for (var data in dataList) {
      try {
        final analyzed = await getFertilizerRecommendation(data, data.cropType);
        results.add(analyzed);
      } catch (e) {
        print('Error analyzing data: $e');
        results.add(data.copyWith(
          notes: 'Error during analysis: $e',
          analysisType: 'Error',
        ));
      }
    }
    return results;
  }
  
  void dispose() {
    // No resources to clean up
  }
} 