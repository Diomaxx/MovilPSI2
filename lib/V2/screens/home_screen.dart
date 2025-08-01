import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'dart:ui';
import 'metrics_screen.dart';
import 'donaciones_screen.dart';
import 'notificaciones_screen.dart';
import '../services/notificacion_service.dart';
import '../services/usuario_service.dart';
import '../mixins/auth_mixin.dart';

class HomeScreen extends StatefulWidget {
  final Usuario? usuario;

  const HomeScreen({Key? key, this.usuario}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AuthMixin {
  int _selectedIndex = 0;
  late Usuario? _usuario;

  List<String> get _screenTitles {
    final titles = ['Donaciones'];
    if (_usuario?.admin == true) {
      titles.add('Métricas');
    }
    titles.add('Notificaciones');
    return titles;
  }

  List<Decoration> get _screenBackgrounds {
    final backgrounds = <Decoration>[
      const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xF21F2033), 
            Color.fromARGB(255, 18, 21, 33), 
          ],
          stops: [0.5, 1.0],
        ),
      ),
    ];
    
    if (_usuario?.admin == true) {
      backgrounds.add(
        const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xF51F2033), 
              Color.fromARGB(255, 18, 21, 33), 
            ],
            stops: [0.4, 1.0],
          ),
        ),
      );
    }
    
    backgrounds.add(
      const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xF51F2033), 
            Color.fromARGB(255, 18, 21, 33), 
          ],
          stops: [0.4, 1.0],
        ),
      ),
    );
    
    return backgrounds;
  }

  @override
  void initState() {
    super.initState();
    NotificacionService.conectarWebSocket();
    _usuario = widget.usuario;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_usuario == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Usuario) {
        setState(() {
          _usuario = args;
        });
      }
    }
  }

  List<Widget> get _screens {
    final screens = <Widget>[const DonacionesScreen()];
    
    if (_usuario?.admin == true) {
      screens.add(const MetricsScreen());
    }
    
    screens.add(const NotificacionesScreen());
    return screens;
  }

  List<BottomNavigationBarItem> _buildBottomNavigationItems() {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.card_giftcard),
        label: 'Donaciones',
      ),
    ];
    
    if (_usuario?.admin == true) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          label: 'Métricas',
        ),
      );
    }
    
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.notifications),
        label: 'Notificaciones',
      ),
    );
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2033),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFF2D3C66), 
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _screenTitles[_selectedIndex],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF6F6F8), 
              ),
            ),
          ],
        ),
        actions: [
          if (_usuario != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),

            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF6F6F8)), 
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: AlertDialog(
                    backgroundColor: const Color(0xEB16182E), 
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    title: const Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Color(0xFFF6F6F8)), 
                    ),
                    content: const Text(
                      '¿Estás seguro que deseas cerrar sesión?',
                      style: TextStyle(color: Color(0xFFD6E2FF)), 
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Color(0xFFB0C4F1)), 
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFE3AB1C), 
                              ),
                            ),
                          );

                          await makeAuthenticatedRequest(() async {
                            final success = await UsuarioService.logout();
                            if (success && mounted) {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                            return success;
                          });
                        },
                        child: const Text(
                          'Cerrar sesión',
                          style: TextStyle(color: Color(0xFFF6F6F8)), 
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: _screenBackgrounds[_selectedIndex],
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2033),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF2D3C66), 
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1F2033), 
          selectedItemColor: const Color(0xFFE3AB1C), 
          unselectedItemColor: const Color(0xFF5B77B2),
          
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          items: _buildBottomNavigationItems(),
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        backgroundColor: const Color(0xFFE3AB1C), 
        foregroundColor: const Color(0xFF1F2033), 

        onPressed: () {
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Actualizando donaciones...'),
              backgroundColor: const Color(0xFF273B6C), 
            ),
          );
        },
        child: const Icon(Icons.refresh),
      )
          : null,
    );
  }
}


class _DonacionesPlaceholder extends StatelessWidget {
  const _DonacionesPlaceholder();

