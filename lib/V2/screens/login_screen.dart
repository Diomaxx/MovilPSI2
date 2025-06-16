import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../services/user_data_service.dart';
import '../models/usuario.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final TextEditingController _ciController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    
    _ciController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  
  Future<void> _handleLogin() async {
    
    FocusScope.of(context).unfocus();

    
    if (_ciController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingrese cédula y contraseña';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('Attempting to login with CI: ${_ciController.text.trim()}');
      
      
      final userInfo = await UsuarioService.verifyUserByCI(_ciController.text.trim());
      
      if (userInfo == null) {
        setState(() {
          _errorMessage = 'Cédula no encontrada en el sistema.';
        });
        return;
      }
      
      
      if (!userInfo.active) {
        setState(() {
          _errorMessage = 'Usuario inactivo. Contacte al administrador.';
        });
        return;
      }
      
      
      final usuario = await UsuarioService.login(
        _ciController.text.trim(),
        _passwordController.text.trim(),
      );

      if (usuario != null) {
        print('Login successful, navigating to home');
        
        
        usuario.admin = userInfo.admin;
        usuario.telefono = userInfo.telefono;
        usuario.active = userInfo.active;

        
        await UserDataService.saveUserCi(_ciController.text.trim());
        await UserDataService.saveUserAdminStatus(usuario.admin);


        Future.microtask(() {
          Navigator.pushReplacementNamed(context, '/home', arguments: usuario);
        });
      } else {
        print('Login returned null usuario');
        setState(() {
          _errorMessage = 'Credenciales inválidas. Por favor intente nuevamente.';
        });
      }
    } catch (e) {
      print('Exception during login: $e');
      setState(() {
        _errorMessage = 'Error de conexión. Por favor intente más tarde.';
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
      backgroundColor:  Color(0xFF000000),
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
                  
                  const SizedBox(height: 60),
                  Container(
                    height: 120,
                    width: 120,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        opacity: const AlwaysStoppedAnimation(.7)
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
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x0), 
                          blurRadius: 10,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        
                        const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Color(0xFFCCCCCC), 
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        
                        TextField(
                          controller: _ciController,
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
                        ),
                        const SizedBox(height: 16),

                        
                        TextField(
                          controller: _passwordController,
                          style: const TextStyle(color: Color(0xFFD6E2FF)), 
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(color: const Color(0xC5CBCBCB)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF3D518A).withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(
                                  0xFF99A4BE)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: const Color(0x7201031A), 
                          ),
                          obscureText: true,
                          onSubmitted: (_) => _handleLogin(),
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
                          onPressed: _isLoading ? null : _handleLogin,
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
                              color: Color(0xFF060915), 
                              strokeWidth: 2.0,
                            ),
                          )
                              : const Text(
                            'INGRESAR',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            '¿No tienes una cuenta? Regístrate',
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