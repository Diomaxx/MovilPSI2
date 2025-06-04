class Metrics {
  // Identification field
  String id;
  
  // Solicitudes statistics
  int totalSolicitudesRecibidas;
  int solicitudesAprobadas;
  int solicitudesRechazadas;
  int solicitudesSinResponder;
  
  // Donaciones statistics
  int donacionesEntregadas;
  int donacionesPendientes;
  
  // Time metrics
  String tiempoPromedioRespuesta;
  String tiempoPromedioEntrega;
  
  // Distribution data
  Map<String, dynamic> donEntregadasProvincia;
  Map<String, int> solicitudesPorMes;
  Map<String, int> topProductosMasSolicitados;
  Map<String, int> solicitudesPorProvincia;
  Map<String, dynamic> solicitudesPorCategoria;
  
  // User activity
  List<dynamic> solicitantesMasActivos;
  
  // Creation date
  String fechaCreacion;

  // Constructor for creating a Metrics instance
  Metrics({
    required this.id,
    required this.totalSolicitudesRecibidas,
    required this.solicitudesAprobadas,
    required this.solicitudesRechazadas,
    required this.solicitudesSinResponder,
    required this.donacionesEntregadas,
    required this.donacionesPendientes,
    required this.tiempoPromedioRespuesta,
    required this.tiempoPromedioEntrega,
    required this.donEntregadasProvincia,
    required this.solicitudesPorMes,
    required this.topProductosMasSolicitados,
    required this.solicitudesPorProvincia,
    required this.solicitudesPorCategoria,
    required this.solicitantesMasActivos,
    required this.fechaCreacion,
  });
} 