class Solicitante {
  final int id;
  final String nombre;
  final String apellido;
  final String telefono;
  final String ci;

  Solicitante({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.ci,
  });
}

class Destino {
  final int id;
  final String direccion;
  final String provincia;
  final String comunidad;

  Destino({
    required this.id,
    required this.direccion,
    required this.provincia,
    required this.comunidad,
  });
}

class Solicitud {
  final String idSolicitud;
  final String fechaInicioIncendio;
  final String fechaSolicitud;
  final bool? aprobada;
  final int cantidadPersonas;
  final String justificacion;
  final String? categoria;
  final String productos;
  final Solicitante solicitante;
  final Destino destino;
  
  
  bool isNew = false;
  bool isRead = false;

  Solicitud({
    required this.idSolicitud,
    required this.fechaInicioIncendio,
    required this.fechaSolicitud,
    this.aprobada,
    required this.cantidadPersonas,
    required this.justificacion,
    this.categoria,
    required this.productos,
    required this.solicitante,
    required this.destino,
    this.isNew = false,
    this.isRead = false,
  });
} 