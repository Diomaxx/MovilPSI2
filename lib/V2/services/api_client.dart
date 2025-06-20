import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';
import 'jwt_service.dart';

class ApiClient {
  
  
  static Future<http.Response> get(String url) async {
    final uri = Uri.parse(url);
    final headers = await _getHeaders(url);
    
    print('GET Request: $url');

    
    final response = await http.get(uri, headers: headers);
    
    print('Response Status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Response Body: ${response.body}');
    }
    
    if (_isUnauthorizedResponse(response)) {
      await _handleUnauthorizedResponse();
    }
    
    return response;
  }
  
  static Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse(url);
    final headers = await _getHeaders(url);
    final jsonBody = body != null ? jsonEncode(body) : null;
    
    print('POST Request: $url');
    print('Headers: $headers');
    print('Body: $jsonBody');
    
    final response = await http.post(uri, headers: headers, body: jsonBody);
    
    print('Response Status: ${response.statusCode}');
    if (response.statusCode >= 400) {
      print('Response Body: ${response.body}');
    }
    
    if (_isUnauthorizedResponse(response)) {
      await _handleUnauthorizedResponse();
    }
    
    return response;
  }
  
  static Future<http.Response> put(String url, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse(url);
    final headers = await _getHeaders(url);
    final jsonBody = body != null ? jsonEncode(body) : null;
    
    print('PUT Request: $url');
    print('Headers: $headers');
    print('Body: $jsonBody');
    
    final response = await http.put(uri, headers: headers, body: jsonBody);
    
    print('Response Status: ${response.statusCode}');
    if (response.statusCode >= 400) {
      print('Response Body: ${response.body}');
    }
    
    if (_isUnauthorizedResponse(response)) {
      await _handleUnauthorizedResponse();
    }
    
    return response;
  }
  
  static Future<http.Response> delete(String url) async {
    final uri = Uri.parse(url);
    final headers = await _getHeaders(url);
    
    print('DELETE Request: $url');
    print('Headers: $headers');
    
    final response = await http.delete(uri, headers: headers);
    
    print('Response Status: ${response.statusCode}');
    if (response.statusCode >= 400) {
      print('Response Body: ${response.body}');
    }
    
    if (_isUnauthorizedResponse(response)) {
      await _handleUnauthorizedResponse();
    }
    
    return response;
  }
  

  static Future<Map<String, String>> _getHeaders(String url) async {
    final requiresAuth = _requiresAuthentication(url);
    
    if (requiresAuth) {
      print('JWT Authentication required for: $url');
      
      final authHeaders = await JwtService.getAuthHeaders();
      if (authHeaders != null) {
        print('JWT token found and valid');
        return authHeaders;
      } else {
        print('No valid JWT token found');
        return {'Content-Type': 'application/json'};
      }
    } else {
      print('No authentication required for: $url');
      return {'Content-Type': 'application/json'};
    }
  }
  
  static bool _requiresAuthentication(String url) {
    return url.startsWith(baseApiUrl) || url.startsWith(baseAuthUrl);
  }
  
  static bool _isUnauthorizedResponse(http.Response response) {
    return response.statusCode == 401;
  }
  
  static Future<void> _handleUnauthorizedResponse() async {
    print('Unauthorized response - clearing invalid token');
    await JwtService.clearToken();
  }
  
  static Future<http.Response> _makeAuthenticatedRequest(
    Future<http.Response> Function() requestFunction,
  ) async {
    final response = await requestFunction();
    
    if (_isUnauthorizedResponse(response)) {
      await _handleUnauthorizedResponse();
    }
    
    return response;
  }
} 