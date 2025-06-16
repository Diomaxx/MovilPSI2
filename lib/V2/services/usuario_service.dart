import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../models/usuario.dart';
import '../controllers/usuario_controller.dart';
import 'jwt_service.dart';
import 'api_client.dart';
import 'user_data_service.dart';

class UsuarioService {
  static final UsuarioController _controller = UsuarioController();
  
  static Future<Usuario?> verifyUserByCI(String ci) async {
    final url = '$baseApiUrl/usuarios/ci/$ci';

    try {
      print('Verifying CI at: $url');
      final response = await ApiClient.get(url);
      print('CI verification response status: ${response.statusCode}');
      print('CI verification response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          print('CI verification JSON decoded successfully: $data');
          final usuario = _controller.fromJson(data);
          print('User verified successfully: ${usuario.nombre}, Admin: ${usuario.admin}');
          return usuario;
        } catch (parseError) {
          print('Error parsing CI verification response: $parseError');
          return null;
        }
      } else {
        print('CI verification failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during CI verification: $e');
      return null;
    }
  }
  
  static Future<Usuario?> login(String ci, String contrasena) async {
    final url = '$baseAuthUrl/login';

    final body = {
      'cedulaIdentidad': ci,
      'contrasena': contrasena,
    };

    try {
      print('Attempting login to: $url');
      print('Request body: $body');
      final response = await ApiClient.post(url, body: body);
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          print('JSON decoded successfully: $data');
          
          if (data.containsKey('token')) {
            final token = data['token'] as String;
            print('JWT token found in response');
            await JwtService.saveToken(token);
            print('JWT token saved successfully');
          } else if (data.containsKey('jwt')) {
            final token = data['jwt'] as String;
            print('JWT token found in response (jwt field)');
            await JwtService.saveToken(token);
            print('JWT token saved successfully');
          } else {
            print('No JWT token found in login response');
          }
          
          Map<String, dynamic> userData;
          if (data.containsKey('user')) {
            userData = data['user'] as Map<String, dynamic>;
          } else if (data.containsKey('usuario')) {
            userData = data['usuario'] as Map<String, dynamic>;
          } else {
            userData = data;
          }
          
          final usuario = _controller.fromJson(userData);
          print('User parsed successfully: ${usuario.nombre}');
          return usuario;
        } catch (parseError) {
          print('Error parsing response data: $parseError');
          return null;
        }
      } else {
        print('Login failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  static Future<Usuario?> register(Usuario usuario) async {
    final url = '$baseApiUrl/usuarios/register';

    final body = _controller.toJson(usuario);

    try {
      final response = await ApiClient.post(url, body: body);
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return _controller.fromJson(data);
        } catch (e) {
          print('Error parsing registration response: $e');
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error during registration: $e');
      return null;
    }
  }

  static Future<bool> logout() async {
    try {
      print('Logging out user...');
      
      await JwtService.clearToken();
      print('JWT token cleared');
      
      await UserDataService.clearUserData();
      print('User data cleared');
      
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  static Future<bool> isAuthenticated() async {
    return await JwtService.isAuthenticated();
  }

} 