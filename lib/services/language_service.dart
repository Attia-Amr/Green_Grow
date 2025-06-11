/*
GREENGROW APP - LANGUAGE SERVICE

This file implements the internationalization and localization system for the app.

SIMPLE EXPLANATION:
- This is like an automatic translator that helps the app speak different languages
- It allows users to switch between English and Arabic with a single tap
- It automatically flips the screen layout for Arabic (right-to-left) text
- It stores your language preference so you don't have to select it every time
- It provides translations for all text in the app
- It handles special formatting needs like dates and numbers in different languages
- It supports replacement of variables in translations like user names or values

TECHNICAL EXPLANATION:
- Implements a comprehensive localization system with dynamic language switching
- Contains RTL/LTR text direction management for proper bidirectional text support
- Implements persistent language preferences through SharedPreferences
- Contains a hierarchical translation dictionary with over 200 localized strings
- Implements a listener pattern for real-time UI updates on language change
- Contains performance optimization through multi-level translation caching
- Implements parameter substitution for dynamic text generation
- Contains helper methods for directional UI elements like alignment and padding
- Implements proper cache invalidation when language changes
- Contains utility wrapper components for consistent text direction throughout the app

This service ensures the application is accessible to users in multiple languages,
providing a seamless multilingual experience with proper cultural adaptation.
*/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LanguageService manages application localization and text direction
/// It provides functionality for:
/// - Language switching between English and Arabic
/// - Text direction management (LTR/RTL)
/// - Translation lookup
/// - Persistent language preferences
/// - Layout alignment helpers
class LanguageService {
  // Key for storing language preference
  static const String _languageKey = 'selected_language';
  // Current language code (defaults to English)
  static String _currentLanguage = 'en';
  // List of callbacks to notify when language changes
  static final List<Function> _listeners = [];

  // Add caching
  static final Map<String, Map<String, String>> _translationCache = {};
  static final Map<String, String> _keyCache = {};
  static const Duration _CACHE_DURATION = Duration(hours: 1);
  static int? _lastCacheUpdate;

