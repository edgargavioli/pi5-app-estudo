class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };
} 