import 'package:flutter/material.dart';
import '../services/jwt_service.dart';

mixin AuthMixin<T extends StatefulWidget> on State<T> {
  
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
    final isAuthenticated = await checkAuthentication();
    
    if (!isAuthenticated && mounted) {
      print('Token expired or invalid - redirecting to login');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Su sesión ha expirado. Por favor inicie sesión nuevamente.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  
  void handleApiResponse(int statusCode) {
    if (statusCode == 401) {
      print('Received 401 Unauthorized - token likely expired');
      validateAuthenticationAndRedirect();
    }
  }
  
  Future<T?> makeAuthenticatedRequest<T>(
    Future<T> Function() apiCall, {
    bool validateBefore = true,
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
      
      if (validateAfter) {
        validateAuthenticationAndRedirect();
      }
      
      return null;
    }
  }
} 