/*
GREENGROW APP - DATA CACHE SERVICE

This file implements a caching system for agricultural data files.

SIMPLE EXPLANATION:
- This is like a temporary storage system that keeps crop and fertilizer data ready for quick access
- It saves important data on your device so the app works even without internet
- It automatically refreshes data every week to ensure you have the latest information
- It stores data in both memory (RAM) and permanent storage (disk) for best performance
- It handles the technical details of loading and processing CSV files
- It converts raw data into a format the app can easily use
- It manages cleanup and refreshing of old data automatically

TECHNICAL EXPLANATION:
- Implements a two-level caching strategy (in-memory and persistent storage)
- Contains cache invalidation based on configurable time thresholds
- Implements CSV parsing with robust error handling and type conversion
- Contains lazy loading pattern for efficient resource utilization
- Implements caching headers and serializable data structures
- Contains defensive programming with comprehensive error trapping
- Implements JSON serialization for persistent storage compatibility
- Contains cache consistency management between memory and disk
- Implements type-safe data access with proper error propagation
- Contains resource cleanup and memory management utilities

This service improves application performance and enables offline functionality
by efficiently managing agricultural dataset caching.
*/

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

/// DataCacheService handles caching of CSV and other data files
/// for improved performance and offline access
class DataCacheService {
  static const String _CROP_DATA_KEY = 'crop_recommendation_data';
  static const String _FERTILIZER_DATA_KEY = 'fertilizer_data';
  static const Duration _CACHE_DURATION = Duration(days: 7);

  // In-memory cache
  static List<Map<String, dynamic>>? _cropDataCache;
  static List<Map<String, dynamic>>? _fertilizerDataCache;
  static int? _lastCacheUpdate;

  /// Loads and caches crop recommendation data
  static Future<List<Map<String, dynamic>>> getCropData() async {
    // Check in-memory cache first
    if (_cropDataCache != null && _isCacheValid()) {
      print('Using in-memory crop data cache');
      return _cropDataCache!;
    }

    // Check persistent cache
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_CROP_DATA_KEY);
    final lastUpdate = prefs.getInt('${_CROP_DATA_KEY}_timestamp');

    if (cachedData != null && lastUpdate != null && _isCacheValidFromTimestamp(lastUpdate)) {
      print('Using persistent crop data cache');
      final data = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
      _cropDataCache = data;
      _lastCacheUpdate = lastUpdate;
      return data;
    }

    // Load from CSV if cache is invalid or missing
    print('Loading crop data from CSV');
    final data = await _loadCropDataFromCsv();
    _cropDataCache = data;
    _lastCacheUpdate = DateTime.now().millisecondsSinceEpoch;

    // Update persistent cache
    await prefs.setString(_CROP_DATA_KEY, jsonEncode(data));
    await prefs.setInt('${_CROP_DATA_KEY}_timestamp', _lastCacheUpdate!);

