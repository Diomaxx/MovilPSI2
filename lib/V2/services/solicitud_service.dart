import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../config.dart';
import '../models/solicitud.dart';
import '../models/NuevaSolicitudWs.dart';
import '../controllers/solicitud_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_client.dart';

class SolicitudService {
  static final SolicitudController _controller = SolicitudController();
  static final List<Function(Solicitud)> _nuevaSolicitudCallbacks = [];

  static bool _notificationsInitialized = false;

  /// Inicializa el servicio de notificaciones de solicitudes
  static Future<void> initNotifications() async {
    if (_notificationsInitialized) return;

    try {
      // Solo solicitar permisos ya que Awesome Notifications se inicializa en main.dart
      await requestNotificationPermission();
      
      _notificationsInitialized = true;
      print('✅ Servicio de notificaciones de solicitudes inicializado correctamente');
      
    } catch (e) {
      print('❌ Error inicializando servicio de notificaciones de solicitudes: $e');
    }
  }

  /// Solicita permisos de notificación
  static Future<void> requestNotificationPermission() async {
    try {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        bool? permissionGranted = await AwesomeNotifications().requestPermissionToSendNotifications();
        print('🔔 Permisos de notificación solicitudes: ${permissionGranted == true ? 'Concedidos' : 'Denegados'}');
      }
    } catch (e) {
      print('❌ Error solicitando permisos de solicitudes: $e');
    }
  }

  /// Muestra notificación para una solicitud usando Awesome Notifications
  static Future<void> _mostrarNotificacion(Solicitud solicitud) async {
    if (!_notificationsInitialized) {
      await initNotifications();
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: solicitud.idSolicitud.hashCode,
          channelKey: 'solicitudes_channel',
          title: 'Nueva solicitud de donación',
          body: 'Se ha recibido una solicitud de ${solicitud.destino?.comunidad ?? "comunidad desconocida"}',
          backgroundColor: Colors.orange,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
          category: NotificationCategory.Message,
          autoDismissible: true,
          showWhen: true,
          payload: {
            'solicitud_id': solicitud.idSolicitud,
            'tipo': 'solicitud',
            'comunidad': solicitud.destino?.comunidad ?? '',
          },
        ),
      );
      
      print('✅ Notificación de solicitud mostrada: ${solicitud.idSolicitud}');
    } catch (e) {
      print('❌ Error al mostrar notificación de solicitud: $e');
    }
  }

  /// Muestra notificación para una solicitud WebSocket usando Awesome Notifications
  static Future<void> _mostrarNotificacionWs(NuevaSolicitudWs solicitud) async {
    if (!_notificationsInitialized) {
      await initNotifications();
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: solicitud.id.hashCode,
          channelKey: 'solicitudes_channel',
          title: 'Nueva solicitud sin responder',
          body: 'Destino ID: ${solicitud.idDestino}, Personas: ${solicitud.cantidadPersonas}',
          backgroundColor: Colors.red,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
          category: NotificationCategory.Message,
          autoDismissible: true,
          showWhen: true,
          payload: {
            'solicitud_id': solicitud.id,
            'tipo': 'solicitud_ws',
            'destino_id': solicitud.idDestino.toString(),
          },
        ),
      );
      
      print('✅ Notificación WS de solicitud mostrada: ${solicitud.id}');
    } catch (e) {
      print('❌ Error al mostrar notificación WS: $e');
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
    final url = '$baseApiUrl/solicitudes';

    try {
      final response = await ApiClient.get(url);

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
