import '../models/solicitud.dart';

class SolicitudController {
  // Convertir JSON a objeto Solicitud
  Solicitud fromJson(Map<String, dynamic> json, {bool isNew = false}) {
    return Solicitud(
      idSolicitud: json['idSolicitud']?.toString() ?? '',
      fechaInicioIncendio: json['fechaInicioIncendio'] ?? '',
      fechaSolicitud: json['fechaSolicitud'] ?? '',
      aprobada: json['aprobada'],
      cantidadPersonas: json['cantidadPersonas'] ?? 0,
      justificacion: json['justificacion'] ?? '',
      categoria: json['categoria'],
      productos: json['productos'] ?? '',
      solicitante: _solicitanteFromJson(json['solicitante']),
      destino: _destinoFromJson(json['destino']),
      isNew: isNew,
      isRead: false,
    );
  }
  
  // Convertir JSON a objeto Solicitante
  Solicitante _solicitanteFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Solicitante(
        id: 0, 
        nombre: '', 
        apellido: '', 
        telefono: '', 
        ci: '',
      );
    }
    
    return Solicitante(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      telefono: json['telefono'] ?? '',
      ci: json['ci'] ?? '',
    );
  }
  
  // Convertir JSON a objeto Destino
  Destino _destinoFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Destino(
        id: 0, 
        direccion: '', 
        provincia: '', 
        comunidad: '',
      );
    }
    
    return Destino(
      id: json['id'] ?? 0,
      direccion: json['direccion'] ?? '',
      provincia: json['provincia'] ?? '',
      comunidad: json['comunidad'] ?? '',
    );
  }
  
  // Formatear fecha
  String formatearFecha(String fecha) {
    if (fecha.isEmpty) return 'Sin fecha';
    
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
  
  // Obtener estado como texto
  String obtenerEstadoTexto(bool? aprobada) {
    if (aprobada == null) return 'Pendiente';
    if (aprobada) return 'Aprobada';
    return 'Rechazada';
  }
  
  // Resumir productos
  String resumirProductos(String productos) {
    if (productos.isEmpty) return 'Sin productos';
    
    final listaProductos = productos.split(',');
    if (listaProductos.length <= 2) {
      return productos.replaceAll(',', ', ');
    }
    
    return '${listaProductos.length} productos';
  }
} 