  @override
  Widget build(BuildContext context) {
    
    final List<Map<String, dynamic>> donaciones = [
      {
        'nombre': 'Donación de alimentos',
        'ci': '1234567',
        'tipo': 'Alimentos',
        'fecha': '2023-05-15',
        'estado': 'Entregado',
      },
      {
        'nombre': 'Donación de ropa',
        'ci': '7654321',
        'tipo': 'Vestimenta',
        'fecha': '2023-05-20',
        'estado': 'Pendiente',
      },
      {
        'nombre': 'Medicamentos para hospital',
        'ci': '9876543',
        'tipo': 'Medicinas',
        'fecha': '2023-05-25',
        'estado': 'No entregado',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: donaciones.length,
      itemBuilder: (context, index) {
        final donacion = donaciones[index];

        
        Color estadoColor;
        switch (donacion['estado'].toLowerCase()) {
          case 'entregado':
            estadoColor = const Color(0xFFE3AB1C); 
            break;
          case 'pendiente':
            estadoColor = Colors.grey;
            break;
          case 'no entregado':
            estadoColor = const Color(0xFF3A4C7D); 
            break;
          default:
            estadoColor = Colors.grey;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0x4D01031A), 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0x1AFFFFFF), 
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x80000000), 
                blurRadius: 8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            donacion['nombre'],
                            style: const TextStyle(
                              color: Color(0xFFF6F6F8), 
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: estadoColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            donacion['estado'],
                            style: TextStyle(
                              color: donacion['estado'].toLowerCase() == 'entregado'
                                  ? Colors.black
                                  : const Color(0xFFF6F6F8), 
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.person, 'CI: ${donacion['ci']}'),
                    const SizedBox(height: 4),
                    _buildDetailRow(Icons.category, 'Tipo: ${donacion['tipo']}'),
                    const SizedBox(height: 4),
                    _buildDetailRow(Icons.calendar_today, 'Fecha: ${donacion['fecha']}'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFFB0C4F1), 
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFD6E2FF), 
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _NotificacionesPlaceholder extends StatelessWidget {
  const _NotificacionesPlaceholder();

  @override
  Widget build(BuildContext context) {
    
    final List<Map<String, dynamic>> notificaciones = [
      {
        'comunidad': 'Comunidad Esperanza',
        'estado': 'Aprobada',
        'ci': '1234567',
        'provincia': 'Santa Cruz',
        'direccion': 'Av. Principal #123',
        'celular': '77123456',
        'fechaInicio': '2023-06-01',
        'fechaSolicitud': '2023-05-15',
        'productos': ['Arroz', 'Leche', 'Azúcar'],
      },
      {
        'comunidad': 'Comunidad San Miguel',
        'estado': 'Pendiente',
        'ci': '7654321',
        'provincia': 'La Paz',
        'direccion': 'Calle Los Pinos #456',
        'celular': '77654321',
        'fechaInicio': '2023-06-10',
        'fechaSolicitud': '2023-05-20',
        'productos': ['Frazadas', 'Ropa de abrigo'],
      },
      {
        'comunidad': 'Hospital Central',
        'estado': 'Rechazada',
        'ci': '9876543',
        'provincia': 'Cochabamba',
        'direccion': 'Av. Salud #789',
        'celular': '77987654',
        'fechaInicio': '2023-06-15',
        'fechaSolicitud': '2023-05-25',
        'productos': ['Medicamentos', 'Insumos médicos'],
        'observacion': 'No cumple con los requisitos establecidos'
      },
    ];

    return Column(
      children: [
        
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x6601031A), 
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF2D3C66), 
                width: 1,
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Todas', true),
                const SizedBox(width: 8),
                _buildFilterChip('Aprobadas', false),
                const SizedBox(width: 8),
                _buildFilterChip('Pendientes', false),
                const SizedBox(width: 8),
                _buildFilterChip('Rechazadas', false),
              ],
            ),
          ),
        ),

        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final notificacion = notificaciones[index];

              
              Color estadoColor;
              Color textColor;
              String estadoText;

              switch (notificacion['estado'].toLowerCase()) {
                case 'aprobada':
                  estadoColor = const Color(0xFFE3AB1C).withOpacity(0.2); 
                  textColor = const Color(0xFFE3AB1C);
                  estadoText = 'Aprobada';
                  break;
                case 'pendiente':
                  estadoColor = const Color(0xFF3A4C7D).withOpacity(0.3); 
                  textColor = const Color(0xFFB0C4F1); 
                  estadoText = 'Pendiente';
                  break;
                case 'rechazada':
                  estadoColor = Colors.red[900]!.withOpacity(0.3);
                  textColor = Colors.red[400]!;
                  estadoText = 'Rechazada';
                  break;
                default:
                  estadoColor = Colors.grey[900]!.withOpacity(0.3);
                  textColor = Colors.grey[400]!;
                  estadoText = 'Desconocido';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0x4D01031A), 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0x1AFFFFFF), 
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x80000000), 
                      blurRadius: 8,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Solicitud de',
                                  style: TextStyle(
                                    color: Color(0xFFF6F6F8), 
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  notificacion['comunidad'],
                                  style: const TextStyle(
                                    color: Color(0xFFD6E2FF), 
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: estadoColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: textColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              estadoText,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildNotificationDetail('CI', notificacion['ci']),
                      _buildNotificationDetail('Comunidad', notificacion['comunidad']),
                      _buildNotificationDetail('Provincia', notificacion['provincia']),
                      _buildNotificationDetail('Dirección', notificacion['direccion']),
                      _buildNotificationDetail('Celular', notificacion['celular']),
                      _buildNotificationDetail('Fecha Inicio', notificacion['fechaInicio']),
                      _buildNotificationDetail(
                        'Fecha Solicitud',
                        notificacion['fechaSolicitud'],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Productos solicitados:',
                        style: TextStyle(
                          color: Color(0xFFF6F6F8), 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          notificacion['productos'].length,
                              (i) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF273B6C).withOpacity(0.5), 
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF3D518A),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              notificacion['productos'][i],
                              style: const TextStyle(
                                color: Color(0xFFD6E2FF), 
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (notificacion['estado'].toLowerCase() == 'rechazada') ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[900]!.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red[800]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Motivo de rechazo:',
                                style: TextStyle(
                                  color: Color(0xFFF6F6F8), 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notificacion['observacion'],
                                style: TextStyle(
                                  color: Colors.red[400],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFE3AB1C) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFE3AB1C) 
              : const Color(0xFF5B77B2), 
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.black
              : const Color(0xFFB0C4F1), 
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildNotificationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Color(0xFFB0C4F1), 
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFFF6F6F8), 
              ),
            ),
          ],
        ),
      ),
    );
  }
} 