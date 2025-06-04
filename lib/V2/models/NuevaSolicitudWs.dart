class NuevaSolicitudWs {
  final String id;
  final String? fechaInicioIncendio;
  final String? fechaSolicitud;
  final List<String> listaProductos;
  final int cantidadPersonas;
  final String categoria;
  final String? idSolicitante;
  final String? idDestino;

  NuevaSolicitudWs({
    required this.id,
    required this.fechaInicioIncendio,
    required this.fechaSolicitud,
    required this.listaProductos,
    required this.cantidadPersonas,
    required this.categoria,
    required this.idSolicitante,
    required this.idDestino,
  });

  factory NuevaSolicitudWs.fromJson(Map<String, dynamic> json) {
    return NuevaSolicitudWs(
      id: json['id'],
      fechaInicioIncendio: json['fechaInicioIncendio'],
      fechaSolicitud: json['fechaSolicitud'],
      listaProductos: List<String>.from(json['listaProductos']),
      cantidadPersonas: json['cantidadPersonas'],
      categoria: json['categoria'],
      idSolicitante: json['idSolicitante'],
      idDestino: json['idDestino'],
    );
  }
}
