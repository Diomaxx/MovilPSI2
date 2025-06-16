import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../config.dart';
import '../models/solicitud.dart';
import '../models/NuevaSolicitudWs.dart';
import '../controllers/solicitud_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class SolicitudService {
  static final SolicitudController _controller = SolicitudController();
  static final List<Function(Solicitud)> _nuevaSolicitudCallbacks = [];

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static bool _notificationsInitialized = false;

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
    print('Notificaciones inicializadas correctamente');
  }

  static Future<void> requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        print('Permiso notificaciones: $result');
      }
    }
  }

  static Future<void> _mostrarNotificacion(Solicitud solicitud) async {
    if (!_notificationsInitialized) {
      await initNotifications();
    }

    await requestNotificationPermission();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'solicitudes_channel',
      'Solicitudes de Donación',
      channelDescription: 'Notificaciones de nuevas solicitudes de donación',
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
        solicitud.idSolicitud.hashCode,
        'Nueva solicitud de donación',
        'Se ha recibido una solicitud de ${solicitud.destino?.comunidad ?? "comunidad desconocida"}',
        notificationDetails,
      );
      print('Notificación mostrada para solicitud: ${solicitud.idSolicitud}');
    } catch (e) {
      print('Error al mostrar notificación: $e');
    }
  }

  static Future<void> _mostrarNotificacionWs(NuevaSolicitudWs solicitud) async {
    if (!_notificationsInitialized) {
      await initNotifications();
    }

    await requestNotificationPermission();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'solicitudes_channel',
      'Solicitudes de Donación',
      channelDescription: 'Notificaciones de nuevas solicitudes de donación',
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
        solicitud.id.hashCode,
        'Nueva solicitud sin responder',
        'Destino ID: ${solicitud.idDestino}, Personas: ${solicitud.cantidadPersonas}',
        notificationDetails,
      );
      print('Notificación WS mostrada para solicitud: ${solicitud.id}');
    } catch (e) {
      print('Error al mostrar notificación WS: $e');
    }
  }

  static void addNuevaSolicitudListener(Function(Solicitud) callback) {
    _nuevaSolicitudCallbacks.add(callback);
  }

  static void removeNuevaSolicitudListener(Function(Solicitud) callback) {
    _nuevaSolicitudCallbacks.remove(callback);
  }

  static void _notificarNuevaSolicitud(Solicitud solicitud) {
    _mostrarNotificacion(solicitud);
    for (var callback in _nuevaSolicitudCallbacks) {
      callback(solicitud);
    }
  }

  static Future<List<Solicitud>> obtenerSolicitudes() async {
    final url = Uri.parse('$baseApiUrl/solicitudes');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Datos de solicitudes recibidos exitosamente');
        final solicitudes = data.map((item) => _controller.fromJson(item)).toList();
        return solicitudes;
      } else {
        print('Error al obtener solicitudes. Código: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error durante la obtención de solicitudes: $e');
      return [];
    }
  }

  static StompClient? _stompClient;

  static void conectarWebSocket(BuildContext context) {
    if (_stompClient != null) {
      print('WebSocket ya estaba inicializado');
      return;
    }

    print('Intentando conectar al WebSocket...');
    initNotifications();

    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://$ip:8080/ws',
        onConnect: (frame) {
          print('WebSocket conectado');
          _stompClient!.subscribe(
            destination: '/topic/nueva-solicitud',
            callback: (frame) async {
              try {
                final data = jsonDecode(frame.body!);
                print('Mensaje recibido por WS: $data');

                final nuevaSolicitud = NuevaSolicitudWs.fromJson(data);
                await _mostrarNotificacionWs(nuevaSolicitud);
              } catch (e) {
                print('Error procesando solicitud del WS: $e');
              }
            },
          );
        },
        onDisconnect: (frame) {
          print('WebSocket desconectado');
        },
        onWebSocketError: (dynamic error) {
          print('Error en WebSocket: $error');
        },
        reconnectDelay: Duration(seconds: 5),
        heartbeatIncoming: Duration(seconds: 10),
        heartbeatOutgoing: Duration(seconds: 10),
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
      ),
    );

    _stompClient!.activate();
    print('Activando WebSocket...');
  }

  static void desconectarWebSocket() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
      print('Desconectado del WebSocket');
    }
  }
}
