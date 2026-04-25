class AuthModel {
  final String token;
  final String username;
  final String baseUrl;
  
  const AuthModel({
    required this.token,
    required this.username,
    required this.baseUrl,
  });
  
  factory AuthModel.fromJson(Map<String, dynamic> json, String baseUrl) {
    return AuthModel(
      token: json['data']?['token'] ?? '',
      username: '',
      baseUrl: baseUrl,
    );
  }
}
