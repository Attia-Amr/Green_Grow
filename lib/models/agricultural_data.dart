/*
GREENGROW APP - AGRICULTURAL DATA EXPLANATION

This file contains all the data models that power our farming app. Here's what everything does:

AgriculturalData Class:
- This is like a digital soil sample report that stores ALL information about a farm's soil and plants
- It has fields for soil type, pH, temperature, rainfall, nutrients (nitrogen, potassium, phosphorus), etc.
- It can track irrigation schedules (when to water plants) with start dates and moisture alerts
- It has special helper methods to save data (toJson/toMap) and load data (fromJson/fromMap)
- The copyWith method lets you update just parts of the data while keeping the rest the same

PlantPredictionInput Class:
- A smaller data container used just for predicting what plants will grow best
- Only includes the essential soil and environment details needed for predictions
- Converts data to a special format our prediction system understands

FertilizerPredictionInput Class:
- Another specialized data container just for recommending fertilizers
- Includes crop type and soil nutrient levels to figure out what plant food is needed
- Also formats data in the exact way our fertilizer prediction system needs it

When the app runs, it creates these data objects to store all farm information, makes predictions,
and helps farmers make smart decisions about their crops and soil health.
*/

import 'package:uuid/uuid.dart';

// This is our main container that holds all information about a farm's soil and plants
// Just like how a form at the doctor's office keeps track of your health information
class AgriculturalData {
  // These are all the pieces of information we store about each farm sample
  // Each one is like a different measurement on our science experiment
  final String id;                  // A unique name tag for each sample, like a serial number
  final String soilType;            // What kind of dirt it is (sandy, clay, loam, etc.)
  final double pH;                  // How acidic or basic the soil is (like lemon juice vs. baking soda)
  final double temperature;         // How hot or cold it is where the plants grow
  final double humidity;            // How much water is in the air (like how foggy it feels)
  final double rainfall;            // How much rain falls in this area
  final double nitrogen;            // Amount of nitrogen nutrient in soil (plants need this to grow leaves)
  final double potassium;           // Amount of potassium nutrient in soil (helps plants fight diseases)
  final double phosphorus;          // Amount of phosphorus nutrient in soil (helps plants make flowers and fruits)
  final double moisture;            // How wet the soil is right now
  final String cropType;            // What plant the farmer wants to grow
  final String predictedCrop;       // What plant our app thinks would grow best here
  final String analysisType;        // What kind of test or analysis we did
  final String? recommendations;    // Our advice to the farmer (the ? means this might be empty)
  final String? predictedFertilizer; // What plant food we think is best (the ? means this might be empty)
  final List<String>? alternativeCrops; // Other plants that might grow well here (a list of options)
  final String? notes;              // Extra notes about this sample
  final int timestamp;              // When this data was collected (stored as a special number)
  final bool irrigationTracking;    // Whether irrigation tracking is enabled for this crop
  // New irrigation tracking fields
  final DateTime? irrigationStartDate;  // When irrigation tracking started
  final double? requiredMoistureLevel;  // Required soil moisture level
  final double? moistureAlertThreshold; // Alert when moisture reaches this level
  final int? irrigationFrequencyDays;   // How often to irrigate (in days)

  // This is the "recipe" for making a new AgriculturalData object
  // It's like a cake recipe that lists all the ingredients you need
  AgriculturalData({
    String? id,                     // The ? means this is optional - we can make one if not provided
    required this.soilType,         // "required" means you MUST provide this ingredient
    required this.pH,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.nitrogen,
    required this.potassium,
    required this.phosphorus,
    this.moisture = 0.0,            // This equals sign gives a default value if none is provided
    required this.cropType,
    this.predictedCrop = '',        // Empty string as default value
    this.alternativeCrops = const [], // Empty list as default value
    this.analysisType = '',
    this.notes = '',
    this.predictedFertilizer,
    this.recommendations,
    this.irrigationTracking = false,
    this.irrigationStartDate,
    this.requiredMoistureLevel,
    this.moistureAlertThreshold,
    this.irrigationFrequencyDays,
    int? timestamp,
  }) : this.id = id ?? const Uuid().v4(),  // If no ID is given, make a new unique one
       this.timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch; // If no timestamp given, use current time

