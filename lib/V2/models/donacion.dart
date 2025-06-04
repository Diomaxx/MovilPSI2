class Donacion {
  // Identificación
  int idDonacion;
  String codigo;
  
  // Fechas
  String? fechaAprobacion;
  String? fechaEntrega;
  
  // Detalles adicionales
  String? categoria;
  String? imagen;
  String? estado;

  // Constructor
  Donacion({
    required this.idDonacion,
    required this.codigo,
    this.fechaAprobacion,
    this.fechaEntrega,
    this.categoria,
    this.imagen,
    this.estado
  });
} 