class ApiConstants {
  static const String baseUrlKey = 'base_url';
  static const String tokenKey = 'auth_token';
  static const String usernameKey = 'username';
  
  // API Endpoints
  static const String loginPath = '/api/auth/login';
  static const String listPath = '/api/fs/list';
  static const String getPath = '/api/fs/get';
  static const String searchPath = '/api/fs/search';
  static const String mkdirPath = '/api/fs/mkdir';
  static const String removePath = '/api/fs/remove';
  static const String renamePath = '/api/fs/rename';
  
  // Default timeouts
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}
