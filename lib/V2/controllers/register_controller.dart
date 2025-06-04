import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../models/usuario.dart';

class RegisterController {
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final correoController = TextEditingController();
  final cedulaController = TextEditingController();
  final celularController = TextEditingController();
  final passwordController = TextEditingController();

  Future<Usuario?> registrar() async {
    final nombre = nombreController.text;
    final apellido = apellidoController.text;
    final correo = correoController.text;
    final cedula = cedulaController.text;
    final celular = celularController.text;
    final password = passwordController.text;

    if (nombre.isEmpty || apellido.isEmpty || correo.isEmpty || cedula.isEmpty ||celular.isEmpty || password.isEmpty) {
      throw 'Por favor, complete todos los campos';
    }

    final usuario = Usuario(
      nombre: nombre,
      apellido: apellido,
      correoElectronico: correo,
      ci: cedula,
      telefono: celular,
      contrasena: password,
    );

    return await UsuarioService.register(usuario);
  }

  void limpiarCampos() {
    nombreController.clear();
    apellidoController.clear();
    correoController.clear();
    cedulaController.clear();
    celularController.clear();
    passwordController.clear();
  }
}
