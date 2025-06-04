class Usuario {
  // User identification field
  int idUsuario;
  
  // Personal information fields
  String nombre;
  String apellido;
  String correoElectronico;
  String ci;
  String telefono;
  
  // Authentication field
  String contrasena;
  
  // Admin status field
  bool admin;
  
  // Active status field
  bool active;

  // Constructor for creating a new Usuario instance
  Usuario({
    required this.ci,
    required this.contrasena,
    this.idUsuario = 0,
    this.nombre = '',
    this.apellido = '',
    this.correoElectronico = '',
    this.telefono = '',
    this.admin = false,
    this.active = true,
  });
}