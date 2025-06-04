import '../models/donacion.dart';

class DonacionController {
  // Método para convertir JSON a objeto Donacion
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
  
  // Método para formatear la fecha en un formato más legible
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
  
  // Método para obtener un estado basado en las fechas
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