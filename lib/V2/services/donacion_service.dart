import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../models/donacion.dart';
import '../controllers/donacion_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DonacionService {
  static final DonacionController _controller = DonacionController();
  
  // Método para obtener todas las donaciones
  static Future<List<Donacion>> obtenerDonaciones() async {
    final url = Uri.parse('$baseApiUrl/donaciones/new');

    try {
      print('Obteniendo donaciones desde: $url');
      final response = await http.get(url);
      print('Respuesta de donaciones - código: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonDecode(response.body);
          print('Datos de donaciones recibidos exitosamente');
          
          // Convertir cada elemento JSON a un objeto Donacion
          final donaciones = data.map((item) => _controller.fromJson(item)).toList();
          return donaciones;
        } catch (parseError) {
          print('Error al analizar datos de donaciones: $parseError');
          return [];
        }
      } else {
        print('Error al obtener donaciones. Código: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error durante la obtención de donaciones: $e');
      return [];
    }
  }

  /// Actualiza el estado de una donación
  static Future<bool> actualizarDonacion({
    required int idDonacion,
    required String ciUsuario,
    required String estado,
    required double latitud,
    required double longitud,
    Uint8List? imagen,
  }) async {
    final url = Uri.parse('$baseApiUrl/donaciones/actualizar/$idDonacion');
    
    // Preparar body del request
    final Map<String, dynamic> body = {
      'ciUsuario': ciUsuario,
      'estado': estado,
      'latitud': latitud,
      'longitud': longitud,
    };
    
    // Si hay imagen, convertirla a base64
    if (imagen != null) {
      final String base64Image = base64Encode(imagen);
      final String dataUri = 'data:image/jpeg;base64,$base64Image'; // o image/png según el tipo
      body['imagen'] = dataUri;    }
    
    try {
      print('Body: $body');
      print('Actualizando donación en: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      print('📥 Respuesta - código: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Donación actualizada exitosamente');
        return true;
      } else {
        print('⚠️ Error al actualizar donación. Código: ${response.statusCode}');
        print('⚠️ Respuesta: ${response.body}');

        Fluttertoast.showToast(
          msg: "Debes estar mas cerca del destino",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        return false;
      }
    } catch (e) {
      print('❌ Error durante la actualización de donación: $e');
      return false;
    }
  }
} 