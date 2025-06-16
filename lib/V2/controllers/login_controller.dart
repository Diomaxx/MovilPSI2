import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../models/usuario.dart';

class LoginController {
  final cedulaController = TextEditingController();
  final passwordController = TextEditingController();

  Future<Usuario?> login() async {
    final cedula = cedulaController.text;
    final password = passwordController.text;

    if (cedula.isEmpty || password.isEmpty) {
      throw 'Por favor, ingrese ambos campos';
    }

    return await UsuarioService.login(cedula, password);
  }

  
  void limpiarCampos() {
    cedulaController.clear();
    passwordController.clear();
  }
}
