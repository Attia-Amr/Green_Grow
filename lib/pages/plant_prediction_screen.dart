import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../services/ml_service.dart';
import '../models/agricultural_data.dart';
import 'fertilizer_screen.dart';
import 'dart:io';
import '../utils/page_transition.dart';
import '../services/analysis_service.dart';
import 'package:flutter/rendering.dart';

// PlantPredictionScreen is a StatefulWidget that handles crop prediction based on soil analysis
// It takes an optional previousAnalysis parameter to pre-fill form fields with historical data
// This allows users to reference or modify previous soil analysis results
class PlantPredictionScreen extends StatefulWidget {
  final AgriculturalData? previousAnalysis;

  const PlantPredictionScreen({
    super.key,
    this.previousAnalysis,
  });

  @override
  State<PlantPredictionScreen> createState() => _PlantPredictionScreenState();
}

// State class for PlantPredictionScreen that manages form state, user input validation,
// and the prediction process. It handles all the business logic for soil analysis and crop prediction.
class _PlantPredictionScreenState extends State<PlantPredictionScreen> with AutomaticKeepAliveClientMixin {
  // Add keep alive override
  @override
  bool get wantKeepAlive => true;

  // Form key for validating all input fields before submission
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers for each input field to manage user input
  // These controllers allow for programmatic access to form field values
  final TextEditingController _soilTypeController = TextEditingController();
  final TextEditingController _phLevelController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();

  // State variables to track prediction results and UI state
  String? _prediction;  // Stores the predicted crop type
  bool _isLoading = false;  // Tracks loading state during prediction
  String _selectedSoilType = 'Sandy';  // Default soil type selection


  @override
  void initState() {
    super.initState();
    if (widget.previousAnalysis != null) {
      _loadPreviousAnalysis();
    }
  }

  // Loads previous analysis data into form fields
  // This allows users to reference or modify previous soil analysis results
  Future<void> _loadPreviousAnalysis() async {
    try {
      if (widget.previousAnalysis != null) {
        setState(() {
          // Populate all form fields with previous analysis data
          _soilTypeController.text = widget.previousAnalysis!.soilType;
          _selectedSoilType = widget.previousAnalysis!.soilType;
          _temperatureController.text = widget.previousAnalysis!.temperature.toString();
          _humidityController.text = widget.previousAnalysis!.humidity.toString();
          _rainfallController.text = widget.previousAnalysis!.rainfall.toString();
          _nitrogenController.text = widget.previousAnalysis!.nitrogen.toString();
          _potassiumController.text = widget.previousAnalysis!.potassium.toString();
          _phosphorusController.text = widget.previousAnalysis!.phosphorus.toString();
          _phLevelController.text = widget.previousAnalysis!.pH.toString();
        });
      }
    } catch (e) {
      print('Error loading previous analysis: $e');
    }
  }

  @override
  void dispose() {
    // Clean up all controllers to prevent memory leaks
    _soilTypeController.dispose();
    _phLevelController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _nitrogenController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _rainfallController.dispose();
    super.dispose();
  }

  // Main prediction function that processes soil analysis data and predicts suitable crops
  // This is the core functionality of the screen, handling validation, ML prediction,
  // and result presentation
  Future<void> _predictPlant() async {
    print('Starting plant prediction process...');
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }
    print('Form validation passed');

    setState(() {
      _isLoading = true;
    });

