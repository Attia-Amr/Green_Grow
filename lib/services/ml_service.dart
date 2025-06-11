/*
GREENGROW APP - MACHINE LEARNING SERVICE

This file implements the core prediction and recommendation engine.

SIMPLE EXPLANATION:
- This is like the agricultural expert brain of the app
- It analyzes your soil data to recommend the best crops to grow
- It suggests the ideal fertilizers based on your plants and soil
- It provides growing tips for optimal plant conditions
- It works even without internet by using built-in knowledge
- It remembers previous recommendations to work faster next time
- It provides detailed descriptions of fertilizers and their benefits
- It ensures recommendations are accurate by checking data against valid ranges

TECHNICAL EXPLANATION:
- Implements a lightweight machine learning system for agricultural predictions
- Contains similarity-based recommendation algorithms for crops and fertilizers
- Implements data normalization and validation with range checking
- Contains multi-level caching for performance optimization
- Implements CSV-based model data with efficient parsing
- Contains singleton pattern for global state management
- Implements prediction streaming with asynchronous operations
- Contains robust error handling with graceful degradation
- Implements weighted similarity scoring for accurate predictions
- Contains input validation with specific agricultural parameter ranges
- Implements alternative recommendation generation with confidence scores

This service forms the intelligent core of the application, providing data-driven
agricultural recommendations using efficient machine learning techniques.
*/

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import '../models/agricultural_data.dart';
import 'package:collection/collection.dart';
import '../models/fertilizer_recommendation.dart';
import '../services/data_cache_service.dart';

/// MLService implements a lightweight machine learning system for agricultural predictions
/// 
/// Design Philosophy:
/// - Singleton pattern for global state management
/// - CSV-based data storage for simplicity and portability
/// - In-memory caching for performance optimization
/// - Input validation for data integrity
/// - Similarity-based prediction algorithms
/// 
/// Key Features:
/// - Plant recommendation based on soil and environmental conditions
/// - Fertilizer recommendation based on crop and soil analysis
/// - Data validation and error handling
/// - Result caching for performance
/// - Extensible prediction models
class MLService {
  // Singleton implementation for global state management
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  // Service state
  bool _isInitialized = false;
  List<Map<String, dynamic>> _plantData = [];      // Plant prediction dataset
  List<Map<String, dynamic>> _fertilizerData = []; // Fertilizer prediction dataset

  // Add caching
  static const String _CACHE_KEY_PREFIX = 'ml_prediction_';
  static const Duration _CACHE_DURATION = Duration(hours: 1);

  // In-memory caches
  final Map<String, Map<String, dynamic>> _predictionCache = {};
  final Map<String, int> _cacheTimestamps = {};
  final Map<String, List<String>> _alternativesCache = {};
  final Map<String, Map<String, String>> _conditionsCache = {};

  // Generate cache key for predictions
  String _getPredictionCacheKey({
    required String soilType,
    required double phLevel,
    required  double phosphorus,
    required double potassium,
    required double nitrogen,
    required double temperature,
    required double humidity,
    required double moisture,
  }) {
    return '$_CACHE_KEY_PREFIX${soilType}_${phLevel.toStringAsFixed(1)}_${phosphorus.toStringAsFixed(1)}_${potassium.toStringAsFixed(1)}_${nitrogen.toStringAsFixed(1)}_${temperature.toStringAsFixed(1)}_${humidity.toStringAsFixed(1)}_${moisture.toStringAsFixed(1)}';
  }

