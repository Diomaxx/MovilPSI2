import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../config.dart';
import '../models/notificacion.dart';

class NotificacionService {
  // Lista de callbacks para nuevas notificaciones
  static final List<Function(Notificacion)> _nuevaNotificacionCallbacks = [];

  // Plugin para notificaciones locales
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _notificationsInitialized = false;

  // Cliente para WebSocket
  static StompClient? _stompClient;

  // Inicializar las notificaciones
  static Future<void> initNotifications() async {
    if (_notificationsInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    _notificationsInitialized = true;
    print('✅ Notificaciones inicializadas correctamente');
  }

  // Solicitar permisos para notificaciones
  static Future<void> requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        print('🔐 Permiso notificaciones: $result');
      }
    }
  }

  // Mostrar una notificación
  static Future<void> _mostrarNotificacion(Notificacion notificacion) async {
    if (!_notificationsInitialized) {
      await initNotifications();
    }

    await requestNotificationPermission();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'notificaciones_channel',
      'Notificaciones',
      channelDescription: 'Notificaciones de la aplicación',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        notificacion.id.hashCode,
        notificacion.titulo,
        notificacion.descripcion,
        notificationDetails,
      );
      print('🔔 Notificación mostrada: ${notificacion.id}');
    } catch (e) {
      print('❌ Error al mostrar notificación: $e');
    }
  }

  // Añadir listener para nuevas notificaciones
  static void addNuevaNotificacionListener(Function(Notificacion) callback) {
    _nuevaNotificacionCallbacks.add(callback);
  }

  // Eliminar listener para nuevas notificaciones
  static void removeNuevaNotificacionListener(Function(Notificacion) callback) {
    _nuevaNotificacionCallbacks.remove(callback);
  }

  // Notificar sobre una nueva notificación
  static void _notificarNuevaNotificacion(Notificacion notificacion) {
    _mostrarNotificacion(notificacion);
    for (var callback in _nuevaNotificacionCallbacks) {
      callback(notificacion);
    }
  }

  // Obtener todas las notificaciones
  static Future<List<Notificacion>> obtenerNotificaciones() async {
    final url = Uri.parse('$baseApiUrl/notificaciones');

    try {
      print('📡 Obteniendo notificaciones desde: $url');
      final response = await http.get(url);
      print('📥 Respuesta - código: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Datos de notificaciones recibidos exitosamente');
        final notificaciones = data.map((item) => Notificacion.fromJson(item)).toList();
        return notificaciones;
      } else {
        print('⚠️ Error al obtener notificaciones. Código: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error durante la obtención de notificaciones: $e');
      return [];
    }
  }

  // Conectar al WebSocket para recibir notificaciones en tiempo real
  static void conectarWebSocket() {
    if (_stompClient != null) {
      print('🟡 WebSocket ya estaba inicializado');
      return;
    }

    print('📡 Intentando conectar al WebSocket para notificaciones...');
    initNotifications();

    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://$ip:8080/ws',
        onConnect: (frame) {
          print('✅ WebSocket de notificaciones conectado');
          _stompClient!.subscribe(
            destination: '/topic/nueva-notificacion',
            callback: (frame) async {
              try {
                final data = jsonDecode(frame.body!);
                print('📨 Notificación recibida por WS: $data');

                final nuevaNotificacion = Notificacion.fromJson(data);
                await _mostrarNotificacion(nuevaNotificacion);
                _notificarNuevaNotificacion(nuevaNotificacion);
              } catch (e) {
                print('❌ Error procesando notificación del WS: $e');
              }
            },
          );
        },
        onDisconnect: (frame) {
          print('🔌 WebSocket de notificaciones desconectado');
        },
        onWebSocketError: (dynamic error) {
          print('❗ Error en WebSocket de notificaciones: $error');
        },
        reconnectDelay: Duration(seconds: 5),
        heartbeatIncoming: Duration(seconds: 10),
        heartbeatOutgoing: Duration(seconds: 10),
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
      ),
    );

    _stompClient!.activate();
    print('⏳ Activando WebSocket de notificaciones...');
  }

  // Desconectar del WebSocket
  static void desconectarWebSocket() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
      print('🛑 Desconectado del WebSocket de notificaciones');
    }
  }

  // Formatear fecha para la UI
  static String formatearFecha(String fecha) {
    if (fecha.isEmpty) return 'Sin fecha';
    
    try {
      final DateTime fechaDateTime = DateTime.parse(fecha);
      return '${fechaDateTime.day}/${fechaDateTime.month}/${fechaDateTime.year} ${fechaDateTime.hour}:${fechaDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }

  // Obtener color basado en nivel de severidad
  static Color obtenerColorSeveridad(String nivelSeveridad) {
    switch (nivelSeveridad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Obtener icono basado en tipo de notificación
  static IconData obtenerIconoTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'solicitud':
        return Icons.assignment;
      case 'donacion':
        return Icons.volunteer_activism;
      case 'sistema':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
} 