    return data;
  }

  /// Loads and caches fertilizer recommendation data
  static Future<List<Map<String, dynamic>>> getFertilizerData() async {
    // Check in-memory cache first
    if (_fertilizerDataCache != null && _isCacheValid()) {
      print('Using in-memory fertilizer data cache');
      return _fertilizerDataCache!;
    }

    // Check persistent cache
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_FERTILIZER_DATA_KEY);
    final lastUpdate = prefs.getInt('${_FERTILIZER_DATA_KEY}_timestamp');

    if (cachedData != null && lastUpdate != null && _isCacheValidFromTimestamp(lastUpdate)) {
      print('Using persistent fertilizer data cache');
      final data = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
      _fertilizerDataCache = data;
      _lastCacheUpdate = lastUpdate;
      return data;
    }

    // Load from CSV if cache is invalid or missing
    print('Loading fertilizer data from CSV');
    final data = await _loadFertilizerDataFromCsv();
    _fertilizerDataCache = data;
    _lastCacheUpdate = DateTime.now().millisecondsSinceEpoch;

    // Update persistent cache
    await prefs.setString(_FERTILIZER_DATA_KEY, jsonEncode(data));
    await prefs.setInt('${_FERTILIZER_DATA_KEY}_timestamp', _lastCacheUpdate!);

    return data;
  }

  /// Loads crop recommendation data from CSV file
  static Future<List<Map<String, dynamic>>> _loadCropDataFromCsv() async {
    try {
      final String csvData = await rootBundle.loadString('assets/models/Crop_recommendation.csv');
      final List<String> rows = csvData.split('\n');
      
      if (rows.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // Get and validate headers
      final headers = rows[0].split(',').map((h) => h.trim()).toList();
      if (headers.isEmpty) {
        throw Exception('No headers found in CSV');
      }

      final List<Map<String, dynamic>> result = [];
      
      // Process each data row
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i].trim();
        if (row.isEmpty) continue; // Skip empty rows
        
        final values = row.split(',').map((v) => v.trim()).toList();
        
        // Skip rows that don't have enough values
        if (values.length != headers.length) {
          print('Warning: Row $i has ${values.length} values but expected ${headers.length}. Skipping row.');
          continue;
        }
        
        // Create map for this row
        final Map<String, dynamic> rowMap = {};
        for (var j = 0; j < headers.length; j++) {
          final value = values[j];
          // Try to convert to number if possible
          if (value.isNotEmpty) {
            try {
              final num? numValue = num.tryParse(value);
              rowMap[headers[j]] = numValue ?? value;
            } catch (e) {
              rowMap[headers[j]] = value;
            }
          } else {
            rowMap[headers[j]] = '';
          }
        }
        result.add(rowMap);
      }

      if (result.isEmpty) {
        throw Exception('No valid data rows found in CSV');
      }

      return result;
    } catch (e) {
      print('Error loading crop data from CSV: $e');
      rethrow;
    }
  }

  /// Loads fertilizer recommendation data from CSV file
  static Future<List<Map<String, dynamic>>> _loadFertilizerDataFromCsv() async {
    try {
      final String csvData = await rootBundle.loadString('assets/models/f2.csv');
      final List<String> rows = csvData.split('\n');
      
      if (rows.isEmpty) {
        throw Exception('Fertilizer CSV file is empty');
      }

      // Get and validate headers
      final headers = rows[0].split(',').map((h) => h.trim()).toList();
      if (headers.isEmpty) {
        throw Exception('No headers found in fertilizer CSV');
      }

      final List<Map<String, dynamic>> result = [];
      
      // Process each data row
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i].trim();
        if (row.isEmpty) continue; // Skip empty rows
        
        final values = row.split(',').map((v) => v.trim()).toList();
        
        // Skip rows that don't have enough values
        if (values.length != headers.length) {
          print('Warning: Row $i in fertilizer data has ${values.length} values but expected ${headers.length}. Skipping row.');
          continue;
        }
        
        // Create map for this row
        final Map<String, dynamic> rowMap = {};
        for (var j = 0; j < headers.length; j++) {
          final value = values[j];
          // Try to convert to number if possible
          if (value.isNotEmpty) {
            try {
              final num? numValue = num.tryParse(value);
              rowMap[headers[j]] = numValue ?? value;
            } catch (e) {
              rowMap[headers[j]] = value;
            }
          } else {
            rowMap[headers[j]] = '';
          }
        }
        result.add(rowMap);
      }

      if (result.isEmpty) {
        throw Exception('No valid data rows found in fertilizer CSV');
      }

      return result;
    } catch (e) {
      print('Error loading fertilizer data from CSV: $e');
      rethrow;
    }
  }

  /// Checks if in-memory cache is valid
  static bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    final age = DateTime.now().millisecondsSinceEpoch - _lastCacheUpdate!;
    return age < _CACHE_DURATION.inMilliseconds;
  }

  /// Checks if cache is valid from a given timestamp
  static bool _isCacheValidFromTimestamp(int timestamp) {
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    return age < _CACHE_DURATION.inMilliseconds;
  }

  /// Clears all caches (both in-memory and persistent)
  static Future<void> clearCache() async {
    _cropDataCache = null;
    _fertilizerDataCache = null;
    _lastCacheUpdate = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_CROP_DATA_KEY);
    await prefs.remove(_FERTILIZER_DATA_KEY);
    await prefs.remove('${_CROP_DATA_KEY}_timestamp');
    await prefs.remove('${_FERTILIZER_DATA_KEY}_timestamp');
  }
} 