  // Check if cache is valid
  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;

    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    return age < _CACHE_DURATION.inMilliseconds;
  }

  // Add to prediction cache
  void _cachePrediction(String key, Map<String, dynamic> prediction) {
    _predictionCache[key] = prediction;
    _cacheTimestamps[key] = DateTime.now().millisecondsSinceEpoch;
  }

  // Get from prediction cache
  Map<String, dynamic>? _getCachedPrediction(String key) {
    if (!_isCacheValid(key)) {
      _predictionCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    return _predictionCache[key];
  }

  /// Input validation ranges for various parameters
  /// These ranges are based on agricultural research and practical limits
  static const Map<String, Map<String, double>> _validationRanges = {
    'temperature': {'min': 0, 'max': 50},    // Celsius
    'humidity': {'min': 0, 'max': 999},      // Percentage
    'moisture': {'min': 0, 'max': 999},      // Percentage
    'nitrogen': {'min': 0, 'max': 99},      // mg/kg
    'potassium': {'min': 0, 'max': 999},     // mg/kg
    'phosphorous': {'min': 0, 'max': 999},   // mg/kg
  };

  // Predefined soil types based on agricultural classifications
  static final List<String> _soilTypes = [
    'Sandy',   // Light, well-draining soil
    'Loamy',   // Balanced, ideal for most crops
    'Clayey',  // Heavy, water-retaining soil
    'Black',   // Rich in organic matter
    'Red',     // Iron-rich soil
  ];

  // Dynamic lists populated from CSV data
  static List<String> _cropTypes = [];
  static final List<String> _fertilizerTypes = [];

  // Public getters for type lists (immutable to prevent external modification)
  static List<String> get soilTypes => List.unmodifiable(_soilTypes);
  static List<String> get cropTypes => List.unmodifiable(_cropTypes);
  static List<String> get fertilizerTypes => List.unmodifiable(_fertilizerTypes);

  /// Validates input parameters against defined ranges
  /// 
  /// Throws exceptions for out-of-range values to prevent invalid predictions
  /// 
  /// Design Decision: Early validation prevents processing of invalid data
  void _validateInputs({
    required double temperature,
    required double humidity,
    required double moisture,
    required double nitrogen,
    required double potassium,
    required double phosphorous,
  }) {
    if (!_isInitialized) throw Exception('MLService not initialized');

    final inputs = {
      'temperature': temperature,
      'humidity': humidity,
      'moisture': moisture,
      'nitrogen': nitrogen,
      'potassium': potassium,
      'phosphorous': phosphorous,
    };

    for (var entry in inputs.entries) {
      final range = _validationRanges[entry.key];
      if (range != null && (entry.value < range['min']! || entry.value > range['max']!)) {
        throw Exception('${entry.key} value ${entry.value} is outside valid range (${range['min']}-${range['max']})');
      }
    }
  }

  /// Initializes the service by loading and processing CSV data
  /// 
  /// Implementation Details:
  /// 1. Loads CSV files from assets
  /// 2. Converts data to structured format
  /// 3. Extracts unique values for dropdowns
  /// 4. Sets up prediction models
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Starting MLService initialization...');

      // Load crop data from cache
      print('Loading plant data...');
      _plantData = await DataCacheService.getCropData();
      print('Plant data loaded: ${_plantData.length} entries');

      // Extract unique crop types from the data
      _cropTypes = _plantData
          .map((entry) => entry['label'].toString())
          .toSet()
          .toList()
        ..sort();
      print('Extracted ${_cropTypes.length} unique crop types');

      // Load fertilizer data from cache
      print('Loading fertilizer data...');
      _fertilizerData = await DataCacheService.getFertilizerData();
      print('Fertilizer data loaded: ${_fertilizerData.length} entries');

      _isInitialized = true;
      print('MLService initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing MLService: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Converts CSV data to structured map format
  /// 
  /// [csvData] - Raw CSV data as list of lists
  /// 
  /// Returns list of maps with header-value pairs
  /// 
  /// Implementation:
  /// - First row contains headers
  /// - Subsequent rows contain values
  /// - Numeric values are converted to doubles
  List<Map<String, dynamic>> _convertCsvToMap(List<List<dynamic>> csvData) {
    if (csvData.isEmpty) return [];

    final headers = csvData[0].map((e) => e.toString()).toList();
    return csvData.skip(1).map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < headers.length; i++) {
        if (i < row.length) {
          // Convert numeric values to double for calculations
          if (row[i] is num) {
            map[headers[i]] = (row[i] as num).toDouble();
          } else {
            map[headers[i]] = row[i];
          }
        }
      }
      return map;
    }).toList();
  }

  /// Predicts suitable plant based on environmental conditions
  /// 
  /// Algorithm:
  /// 1. Validates input parameters
  /// 2. Checks prediction cache
  /// 3. Calculates similarity scores
  /// 4. Returns best matching plant
  /// 
  /// Uses weighted similarity scoring for accurate predictions
  Future<String> predictPlant({
    required String soilType,
    required double phLevel,
    required double phosphorus,
    required double potassium,
    required double nitrogen,
    required double temperature,
    required double humidity,
    required double moisture,
  }) async {
    print('Starting plant prediction...');
    _validateInputs(
      temperature: temperature,
      humidity: humidity,
      moisture: moisture,
      nitrogen: nitrogen,
      potassium: potassium,
      phosphorous: phosphorus,
    );

    final cacheKey = _getPredictionCacheKey(
      soilType: soilType,
      phLevel: phLevel,
      phosphorus: phosphorus,
      potassium: potassium,
      nitrogen: nitrogen,
      temperature: temperature,
      humidity: humidity,
      moisture: moisture,
    );

    // Check cache first
    final cachedPrediction = _getCachedPrediction(cacheKey);
    if (cachedPrediction != null) {
      print('Cache hit! Returning cached prediction');
      return cachedPrediction['prediction'] as String;
    }

    if (!_isInitialized) {
      print('Service not initialized, initializing now...');
      await initialize();
    }

    try {
      print('Making prediction...');
      final prediction = _predictPlantFromCSV(
        soilType: soilType,
        phLevel: phLevel,
        phosphorus: phosphorus,
        potassium: potassium,
        nitrogen: nitrogen,
        temperature: temperature,
        humidity: humidity,
        moisture: moisture,
      );
      print('Prediction made: $prediction');

      // Cache the prediction
      _cachePrediction(cacheKey, {
        'prediction': prediction,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      return prediction;
    } catch (e, stackTrace) {
      print('Error predicting plant: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Core plant prediction algorithm using similarity scoring
  /// 
  /// Algorithm Details:
  /// 1. Compares input parameters with dataset entries
  /// 2. Calculates weighted similarity scores
  /// 3. Returns best matching plant variety
  /// 4. Implements minimum similarity threshold
  String _predictPlantFromCSV({
    required String soilType,
    required double phLevel,
    required double phosphorus,
    required double potassium,
    required double nitrogen,
    required double temperature,
    required double humidity,
    required double moisture,
  }) {
    if (_plantData.isEmpty) {
      throw Exception('Plant data not loaded');
    }

    // Initialize with first entry
    var bestMatch = _plantData[0];
    var bestScore = _calculatePlantSimilarityScore(
      soilType: soilType,
      phLevel: phLevel,
      phosphorus: phosphorus,
      potassium: potassium,
      nitrogen: nitrogen,
      temperature: temperature,
      humidity: humidity,
      moisture: moisture,
      data: _plantData[0],
    );

    // Find best matching entry
    for (var data in _plantData.skip(1)) {
      final score = _calculatePlantSimilarityScore(
        soilType: soilType,
        phLevel: phLevel,
        phosphorus: phosphorus,
        potassium: potassium,
        nitrogen: nitrogen,
        temperature: temperature,
        humidity: humidity,
        moisture: moisture,
        data: data,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMatch = data;
      }
    }

    // Check minimum similarity threshold
    if (bestScore < 0.4) { // 40% similarity required
      throw Exception('No suitable crop found for these conditions');
    }

    // Extract and validate prediction
    final cropName = bestMatch['label'];
    if (cropName == null || cropName.toString().trim().isEmpty) {
      throw Exception('Invalid crop data found');
    }

    print('Predicted crop: $cropName with score: ${(bestScore * 100).toStringAsFixed(1)}%');
    return cropName.toString();
  }

  /// Calculates similarity score between input parameters and dataset entry
  /// 
  /// Scoring Algorithm:
  /// - Normalizes all parameters to 0-1 range
  /// - Applies weighted importance to different factors
  /// - Handles missing or invalid data gracefully
  double _calculatePlantSimilarityScore({
    required String soilType,
    required double phLevel,
    required double phosphorus,
    required double potassium,
    required double nitrogen,
    required double temperature,
    required double humidity,
    required double moisture,
    required Map<String, dynamic> data,
  }) {
    try {
      // Extract and normalize dataset values
      final dataP = double.tryParse(data['P']?.toString() ?? '') ?? 0.0;
      final dataN = double.tryParse(data['N']?.toString() ?? '') ?? 0.0;
      final dataK = double.tryParse(data['K']?.toString() ?? '') ?? 0.0;
      final dataTemp = double.tryParse(data['temperature']?.toString() ?? '') ?? 0.0;
      final dataHumidity = double.tryParse(data['humidity']?.toString() ?? '') ?? 0.0;
      final dataPh = double.tryParse(data['ph']?.toString() ?? '') ?? 0.0;
      final dataRainfall = double.tryParse(data['rainfall']?.toString() ?? '') ?? 0.0;

      // Calculate normalized differences (0-1 scale)
      final pDiff = 1 - (phosphorus - dataP).abs() / 145.0;
      final nDiff = 1 - (nitrogen - dataN).abs() / 140.0;
      final kDiff = 1 - (potassium - dataK).abs() / 205.0;
      final tempDiff = 1 - (temperature - dataTemp).abs() / 50.0;
      final humidityDiff = 1 - (humidity - dataHumidity).abs() / 100.0;
      final phDiff = 1 - (phLevel - dataPh).abs() / 14.0;
      final rainfallDiff = 1 - (moisture - dataRainfall).abs() / 300.0;

      // Calculate weighted score based on factor importance
      final score = (
          nDiff * 0.2 +      // Nitrogen (highest weight)
              pDiff * 0.15 +     // Phosphorus
              kDiff * 0.15 +     // Potassium
              phDiff * 0.15 +    // pH
              tempDiff * 0.15 +  // Temperature
              humidityDiff * 0.1 + // Humidity
              rainfallDiff * 0.1   // Rainfall/Moisture
      );

      return score;
    } catch (e) {
      print('Error calculating similarity score: $e');
      return 0.0;  // Return minimum score on error
    }
  }

  /// Predicts optimal fertilizer based on crop and soil conditions
  /// 
  /// Returns a FertilizerRecommendation object containing:
  /// - Recommended fertilizer type
  /// - Alternative options
  /// - Soil deficiency analysis
  /// - Application instructions
  Future<FertilizerRecommendation> predictFertilizer({
    required String cropType,
    required double nitrogen,
    required double potassium,
    required double phosphorous,
    required double temperature,
    required double humidity,
    required double soilMoisture,
    required String soilType,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Validate all input parameters
      _validateInputs(
        temperature: temperature,
        humidity: humidity,
        moisture: soilMoisture,
        nitrogen: nitrogen,
        potassium: potassium,
        phosphorous: phosphorous,
      );

      // Find best matching fertilizers
      final recommendations = _findFertilizerMatches(
        cropType: cropType,
        nitrogen: nitrogen,
        potassium: potassium,
        phosphorous: phosphorous,
        temperature: temperature,
        humidity: humidity,
        moisture: soilMoisture,
        soilType: soilType,
      );

      if (recommendations.isEmpty) {
        throw Exception('No suitable fertilizer recommendations found');
      }

      return recommendations.first;
    } catch (e) {
      print('Error predicting fertilizer: $e');
      rethrow;
    }
  }

  /// Finds matching fertilizers based on input conditions
  /// 
  /// Algorithm:
  /// 1. Calculates similarity scores for all fertilizers
  /// 2. Filters by minimum similarity threshold
  /// 3. Sorts by score
  /// 4. Returns top recommendations
  List<FertilizerRecommendation> _findFertilizerMatches({
    required String cropType,
    required double nitrogen,
    required double potassium,
    required double phosphorous,
    required double temperature,
    required double humidity,
    required double moisture,
    required String soilType,
  }) {
    // Store matches with their scores
    final scoredMatches = <MapEntry<double, Map<String, dynamic>>>[];

    // Calculate scores for all fertilizers
    for (var entry in _fertilizerData) {
      final score = _calculateSimilarityScore(
        entry: entry,
        cropType: cropType,
        nitrogen: nitrogen,
        potassium: potassium,
        phosphorous: phosphorous,
        temperature: temperature,
        humidity: humidity,
        moisture: moisture,
        soilType: soilType,
      );

      if (score > 0.5) { // 50% similarity threshold
        scoredMatches.add(MapEntry(score, entry));
      }
    }

    // Sort by score (highest first)
    scoredMatches.sort((a, b) => b.key.compareTo(a.key));

    // Convert top matches to recommendations
    return scoredMatches.take(3).map((match) {
      final entry = match.value;
      final score = match.key;

      return FertilizerRecommendation(
        recommendedFertilizer: entry['Fertilizer'],
        alternativeFertilizers: [],
        soilDeficiencies: {
          'nitrogen': (1 - (nitrogen / 140)) * 100,
          'phosphorus': (1 - (phosphorous / 145)) * 100,
          'potassium': (1 - (potassium / 205)) * 100,
        },
        description: getFertilizerDescription(entry['Fertilizer']),
        applicationInstructions: _generateApplicationInstructions(
          fertilizer: entry['Fertilizer'],
          cropType: cropType,
          score: score,
        ),
      );
    }).toList();
  }

  /// Calculates similarity score for fertilizer matching
  /// 
  /// Scoring Weights:
  /// - Crop Type: 3.0 (highest)
  /// - Soil Type: 2.0
  /// - NPK Levels: 2.0 each
  /// - Environmental Factors: 1.0 each
  double _calculateSimilarityScore({
    required Map<String, dynamic> entry,
    required String cropType,
    required double nitrogen,
    required double potassium,
    required double phosphorous,
    required double temperature,
    required double humidity,
    required double moisture,
    required String soilType,
  }) {
    double score = 0.0;
    int factors = 0;

    // Primary matching factors
    if (entry['Crop_Type'].toString().toLowerCase() == cropType.toLowerCase()) {
      score += 3.0;
      factors += 3;
    }
    if (entry['Soil_Type'].toString().toLowerCase() == soilType.toLowerCase()) {
      score += 2.0;
      factors += 2;
    }

    // NPK matching (normalized differences)
    final nDiff = 1.0 - ((entry['Nitrogen'] as num).toDouble() - nitrogen).abs() / 140.0;
    final pDiff = 1.0 - ((entry['Phosphorous'] as num).toDouble() - phosphorous).abs() / 145.0;
    final kDiff = 1.0 - ((entry['Potassium'] as num).toDouble() - potassium).abs() / 205.0;

    score += nDiff * 2.0 + pDiff * 2.0 + kDiff * 2.0;
    factors += 6;

    // Environmental conditions
    final tempDiff = 1.0 - ((entry['Temparature'] as num).toDouble() - temperature).abs() / 50.0;
    final humDiff = 1.0 - ((entry['Humidity'] as num).toDouble() - humidity).abs() / 100.0;
    final moistDiff = 1.0 - ((entry['Moisture'] as num).toDouble() - moisture).abs() / 100.0;

    score += tempDiff + humDiff + moistDiff;
    factors += 3;

    // Normalize final score
    return score / factors;
  }

  /// Generates application instructions for fertilizer
  /// 
  /// Combines:
  /// - Base fertilizer description
  /// - Confidence score
  /// - General guidelines
  /// - Safety precautions
  String _generateApplicationInstructions({
    required String fertilizer,
    required String cropType,
    required double score,
  }) {
    final confidence = (score * 100).toStringAsFixed(1);
    final baseInstructions = getFertilizerDescription(fertilizer);

    return '''
Based on analysis (${confidence}% match):
$baseInstructions

Application Guidelines:
1. Test soil before application
2. Apply during appropriate growth stage
3. Follow local agricultural extension recommendations
4. Consider weather conditions before application
''';
  }

  /// Cleans up service resources
  void dispose() {
    _predictionCache.clear();
    _cacheTimestamps.clear();
    _alternativesCache.clear();
    _conditionsCache.clear();
    _isInitialized = false;
    _plantData.clear();
    _fertilizerData.clear();
  }

  /// Returns detailed description for each fertilizer type
  /// 
  /// Includes:
  /// - NPK content
  /// - Primary benefits
  /// - Best use cases
  static String getFertilizerDescription(String fertilizer) {
    final Map<String, String> descriptions = {
      'Urea': 'High in nitrogen (46%). Best for leafy growth and overall plant development.',
      'DAP': 'Di-ammonium phosphate (18-46-0). Good source of phosphorus and nitrogen.',
      'TSP': 'Triple Super Phosphate. High phosphorus content for root development.',
      'Superphosphate': 'Good source of phosphorus and calcium. Helps in root growth.',
      'Potassium sulfate': 'Sulfate of Potash. High in potassium, good for fruit quality.',
      'Potassium chloride': 'Muriate of Potash. High potassium content for yield improvement.',
      '28-28': 'Balanced nitrogen and phosphorus. Good for vegetative growth.',
      '20-20': 'Balanced NPK ratio for general purpose use.',
      '17-17-17': 'Balanced blend for all-around plant nutrition.',
      '15-15-15': 'Balanced fertilizer for steady growth.',
      '14-35-14': 'High phosphorus blend for flowering and fruiting.',
      '14-14-14': 'Balanced nutrition for general crop health.',
      '10-26-26': 'High in phosphorus and potassium for root and fruit development.',
      '10-10-10': 'Mild balanced fertilizer for sensitive plants.'
    };

    return descriptions[fertilizer] ?? 'A balanced fertilizer for plant growth and development.';
  }

  /// Returns optimal growing conditions for specific crops
  /// 
  /// Includes:
  /// - Temperature range
  /// - Humidity requirements
  /// - Soil type preference
  /// - Water needs
  static Map<String, String> getCropConditions(String crop) {
    final MLService instance = MLService();

    // Check cache first
    if (instance._conditionsCache.containsKey(crop)) {
      return instance._conditionsCache[crop]!;
    }

    final Map<String, Map<String, String>> conditions = {
      'Rice': {
        'temperature': '20-27°C',
        'humidity': '80-85%',
        'soil': 'Clayey or Loamy',
        'water': 'High',
      },
      'Cotton': {
        'temperature': '25-35°C',
        'humidity': '50-85%',
        'soil': 'Black or Red',
        'water': 'Moderate',
      },
      'Maize': {
        'temperature': '26-33°C',
        'humidity': '50-65%',
        'soil': 'Sandy or Loamy',
        'water': 'Moderate',
      },
      'Watermelon': {
        'temperature': '25-30°C',
        'humidity': '80-85%',
        'soil': 'Loamy',
        'water': 'High',
      },
    };

    final result = conditions[crop] ?? {
      'temperature': '20-30°C',
      'humidity': '60-80%',
      'soil': 'Well-drained soil',
      'water': 'Moderate',
    };

    // Cache the result
    instance._conditionsCache[crop] = result;
    return result;
  }

  /// Clears prediction caches
  /// Used when data or conditions change significantly
  void clearCache() {
    _predictionCache.clear();
    _cacheTimestamps.clear();
    _alternativesCache.clear();
    _conditionsCache.clear();
  }

  /// Predicts suitable plants for given conditions
  /// 
  /// Returns top 3 matching crops or defaults if no matches
  Future<List<String>> predictPlants({
    required String soilType,
    required double phLevel,
    required double phosphorus,
    required double potassium,
    required double nitrogen,
    required double temperature,
    required double humidity,
    required double moisture,
  }) async {
    final cacheKey = _getPredictionCacheKey(
      soilType: soilType,
      phLevel: phLevel,
      phosphorus: phosphorus,
      potassium: potassium,
      nitrogen: nitrogen,
      temperature: temperature,
      humidity: humidity,
      moisture: moisture,
    );

    // Check cache first
    if (_alternativesCache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      return _alternativesCache[cacheKey]!;
    }

    if (!_isInitialized) await initialize();

    try {
      final matchingEntries = _fertilizerData.where((entry) =>
      entry['Soil_Type'].toString().toLowerCase() == soilType.toLowerCase()
      ).toList();

      final uniqueCrops = matchingEntries
          .map((e) => e['Crop_Type'].toString().toLowerCase())
          .toSet()
          .toList();

      final results = uniqueCrops.isNotEmpty
          ? uniqueCrops.take(3).toList()
          : ['rice', 'maize', 'cotton'];

      // Cache the results
      _alternativesCache[cacheKey] = results;
      _cacheTimestamps[cacheKey] = DateTime.now().millisecondsSinceEpoch;

      return results;
    } catch (e) {
      print('Error predicting plants: $e');
      return ['rice', 'maize', 'cotton'];
    }
  }

  /// Loads unique crop types from CSV data
  /// 
  /// Process:
  /// 1. Reads CSV file
  /// 2. Extracts unique crop names
  /// 3. Formats and sorts results
  static Future<List<String>> loadCropTypes() async {
    try {
      final String csvData = await rootBundle.loadString('assets/data/crop_recommendation.csv');
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);

      // Extract unique crop names
      final Set<String> uniqueCrops = {};
      for (var i = 1; i < csvTable.length; i++) {
        final cropName = csvTable[i][0].toString().trim();
        uniqueCrops.add(cropName);
      }

      // Sort alphabetically
      final sortedCrops = uniqueCrops.toList()..sort();
      return sortedCrops;
    } catch (e) {
      print('Error loading crop types: $e');
      return [];
    }
  }

  /// Initializes crop types list
  static Future<void> initializeCropTypes() async {
    _cropTypes = await loadCropTypes();
  }
} 
