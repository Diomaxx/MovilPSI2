import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'V2/screens/home_screen.dart';
import 'V2/screens/login_screen.dart';
import 'V2/screens/register_screen.dart';
import 'V2/services/notificacion_service.dart';
import 'V2/services/usuario_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'donaciones_channel',
        channelName: 'Notificaciones de Donaciones',
        channelDescription: 'Canal para todas las notificaciones de la aplicación',
        defaultColor: Colors.black,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
      NotificationChannel(
        channelKey: 'solicitudes_channel',
        channelName: 'Solicitudes de Donación',
        channelDescription: 'Notificaciones de nuevas solicitudes de donación',
        defaultColor: Colors.orange,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
    ],
    debug: false,
  );

  await NotificacionService.initNotifications();

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
        primaryColor: const Color(0xFF3D71B8),
        scaffoldBackgroundColor: const Color(0xFF25273F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF25273F),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE3AB1C),
          secondary: Color(0xFFFFD833),
          surface: Color(0xFF12152C),
          onSurface: Color(0xFFF6F6F8),
          background: Color(0xFF25273F),
          onBackground: Color(0xFFD9E5FF),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFB8CCFF),
          ),
        ),
        textTheme: GoogleFonts.montserratTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE3AB1C),
            foregroundColor: const Color(0xFFF6F6F8),
            shape: const RoundedRectangleBorder(),
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificacionService.conectarWebSocket();
    });
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final isAuthenticated = await UsuarioService.isAuthenticated();
      
      if (mounted) {
        setState(() {
          _isLoggedIn = isAuthenticated;
          _isLoading = false;
        });
      }
      
      print('🔐 Authentication status: ${isAuthenticated ? 'AUTHENTICATED' : 'NOT AUTHENTICATED'}');
    } catch (e) {
      print('❌ Error checking authentication: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE3AB1C),
              ),
            )
          : _isLoggedIn
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}