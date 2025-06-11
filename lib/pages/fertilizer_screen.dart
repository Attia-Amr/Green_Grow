import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../services/ml_service.dart';
import '../models/agricultural_data.dart';
import '../models/fertilizer_recommendation.dart';
import 'plant_prediction_screen.dart';
import 'dart:io';
import 'package:hellow/pages/plant_prediction_screen.dart';



/// FertilizerScreen is a StatefulWidget that allows users to input agricultural data
/// and receive fertilizer recommendations based on machine learning predictions.
/// 
/// This screen collects soil parameters (type, nutrients), environmental conditions
/// (temperature, humidity, rainfall), and crop information to determine the optimal
/// fertilizer type and application recommendations for maximizing crop yield.
class FertilizerScreen extends StatefulWidget {
  // Agricultural data passed from previous screens (soil analysis, crop detection, etc.)
  // Contains soil properties, environmental conditions, and crop information
  final Map<String, dynamic> agriculturalData;
  
  // Selected crop type that the user is growing or planning to grow
  // Used as primary input for the fertilizer recommendation algorithm
  final String selectedCrop;

  // Default values for agricultural data parameters if none provided
  // These represent typical moderate conditions suitable for basic analysis
  static const Map<String, dynamic> defaultAgriculturalData = {
    'soilType': 'Sandy',      // Default soil type 
    'pH': 7.99,                // Neutral pH balance
    'temperature': 25.0,      // Room temperature in Celsius
    'humidity': 50.0,         // Moderate humidity percentage
    'rainfall': 0.0,          // No rainfall by default
    'nitrogen': 0.0,          // Initial NPK values set to zero
    'potassium': 0.0,         // to ensure user provides actual readings
    'phosphorus': 0.0,        // for accurate recommendations
    'predictedCrop': 'Rice',  // Common crop with wide growing range
    'cropType': 'Rice',       // Matches predicted crop for consistency
    'analysisType': 'Fertilizer Recommendation', // Identifies analysis purpose
  };

  // Public constructor with optional parameters and default values
  // Allows screen to be instantiated with partial or no data
  const FertilizerScreen({
    Key? key,
    Map<String, dynamic>? agriculturalData,
    String? selectedCrop,
  }) : this._(
          key: key,
          agriculturalData: agriculturalData ?? defaultAgriculturalData,
          selectedCrop: selectedCrop ?? 'Rice',
        );

  // Private constructor with required parameters
  // Used by the public constructor to enforce required fields
  const FertilizerScreen._({
    Key? key,
    required this.agriculturalData,
    required this.selectedCrop,
  }) : super(key: key);

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

/// State class for the FertilizerScreen that manages UI state, user input,
/// and fertilizer prediction logic
class _FertilizerScreenState extends State<FertilizerScreen> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final MLService _mlService = MLService();
  bool _isMLServiceInitialized = false;
  
  // Text controllers for input fields
  final _cropTypeController = TextEditingController();
  final _soilTypeController = TextEditingController();
  final _phLevelController = TextEditingController();
  final _nitrogenController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _rainfallController = TextEditingController();
  
  String? _predictedFertilizer;
  FertilizerRecommendation? _recommendation;
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedSoilType = 'Sandy';
  String _selectedCropType = '';

  // Map of fertilizer types to their image assets for visual representation
  // This helps users visually identify recommended fertilizer products
  final Map<String, String> _fertilizerImages = {
    'Urea': 'assets/images/fertilizers/urea.png', // High nitrogen fertilizer
    'DAP': 'assets/images/fertilizers/dap.png',   // Diammonium phosphate
    'NPK': 'assets/images/fertilizers/17-17-17.png', // Balanced NPK formula
    'TSP': 'assets/images/fertilizers/tsp.png',   // Triple superphosphate
    'Superphosphate': 'assets/images/fertilizers/superphosphate.png', // High phosphorus
    'Potassium sulfate': 'assets/images/fertilizers/potassium_sulfate.png', // K source
    'Potassium chloride': 'assets/images/fertilizers/potassium_chloride.png', // K source
    '28-28': 'assets/images/fertilizers/28-28.png', // High N-P formula
    '20-20': 'assets/images/fertilizers/20-20.png', // Balanced N-P formula
    '17-17-17': 'assets/images/fertilizers/17-17-17.png', // Classic balanced formula
    '15-15-15': 'assets/images/fertilizers/15-15-15.png', // Balanced lower concentration
    '14-35-14': 'assets/images/fertilizers/14-35-14.png', // Phosphorus-focused formula
    '14-14-14': 'assets/images/fertilizers/14-14-14.png', // Balanced lower concentration
    '10-26-26': 'assets/images/fertilizers/10-26-26.png', // P-K focused formula
    '10-10-10': 'assets/images/fertilizers/10-10-10.png', // Entry level balanced formula
  };

  @override
  void initState() {
    super.initState();
    _initializeMLService();
  }

