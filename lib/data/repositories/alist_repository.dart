import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/auth_model.dart';
import '../models/file_model.dart';
import '../services/api_service.dart';

final alistRepositoryProvider = Provider<AlistRepository>((ref) {
  return AlistRepository(ref.watch(apiServiceProvider));
});

class AlistRepository {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();
  
  AlistRepository(this._apiService);
  
  // Auth
  Future<AuthModel> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    // Format URL
    String url = baseUrl;
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    
    final response = await _apiService.login(
      baseUrl: url,
      username: username,
      password: password,
    );
    
    if (response['code'] == 200) {
      final auth = AuthModel.fromJson(response, url);
      
      // Save credentials
      await _storage.write(key: ApiConstants.baseUrlKey, value: url);
      await _storage.write(key: ApiConstants.tokenKey, value: auth.token);
      await _storage.write(key: ApiConstants.usernameKey, value: username);
      
      _apiService.resetDio();
      return auth;
    }
    
    throw Exception(response['message'] ?? 'Login failed');
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: ApiConstants.tokenKey);
    final baseUrl = await _storage.read(key: ApiConstants.baseUrlKey);
    return token != null && baseUrl != null && token.isNotEmpty;
  }
  
  Future<void> logout() async {
    await _storage.deleteAll();
    _apiService.resetDio();
  }
  
  Future<String?> getBaseUrl() async {
    return _storage.read(key: ApiConstants.baseUrlKey);
  }
  
  Future<String?> getUsername() async {
    return _storage.read(key: ApiConstants.usernameKey);
  }
  
  // Files
  Future<FileListResponse> listFiles({
    required String path,
    int page = 1,
    int perPage = 50,
    bool forceRefresh = false,
  }) async {
    return _apiService.listFiles(
      path: path,
      page: page,
      perPage: perPage,
      forceRefresh: forceRefresh,
    );
  }
  
  Future<String> getFileUrl(String path, {String? sign}) async {
    return _apiService.getDownloadUrl(path, sign: sign);
  }
  
  Future<Map<String, dynamic>> getFileInfo(String path) async {
    return _apiService.getFileInfo(path: path);
  }
}
