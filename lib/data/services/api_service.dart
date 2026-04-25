import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/file_model.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authTokenProvider = StateProvider<String?>((ref) => null);
final baseUrlProvider = StateProvider<String>((ref) => '');

class ApiService {
  Dio? _dio;
  final _storage = const FlutterSecureStorage();
  
  Future<Dio> _getDio() async {
    if (_dio != null) return _dio!;
    
    final baseUrl = await _storage.read(key: ApiConstants.baseUrlKey) ?? '';
    final token = await _storage.read(key: ApiConstants.tokenKey) ?? '';
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      ),
    );
    
    // Interceptors
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🔷 REQUEST: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ERROR: ${error.message}');
          handler.next(error);
        },
      ),
    );
    
    return _dio!;
  }
  
  void resetDio() => _dio = null;
  
  // Login
  Future<Map<String, dynamic>> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    
    final response = await dio.post(
      ApiConstants.loginPath,
      data: {
        'username': username,
        'password': password,
      },
    );
    
    return response.data;
  }
  
  // List files
  Future<FileListResponse> listFiles({
    required String path,
    int page = 1,
    int perPage = 50,
    bool forceRefresh = false,
    String? password,
  }) async {
    final dio = await _getDio();
    
    final response = await dio.post(
      ApiConstants.listPath,
      data: {
        'path': path,
        'page': page,
        'per_page': perPage,
        'refresh': forceRefresh,
        if (password != null) 'password': password,
      },
    );
    
    if (response.data['code'] == 200) {
      return FileListResponse.fromJson(response.data);
    }
    
    throw Exception(response.data['message'] ?? 'Failed to load files');
  }
  
  // Get file info
  Future<Map<String, dynamic>> getFileInfo({
    required String path,
    String? password,
  }) async {
    final dio = await _getDio();
    
    final response = await dio.post(
      ApiConstants.getPath,
      data: {
        'path': path,
        if (password != null) 'password': password,
      },
    );
    
    if (response.data['code'] == 200) {
      return response.data['data'];
    }
    
    throw Exception(response.data['message'] ?? 'Failed to get file info');
  }
  
  // Search
  Future<FileListResponse> searchFiles({
    required String path,
    required String keyword,
    int page = 1,
    int perPage = 50,
  }) async {
    final dio = await _getDio();
    
    final response = await dio.post(
      ApiConstants.searchPath,
      data: {
        'parent': path,
        'keywords': keyword,
        'page': page,
        'per_page': perPage,
      },
    );
    
    if (response.data['code'] == 200) {
      return FileListResponse.fromJson(response.data);
    }
    
    throw Exception('Search failed');
  }
  
  // Get direct download URL
  Future<String> getDownloadUrl(String path, {String? sign}) async {
    final baseUrl = await _storage.read(key: ApiConstants.baseUrlKey) ?? '';
    final token = await _storage.read(key: ApiConstants.tokenKey) ?? '';
    
    String url = '$baseUrl/d$path';
    if (sign != null && sign.isNotEmpty) {
      url += '?sign=$sign&token=$token';
    }
    return url;
  }
}
