import 'package:flutter/material.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller for registration form
  final RegisterController _controller = RegisterController();

  // Loading state and error handling
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _controller.limpiarCampos();
    super.dispose();
  }

  // Handle registration attempt
  Future<void> _handleRegister() async {
    // Ocultar teclado
    FocusScope.of(context).unfocus();

    // Validación simple de campos
    if (_controller.nombreController.text.isEmpty ||
        _controller.apellidoController.text.isEmpty ||
        _controller.correoController.text.isEmpty ||
        _controller.cedulaController.text.isEmpty ||
        _controller.celularController.text.isEmpty ||
        _controller.passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor complete todos los campos';
      });
      return;
    }

    // Validación simple de correo electrónico
    if (!_controller.correoController.text.contains('@')) {
      setState(() {
        _errorMessage = 'Por favor ingrese un correo electrónico válido';
      });
      return;
    }

    if(_controller.celularController.text.length>8){
      setState(() {
        _errorMessage = 'Por favor ingrese un numero de celular válido';
      });
      return;
    }
    final celularNumber = int.tryParse(_controller.celularController.text);
    if (celularNumber == null ||
        celularNumber < 60000000 ||
        celularNumber > 79999999) {
      setState(() {
        _errorMessage = 'Por favor ingrese un número de celular válido . ';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('Intentando registrar usuario...');
      final usuario = await _controller.registrar();

      if (usuario != null) {
        // Si el registro es exitoso, limpiar campos y navegar a login
        _controller.limpiarCampos();
        print('Registro exitoso, redirigiendo a login');

        if (mounted) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro exitoso. Por favor inicie sesión.'),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar a login automáticamente
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        print('Registro falló, usuario es null');
        setState(() {
          _errorMessage = 'Error en el registro. Por favor intente nuevamente.';
        });
      }
    } catch (e) {
      print('Excepción durante registro: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Registro de Usuario',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Applying a gradient background similar to the login screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF171731), // 93% opacity dark navy
              Color(0xFF10151F), // 38% opacity black
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo
                  Container(
                    height: 100,
                    width: 100,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0x1031A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFFF), 
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Title
                        const Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            color: Color(0xFFF6F6F8), 
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Nombre Input
                        TextField(
                          controller: _controller.nombreController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), // Light blue text
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            labelStyle: TextStyle(
                              color: const Color(0xC5CBCBCB),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF3D518A).withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(
                                  0xFF99A4BE)),
                              borderRadius:   BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: const Color(0x7201031A),
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Apellido Input
                        TextField(
                          controller: _controller.apellidoController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), // Light blue text
                          decoration: InputDecoration(
                            labelText: 'Apellido',
                            labelStyle: TextStyle(
                              color: const Color(0xC5CBCBCB),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF3D518A).withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(
                                  0xFF99A4BE)),
                              borderRadius:   BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: const Color(0x7201031A),
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Correo input
                        TextField(
                          controller: _controller.correoController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), // Light blue text
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            labelStyle: TextStyle(
                              color: const Color(0xC5CBCBCB),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF3D518A).withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(
                                  0xFF99A4BE)),
                              borderRadius:   BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: const Color(0x7201031A),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // CI Input
                        TextField(
                          controller: _controller.cedulaController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), // Light blue text
                          decoration: InputDecoration(
                            labelText: 'Cédula de Identidad',
                            labelStyle: TextStyle(
                              color: const Color(0xC5CBCBCB),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF3D518A).withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(
                                  0xFF99A4BE)),
                              borderRadius:   BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: const Color(0x7201031A),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        //TELEFONO
                        TextField(
                          controller: _controller.celularController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), 
                          decoration: InputDecoration(
                            labelText: 'Número de Celular',
                            labelStyle: TextStyle(
                              color: const Color(0xC5CBCBCB),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF3D518A).withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(
                                  0xFF99A4BE)),
                              borderRadius:   BorderRadius.circular(10),
                            ),  
                            filled: true,
                            fillColor: const Color(0x7201031A),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        // Password Input
                        TextField(
                          controller: _controller.passwordController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), // Light blue text
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(
                              color: const Color(0xC5CBCBCB),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF3D518A).withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(
                                  0xFF99A4BE)),
                              borderRadius:   BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: const Color(0x7201031A),
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleRegister(),
                        ),
                        const SizedBox(height: 24),

                        // Error message
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Register Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDAAB34), // Golden yellow
                            foregroundColor: const Color(0xFF232323), // White text
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
                            disabledBackgroundColor: const Color(0xFF3A4C7D).withOpacity(0.5), // Navy blue with opacity
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFF6F6F8), // White
                              strokeWidth: 2.0,
                            ),
                          )
                              : const Text(
                            'REGISTRARSE',
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Login Link
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            '¿Ya tienes cuenta? Iniciar sesión',
                            style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12), // Light blue text
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}