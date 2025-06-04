import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

/// Widget that displays a map with the user's current location
class LocationMapWidget extends StatefulWidget {
  /// Function to call when location changes
  final Function(double latitude, double longitude)? onLocationChanged;

  /// Initial latitude if available
  final double? initialLatitude;

  /// Initial longitude if available
  final double? initialLongitude;

  /// Height of the map widget
  final double height;

  const LocationMapWidget({
    Key? key,
    this.onLocationChanged,
    this.initialLatitude,
    this.initialLongitude,
    this.height = 200,
  }) : super(key: key);

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  /// Controller for the Google Map
  final Completer<GoogleMapController> _controller = Completer();

  /// Set of markers to display on the map
  final Set<Marker> _markers = {};

  /// Current camera position
  CameraPosition? _currentPosition;

  /// Current marker position
  LatLng? _markerPosition;

  /// Flag to indicate if the map is loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // If we have initial coordinates, use them
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _initializeMap(widget.initialLatitude!, widget.initialLongitude!);
    } else {
      // Otherwise get current location
      _getCurrentLocation();
    }
  }

  /// Initialize map with given coordinates
  void _initializeMap(double latitude, double longitude) {
    final position = LatLng(latitude, longitude);

    setState(() {
      _markerPosition = position;
      _currentPosition = CameraPosition(
        target: position,
        zoom: 16.0,
      );

      _updateMarker();

      _isLoading = false;
    });

    // Notify parent about location if callback is provided
    if (widget.onLocationChanged != null) {
      widget.onLocationChanged!(latitude, longitude);
    }
  }

  /// Update marker position on the map
  void _updateMarker() {
    if (_markerPosition == null) return;

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _markerPosition!,
          draggable: true,
          infoWindow: const InfoWindow(
            title: 'Ubicación seleccionada',
          ),
          onDragEnd: (newPosition) {
            setState(() {
              _markerPosition = newPosition;
            });

            // Notify parent about new location
            if (widget.onLocationChanged != null) {
              widget.onLocationChanged!(
                newPosition.latitude,
                newPosition.longitude,
              );
            }
          },
        ),
      );
    });
  }

  /// Get current location and update map
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final location = await LocationService.getCurrentLocation();
      _initializeMap(location['latitude']!, location['longitude']!);
    } catch (e) {
      print('Error al obtener ubicación para el mapa: $e');
      // Use default location as fallback
      _initializeMap(
        LocationService.defaultLatitude,
        LocationService.defaultLongitude,
      );
    }
  }

  /// Handle tap on map to move marker
  void _handleMapTap(LatLng position) {
    setState(() {
      _markerPosition = position;
    });

    _updateMarker();

    // Notify parent about new location
    if (widget.onLocationChanged != null) {
      widget.onLocationChanged!(
        position.latitude,
        position.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
        color: Colors.grey[800], // Dark background for loading state
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Map
            _isLoading || _currentPosition == null
                ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
                : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _currentPosition!,
              markers: _markers,
              zoomControlsEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                _setMapStyle(controller);
              },
              onTap: _handleMapTap,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              },
            ),


            // Refresh button
            Positioned(
              top: 8,
              right: 8,
              child: FloatingActionButton.small(
                backgroundColor: Colors.black,
                elevation: 4,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                onPressed: _getCurrentLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Set the map style to dark mode
  Future<void> _setMapStyle(GoogleMapController controller) async {
    const String mapStyle = '''
      [
        {
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#242f3e"
            }
          ]
        },
        {
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#746855"
            }
          ]
        },
        {
          "elementType": "labels.text.stroke",
          "stylers": [
            {
              "color": "#242f3e"
            }
          ]
        },
        {
          "featureType": "administrative.locality",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#d59563"
            }
          ]
        },
        {
          "featureType": "poi",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#d59563"
            }
          ]
        },
        {
          "featureType": "poi.park",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#263c3f"
            }
          ]
        },
        {
          "featureType": "poi.park",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#6b9a76"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#38414e"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry.stroke",
          "stylers": [
            {
              "color": "#212a37"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#9ca5b3"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#746855"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry.stroke",
          "stylers": [
            {
              "color": "#1f2835"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#f3d19c"
            }
          ]
        },
        {
          "featureType": "transit",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#2f3948"
            }
          ]
        },
        {
          "featureType": "transit.station",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#d59563"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#17263c"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#515c6d"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "labels.text.stroke",
          "stylers": [
            {
              "color": "#17263c"
            }
          ]
        }
      ]
    ''';

    try {
      await controller.setMapStyle(mapStyle);
    } catch (e) {
      print('Error setting map style: $e');
    }
  }
} 