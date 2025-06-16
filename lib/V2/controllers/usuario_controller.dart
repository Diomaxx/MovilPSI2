import '../models/usuario.dart';

class UsuarioController {
  Usuario fromJson(Map<String, dynamic> json) {
    print('Response JSON structure: $json');
    
    final userData = json.containsKey('usuario') ? json['usuario'] : json;
    
    return Usuario(
      idUsuario: userData['idUsuario'] ?? userData['_id'] ?? 0,
      nombre: userData['nombre'] ?? '',
      apellido: userData['apellido'] ?? '',
      correoElectronico: userData['correoElectronico'] ?? '',
      ci: userData['ci'] ?? userData['cedulaIdentidad'] ?? '',
      telefono: userData['telefono'] ?? '',
      contrasena: userData['contrasena'] ?? '',
      admin: userData['admin'] ?? false,
      active: userData['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson(Usuario usuario) {
    return {
      'idUsuario': usuario.idUsuario,
      'nombre': usuario.nombre,
      'apellido': usuario.apellido,
      'correoElectronico': usuario.correoElectronico,
      'ci': usuario.ci,
      'telefono': usuario.telefono,
      'contrasena': usuario.contrasena,
      'admin': usuario.admin,
      'active': usuario.active,
    };
  }

  bool validateLogin(String ci, String password) {
    return ci.isNotEmpty && password.isNotEmpty;
  }

  bool validateRegistration(Usuario usuario) {
    return usuario.nombre.isNotEmpty && 
           usuario.apellido.isNotEmpty && 
           usuario.correoElectronico.isNotEmpty && 
           usuario.ci.isNotEmpty && 
           usuario.contrasena.isNotEmpty;
  }
}
