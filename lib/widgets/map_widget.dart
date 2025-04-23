import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapWidget extends StatefulWidget {
  final List<LatLng>? bookLocations;
  final Function(LatLng)? onLocationSelected;

  const MapWidget({
    Key? key,
    this.bookLocations,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng? _currentLocation;
  MapController _mapController = MapController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _currentLocation ?? LatLng(51.5, -0.09),
            zoom: 13.0,
            onTap: (tapPosition, point) {
              if (widget.onLocationSelected != null) {
                widget.onLocationSelected!(point);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.book_swap',
            ),
            if (_currentLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    builder: (ctx) => const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 40.0,
                    ),
                  ),
                  ...?widget.bookLocations?.map((location) => Marker(
                        point: location,
                        builder: (ctx) => const Icon(
                          Icons.book,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      )),
                ],
              ),
          ],
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.move(_currentLocation!, 13.0);
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
} 