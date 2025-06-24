import 'package:flutter/material.dart';
import '../services/jwt_service.dart';

mixin AuthMixin<T extends StatefulWidget> on State<T> {
  
  // Flag to prevent multiple simultaneous redirections
  static bool _isRedirecting = false;
  
  Future<bool> checkAuthentication() async {
    try {
      final isAuthenticated = await JwtService.isAuthenticated();
      print('Authentication check: ${isAuthenticated ? 'VALID' : 'INVALID'}');
      return isAuthenticated;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }
  
  Future<void> validateAuthenticationAndRedirect() async {
    // Prevent multiple simultaneous redirections
    if (_isRedirecting) {
      print('Redirection already in progress, skipping...');
      return;
    }
    
    final isAuthenticated = await checkAuthentication();
    
    if (!isAuthenticated && mounted && !_isRedirecting) {
      print('Token expired or invalid - redirecting to login');
      _isRedirecting = true;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Su sesión ha expirado. Por favor inicie sesión nuevamente.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      
      Navigator.pushReplacementNamed(context, '/login').then((_) {
        // Reset flag after navigation completes
        _isRedirecting = false;
      });
    }
  }
  
  void handleApiResponse(int statusCode) {
    if (statusCode == 401 && !_isRedirecting) {
      print('Received 401 Unauthorized - token likely expired');
      validateAuthenticationAndRedirect();
    }
  }
  
  Future<T?> makeAuthenticatedRequest<T>(
    Future<T> Function() apiCall, {
    bool validateBefore = false, // Changed default to false to be less aggressive
    bool validateAfter = true,
  }) async {
    try {
      if (validateBefore) {
        final isAuthenticated = await checkAuthentication();
        if (!isAuthenticated) {
          validateAuthenticationAndRedirect();
          return null;
        }
      }
      
      final result = await apiCall();
      
      return result;
    } catch (e) {
      print('Error in authenticated request: $e');
      
      // Only validate after if we get specific auth errors
      if (validateAfter && e.toString().contains('401')) {
        validateAuthenticationAndRedirect();
      }
      
      return null;
    }
  }
} 