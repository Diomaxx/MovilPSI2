import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../models/usuario.dart';
import '../controllers/usuario_controller.dart';

class UsuarioService {
  static final UsuarioController _controller = UsuarioController();
  
  static Future<Usuario?> verifyUserByCI(String ci) async {
    final url = Uri.parse('$baseApiUrl/usuarios/ci/$ci');

    try {
      print('Verifying CI at: $url');
      final response = await http.get(url);
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
  
  // Method to login user
  static Future<Usuario?> login(String ci, String contrasena) async {
    final url = Uri.parse('$baseAuthUrl/login');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'cedulaIdentidad': ci,
      'contrasena': contrasena,
    });

    try {
      print('Attempting login to: $url');
      print('Request body: $body');
      final response = await http.post(url, headers: headers, body: body);
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          print('JSON decoded successfully: $data');
          final usuario = _controller.fromJson(data);
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

  // Method to register new user
  static Future<Usuario?> register(Usuario usuario) async {
    final url = Uri.parse('$baseApiUrl/usuarios/register');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode(_controller.toJson(usuario));

    try {
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return _controller.fromJson(data);
        } catch (e) {
          print('Error parsing registration response: $e');
          return null;
        }
      } else {
        // Return null on failed registration
        return null;
      }
    } catch (e) {
      // Handle exceptions
      print('Error during registration: $e');
      return null;
    }
  }

} 