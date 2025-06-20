import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JwtService {
  static const String _tokenKey = 'jwt_token';
  static const String _tokenExpiryKey = 'jwt_token_expiry';
  
  static Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      final expiryTime = _getTokenExpiryTime(token);
      if (expiryTime != null) {
        await prefs.setInt(_tokenExpiryKey, expiryTime.millisecondsSinceEpoch);
      }
      
      print('JWT token saved successfully');
      return true;
    } catch (e) {
      print('Error saving JWT token: $e');
      return false;
    }
  }
  
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      // Check if token is still valid
      if (token != null && !await isTokenExpired()) {
        return token;
      } else {
        // Remove expired token
        await clearToken();
        return null;
      }
    } catch (e) {
      print('Error retrieving JWT token: $e');
      return null;
    }
  }
  
  static Future<bool> isTokenExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryTimeMillis = prefs.getInt(_tokenExpiryKey);
      
      if (expiryTimeMillis == null) return true;
      
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimeMillis);
      final currentTime = DateTime.now();
      
      final isExpired = currentTime.isAfter(expiryTime.subtract(const Duration(minutes: 5)));
      
      print('Token expiry check: ${isExpired ? 'EXPIRED' : 'VALID'}');
      return isExpired;
    } catch (e) {
      print('Error checking token expiry: $e');
      return true;
    }
  }
  
  static Future<bool> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_tokenExpiryKey);
      print('JWT token cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing JWT token: $e');
      return false;
    }
  }
  
  static Future<Map<String, String>?> getAuthHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return null;
  }
  
  static DateTime? _getTokenExpiryTime(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      
      final paddedPayload = payload + '=' * (4 - payload.length % 4);
      
      final decoded = utf8.decode(base64Url.decode(paddedPayload));
      final payloadMap = jsonDecode(decoded);
      
      if (payloadMap['exp'] != null) {
        final expiry = payloadMap['exp'] as int;
        return DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
      }
      
      return null;
    } catch (e) {
      print('Error extracting token expiry: $e');
      return null;
    }
  }
  
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
} 