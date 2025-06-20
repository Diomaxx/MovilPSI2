import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/notificacion.dart';
import '../services/notificacion_service.dart';
import '../mixins/auth_mixin.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({Key? key}) : super(key: key);

  @override
  _NotificacionesScreenState createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> with AuthMixin {
  
  bool _isLoading = true;
  List<Notificacion> _notificaciones = [];
  String? _errorMessage;
  String _filtroTipo = 'Todas';

  List<Notificacion> get _notificacionesFiltradas {
    if (_filtroTipo == 'Todas') return _notificaciones;
    return _notificaciones.where((n) => n.tipo == _filtroTipo).toList();
  }


  @override
  void initState() {
    super.initState();
    validateAuthenticationAndRedirect();
    _cargarNotificaciones();

    NotificacionService.addNuevaNotificacionListener(_onNuevaNotificacion);

    NotificacionService.conectarWebSocket();
  }

  @override
  void dispose() {
    
    NotificacionService.removeNuevaNotificacionListener(_onNuevaNotificacion);
    
    super.dispose();
  }

  
  void _onNuevaNotificacion(Notificacion nuevaNotificacion) {
    setState(() {
      
      _notificaciones.insert(0, nuevaNotificacion);

      
      _mostrarNotificacionUI(nuevaNotificacion);
    });
  }

  
  void _mostrarNotificacionUI(Notificacion notificacion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notificacion.titulo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color.fromARGB(255, 92, 92, 92).withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'VER',
          textColor: const Color.fromARGB(255, 212, 169, 17),
          onPressed: () {
            
          },
        ),
      ),
    );
  }

  
  Future<void> _cargarNotificaciones() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await makeAuthenticatedRequest(() async {
      try {
        final notificaciones = await NotificacionService.obtenerNotificaciones();

        if (mounted) {
          setState(() {
            _notificaciones = notificaciones;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error al cargar notificaciones: $e';
            _isLoading = false;
          });
        }
      }
      return null;
    });
  }

  
  void _marcarComoLeida(Notificacion notificacion) {
    setState(() {
      notificacion.isRead = true;
      notificacion.isNew = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargarNotificaciones,
      color: Colors.black,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.black,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarNotificaciones,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_notificaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notificaciones',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    
    return Column(
      children: [
        Container(
          color: const Color(0xFF1B1E3C),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 40,
            right: 40,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Todas', 'Alerta', 'Solicitud'].map((tipo) {
              final isSelected = _filtroTipo == tipo;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _filtroTipo = tipo;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      tipo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      width: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.yellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(
              top: 0,
            ),
            itemCount: _notificacionesFiltradas.length,
            itemBuilder: (context, index) {
              final notificacion = _notificacionesFiltradas[index];
              return _buildNotificacionItem(notificacion);
            },
          ),
        ),
      ],
    );

  }


  Widget _buildNotificacionItem(Notificacion notificacion) {
    
    final backgroundColor = notificacion.isNew
        ? Colors.blue.withOpacity(0.12)
        : (notificacion.isRead ? Colors.transparent : Colors.grey.withOpacity(0.05));

    final Color severidadColor = NotificacionService.obtenerColorSeveridad(notificacion.nivelSeveridad);

    final IconData tipoIcono = NotificacionService.obtenerIconoTipo(notificacion.tipo);

    return GestureDetector(
      onTap: () {
        _marcarComoLeida(notificacion);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Color.fromARGB(174, 246, 246, 246),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Icon(
                  tipoIcono,
                  color: Color.fromARGB(255, 26, 64, 105),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notificacion.titulo,
                          style: TextStyle(
                            fontWeight: notificacion.isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        NotificacionService.formatearFecha(notificacion.fechaCreacion),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  Text(
                    const Utf8Decoder().convert( notificacion.descripcion.runes.toList()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[200],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: severidadColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Prioridad ${notificacion.nivelSeveridad}',
                        style: TextStyle(
                          fontSize: 12,
                          color: severidadColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' • ${notificacion.tipo}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (notificacion.isNew)
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD833),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}