    try {
      print('Validating input values...');
      // Validate all input values to ensure they are within acceptable ranges
      // This prevents invalid data from being sent to the ML model
      final phLevel = double.parse(_phLevelController.text);
      if (phLevel < 0 || phLevel > 14) {
        throw Exception('Invalid pH range');
      }

      final phosphorus = double.parse(_phosphorusController.text);
      final potassium = double.parse(_potassiumController.text);
      final nitrogen = double.parse(_nitrogenController.text);
      if (phosphorus < 0 || potassium < 0 || nitrogen < 0) {
        throw Exception('Invalid nutrient values');
      }

      final temperature = double.parse(_temperatureController.text);
      if (temperature < -50 || temperature > 50) {
        throw Exception('Invalid temperature range');
      }

      final humidity = double.parse(_humidityController.text);
      if (humidity < 0 || humidity > 100) {
        throw Exception('Invalid humidity range');
      }

      final moisture = double.parse(_rainfallController.text);
      if (moisture < 0) {
        throw Exception('Invalid rainfall format');
      }

      print('Input values validated successfully');
      print('Calling MLService.predictPlant...');
      final mlService = MLService();
      final prediction = await mlService.predictPlant(
        soilType: _selectedSoilType,
        phLevel: phLevel,
        phosphorus: phosphorus,
        potassium: potassium,
        nitrogen: nitrogen,
        temperature: temperature,
        humidity: humidity,
        moisture: moisture,
      );
      print('Prediction received: $prediction');

      if (prediction == null || prediction.isEmpty) {
        throw Exception('Prediction error');
      }

      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });

      if (mounted) {
        _showPredictionResult([prediction], 'AI recommendations would go here');
      }
    } catch (e) {
      print('Error in prediction: $e');
      setState(() {
        _isLoading = false;
        _prediction = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigates to the fertilizer recommendation screen with the current analysis data
  // This allows users to get fertilizer recommendations for their predicted crop
  void _navigateToFertilizer() {
    print('=== Fertilizer Navigation Debug ===');
    print('_prediction value: $_prediction');
    print('_selectedSoilType: $_selectedSoilType');
    print('pH Level: ${_phLevelController.text}');
    print('Temperature: ${_temperatureController.text}');
    print('Humidity: ${_humidityController.text}');
    print('Rainfall: ${_rainfallController.text}');
    print('Nitrogen: ${_nitrogenController.text}');
    print('Potassium: ${_potassiumController.text}');
    print('Phosphorus: ${_phosphorusController.text}');
    print('==============================');

    if (_prediction == null) {
      print('Error: _prediction is null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No prediction available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare agricultural data for fertilizer recommendation
    final agriculturalData = {
      'soilType': _selectedSoilType,
      'pH': double.parse(_phLevelController.text),
      'temperature': double.parse(_temperatureController.text),
      'humidity': double.parse(_humidityController.text),
      'rainfall': double.parse(_rainfallController.text),
      'nitrogen': double.parse(_nitrogenController.text),
      'potassium': double.parse(_potassiumController.text),
      'phosphorus': double.parse(_phosphorusController.text),
      'predictedCrop': _prediction,
      'cropType': _prediction,
      'analysisType': 'Crop Recommendation',
    };

    print('=== Agricultural Data Being Passed ===');
    print(agriculturalData);
    print('==================================');

    // Navigate to fertilizer screen with the analysis data
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FertilizerScreen(
          agriculturalData: agriculturalData,
          selectedCrop: _prediction!,
        ),
      ),
    );
  }

  // Builds the main UI of the screen
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      body: Stack(
        children: [
          // Background Image with extended edges for visual appeal
          // Positioned slightly off-screen to create a full-bleed effect
          Positioned(
            top: -60,
            left: -45,
            right: -0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.37,
              child: Image.asset(
                'assets/images/topheader.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent blur overlay to improve text readability
          // Creates a frosted glass effect over the background image
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          // Main Content Area with safe area handling
          SafeArea(
            bottom: false, // Don't apply safe area at bottom (handled by nav)
            child: Column(
              children: [
                // Space for header image
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                // Main form container with white background and rounded top corners
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 235, 234, 234),  ///////////////////////////////////////////////////////// لون الخلفيه
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 28),
                        // Screen title with consistent styling
Text(
  'Soil Analysis',
  style: const TextStyle(
    fontSize: 35,
    
    fontWeight: FontWeight.w700,
    color:  const Color.fromARGB(255, 14, 63, 26),
    letterSpacing: 0,
    height: 1,
    shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(1, 1),
        blurRadius: 2,
      ),
    ],
  ),
),


                        const SizedBox(height: 32),
                        // Scrollable form container with bounce physics
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                24,
                                0,
                                24,
                                MediaQuery.of(context).viewInsets.bottom + 20,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Two-column layout for form fields
                                    // Left column contains labels, right column contains inputs
                                    IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Labels Column with fixed width
                                          SizedBox(
                                            width: 100,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Soil type label
                                                Text(
                                                  'Soil Type',
                                                  style: const TextStyle(
                                                    color: Color(0xFF0C2C1E),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                // pH level label
                                                Text(
                                                  'pH Level',
                                                  style: const TextStyle(
                                                    color: Color(0xFF0C2C1E),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                // Phosphorus label
                                                Text(
                                                  'Phosphorus',
                                                  style: const TextStyle(
                                                    color: Color(0xFF0C2C1E),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                // Potassium label
                                                Text(
                                                  'Potassium',
                                                  style: const TextStyle(
                                                    color: Color(0xFF0C2C1E),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                // Nitrogen label
                                                Text(
                                                  'Nitrogen',
                                                  style: const TextStyle(
                                                    color: Color(0xFF0C2C1E),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                // Temperature label
                                                Text(
                                                  'Temperature',
                                                  style: const TextStyle(
                                                    color: Color(0xFF0C2C1E),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                // Humidity label
                                                Text(
                                                  'Humidity',
                                                  style: const TextStyle(
                                                    color: Color(0xFF0C2C1E),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                // Rainfall label
                                                Text(
                                                  'Rainfall',
                                                  style: const TextStyle(
                                                    color: Color(0xFF0C2C1E),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Inputs Column with flexible width
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Soil type dropdown
                                                _buildDropdownField(
                                                  value: _selectedSoilType,
                                                  items: MLService.soilTypes,
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      setState(() {
                                                        _selectedSoilType = newValue;
                                                        _soilTypeController.text = newValue;
                                                      });
                                                    }
                                                  },
                                                  icon: Icons.landscape,
                                                ),
                                                const SizedBox(height: 16),
                                                // pH level input field
                                                _buildInputField(
                                                  controller: _phLevelController,
                                                  placeholder: 'Enter pH level',
                                                  unit: '',
                                                  icon: Icons.water_drop,
                                                ),
                                                const SizedBox(height: 16),
                                                // Phosphorus input field
                                                _buildInputField(
                                                  controller: _phosphorusController,
                                                  placeholder: '0 - 100',
                                                  unit: 'mg/kg',
                                                  icon: Icons.science,
                                                ),
                                                const SizedBox(height: 16),
                                                // Potassium input field
                                                _buildInputField(
                                                  controller: _potassiumController,
                                                  placeholder: '0 - 100',
                                                  unit: 'mg/kg',
                                                  icon: Icons.grain,
                                                ),
                                                const SizedBox(height: 16),
                                                // Nitrogen input field
                                                _buildInputField(
                                                  controller: _nitrogenController,
                                                  placeholder: '0 - 100',
                                                  unit: 'mg/kg',
                                                  icon: Icons.eco,
                                                ),
                                                const SizedBox(height: 16),
                                                // Temperature input field
                                                _buildInputField(
                                                  controller: _temperatureController,
                                                  placeholder: 'Enter temperature',
                                                  unit: '°C',
                                                  icon: Icons.thermostat,
                                                ),
                                                const SizedBox(height: 16),
                                                // Humidity input field
                                                _buildInputField(
                                                  controller: _humidityController,
                                                  placeholder: 'Enter humidity',
                                                  unit: '%',
                                                  icon: Icons.water_drop,
                                                ),
                                                const SizedBox(height: 16),
                                                // Rainfall input field
                                                _buildInputField(
                                                  controller: _rainfallController,
                                                  placeholder: 'Enter rainfall',
                                                  unit: 'mm',
                                                  icon: Icons.water,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Predict Button with loading state
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _predictPlant,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 14, 63, 26),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                'Predict',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build consistent styled input fields
  // Creates text fields with validation, icons and unit labels
  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required String unit,
    required IconData icon,
  }) {
    return Container(
  height: 40,
  decoration: BoxDecoration(
    color: const Color.fromARGB(255, 187, 204, 195), // Light green background
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.10), // لون الشادو وشفافيته
        blurRadius: 3, // نعومة الشادو
        offset: Offset(0, 2), // اتجاه الشادو (يمين/يسار، فوق/تحت)
      ),
    ],
  ),
  child: TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      hintText: placeholder,
      hintStyle: const TextStyle(
        color: Color.fromARGB(110, 7, 34, 14),
        fontSize: 14,
      ),
      suffixText: unit,
      suffixStyle: const TextStyle(
        color: Color(0xFF116530),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color.fromARGB(255, 14, 85, 40),
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 187, 204, 195),
    ),
    validator: (value) {
      print('Validating field with value: $value');
      if (value == null || value.isEmpty) {
        print('Field validation failed: value is empty');
        return 'This field is required';
      }
      try {
        final numValue = double.parse(value);
        print('Field validation passed: $numValue');
        return null;
      } catch (e) {
        print('Field validation failed: $e');
        return 'Invalid number format';
      }
    },
  ),
);

  }

  // Helper method to build consistent dropdown fields
  // Creates dropdowns for soil type selection with custom styling
  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
   return Container(
  height: 40,
  decoration: BoxDecoration(
    color: const Color(0xFFEAFBF2),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.10), // لون الظل وشفافيته
        blurRadius: 3, // نعومة الظل
        offset: const Offset(0, 2), // اتجاه الظل (يمين/يسار، فوق/تحت)
      ),
    ],
  ),
  child: DropdownButtonFormField<String>(
    value: value,
    items: items.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      );
    }).toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: const Color.fromARGB(255, 10, 88, 39),
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 146, 170, 160),
    ),
    icon: const Icon(
      Icons.keyboard_arrow_down,
      color: Color.fromARGB(255, 22, 73, 41),
      size: 20,
    ),
    style: const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
    dropdownColor: const Color.fromARGB(255, 198, 214, 207),
  ),
);

  }

  // Shows the prediction result in a modal dialog
  // This provides a detailed view of the recommended crop with AI recommendations
  void _showPredictionResult(List<String> predictedPlants, String aiRecommendations) {
    print('_showPredictionResult called with prediction: ${predictedPlants.first}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
Text(
  'Recommended Plants',
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.w800, // خط أثقل شوي
    color:const Color.fromARGB(255, 14, 63, 26), // لون زيتوني غامق
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.15), // تقليل الشادو للـ 15%
        offset: const Offset(1, 1), // تقليل المسافة
        blurRadius: 2, // تقليل نعومة الشادو
      ),
    ],
  ),
),

                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/plants/${predictedPlants.first.toLowerCase()}.png',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if (frame == null) {
                              return SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      const Color.fromARGB(255, 112, 172, 115),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return AnimatedOpacity(
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              child: child,
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              color: Colors.green.withOpacity(0.1),
                              child: Center(
                                child: Icon(
                                  Icons.eco,
                                  size: 40,
                                  color: Colors.green.shade300,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(15),
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                predictedPlants.first,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Optimal Conditions',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
Expanded(
  child: TextButton(
    onPressed: () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    },
    style: TextButton.styleFrom(
      foregroundColor: Colors.grey[800], // رصاصي غامق
    ),
    child: const Text('Close'),
  ),
),

                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (mounted) {
                            Navigator.of(context).pop();
                            _navigateToFertilizer();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 9, 65, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Get Fertilizer Recommendation',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 