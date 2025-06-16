class Donacion {
  int idDonacion;
  String codigo;
  
  String? fechaAprobacion;
  String? fechaEntrega;
  
  String? categoria;
  String? imagen;
  String? estado;

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