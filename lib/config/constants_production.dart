class ApiConstants {
  // Production URL - Update this for production deployment
  static const String baseUrl = 'https://api.delivero.com';
  static const String apiVersion = '/api';
  
  // API Endpoints
  static const String auth = '$apiVersion/auth';
  static const String restaurants = '$apiVersion/restaurants';
  static const String menu = '$apiVersion/menu';
  static const String orders = '$apiVersion/orders';
  static const String delivery = '$apiVersion/delivery';
  static const String payments = '$apiVersion/payments';
  
  // Payment methods
  static const List<String> paymentMethods = ['card', 'cash', 'wallet'];
  
  // Socket.io
  static const String socketUrl = baseUrl;
  
  // Authentication Endpoints
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String me = '$auth/me';
  static const String updateProfile = '$auth/updatedetails';
  static const String updatePassword = '$auth/updatepassword';
  static const String updateFcmToken = '$auth/fcm-token';
  static const String logout = '$auth/logout';
  
  // Google Maps API Key - Use environment variable in production
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY'
  );
  
  // Stripe Publishable Key - Use environment variable in production
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'YOUR_STRIPE_PUBLISHABLE_KEY'
  );
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Helper to construct image URL safely
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty || imagePath == 'default-food.png' || imagePath == 'default-restaurant.png') {
      return '$baseUrl/uploads/default-food.png';
    }
    
    String path = imagePath;
    
    // Normalize slashes
    path = path.replaceAll('\\', '/');
    path = path.replaceAll('\\', '/');
    
    // If it's an absolute URL
    if (path.startsWith('http')) {
      // If it points to localhost (common in dev), replace with production baseUrl
      if (path.contains('localhost') || path.contains('127.0.0.1') || path.contains('10.0.2.2')) {
        final uploadsIndex = path.indexOf('/uploads/');
        if (uploadsIndex != -1) {
          path = path.substring(uploadsIndex + 1);
        } else {
          // If no uploads prefix, just use the path after the domain
          final domainEnd = path.indexOf('/', 8); // Skip http://
          if (domainEnd != -1) return '$baseUrl${path.substring(domainEnd)}';
          return path;
        }
      } else {
        return path;
      }
    }
    
    // Remove leading slash
    if (path.startsWith('/')) path = path.substring(1);
    
    // Ensure uploads/ prefix unless it's already an api path
    if (!path.startsWith('uploads/') && !path.startsWith('api/')) {
      path = 'uploads/$path';
    }
    
    return '$baseUrl/$path';
  }
}