  /// Initializes the language service with saved preferences
  /// Should be called at app startup
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'en';
  }

  /// Returns the current language code
  static String getCurrentLanguageCode() {
    return _currentLanguage;
  }

  /// Changes the application language
  /// 
  /// [languageCode] - The language code to switch to ('en' or 'ar')
  /// 
  /// Throws an exception if the language code is not supported
  static Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'ar') {
      throw Exception('Unsupported language code: $languageCode');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    _currentLanguage = languageCode;
    
    // Notify all registered listeners of the language change
    for (var listener in _listeners) {
      listener();
    }

    // Clear cache when language changes
    _clearCache();
  }

  /// Toggles between English and Arabic languages
  static Future<void> toggleLanguage() async {
    final newLanguage = _currentLanguage == 'en' ? 'ar' : 'en';
    await setLanguage(newLanguage);
  }

  /// Checks if the current language is right-to-left
  static bool isRtl() {
    return _currentLanguage == 'ar';
  }

  /// Registers a callback for language change notifications
  static void addListener(Function callback) {
    _listeners.add(callback);
  }

  /// Removes a previously registered language change callback
  static void removeListener(Function callback) {
    _listeners.remove(callback);
  }

  /// Check if cache is valid
  static bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - _lastCacheUpdate!) < _CACHE_DURATION.inMilliseconds;
  }

  /// Clear cache when language changes
  static void _clearCache() {
    _translationCache.clear();
    _keyCache.clear();
    _lastCacheUpdate = null;
  }

  /// Add to cache
  static void _cacheTranslation(String locale, String key, String translation) {
    if (!_translationCache.containsKey(locale)) {
      _translationCache[locale] = {};
    }
    _translationCache[locale]![key] = translation;
    _keyCache[key] = translation;
    _lastCacheUpdate = DateTime.now().millisecondsSinceEpoch;
  }

  /// Get from cache
  static String? _getCachedTranslation(String locale, String key) {
    if (!_isCacheValid()) {
      _clearCache();
      return null;
    }
    return _translationCache[locale]?[key] ?? _keyCache[key];
  }

  /// Replaces parameters in a translation string
  /// 
  /// [text] - The text containing parameter placeholders
  /// [params] - Map of parameter names to their values
  /// 
  /// Returns the text with all parameters replaced
  static String _replaceParams(String text, Map<String, dynamic> params) {
    String result = text;
    params.forEach((paramKey, paramValue) {
      result = result.replaceAll('{$paramKey}', paramValue.toString());
    });
    return result;
  }

  /// Translates a key into the current language
  /// 
  /// [context] - The build context
  /// [key] - The translation key to look up
  /// [params] - Optional parameters for string interpolation
  /// 
  /// Returns the translated string, or the key if no translation is found
  static String translate(BuildContext context, String key, [Map<String, dynamic>? params]) {
    final locale = Localizations.localeOf(context).languageCode;
    
    // Check cache first
    final cachedTranslation = _getCachedTranslation(locale, key);
    if (cachedTranslation != null) {
      if (params != null) {
        return _replaceParams(cachedTranslation, params);
      }
      return cachedTranslation;
    }

    // Get translation from delegate
    String translation = _translations[key]?[_currentLanguage] ?? key;
    
    // Cache the translation
    _cacheTranslation(locale, key, translation);

    // Replace parameters if provided
    if (params != null) {
      translation = _replaceParams(translation, params);
    }

    return translation;
  }

  /// Translation map containing all supported strings
  /// Organized by key and language code
  static final Map<String, Map<String, String>> _translations = {
    // Login and registration
    'login': {
      'en': 'Login',
      'ar': 'تسجيل الدخول',
    },
    'register': {
      'en': 'Register',
      'ar': 'تسجيل',
    },
    'email': {
      'en': 'Email',
      'ar': 'البريد الإلكتروني',
    },
    'password': {
      'en': 'Password',
      'ar': 'كلمة المرور',
    },
    'confirm_password': {
      'en': 'Confirm Password',
      'ar': 'تأكيد كلمة المرور',
    },
    'current_password': {
      'en': 'Current Password',
      'ar': 'كلمة المرور الحالية',
    },
    'new_password': {
      'en': 'New Password',
      'ar': 'كلمة المرور الجديدة',
    },
    'change_password': {
      'en': 'Change Password',
      'ar': 'تغيير كلمة المرور',
    },
    'all_fields_required': {
      'en': 'All fields are required',
      'ar': 'جميع الحقول مطلوبة',
    },
    'passwords_dont_match': {
      'en': 'Passwords don\'t match',
      'ar': 'كلمات المرور غير متطابقة',
    },
    'current_password_incorrect': {
      'en': 'Current password is incorrect',
      'ar': 'كلمة المرور الحالية غير صحيحة',
    },
    'password_too_short': {
      'en': 'Password must be at least 6 characters',
      'ar': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
    },
    'password_updated': {
      'en': 'Password updated successfully',
      'ar': 'تم تحديث كلمة المرور بنجاح',
    },
    'username': {
      'en': 'Username',
      'ar': 'اسم المستخدم',
    },
    'phone': {
      'en': 'Phone',
      'ar': 'رقم الهاتف',
    },
    'location': {
      'en': 'Location',
      'ar': 'الموقع',
    },
    
    // Profile screen
    'profile': {
      'en': 'Profile',
      'ar': 'الملف الشخصي',
    },
    'edit_name': {
      'en': 'Edit Name',
      'ar': 'تعديل الاسم',
    },
    'edit_email': {
      'en': 'Edit Email',
      'ar': 'تعديل البريد الإلكتروني',
    },
    'edit_phone': {
      'en': 'Edit Phone',
      'ar': 'تعديل رقم الهاتف',
    },
    'edit_location': {
      'en': 'Edit Location',
      'ar': 'تعديل الموقع',
    },
    'notifications': {
      'en': 'Notifications',
      'ar': 'الإشعارات',
    },
    'language': {
      'en': 'Language',
      'ar': 'اللغة',
    },
    'english': {
      'en': 'English',
      'ar': 'الإنجليزية',
    },
    'arabic': {
      'en': 'Arabic',
      'ar': 'العربية',
    },
    'help': {
      'en': 'Help',
      'ar': 'المساعدة',
    },
    'logout': {
      'en': 'Logout',
      'ar': 'تسجيل الخروج',
    },
    'go_back': {
      'en': 'Go Back',
      'ar': 'رجوع',
    },
    'save': {
      'en': 'Save',
      'ar': 'حفظ',
    },
    'cancel': {
      'en': 'Cancel',
      'ar': 'إلغاء',
    },
      
      // Navigation
    'home': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
    'plants': {
      'en': 'Plants',
      'ar': 'النباتات',
    },
    'irrigation': {
      'en': 'Irrigation',
      'ar': 'الري',
    },
    'irrigation_settings': {
      'en': 'Irrigation Settings',
      'ar': 'إعدادات الري',
    },
    'start_tracking_date': {
      'en': 'Start tracking from',
      'ar': 'بدء التتبع من',
    },
    'required_moisture': {
      'en': 'Required moisture level',
      'ar': 'مستوى الرطوبة المطلوب',
    },
    'alert_threshold': {
      'en': 'Alert when moisture below',
      'ar': 'تنبيه عندما تكون الرطوبة أقل من',
    },
    'irrigation_frequency': {
      'en': 'Irrigation every',
      'ar': 'الري كل',
    },
    'days': {
      'en': 'days',
      'ar': 'أيام',
    },
    'plant': {
      'en': 'Plant',
      'ar': 'النبات',
    },
    'fertilization': {
      'en': 'Fertilization',
      'ar': 'تسميد',
    },
    'welcome': {
      'en': 'Welcome',
      'ar': 'مرحباً',
    },
    
    // Permissions
    'location_permission_required': {
      'en': 'Location Permission Required',
      'ar': 'إذن الموقع مطلوب',
    },
    'location_permission_message': {
      'en': 'This app needs access to your location for better recommendations.',
      'ar': 'يحتاج هذا التطبيق إلى الوصول إلى موقعك للحصول على توصيات أفضل.',
    },
    'open_settings': {
      'en': 'Open Settings',
      'ar': 'فتح الإعدادات',
    },
    
    // Other
    'loading': {
      'en': 'Loading...',
      'ar': 'جاري التحميل...',
    },
    'error_loading': {
      'en': 'Error loading data',
      'ar': 'خطأ في تحميل البيانات',
    },
    'retry': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
    },
    
    // Plant prediction screen
    'plant_prediction': {
      'en': 'Plant Prediction',
      'ar': 'التنبؤ بالنبات',
    },
    'soil_parameters': {
      'en': 'Soil Parameters',
      'ar': 'معايير التربة',
    },
    'nutrient_levels': {
      'en': 'Nutrient Levels',
      'ar': 'مستويات المغذيات',
    },
    'environmental_conditions': {
      'en': 'Environmental Conditions',
      'ar': 'الظروف البيئية',
    },
    'ph_level': {
      'en': 'PH Level',
      'ar': 'درجة الحموضة',
    },
    'nitrogen': {
      'en': 'Nitrogen',
      'ar': 'النيتروجين',
    },
    'phosphorus': {
      'en': 'Phosphorus',
      'ar': 'الفوسفور',
    },
    'potassium': {
      'en': 'Potassium',
      'ar': 'البوتاسيوم',
    },
    'temperature': {
      'en': 'Temperature',
      'ar': 'درجة الحرارة',
    },
    'humidity': {
      'en': 'Humidity',
      'ar': 'الرطوبة',
    },
    'rainfall': {
      'en': 'Rainfall',
      'ar': 'هطول الأمطار',
    },
    'predict_plant': {
      'en': 'Predict Plant',
      'ar': 'التنبؤ بالنبات',
    },
    'recommended_plant': {
      'en': 'Recommended Plant',
      'ar': 'النبات الموصى به',
    },
    'required': {
      'en': 'Required',
      'ar': 'مطلوب',
    },
    
    // Soil types
    'clay': {
      'en': 'Clay',
      'ar': 'طينية',
    },
    'sandy': {
      'en': 'Sandy',
      'ar': 'رملية',
    },
    'loamy': {
      'en': 'Loamy',
      'ar': 'طميية',
    },
    'silty': {
      'en': 'Silty',
      'ar': 'سلتية',
    },
    'peaty': {
      'en': 'Peaty',
      'ar': 'خثية',
    },
    'chalky': {
      'en': 'Chalky',
      'ar': 'كلسية',
    },
    
    // Error messages
    'invalid_number': {
      'en': 'Please enter a valid number',
      'ar': 'الرجاء إدخال رقم صحيح',
    },
    
    // Buttons
    'predict': {
      'en': 'Predict',
      'ar': 'تنبؤ',
    },
    'soil_type': {
      'en': 'Soil Type',
      'ar': 'نوع التربة',
    },
    
    // Chat Screen
    'chat_greeting': {
      'en': 'Hey {username}, How Can I Help You?',
      'ar': 'مرحباً {username}، كيف يمكنني مساعدتك؟',
    },
    'chat_input_hint': {
      'en': 'write a message ....',
      'ar': 'اكتب رسالة ....',
    },
    'chat_listening': {
      'en': 'Listening...',
      'ar': 'جاري الاستماع...',
    },
    'chat_ai_typing': {
      'en': 'AI is typing...',
      'ar': 'الذكاء الاصطناعي يكتب...',
    },
    'chat_history': {
      'en': 'Chat History',
      'ar': 'سجل المحادثات',
    },
    'chat_with_ai': {
      'en': 'Chat with AI',
      'ar': 'محادثة مع الذكاء الاصطناعي',
    },
    'track_irrigation': {
      'en': 'Track Irrigation',
      'ar': 'تتبع الري',
    },
    'track_irrigation_desc': {
      'en': 'Track irrigation to ensure your plants get the right amount of water.',
      'ar': 'تتبع الري لضمان أن نباتاتك تحصل على المياه المناسبة.',
    },
  
    'chat_session': {
      'en': 'Chat Session',
      'ar': 'جلسة محادثة',
    },
    'chat_no_messages': {
      'en': 'No messages yet',
      'ar': 'لا توجد رسائل بعد',
    },
    'chat_microphone_permission': {
      'en': 'Microphone permission is required for voice input',
      'ar': 'إذن الميكروفون مطلوب لإدخال الصوت',
    },
    'chat_error_loading': {
      'en': 'Error loading chat history',
      'ar': 'خطأ في تحميل سجل المحادثات',
    },
    'chat_clear_history_title': {
      'en': 'Clear All History?',
      'ar': 'مسح كل السجل؟',
    },
    'chat_clear_history_message': {
      'en': 'This will delete all chat history. This action cannot be undone.',
      'ar': 'سيؤدي هذا إلى حذف كل سجل المحادثات. لا يمكن التراجع عن هذا الإجراء.',
    },
    'chat_delete_session_title': {
      'en': 'Delete Chat Session?',
      'ar': 'حذف جلسة المحادثة؟',
    },
    'chat_delete_session_message': {
      'en': 'This will delete this chat session. This action cannot be undone.',
      'ar': 'سيؤدي هذا إلى حذف جلسة المحادثة هذه. لا يمكن التراجع عن هذا الإجراء.',
    },
    'chat_error_message': {
      'en': 'Sorry, there was an error processing your request. Please try again.',
      'ar': 'عذراً، حدث خطأ في معالجة طلبك. يرجى المحاولة مرة أخرى.',
    },
    'just_now': {
      'en': 'Just now',
      'ar': 'الآن',
    },
    'minutes_ago': {
      'en': '{minutes}m ago',
      'ar': 'منذ {minutes} دقيقة',
    },
    'hours_ago': {
      'en': '{hours}h ago',
      'ar': 'منذ {hours} ساعة',
    },
    'days_ago': {
      'en': '{days}d ago',
      'ar': 'منذ {days} يوم',
    },
    'clear': {
      'en': 'Clear',
      'ar': 'مسح',
    },
    'edit_username': {
      'en': 'Edit Username',
      'ar': 'تعديل الاسم',
    },
    'delete': {
      'en': 'Delete',
      'ar': 'حذف',
    },
    // Fertilizer Prediction Screen
    'fertilizer_prediction': {
      'en': 'Fertilizer Prediction',
      'ar': 'التنبؤ بالأسمدة',
    },
    'soil_moisture': {
      'en': 'Soil Moisture',
      'ar': 'رطوبة التربة',
    },
    'crop_type': {
      'en': 'Crop Type',
      'ar': 'نوع المحصول',
    },
    'predict': {
      'en': 'Predict',
      'ar': 'تنبؤ',
    },
    'recommended_fertilizer': {
      'en': 'Recommended Fertilizer',
      'ar': 'السماد الموصى به',
    },
    'required_field': {
      'en': 'Required',
      'ar': 'مطلوب',
    },
    'error': {
      'en': 'Error',
      'ar': 'خطأ',
    },
    'ok': {
      'en': 'OK',
      'ar': 'موافق',
    },
    'close': {
      'en': 'Close',
      'ar': 'إغلاق',
    },
    'unit_celsius': {
      'en': '°C',
      'ar': '°م',
    },
    'unit_percent': {
      'en': '%',
      'ar': '%',
    },
    'unit_mgkg': {
      'en': 'mg/kg',
      'ar': 'مجم/كجم',
    },
    // Fertilizer Screen
    'fertilizer_analysis': {
      'en': 'Fertilizer Analysis',
      'ar': 'تحليل الأسمدة',
    },
    'select': {
      'en': 'Select',
      'ar': 'اختر',
    },
    'unknown_error': {
      'en': 'An unknown error occurred',
      'ar': 'حدث خطأ غير معروف',
    },
    'error_predicting_fertilizer': {
      'en': 'Error predicting fertilizer: {error}',
      'ar': 'خطأ في التنبؤ بالسماد: {error}',
    },
    'input_range': {
      'en': '0 - {max}',
      'ar': '٠ - {max}',
    },
    'fertilizer_description': {
      'en': 'Description',
      'ar': 'الوصف',
    },
    // Additional Fertilizer Screen translations
    'soil_type_suffix': {
      'en': 'Soil Type',
      'ar': 'نوع التربة',
    },
    'fertilizer_recommendation': {
      'en': 'Fertilizer Recommendation',
      'ar': 'توصية السماد',
    },
    'fertilizer_details': {
      'en': 'Fertilizer Details',
      'ar': 'تفاصيل السماد',
    },
    'loading_prediction': {
      'en': 'Predicting...',
      'ar': 'جاري التنبؤ...',
    },
    'validation_error_temperature': {
      'en': 'Temperature must be between -50°C and 50°C',
      'ar': 'يجب أن تكون درجة الحرارة بين -٥٠ و ٥٠ درجة مئوية',
    },
    'validation_error_humidity': {
      'en': 'Humidity must be between 0% and 100%',
      'ar': 'يجب أن تكون الرطوبة بين ٠٪ و ١٠٠٪',
    },
    'validation_error_moisture': {
      'en': 'Soil moisture must be between 0% and 100%',
      'ar': 'يجب أن تكون رطوبة التربة بين ٠٪ و ١٠٠٪',
    },
    'validation_error_nutrients': {
      'en': 'Nutrient values cannot be negative',
      'ar': 'لا يمكن أن تكون قيم المغذيات سالبة',
    },
    // Help Screen
    'faq': {
      'en': 'FAQ',
      'ar': 'الأسئلة الشائعة',
    },
    'contact_support': {
      'en': 'Contact Support',
      'ar': 'اتصل بالدعم',
    },
    'user_guide': {
      'en': 'User Guide',
      'ar': 'دليل المستخدم',
    },
    'getting_started': {
      'en': 'Getting Started',
      'ar': 'البدء',
    },
    'managing_plants': {
      'en': 'Managing Plants',
      'ar': 'إدارة النباتات',
    },
    // Login Screen
    'phone_number': {
      'en': 'Phone Number',
      'ar': 'رقم الهاتف',
    },
    'your_email': {
      'en': 'Your Email',
      'ar': 'بريدك الإلكتروني',
    },
    'remember_me': {
      'en': 'Remember me',
      'ar': 'تذكرني',
    },
    'forgot_password': {
      'en': 'Forgot Password?',
      'ar': 'نسيت كلمة المرور؟',
    },
    'or_login_with': {
      'en': 'Or login with',
      'ar': 'أو سجل الدخول باستخدام',
    },
    'google': {
      'en': 'Google',
      'ar': 'جوجل',
    },
    'facebook': {
      'en': 'Facebook',
      'ar': 'فيسبوك',
    },
    'dont_have_account': {
      'en': 'Don\'t have an account?',
      'ar': 'ليس لديك حساب؟',
    },
    'sign_up': {
      'en': 'Sign Up',
      'ar': 'إنشاء حساب',
    },
    // Register Screen
    'create_account': {
      'en': 'Create Account',
      'ar': 'إنشاء حساب',
    },
    'full_name': {
      'en': 'Full Name',
      'ar': 'الاسم الكامل',
    },
    'email_address': {
      'en': 'Email Address',
      'ar': 'البريد الإلكتروني',
    },
    'location': {
      'en': 'Location',
      'ar': 'الموقع',
    },
    'confirm_password': {
      'en': 'Confirm Password',
      'ar': 'تأكيد كلمة المرور',
    },
    'already_have_account': {
      'en': 'Already have an account?',
      'ar': 'لديك حساب بالفعل؟',
    },
    // Validation Messages
    'please_enter_email': {
      'en': 'Please enter your email',
      'ar': 'الرجاء إدخال بريدك الإلكتروني',
    },
    'please_enter_valid_email': {
      'en': 'Please enter a valid email',
      'ar': 'الرجاء إدخال بريد إلكتروني صحيح',
    },
    'please_enter_password': {
      'en': 'Please enter your password',
      'ar': 'الرجاء إدخال كلمة المرور',
    },
    'password_min_length': {
      'en': 'Password must be at least 6 characters',
      'ar': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
    },
    'please_enter_name': {
      'en': 'Please enter your name',
      'ar': 'الرجاء إدخال اسمك',
    },
    'please_enter_phone': {
      'en': 'Please enter your phone number',
      'ar': 'الرجاء إدخال رقم هاتفك',
    },
    'please_enter_location': {
      'en': 'Please enter your location',
      'ar': 'الرجاء إدخال موقعك',
    },
    'please_confirm_password': {
      'en': 'Please confirm your password',
      'ar': 'الرجاء تأكيد كلمة المرور',
    },
    'passwords_dont_match': {
      'en': 'Passwords do not match',
      'ar': 'كلمات المرور غير متطابقة',
    },
    // FAQ Content
    'faq_plant_prediction': {
      'en': 'How to use plant prediction?',
      'ar': 'كيفية استخدام التنبؤ بالنبات؟',
    },
    'faq_plant_prediction_answer': {
      'en': 'Take a clear photo of your plant or upload one from your gallery. Our AI will analyze it and provide detailed information about the plant species, care instructions, and potential issues.',
      'ar': 'التقط صورة واضحة لنباتك أو قم بتحميل صورة من معرض الصور. سيقوم الذكاء الاصطناعي لدينا بتحليلها وتقديم معلومات مفصلة عن نوع النبات وتعليمات العناية والمشاكل المحتملة.',
    },
    'faq_irrigation': {
      'en': 'How does the irrigation system work?',
      'ar': 'كيف يعمل نظام الري؟',
    },
    'faq_irrigation_answer': {
      'en': 'The irrigation system monitors soil moisture, temperature, and weather conditions to optimize watering schedules. You can enable/disable features like the rain sensor and set custom temperature thresholds.',
      'ar': 'يراقب نظام الري رطوبة التربة ودرجة الحرارة وظروف الطقس لتحسين جداول الري. يمكنك تمكين/تعطيل الميزات مثل مستشعر المطر وتعيين حدود درجة الحرارة المخصصة.',
    },
    'faq_fertilizer': {
      'en': 'How to get fertilizer suggestions?',
      'ar': 'كيف تحصل على اقتراحات الأسمدة؟',
    },
    'faq_fertilizer_answer': {
      'en': 'Enter your soil parameters including pH, nitrogen, phosphorus, and potassium levels. The system will analyze these values and recommend the most suitable fertilizers for your plants.',
      'ar': 'أدخل معلمات التربة بما في ذلك درجة الحموضة ومستويات النيتروجين والفوسفور والبوتاسيوم. سيقوم النظام بتحليل هذه القيم والتوصية بأفضل الأسمدة المناسبة لنباتاتك.',
    },
    // Language Settings
    'switch_to_arabic': {
      'en': 'عربي',
      'ar': 'عربي',
    },
    'switch_to_english': {
      'en': 'English',
      'ar': 'English',
    },
    // Help Screen Guide Content
    'getting_started_guide': {
      'en': 'Create an account, set up your profile, and start exploring plant identification and care features.',
      'ar': 'قم بإنشاء حساب، وإعداد ملفك الشخصي، وابدأ في استكشاف ميزات تحديد النباتات والعناية بها.',
    },
    'managing_plants_guide': {
      'en': 'Add plants to your collection, track their growth, and receive care reminders.',
      'ar': 'أضف النباتات إلى مجموعتك، وتتبع نموها، واحصل على تذكيرات العناية.',
    },
    // Plant Prediction Screen
    'soil_analysis': {
      'en': 'Soil Analysis',
      'ar': 'تحليل التربة',
    },
    'recommended_crop': {
      'en': 'Recommended Crop',
      'ar': 'المحصول الموصى به',
    },
    'recommended_plants': {
      'en': 'Recommended Plants',
      'ar': 'النباتات الموصى بها',
    },
    'get_fertilizer_recommendation': {
      'en': 'Get Fertilizer Recommendation',
      'ar': 'الحصول على توصية السماد',
    },
    'optimal_conditions': {
      'en': 'Optimal conditions: {temp}°C | {humidity}%',
      'ar': 'الظروف المثالية: {temp}°م | {humidity}%',
    },
    'rainfall': {
      'en': 'Rainfall',
      'ar': 'هطول الأمطار',
    },
    // Validation messages
    'ph_range_error': {
      'en': 'pH level must be between 0 and 14',
      'ar': 'يجب أن تكون درجة الحموضة بين 0 و 14',
    },
    'rainfall_negative_error': {
      'en': 'Rainfall cannot be negative',
      'ar': 'لا يمكن أن يكون هطول الأمطار سالباً',
    },
    'prediction_error': {
      'en': 'Could not get prediction. Please try again.',
      'ar': 'تعذر الحصول على التنبؤ. يرجى المحاولة مرة أخرى.',
    },
    // Placeholders
    'ph_placeholder': {
      'en': '0.0 - 14.0',
      'ar': '٠.٠ - ١٤.٠',
    },
    'rainfall_placeholder': {
      'en': '0 - 300',
      'ar': '٠ - ٣٠٠',
    },
    // Units
    'unit_ph': {
      'en': 'pH',
      'ar': 'pH',
    },
    'unit_mm': {
      'en': 'mm',
      'ar': 'مم',
    },
    'irrigation_tracking': {
      'en': 'Irrigation Tracking',
      'ar': 'تتبع الري',
    },
    
    'input_value': {
      'en': 'Enter value',
      'ar': 'أدخل القيمة',
    },
    'close': {
      'en': 'Close',
      'ar': 'إغلاق',
    },
    // Weather related translations
    'weather_information': {
      'en': 'Weather Information',
      'ar': 'معلومات الطقس',
    },
    'wind': {
      'en': 'Wind',
      'ar': 'الرياح',
    },
    'air_quality': {
      'en': 'Air Quality',
      'ar': 'جودة الهواء',
    },
    'current': {
      'en': 'Current',
      'ar': 'الحالية',
    },
    'on': {
      'en': 'On',
      'ar': 'تشغيل',
    },
    'off': {
      'en': 'Off',
      'ar': 'إيقاف',
    },
    'rain_sensor': {
      'en': 'Rain Sensor',
      'ar': 'مستشعر المطر',
    },
    'soil_fertility': {
      'en': 'Soil Fertility',
      'ar': 'خصوبة التربة',
    },
    'fertility_range': {
      'en': 'Optimal Range',
      'ar': 'النطاق المثالي',
    },
    // Weather and soil related translations
    'current_moisture': {
      'en': 'Current Moisture',
      'ar': 'الرطوبة الحالية',
    },
    'moisture': {
      'en': 'Moisture',
      'ar': 'الرطوبة',
    },
    // Main screen translations
    'exit_app_title': {
      'en': 'Exit App?',
      'ar': 'الخروج من التطبيق؟',
    },
    'exit_app_message': {
      'en': 'Are you sure you want to exit the app?',
      'ar': 'هل أنت متأكد أنك تريد الخروج من التطبيق؟',
    },
    'welcome_user': {
      'en': 'Welcome {username}',
      'ar': 'مرحباً {username}',
    },
    'precipitation': {
      'en': 'Precipitation',
      'ar': 'هطول الأمطار',
    },
    'my_plants': {
      'en': 'My Plants',
      'ar': 'نباتاتي',
    },
    'show_all': {
      'en': 'Show All',
      'ar': 'عرض الكل',
    },
    'no_plants_title': {
      'en': 'No Plants Yet',
      'ar': 'لا توجد نباتات بعد',
    },
    'no_plants_message': {
      'en': 'Start analyzing your soil to get plant recommendations!',
      'ar': 'ابدأ بتحليل تربتك للحصول على توصيات النباتات!',
    },
    'no_recommendations': {
      'en': 'No recommendations available.',
      'ar': 'لا توجد توصيات متاحة.',
    },
    'chat_plant_analysis': {
      'en': 'I\'d like to discuss this plant analysis:\n\nPlant: {plant}\nCurrent Status: {status}\n\nKey Growing Parameters:\n- Soil Type: {soilType}\n- Temperature: {temperature}\n- Humidity: {humidity}\n- Water Needs: {waterNeeds}\n\nCould you please:\n1. Explain if these conditions are optimal for this plant\n2. Provide tips for maintaining ideal growing conditions\n3. Suggest any preventive measures for common issues with this plant?',
      'ar': 'أود مناقشة تحليل هذا النبات:\n\nالنبات: {plant}\nالحالة الحالية: {status}\n\nمعايير النمو الرئيسية:\n- نوع التربة: {soilType}\n- درجة الحرارة: {temperature}\n- الرطوبة: {humidity}\n- احتياجات المياه: {waterNeeds}\n\nهل يمكنك من فضلك:\n1. شرح ما إذا كانت هذه الظروف مثالية لهذا النبات\n2. تقديم نصائح للحفاظ على ظروف النمو المثالية\n3. اقتراح أي تدابير وقائية للمشاكل الشائعة مع هذا النبات؟',
    },
    'not_specified': {
      'en': 'Not specified',
      'ar': 'غير محدد',
    },
    // History screen translations
    'history': {
      'en': 'History',
      'ar': 'السجل',
    },
    'clear_all_history': {
      'en': 'Clear All History',
      'ar': 'مسح كل السجل',
    },
    'clear_history_title': {
      'en': 'Clear History',
      'ar': 'مسح السجل',
    },
    'clear_history_message': {
      'en': 'Are you sure you want to clear all history? This action cannot be undone.',
      'ar': 'هل أنت متأكد أنك تريد مسح كل السجل؟ لا يمكن التراجع عن هذا الإجراء.',
    },
    'delete_entry': {
      'en': 'Delete Entry',
      'ar': 'حذف السجل',
    },
    'delete_entry_message': {
      'en': 'Are you sure you want to delete this history entry?',
      'ar': 'هل أنت متأكد أنك تريد حذف هذا السجل؟',
    },
    'no_history': {
      'en': 'No history yet',
      'ar': 'لا يوجد سجل بعد',
    },
    'error_loading': {
      'en': 'Error: {error}',
      'ar': 'خطأ: {error}',
    },
    'retry': {
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
    },
    'soil_type_label': {
      'en': 'Soil Type: {type}',
      'ar': 'نوع التربة: {type}',
    },
    'fertilizer_label': {
      'en': 'Fertilizer: {type}',
      'ar': 'السماد: {type}',
    },
    'chat_history_plant': {
      'en': 'Let\'s discuss this plant analysis:\nPlant: {plant}\nSoil Type: {soilType}\npH: {ph}\nTemperature: {temp}°C\nHumidity: {humidity}%\nRainfall: {rainfall}mm\nNitrogen: {n}mg/kg\nPhosphorus: {p}mg/kg\nPotassium: {k}mg/kg\n\ I would you like to know more about this plant',
      'ar': 'دعنا نناقش تحليل هذا النبات:\nالنبات: {plant}\nنوع التربة: {soilType}\nدرجة الحموضة: {ph}\nدرجة الحرارة: {temp}°م\nالرطوبة: {humidity}٪\nهطول الأمطار: {rainfall}مم\nالنيتروجين: {n}مجم/كجم\nالفوسفور: {p}مجم/كجم\nالبوتاسيوم: {k}مجم/كجم\n\n أريد أن أعرف أكثر عن هذا النبات',
    },
    'chat_about_plant': {
      'en': 'Chat about this plant',
      'ar': 'التحدث عن هذا النبات',
    },
    // Bottom Navigation Bar
    'nav_home': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
    'nav_plant': {
      'en': 'Plant',
      'ar': 'النبات',
    },
    'nav_irrigation': {
      'en': 'Irrigation',
      'ar': 'الري',
    },
    'nav_fertilizer': {
      'en': 'Fertilizer',
      'ar': 'التسميد',
    },
    'ai_helper_tooltip': {
      'en': 'How can I help you?',
      'ar': 'كيف يمكنني مساعدتك؟',
    },
    // Settings Screen
    'settings': {
      'en': 'Settings',
      'ar': 'الإعدادات',
    },
    'account_settings': {
      'en': 'Account Settings',
      'ar': 'إعدادات الحساب',
    },
    'edit_profile': {
      'en': 'Edit profile',
      'ar': 'تعديل الملف الشخصي',
    },
    'change_password': {
      'en': 'Change password',
      'ar': 'تغيير كلمة المرور',
    },
    'keep_analysis': {
      'en': 'Keep my analysis work for farm',
      'ar': 'حفظ تحليلاتي للمزرعة',
    },
    'push_notifications': {
      'en': 'Push notifications',
      'ar': 'الإشعارات',
    },
    'dark_mode': {
      'en': 'Dark Mode',
      'ar': 'الوضع المظلم',
    },
    'theme_settings': {
      'en': 'Theme Settings',
      'ar': 'إعدادات المظهر',
    },
    'theme_changed': {
      'en': 'Theme changed',
      'ar': 'تم تغيير المظهر',
    },
    'light_mode': {
      'en': 'Light Mode',
      'ar': 'الوضع الفاتح',
    },
    'more': {
      'en': 'More',
      'ar': 'المزيد',
    },
    'about_us': {
      'en': 'About us',
      'ar': 'عن التطبيق',
    },
    'ai_recommendations': {
      'en': 'AI Recommendations',
      'ar': 'توصيات الذكاء الاصطناعي',
    },
    'no_prediction_error': {
      'en': 'Please make a plant prediction first',
      'ar': 'يرجى إجراء تنبؤ بالنبات أولاً',
    },
    'get_fertilizer_recommendation': {
      'en': 'Get Fertilizer Recommendation',
      'ar': 'الحصول على توصية السماد',
    },
    'fertilizer_prediction': {
      'en': 'Fertilizer Prediction',
      'ar': 'التنبؤ بالأسمدة',
    },
    'soil_analysis': {
      'en': 'Soil Analysis',
      'ar': 'تحليل التربة',
    },
    'recommended_crop': {
      'en': 'Recommended Crop',
      'ar': 'المحصول الموصى به',
    },
    'recommended_plants': {
      'en': 'Recommended Plants',
      'ar': 'النباتات الموصى بها',
    },
    'optimal_conditions': {
      'en': 'Optimal conditions: {temp}°C | {humidity}%',
      'ar': 'الظروف المثالية: {temp}°م | {humidity}%',
    },
    // Authentication error messages
    'invalid_credentials': {
      'en': 'Invalid email or password',
      'ar': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
    },
    'email_already_registered': {
      'en': 'Email is already registered',
      'ar': 'البريد الإلكتروني مسجل بالفعل',
    },
    'weak_password': {
      'en': 'Password is too weak',
      'ar': 'كلمة المرور ضعيفة جداً',
    },
    'invalid_email_format': {
      'en': 'Invalid email format',
      'ar': 'صيغة البريد الإلكتروني غير صحيحة',
    },
    'network_error': {
      'en': 'Network error. Please check your connection',
      'ar': 'خطأ في الشبكة. يرجى التحقق من اتصالك',
    },
    'server_error': {
      'en': 'Server error. Please try again later',
      'ar': 'خطأ في الخادم. يرجى المحاولة لاحقاً',
    },
    'login_success': {
      'en': 'Login successful',
      'ar': 'تم تسجيل الدخول بنجاح',
    },
    'registration_success': {
      'en': 'Registration successful',
      'ar': 'تم التسجيل بنجاح',
    },
    'logout_success': {
      'en': 'Logged out successfully',
      'ar': 'تم تسجيل الخروج بنجاح',
    },
    'session_expired': {
      'en': 'Session expired. Please login again',
      'ar': 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى',
    },
    'invalid_password': {
      'en': 'Invalid password',
      'ar': 'كلمة المرور غير صحيحة',
    },
    'user_not_found': {
      'en': 'User not found',
      'ar': 'المستخدم غير موجود',
    },
    'please_try_again': {
      'en': 'Please try again',
      'ar': 'يرجى المحاولة مرة أخرى',
    },
    'irrigation_tracking_active': {
      'en': 'Irrigation tracking is active',
      'ar': 'تتبع الري نشط',
    },
    'tracked_plants': {
      'en': 'Tracked Plants',
      'ar': 'النباتات المتتبعة',
    },
    'no_tracked_plants': {
      'en': 'No plants being tracked',
      'ar': 'لا توجد نباتات متتبعة',
    },
    'next_irrigation': {
      'en': 'Next Irrigation',
      'ar': 'الري القادم',
    },
    'required_level': {
      'en': 'Required Level',
      'ar': 'المستوى المطلوب',
    },
    'alert_at': {
      'en': 'Alert At',
      'ar': 'تنبيه عند',
    },
    'active': {
      'en': 'Active',
      'ar': 'نشط',
    },
    'inactive': {
      'en': 'Inactive',
      'ar': 'غير نشط',
    },
    'not_set': {
      'en': 'Not Set',
      'ar': 'غير محدد',
    },
    'today': {
      'en': 'Today',
      'ar': 'اليوم',
    },
    'tomorrow': {
      'en': 'Tomorrow',
      'ar': 'غداً',
    },
    'in_days': {
      'en': 'In {days} days',
      'ar': 'في {days} أيام',
    },
  };

  /// Returns the appropriate text direction for the current language
  static TextDirection getTextDirection() {
    return _currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Returns the appropriate alignment based on the current language
  /// 
  /// [start] - Whether to align to the start or end
  /// 
  /// Returns Alignment.centerLeft/Right based on language direction
  static Alignment getAlignment(bool start) {
    if (_currentLanguage == 'ar') {
      return start ? Alignment.centerRight : Alignment.centerLeft;
    }
    return start ? Alignment.centerLeft : Alignment.centerRight;
  }

  /// Returns appropriate edge insets based on the current language
  /// 
  /// Handles RTL/LTR differences in padding and margins
  static EdgeInsets getEdgeInsets({double? start, double? end, double? top, double? bottom}) {
    if (_currentLanguage == 'ar') {
      return EdgeInsets.only(
        right: start ?? 0,
        left: end ?? 0,
        top: top ?? 0,
        bottom: bottom ?? 0,
      );
    }
    return EdgeInsets.only(
      left: start ?? 0,
      right: end ?? 0,
      top: top ?? 0,
      bottom: bottom ?? 0,
    );
  }

  /// Wraps a widget with appropriate text direction
  /// 
  /// [context] - The build context
  /// [child] - The widget to wrap
  /// 
  /// Returns a directional widget based on current language
  static Widget wrapWithDirectional({required BuildContext context, required Widget child}) {
    return Directionality(
      textDirection: getTextDirection(),
      child: child,
    );
  }
} 