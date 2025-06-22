import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../config.dart';
import '../models/notificacion.dart';
import 'api_client.dart';

class NotificacionService {
  static final List<Function(Notificacion)> _nuevaNotificacionCallbacks = [];
  static bool _notificationsInitialized = false;
  static StompClient? _stompClient;

  /// Inicializa el servicio de notificaciones (no reinicializa Awesome Notifications)
  static Future<void> initNotifications() async {
    if (_notificationsInitialized) return;

    try {
      // Solo solicitar permisos ya que Awesome Notifications se inicializa en main.dart
      await requestNotificationPermission();
      
      _notificationsInitialized = true;
      print('✅ Servicio de notificaciones inicializado correctamente');
      
    } catch (e) {
      print('❌ Error inicializando servicio de notificaciones: $e');
    }
  }

  /// Solicita permisos de notificación
  static Future<void> requestNotificationPermission() async {
    try {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        // Mostrar diálogo de permisos
        bool? permissionGranted = await AwesomeNotifications().requestPermissionToSendNotifications();
        print('🔔 Permisos de notificación: ${permissionGranted == true ? 'Concedidos' : 'Denegados'}');
      } else {
        print('✅ Permisos de notificación ya concedidos');
      }
    } catch (e) {
      print('❌ Error solicitando permisos: $e');
    }
  }

  /// Muestra una notificación usando Awesome Notifications
  static Future<void> _mostrarNotificacion(Notificacion notificacion) async {
    if (!_notificationsInitialized) {
      await initNotifications();
    }

    try {
      // Determinar el color de la notificación basado en la severidad
      Color notificationColor = _obtenerColorPorSeveridad(notificacion.nivelSeveridad);
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificacion.id.hashCode,
          channelKey: 'donaciones_channel',
          title: notificacion.titulo,
          body: notificacion.descripcion,
          backgroundColor: notificationColor,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
          category: NotificationCategory.Message,
          autoDismissible: true,
          showWhen: true,
          customSound: null, // Usar sonido por defecto
          payload: {
            'notificacion_id': notificacion.id,
            'tipo': notificacion.tipo,
            'severidad': notificacion.nivelSeveridad,
          },
        ),
      );
      
      print('✅ Notificación mostrada con Awesome Notifications: ${notificacion.id}');
    } catch (e) {
      print('❌ Error al mostrar notificación: $e');
    }
  }

  /// Obtiene el color de la notificación basado en la severidad
  static Color _obtenerColorPorSeveridad(String severidad) {
    switch (severidad.toLowerCase()) {
      case 'alta':
      case 'critica':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  static void addNuevaNotificacionListener(Function(Notificacion) callback) {
    _nuevaNotificacionCallbacks.add(callback);
  }

  static void removeNuevaNotificacionListener(Function(Notificacion) callback) {
    _nuevaNotificacionCallbacks.remove(callback);
  }

  static void _notificarNuevaNotificacion(Notificacion notificacion) {
    _mostrarNotificacion(notificacion);
    for (var callback in _nuevaNotificacionCallbacks) {
      callback(notificacion);
    }
  }

  static Future<List<Notificacion>> obtenerNotificaciones() async {
    final url = '$baseApiUrl/notificaciones';

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Datos de notificaciones recibidos exitosamente');
        final notificaciones = data.map((item) => Notificacion.fromJson(item)).toList();
        return notificaciones;
      } else {
        print('Error al obtener notificaciones. Código: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error durante la obtención de notificaciones: $e');
      return [];
    }
  }

  static void conectarWebSocket() {
    if (_stompClient != null) {
      print('WebSocket ya estaba inicializado');
      return;
    }

    print('Intentando conectar al WebSocket para notificaciones...');
    initNotifications();

    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://$ip:8080/ws',
        onConnect: (frame) {
          print('WebSocket de notificaciones conectado');
          _stompClient!.subscribe(
            destination: '/topic/nueva-notificacion',
            callback: (frame) async {
              try {
                final data = jsonDecode(frame.body!);
                print('Notificación recibida por WS: $data');

                final nuevaNotificacion = Notificacion.fromJson(data);
                await _mostrarNotificacion(nuevaNotificacion);
                _notificarNuevaNotificacion(nuevaNotificacion);
              } catch (e) {
                print('Error procesando notificación del WS: $e');
              }
            },
          );
        },
        onDisconnect: (frame) {
          print('WebSocket de notificaciones desconectado');
        },
        onWebSocketError: (dynamic error) {
          print('Error en WebSocket de notificaciones: $error');
        },
        reconnectDelay: Duration(seconds: 5),
        heartbeatIncoming: Duration(seconds: 10),
        heartbeatOutgoing: Duration(seconds: 10),
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
      ),
    );

    _stompClient!.activate();
    print('Activando WebSocket de notificaciones...');
  }

  static void desconectarWebSocket() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
      print('Desconectado del WebSocket de notificaciones');
    }
  }

  /// Obtiene el color según el nivel de severidad para la UI
  static Color obtenerColorSeveridad(String severidad) {
    return _obtenerColorPorSeveridad(severidad);
  }

  /// Obtiene el ícono según el tipo de notificación
  static IconData obtenerIconoTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'alerta':
        return Icons.warning;
      case 'solicitud':
        return Icons.help_outline;
      case 'donacion':
        return Icons.favorite;
      case 'sistema':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  /// Formatea la fecha para mostrar en la UI
  static String formatearFecha(String fecha) {
    if (fecha.isEmpty) return 'Sin fecha';
    
    try {
      final DateTime fechaDateTime = DateTime.parse(fecha);
      return '${fechaDateTime.day}/${fechaDateTime.month}/${fechaDateTime.year} ${fechaDateTime.hour}:${fechaDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }
} 