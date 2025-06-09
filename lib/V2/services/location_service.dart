import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

/// Service to manage location-related operations
class LocationService {
  static const double defaultLatitude = -17.7833;
  static const double defaultLongitude = -63.1821;
  
  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Los servicios de ubicación están desactivados');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, try again next time
        print('Permisos de ubicación denegados');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      print('Permisos de ubicación denegados permanentemente');
      return false;
    }
    
    // Permissions are granted
    return true;
  }
  
  static Future<bool?> showLocationPermissionDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de ubicación'),
        content: const Text(
          'Necesitamos acceder a tu ubicación para registrar dónde se realizó la entrega de la donación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Permitir'),
          ),
        ],
      ),
    );
  }
  
  static Future<Map<String, double>> getCurrentLocation() async {
    final hasPermission = await requestLocationPermission();
    
    if (hasPermission) {
      try {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        print('Ubicación obtenida: ${position.latitude}, ${position.longitude}');
        
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      } catch (e) {
        print('Error al obtener ubicación: $e');
        return {
          'latitude': defaultLatitude,
          'longitude': defaultLongitude,
        };
      }
    } else {
      return {
        'latitude': defaultLatitude,
        'longitude': defaultLongitude,
      };
    }
  }
} 