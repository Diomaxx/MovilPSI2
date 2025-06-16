class Metrics {
  String id;
  
  int totalSolicitudesRecibidas;
  int solicitudesAprobadas;
  int solicitudesRechazadas;
  int solicitudesSinResponder;
  
  int donacionesEntregadas;
  int donacionesPendientes;
  
  String tiempoPromedioRespuesta;
  String tiempoPromedioEntrega;
  
  Map<String, dynamic> donEntregadasProvincia;
  Map<String, int> solicitudesPorMes;
  Map<String, int> topProductosMasSolicitados;
  Map<String, int> solicitudesPorProvincia;
  Map<String, dynamic> solicitudesPorCategoria;
  
  List<dynamic> solicitantesMasActivos;
  
  String fechaCreacion;

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