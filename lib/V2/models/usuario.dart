class Usuario {
  int idUsuario;
  
  String nombre;
  String apellido;
  String correoElectronico;
  String ci;
  String telefono;
  
  String contrasena;
  
  bool admin;
  
  bool active;

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