  // These are "getters" - shortcut ways to get certain values with a different name
  // Like saying "Johnny" is the same as "John" - just a different name for the same thing
  double get phLevel => pH;
  double get phosphorous => phosphorus;

  // This function converts our data into a format that can be easily saved or sent to other apps
  // It's like translating our information from English to Spanish so other programs can understand it
  Map<String, dynamic> toJson() => toMap();

  // This creates a "map" (a collection of key-value pairs) from our data
  // Think of it like putting each piece of information in a labeled envelope
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'soilType': soilType,
      'pH': pH,
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      'nitrogen': nitrogen,
      'potassium': potassium,
      'phosphorus': phosphorus,
      'moisture': moisture,
      'cropType': cropType,
      'predictedCrop': predictedCrop,
      'analysisType': analysisType,
      'recommendations': recommendations,
      'predictedFertilizer': predictedFertilizer,
      'alternativeCrops': alternativeCrops,
      'notes': notes,
      'timestamp': timestamp,
      'irrigationTracking': irrigationTracking,
      'irrigationStartDate': irrigationStartDate?.millisecondsSinceEpoch,
      'requiredMoistureLevel': requiredMoistureLevel,
      'moistureAlertThreshold': moistureAlertThreshold,
      'irrigationFrequencyDays': irrigationFrequencyDays,
    };
  }

  // This is a "factory" - a special function that creates a new AgriculturalData from saved data
  // It's like a machine that takes envelopes with labels and puts all the information back together
  factory AgriculturalData.fromJson(Map<String, dynamic> json) => AgriculturalData.fromMap(json);

  // This factory takes a map (our labeled envelopes) and builds a new AgriculturalData object
  // It also provides default values if some information is missing (like 0.0 for numbers or '' for text)
  factory AgriculturalData.fromMap(Map<String, dynamic> map) {
    return AgriculturalData(
      id: map['id'],
      soilType: map['soilType'] ?? '',
      pH: (map['pH'] ?? 0.0).toDouble(),
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      rainfall: (map['rainfall'] ?? 0.0).toDouble(),
      nitrogen: (map['nitrogen'] ?? 0.0).toDouble(),
      potassium: (map['potassium'] ?? 0.0).toDouble(),
      phosphorus: (map['phosphorus'] ?? 0.0).toDouble(),
      moisture: (map['moisture'] ?? 0.0).toDouble(),
      cropType: map['cropType'] ?? '',
      predictedCrop: map['predictedCrop'] ?? '',
      analysisType: map['analysisType'] ?? '',
      recommendations: map['recommendations'],
      predictedFertilizer: map['predictedFertilizer'],
      alternativeCrops: map['alternativeCrops'] != null ? List<String>.from(map['alternativeCrops']) : null,
      notes: map['notes'],
      irrigationTracking: map['irrigationTracking'] ?? false,
      irrigationStartDate: map['irrigationStartDate'] != null ? 
          DateTime.fromMillisecondsSinceEpoch(map['irrigationStartDate']) : null,
      requiredMoistureLevel: (map['requiredMoistureLevel'] ?? 0.0).toDouble(),
      moistureAlertThreshold: (map['moistureAlertThreshold'] ?? 0.0).toDouble(),
      irrigationFrequencyDays: map['irrigationFrequencyDays'],
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  // This function creates a copy of our data but lets us change some parts
  // It's like making a photocopy of a form but filling in some blanks differently
  AgriculturalData copyWith({
    String? soilType,
    double? pH,
    double? temperature,
    double? humidity,
    double? rainfall,
    double? nitrogen,
    double? potassium,
    double? phosphorus,
    double? moisture,
    String? cropType,
    String? predictedCrop,
    String? analysisType,
    String? recommendations,
    String? predictedFertilizer,
    List<String>? alternativeCrops,
    String? notes,
    bool? irrigationTracking,
    DateTime? irrigationStartDate,
    double? requiredMoistureLevel,
    double? moistureAlertThreshold,
    int? irrigationFrequencyDays,
    int? timestamp,
  }) {
    return AgriculturalData(
      id: this.id,                                // We keep the same ID
      soilType: soilType ?? this.soilType,        // ?? means "use the new value if provided, otherwise keep the old one"
      pH: pH ?? this.pH,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      rainfall: rainfall ?? this.rainfall,
      nitrogen: nitrogen ?? this.nitrogen,
      potassium: potassium ?? this.potassium,
      phosphorus: phosphorus ?? this.phosphorus,
      moisture: moisture ?? this.moisture,
      cropType: cropType ?? this.cropType,
      predictedCrop: predictedCrop ?? this.predictedCrop,
      analysisType: analysisType ?? this.analysisType,
      recommendations: recommendations ?? this.recommendations,
      predictedFertilizer: predictedFertilizer ?? this.predictedFertilizer,
      alternativeCrops: alternativeCrops ?? this.alternativeCrops,
      notes: notes ?? this.notes,
      irrigationTracking: irrigationTracking ?? this.irrigationTracking,
      irrigationStartDate: irrigationStartDate ?? this.irrigationStartDate,
      requiredMoistureLevel: requiredMoistureLevel ?? this.requiredMoistureLevel,
      moistureAlertThreshold: moistureAlertThreshold ?? this.moistureAlertThreshold,
      irrigationFrequencyDays: irrigationFrequencyDays ?? this.irrigationFrequencyDays,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// This class holds just the information we need to predict what plants will grow best
// It's like a smaller form with only the questions needed for this specific prediction
class PlantPredictionInput {
  final double temperature;         // How hot or cold it is
  final double humidity;            // How much water is in the air
  final double moisture;            // How wet the soil is
  final String soilType;            // What kind of dirt it is
  final double nitrogen;            // Nitrogen nutrient level
  final double potassium;           // Potassium nutrient level
  final double phosphorous;         // Phosphorous nutrient level

  // The recipe for making a PlantPredictionInput
  PlantPredictionInput({
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.soilType,
    required this.nitrogen,
    required this.potassium,
    required this.phosphorous,
  });

  // This converts our data to a format the prediction system can understand
  // Notice how some names start with capital letters - that's because the prediction
  // system expects those exact names (like filling in a form with specific field names)
  Map<String, dynamic> toMap() {
    return {
      'Temperature': temperature,
      'Humidity': humidity,
      'Moisture': moisture,
      'Soil_Type': soilType,
      'Nitrogen': nitrogen,
      'Potassium': potassium,
      'Phosphorous': phosphorous,
    };
  }
}

// This class holds just the information we need to predict what fertilizer to use
// It's another specialized form with just the questions needed for fertilizer advice
class FertilizerPredictionInput {
  final String cropType;            // What plant we're growing
  final double nitrogen;            // Current nitrogen level in soil
  final double potassium;           // Current potassium level in soil
  final double phosphorous;         // Current phosphorous level in soil
  final double temperature;         // How hot or cold it is
  final double humidity;            // How much water is in the air
  final double soilMoisture;        // How wet the soil is
  final String soilType;            // What kind of dirt it is

  // The recipe for making a FertilizerPredictionInput
  FertilizerPredictionInput({
    required this.cropType,
    required this.nitrogen,
    required this.potassium,
    required this.phosphorous,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.soilType,
  });

  // This converts our data to a format the fertilizer prediction system can understand
  // Again using specific field names the system expects (with underscores and capitals)
  Map<String, dynamic> toMap() {
    return {
      'Crop_Type': cropType,
      'Nitrogen': nitrogen,
      'Potassium': potassium,
      'Phosphorous': phosphorous,
      'Temperature': temperature,
      'Humidity': humidity,
      'Soil_Moisture': soilMoisture,
      'Soil_Type': soilType,
    };
  }
} 