  Future<void> _initializeMLService() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _mlService.initialize();
      setState(() {
        _isMLServiceInitialized = true;
        // Set initial crop type from available options
        if (MLService.cropTypes.isNotEmpty) {
          _selectedCropType = widget.selectedCrop;
          if (!MLService.cropTypes.contains(_selectedCropType)) {
            _selectedCropType = MLService.cropTypes.first;
          }
        }
      });
      _populateFields();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing service: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFields() {
    _cropTypeController.text = _selectedCropType;
    _soilTypeController.text = widget.agriculturalData['soilType'] ?? '';
    _phLevelController.text = widget.agriculturalData['pH']?.toString() ?? '';
    _nitrogenController.text = widget.agriculturalData['nitrogen']?.toString() ?? '';
    _potassiumController.text = widget.agriculturalData['potassium']?.toString() ?? '';
    _phosphorusController.text = widget.agriculturalData['phosphorus']?.toString() ?? '';
    _temperatureController.text = widget.agriculturalData['temperature']?.toString() ?? '';
    _humidityController.text = widget.agriculturalData['humidity']?.toString() ?? '';
    _rainfallController.text = widget.agriculturalData['rainfall']?.toString() ?? '';
    _selectedSoilType = widget.agriculturalData['soilType'] ?? 'Sandy';
  }

  @override
  void dispose() {
    // Clean up all controllers when widget is disposed to prevent memory leaks
    _scrollController.dispose();
    _cropTypeController.dispose();
    _soilTypeController.dispose();
    _phLevelController.dispose();
    _nitrogenController.dispose();
    _potassiumController.dispose();
    _phosphorusController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _rainfallController.dispose();
    super.dispose();
  }

