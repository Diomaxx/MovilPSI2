import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'V2/screens/home_screen.dart';
import 'V2/screens/login_screen.dart';
import 'V2/screens/register_screen.dart';
import 'V2/services/notificacion_service.dart';
import 'package:flutter/services.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar notificaciones
  await NotificacionService.initNotifications();

  // Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donaciones App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Colores principales de la aplicación
        primaryColor: const Color(0xFF3D71B8), // Light navy blue similar to web
        scaffoldBackgroundColor: const Color(0xFF25273F), // Slightly lighter dark navy background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF25273F),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE3AB1C), // Golden yellow accent
          secondary: Color(0xFFFFD833), // Highlight yellow
          surface: Color(0xFF12152C), // Very dark navy for cards
          onSurface: Color(0xFFF6F6F8), // White text
          background: Color(0xFF25273F), // Slightly lighter dark navy background
          onBackground: Color(0xFFD9E5FF), // Lighter blue text
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFB8CCFF), // Lighter blue for buttons
          ),
        ),
        textTheme: GoogleFonts.montserratTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE3AB1C), // Golden yellow
            foregroundColor: const Color(0xFFF6F6F8), // White text
            shape: const RoundedRectangleBorder(), // No border radius
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Color(0xFF6B6B6B)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFF4C6CB0).withOpacity(0.7)),
            borderRadius: BorderRadius.zero,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4C6CB0)),
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      // Define named routes
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigation(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Check for existing login session here if needed

    // Conectar al WebSocket para recibir notificaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Conectar al WebSocket después de que se haya construido la UI
      NotificacionService.conectarWebSocket();
    });
  }

  @override
  void dispose() {
    // Desconectar WebSocket al cerrar la aplicación
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoggedIn
          ? const HomeScreen() // Si está logueado, muestra HomeScreen
          : const LoginScreen(), // Si no está logueado, muestra LoginScreen
    );
  }
}