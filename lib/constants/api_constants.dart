// This is a special container called a "class" that holds all our API information in one place
// Think of it like a labeled box where we store all the important details about talking to our app's backend
class ApiConstants {
  // Base URL for the API
  // This is like the main address of our app's backend - just like your home address
  // All our requests will start with this address before adding specific details
  static const String BASE_URL = 'https://api.greengrow.com/v1';
  
  // Endpoints
  // These are like different rooms in the house at our main address
  // Each endpoint takes us to a different service or feature
  // We add these to the BASE_URL to make a complete address for each feature
  static const String CROP_RECOMMENDATION_ENDPOINT = '/crop-recommend';   // This lets us get suggestions on what crops to plant
  static const String FERTILIZER_RECOMMENDATION_ENDPOINT = '/fertilizer-recommend';   // This helps us know what fertilizer to use
  static const String SOIL_HEALTH_ENDPOINT = '/soil-health';   // This tells us how good our soil is
  static const String YIELD_PREDICTION_ENDPOINT = '/yield-prediction';   // This predicts how much crops we'll get
  
  // API Keys (in a real app, these would be stored securely)
  // This is like a special password that lets our app talk to the backend
  // Without this key, the backend would say "I don't know you" and not respond
  // In a real app, we would hide this key somewhere safer than this file
  static const String API_KEY = 'demo_key_123';
  
  // Request Timeouts
  // These tell our app how long to wait for a response before giving up
  // Just like if you called a friend but hung up if they didn't answer in 30 seconds
  // This prevents our app from waiting forever if there's a problem
  static const int CONNECTION_TIMEOUT = 30000; // 30 seconds - time to establish connection
  static const int RECEIVE_TIMEOUT = 30000; // 30 seconds - time to get a response after connecting
} 