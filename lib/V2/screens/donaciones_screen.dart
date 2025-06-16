import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/donacion.dart';
import '../services/donacion_service.dart';
import '../services/user_data_service.dart';
import '../services/location_service.dart';
import '../controllers/donacion_controller.dart';
import '../widgets/location_map.dart';

class DonacionesScreen extends StatefulWidget {
  const DonacionesScreen({Key? key}) : super(key: key);
  @override
  _DonacionesScreenState createState() => _DonacionesScreenState();
}

class _DonacionesScreenState extends State<DonacionesScreen> {
  final DonacionController _controller = DonacionController();

  bool _isLoading = true;
  List<Donacion> _donaciones = [];
  String? _errorMessage;
  String? _userCi;

  @override
  void initState() {
    super.initState();
    _cargarDonaciones();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final ci = await UserDataService.getUserCi();
    if (mounted) {
      setState(() {
        _userCi = ci; 
      });
    }
  }

  Future<void> _cargarDonaciones() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final donaciones = await DonacionService.obtenerDonaciones();

      setState(() {
        _donaciones = donaciones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar donaciones: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
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
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarDonaciones,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Intentar nuevamente'),
            ),
          ],
        ),
      );
    }

    if (_donaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: Colors.black,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay donaciones disponibles',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No se encontraron registros de donaciones',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarDonaciones,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0x76000000),
                foregroundColor: Colors.white,
              ),
              child: const Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDonaciones,
      color: Colors.black,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 50,
          bottom: 16,

        ),
        itemCount: _donaciones.length,
        itemBuilder: (context, index) {
          final donacion = _donaciones[index];
          return _buildDonacionCard(donacion);
        },
      ),
    );
  }

  Widget _buildDonacionCard(Donacion donacion) {
    String? estado = donacion.estado; 
    bool? yaEntregada = estado?.toLowerCase() == 'entregada';

    Color estadoColor = Colors.grey[800]!;
    Color textColor = Colors.white;

    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xCF181B26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF262626), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xE00F101C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Donación #${donacion.idDonacion}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estado == "Iniciando armado de paquete" ? "Armando Paq." : estado!,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('Código', donacion.codigo, Icons.qr_code),
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Fecha de Aprobación',
                    _controller.formatearFecha(donacion.fechaAprobacion),
                    Icons.event_available),
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Fecha de Entrega',
                    _controller.formatearFecha(donacion.fechaEntrega),
                    Icons.delivery_dining),
                if (donacion.categoria != null && donacion.categoria!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Categoría', donacion.categoria!, Icons.category),
                ],
                if (!(yaEntregada ||
                    estado == "Iniciando armado de paquete" ||
                    estado == "Pendiente")) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _mostrarModalActualizacion(donacion),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0x5F000000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'ACTUALIZAR',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFF5F5F5), // Gris 100
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  void _mostrarModalActualizacion(Donacion donacion) async {
    String estadoSeleccionado = 'En Camino';
    Uint8List? imagenBytes;
    File? imagen;
    bool isLoading = false;

    double? latitude;
    double? longitude;

    if (_userCi == null || _userCi!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener su cédula de identidad. Por favor inicie sesión nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF101621),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 25,
                right: 25,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Actualizar Donación #${donacion.idDonacion}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),

                    
                    ListTile(
                      leading: const Icon(Icons.credit_card_outlined, color: Colors.white),
                      title: const Text('Cédula de Identidad',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(_userCi ?? 'No disponible',
                        style: const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      dense: true,
                    ),

                    
                    ListTile(
                      leading: const Icon(Icons.inventory_2_outlined, color: Colors.white),
                      title: const Text('Estado',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.grey[850],
                        ),
                        child: DropdownButton<String>(
                          value: estadoSeleccionado,
                          isExpanded: true,
                          dropdownColor: Colors.grey[850],
                          style: const TextStyle(color: Colors.white),
                          underline: Container(
                            height: 1,
                            color: Colors.grey[400],
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                estadoSeleccionado = newValue;
                              });
                            }
                          },
                          items: <String>['En Camino', 'Entregado']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    
                    const ListTile(
                      leading: Icon(Icons.location_on_outlined, color: Colors.white),
                      title: Text('Tu Ubicación Actual',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text('Se usará esta ubicación para registrar la donación',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),

                    
                    LocationMapWidget(
                      height: 250,
                      onLocationChanged: (lat, lng) {
                        setState(() {
                          latitude = lat;
                          longitude = lng;
                        });
                      },
                    ),

                    
                    ListTile(
                      leading: const Icon(Icons.photo_camera_outlined, color: Colors.white),
                      title: const Text('Imagen de Evidencia',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text('Tome una foto o seleccione de su galería',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                          IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            tooltip: 'Tomar foto',
                            onPressed: () async {
                              final picker = ImagePicker();
                              final XFile? pickedFile = await picker.pickImage(
                                source: ImageSource.camera,
                                maxWidth: 800,
                                imageQuality: 80,
                              );

                              if (pickedFile != null) {
                                setState(() {
                                  imagen = File(pickedFile.path);
                                  imagenBytes = File(pickedFile.path).readAsBytesSync();
                                });
                              }
                            },
                          ),
                          
                          IconButton(
                            icon: const Icon(Icons.photo_library, color: Colors.white),
                            tooltip: 'Seleccionar de galería',
                            onPressed: () async {
                              final picker = ImagePicker();
                              final XFile? pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 800,
                                imageQuality: 80,
                              );

                              if (pickedFile != null) {
                                setState(() {
                                  imagen = File(pickedFile.path);
                                  imagenBytes = File(pickedFile.path).readAsBytesSync();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    if (imagen != null) ...[
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _mostrarImagenCompleta(context, imagen!);
                            },
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                                image: DecorationImage(
                                  image: FileImage(imagen!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.zoom_in,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    imagen = null;
                                    imagenBytes = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                    Container(
                      constraints: const BoxConstraints(minHeight: 100),
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                        color: Colors.grey[850],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), 
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.photo_size_select_actual_outlined,
                            color: Colors.grey,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No se ha seleccionado ninguna imagen',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading || latitude == null || longitude == null
                            ? null
                            : () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            final success = await DonacionService.actualizarDonacion(
                              idDonacion: donacion.idDonacion,
                              ciUsuario: _userCi!,
                              estado: estadoSeleccionado,
                              latitud: latitude!,
                              longitud: longitude!,
                              imagen: imagenBytes,
                            );

                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('¡Donación actualizada correctamente!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _cargarDonaciones();
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error al actualizar la donación. Intente nuevamente.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            print('Error al actualizar donación: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFDC007),
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey.shade800,
                          disabledForegroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.0,
                          ),
                        )
                            : const Text(
                          'GUARDAR CAMBIOS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarImagenCompleta(BuildContext context, File imagen) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Image.file(
                imagen,
                fit: BoxFit.contain,
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}