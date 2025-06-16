import 'package:flutter/material.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController _controller = RegisterController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _controller.limpiarCampos();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

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
        _controller.limpiarCampos();
        print('Registro exitoso, redirigiendo a login');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro exitoso. Por favor inicie sesión.'),
              backgroundColor: Colors.green,
            ),
          );

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF171731), 
              Color(0xFF10151F), 
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

                        TextField(
                          controller: _controller.nombreController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), 
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

                        TextField(
                          controller: _controller.apellidoController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), 
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

                        TextField(
                          controller: _controller.correoController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), 
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

                        TextField(
                          controller: _controller.cedulaController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), 
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
                        TextField(
                          controller: _controller.passwordController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), 
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

                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDAAB34), 
                            foregroundColor: const Color(0xFF232323), 
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
                            disabledBackgroundColor: const Color(0xFF3A4C7D).withOpacity(0.5), 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFF6F6F8), 
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

                        
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            '¿Ya tienes cuenta? Iniciar sesión',
                            style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12), 
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