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
  
  static Future<List<Donacion>> obtenerDonaciones() async {
    final url = Uri.parse('$baseApiUrl/donaciones/new');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonDecode(response.body);
          print('Datos de donaciones recibidos exitosamente');
          
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

  static Future<bool> actualizarDonacion({
    required int idDonacion,
    required String ciUsuario,
    required String estado,
    required double latitud,
    required double longitud,
    Uint8List? imagen,
  }) async {
    final url = Uri.parse('$baseApiUrl/donaciones/actualizar/$idDonacion');
    
    final Map<String, dynamic> body = {
      'ciUsuario': ciUsuario,
      'estado': estado,
      'latitud': latitud,
      'longitud': longitud,
    };
    
    if (imagen != null) {
      final String base64Image = base64Encode(imagen);
      final String dataUri = 'data:image/jpeg;base64,$base64Image';
      body['imagen'] = dataUri;    }
    
    try {
      print('Body: $body');
      print('Actualizando donación en: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      

      if (response.statusCode == 200) {
        print('Donación actualizada exitosamente');
        return true;
      } else {
        print('Error al actualizar donación. Código: ${response.statusCode}');
        print('Respuesta: ${response.body}');

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
      print('Error durante la actualización de donación: $e');
      return false;
    }
  }
} 