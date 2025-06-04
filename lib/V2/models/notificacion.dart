// Modelo para las notificaciones basado en la estructura del API
class Notificacion {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String nivelSeveridad;
  final String fechaCreacion;
  
  // Para uso interno de la UI
  bool isRead;
  bool isNew;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.nivelSeveridad,
    required this.fechaCreacion,
    this.isRead = false,
    this.isNew = false,
  });

  // Factory constructor para crear una Notificación desde un JSON
  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipo: json['tipo'] ?? '',
      nivelSeveridad: json['nivelSeveridad'] ?? '',
      fechaCreacion: json['fechaCreacion'] ?? '',
      isNew: true,
      isRead: false,
    );
  }
} 