import '../models/usuario.dart';

class UsuarioController {
  Usuario fromJson(Map<String, dynamic> json) {
    // Print out the structure of the JSON response for debugging
    print('Response JSON structure: $json');
    
    // Check if the response contains 'usuario' property which is often the case with login responses
    final userData = json.containsKey('usuario') ? json['usuario'] : json;
    
    return Usuario(
      idUsuario: userData['idUsuario'] ?? userData['_id'] ?? 0,
      nombre: userData['nombre'] ?? '',
      apellido: userData['apellido'] ?? '',
      correoElectronico: userData['correoElectronico'] ?? '',
      // Handle both field name possibilities
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
