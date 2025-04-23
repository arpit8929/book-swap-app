import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:book_swap/models/book.dart';
import 'package:book_swap/providers/app_provider.dart';
import 'package:book_swap/screens/book_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  double _searchRadius = 5.0;
  List<Book> _filteredBooks = [];
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      final position = await Geolocator.getCurrentPosition();
      
      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (mounted) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        _updateFilteredBooks(appProvider.books);
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateFilteredBooks(List<Book> books) {
    if (_currentPosition == null || !mounted) return;

    final filtered = books.where((book) {
      if (!book.isAvailable) return false;
      
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        book.latitude,
        book.longitude,
      ) / 1000;

      if (distance > _searchRadius) return false;

      if (_searchQuery.isNotEmpty) {
        return book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      }

      return true;
    }).toList();

    if (mounted) {
      setState(() {
        _filteredBooks = filtered;
      });
    }
  }

  List<Marker> _createMarkers() {
    if (_currentPosition == null) return [];
    
    final markers = <Marker>[
      // Current location marker
      Marker(
        point: _currentPosition!,
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 40.0,
        ),
      ),
    ];

    // Book markers
    markers.addAll(_filteredBooks.map((book) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        book.latitude,
        book.longitude,
      ) / 1000;

      return Marker(
        point: LatLng(book.latitude, book.longitude),
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Author: ${book.author}'),
                    Text('Distance: ${distance.toStringAsFixed(1)} km'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsScreen(book: book),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Icon(
            Icons.book,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
    }));

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_currentPosition == null) {
            return const Center(child: Text('Location not available'));
          }

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: _currentPosition!,
                  initialZoom: 12.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.book_swap',
                  ),
                  MarkerLayer(
                    markers: _createMarkers(),
                  ),
                ],
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search books...',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            _updateFilteredBooks(appProvider.books);
                          },
                        ),
                        Row(
                          children: [
                            const Text('Search Radius:'),
                            Expanded(
                              child: Slider(
                                value: _searchRadius,
                                min: 1,
                                max: 20,
                                divisions: 19,
                                label: '${_searchRadius.toStringAsFixed(1)} km',
                                onChanged: (value) {
                                  setState(() {
                                    _searchRadius = value;
                                  });
                                  _updateFilteredBooks(appProvider.books);
                                },
                              ),
                            ),
                            Text('${_searchRadius.toStringAsFixed(1)} km'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 