  /// Predicts the optimal fertilizer based on user-input agricultural values
  /// This is the core function that processes data and returns recommendations
  Future<void> _predictFertilizer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _predictedFertilizer = null;
      _recommendation = null;
    });

    try {
      final nitrogen = double.parse(_nitrogenController.text);
      final potassium = double.parse(_potassiumController.text);
      final phosphorous = double.parse(_phosphorusController.text);
      if (nitrogen < 0 || potassium < 0 || phosphorous < 0) {
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
      if (moisture < 0 || moisture > 100) {
        throw Exception('Invalid moisture range');
      }

      final recommendation = await _mlService.predictFertilizer(
        cropType: _selectedCropType,
        nitrogen: nitrogen,
        potassium: potassium,
        phosphorous: phosphorous,
        temperature: temperature,
        humidity: humidity,
        soilMoisture: moisture,
        soilType: _selectedSoilType,
      );

      setState(() {
        _predictedFertilizer = recommendation.recommendedFertilizer;
        _recommendation = recommendation;
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
Text(
  'Hello',
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 26, 71, 52), // زيتوني غامق
    shadows: [
      Shadow(
        color: Colors.black26, // ظل خفيف
        offset: Offset(1, 1),
        blurRadius: 2,
      ),
    ],
  ),
),

                    const SizedBox(height: 24),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAFBF2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            _fertilizerImages[_predictedFertilizer] ?? 'assets/images/fertilizers/plant_default.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                            
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.eco,
                                color: Color(0xFF116530),
                                size: 40,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _predictedFertilizer!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0C2C1E),
                      ),
                    ),
                    if (_recommendation?.description != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _recommendation!.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0C2C1E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  const Color.fromARGB(255, 14, 63, 26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /// Automatically scrolls to the next input field when user moves through form
  /// Improves usability by keeping the current field visible as user progresses
  void _scrollToNextField(int index) {
    final itemHeight = 65.0; // Approximate height of each form field with padding
    final screenHeight = MediaQuery.of(context).size.height;
    final scrollOffset = index * itemHeight;
    
    // Only scroll if the target field would be off-screen
    if (scrollOffset > _scrollController.offset + screenHeight - 200) {
      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300), // Smooth animation
        curve: Curves.easeInOut, // Easing animation curve
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    if (!_isMLServiceInitialized) {
      return Scaffold(
  appBar: AppBar(
    title: const Text('Fertilizer Recommendation'),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context); // يرجعك للصفحة السابقة
      },
    ),
  ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      body: Stack(
        children: [
          // Background Image with curve effect at top of screen
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
          // Semi-transparent blur overlay for better text contrast
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          // Main Content Area - Form and inputs
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
                    decoration: const BoxDecoration(
                      color: const Color.fromARGB(255, 235, 234, 234), /////////////////////////////////////////// لون الباك جراوند
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20.0),
  child: Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        iconSize: 30, // ✅

        color: Color.fromARGB(255, 14, 63, 26),
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => PlantPredictionScreen()),
            (Route<dynamic> route) => false,
          );
        },
      ),
      const SizedBox(width: 15),
      Expanded(
        child: Text(
          'Fertilizer Analysis',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: const Color.fromARGB(255, 14, 63, 26),
            letterSpacing: 0,
            height: 2.5,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),



                        const SizedBox(height: 12),
                        // Scrollable form container
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(), // iOS-style bounce
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
                                    // Two-column layout with labels and input fields
                                    IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // First column: Field labels
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
                                                 // Crop type label
                                                Text(
                                                  'Crop Type',
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
                                                // Soil moisture label
                                                Text(
                                                  'Soil Moisture',
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
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Second column: Input fields
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Soil type dropdown (Clay, Loamy, Sandy, etc.)
                                                _buildDropdownField(
                                                  value: _selectedSoilType,
                                                  items: MLService.soilTypes,
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      setState(() {
                                                        _selectedSoilType = newValue;
                                                      });
                                                      _scrollToNextField(4);
                                                    }
                                                  },
                                                  icon: Icons.landscape,
                                                ),
                                                const SizedBox(height: 20),
                                                // Crop type dropdown (Rice, Wheat, Cotton, etc.)
                                                _buildDropdownField(
                                                  value: _selectedCropType,
                                                  items: MLService.cropTypes,
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      setState(() {
                                                        _selectedCropType = newValue;
                                                      });
                                                      _scrollToNextField(5);
                                                    }
                                                  },
                                                  icon: Icons.grass,
                                                ),
                                                const SizedBox(height: 20),
                                                // Temperature input field (-50°C to 50°C)
                                                _buildInputField(
                                                  controller: _temperatureController,
                                                  placeholder: 'Input range',
                                                  unit: '°C',
                                                  icon: Icons.thermostat,
                                                  fieldIndex: 0,
                                                ),
                                                const SizedBox(height: 16),
                                                // Humidity input field (0-100%)
                                                _buildInputField(
                                                  controller: _humidityController,
                                                  placeholder: 'Input range',
                                                  unit: '%',
                                                  icon: Icons.water_drop,
                                                  fieldIndex: 1,
                                                ),
                                                const SizedBox(height: 16),
                                                // Soil moisture/rainfall input field (0-100%)
                                                _buildInputField(
                                                  controller: _rainfallController,
                                                  placeholder: 'Input range',
                                                  unit: '%',
                                                  icon: Icons.water,
                                                  fieldIndex: 2,
                                                ),
                                                const SizedBox(height: 20),
                                                
                                                // Nitrogen input field (0-100 mg/kg)
                                                _buildInputField(
                                                  controller: _nitrogenController,
                                                  placeholder: 'Input range',
                                                  unit: 'mg/kg',
                                                  icon: Icons.eco,
                                                  fieldIndex: 5,
                                                ),
                                                const SizedBox(height: 20),
                                                // Phosphorus input field (0-100 mg/kg)
                                                _buildInputField(
                                                  controller: _phosphorusController,
                                                  placeholder: 'Input range',
                                                  unit: 'mg/kg',
                                                  icon: Icons.science,
                                                  fieldIndex: 6,
                                                ),
                                                const SizedBox(height: 20),
                                                // Potassium input field (0-100 mg/kg)
                                                _buildInputField(
                                                  controller: _potassiumController,
                                                  placeholder: 'Input range',
                                                  unit: 'mg/kg',
                                                  icon: Icons.grain,
                                                  fieldIndex: 7,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    // Error message display for validation failures or API errors
                                    if (_errorMessage.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          _errorMessage,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    // Predict Button - Triggers ML prediction process
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _predictFertilizer,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:  const Color.fromARGB(255, 14, 63, 26), // Green button
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25), // Pill shape
                                          ),
                                          elevation: 0, // Flat design
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                'Predict',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
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

  /// Helper method to build consistent styled input fields
  /// Creates text fields with validation, icons and unit labels
  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required String unit,
    required IconData icon,
    required int fieldIndex,
  }) {
return Container(
  height: 40,
  decoration: BoxDecoration(
    color: const Color.fromARGB(255, 187, 204, 195), // Light green background
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1), // ظل خفيف
        blurRadius: 4, // درجة التمويه
        offset: Offset(0, 2), // اتجاه الظل (أسفل قليلًا)
      ),
    ],
  ),
  child: TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    style: const TextStyle(fontSize: 14),
    onFieldSubmitted: (_) => _scrollToNextField(fieldIndex + 1),
    decoration: InputDecoration(
      hintText: placeholder,
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontSize: 12,
      ),
      suffixText: unit,
      suffixStyle: const TextStyle(
        color: Color.fromARGB(255, 77, 136, 99),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF116530),
        size: 18,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 187, 204, 195),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Required field';
      }
      return null;
    },
  ),
);

  }

  /// Helper method to build consistent dropdown fields
  /// Creates dropdowns for soil type and crop selection
  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    // Show loading indicator if items list is empty (still loading)
    if (items.isEmpty) {
      return Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEAFBF2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Ensure selected value exists in items list
    final currentValue = items.contains(value) ? value : items.first;
    
return Container(
  height: 40,
  decoration: BoxDecoration(
    color: const Color.fromARGB(255, 146, 170, 160), // Light green background
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1), // ظل خفيف
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: DropdownButtonFormField<String>(
    value: currentValue,
    items: items.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(
          item,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      );
    }).toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF116530), // Green icon
        size: 18,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 146, 170, 160), // Same background
    ),
    icon: const Icon(
      Icons.keyboard_arrow_down,
      color: Color(0xFF116530),
      size: 18,
    ),
    dropdownColor: const Color.fromARGB(255, 198, 214, 207),
  ),
);

  }

  // Add keep alive override
  @override
  bool get wantKeepAlive => true;
} 


//InputDecoration