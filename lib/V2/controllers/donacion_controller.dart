import '../models/donacion.dart';

class DonacionController {
  
  Donacion fromJson(Map<String, dynamic> json) {
    return Donacion(
      idDonacion: json['idDonacion'] ?? 0,
      codigo: json['codigo'] ?? '',
      fechaAprobacion: json['fechaAprobacion'],
      fechaEntrega: json['fechaEntrega'],
      categoria: json['categoria'],
      imagen: json['imagen'],
      estado: json['estado']
    );
  }
  
  
  String formatearFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) {
      return 'No disponible';
    }
    
    try {
      final partes = fecha.split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
      return fecha;
    } catch (e) {
      return fecha;
    }
  }
  
  
  String obtenerEstado(Donacion donacion) {
    if (donacion.fechaEntrega != null && donacion.fechaEntrega!.isNotEmpty) {
      return 'Entregada';
    } else if (donacion.fechaAprobacion != null && donacion.fechaAprobacion!.isNotEmpty) {
      return 'Pendiente de entrega';
    } else {
      return 'En proceso';
    }
  }
} 