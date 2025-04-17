import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';

class HealthCentersScreen extends StatefulWidget {
  const HealthCentersScreen({Key? key}) : super(key: key);

  @override
  State<HealthCentersScreen> createState() => _HealthCentersScreenState();
}

class _HealthCentersScreenState extends State<HealthCentersScreen>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  Location _location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;
  bool _isLoading = true;
  String _errorMessage = '';

  // Sri Lanka center coordinates
  final LatLng _sriLankaCenter = const LatLng(7.8731, 80.7718);
  final List<Marker> _markers = [];

  // Sample health centers data
  final List<Map<String, dynamic>> _healthCenters = [
    {
      'id': '1',
      'name': 'National Sports Medicine Center',
      'address': 'Colombo 07, Sri Lanka',
      'phone': '+94 11 2698 456',
      'services': [
        'Medical Check-ups',
        'Physiotherapy',
        'Nutrition Counseling'
      ],
      'position': const LatLng(6.9101, 79.8642),
    },
    {
      'id': '2',
      'name': 'Kandy Sports Health Center',
      'address': 'Kandy, Sri Lanka',
      'phone': '+94 81 2234 567',
      'services': ['Injury Treatment', 'Supplements', 'Fitness Assessment'],
      'position': const LatLng(7.2906, 80.6337),
    },
    {
      'id': '3',
      'name': 'Galle Sports Medicine Institute',
      'address': 'Galle, Sri Lanka',
      'phone': '+94 91 2245 678',
      'services': ['Rehabilitation', 'Sports Psychology', 'Nutrition'],
      'position': const LatLng(6.0535, 80.2210),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeMap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _markers.clear();
    });

    // Add health center markers
    for (var center in _healthCenters) {
      _markers.add(
        Marker(
          point: center['position'],
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () => _showHealthCenterDetails(center),
            child: Column(
              children: [
                Icon(Icons.local_hospital,
                    color: AppTheme.primaryColor, size: 30),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    center['name'].toString().split(' ')[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    try {
      await _checkLocationPermission();
    } catch (e) {
      setState(() {
        _errorMessage = 'Location permission error: $e';
        _isLoading = false;
      });
      print("Location permission error: $e");
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          setState(() {
            _errorMessage = 'Location services are disabled';
            _isLoading = false;
          });
          return;
        }
      }

      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          setState(() {
            _errorMessage = 'Location permission not granted';
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _isLoading = false;
      });

      // Only get location if we have permission
      if (_permissionGranted == PermissionStatus.granted) {
        _getLocation();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Permission check error: $e';
        _isLoading = false;
      });
      print("Permission check error: $e");
    }
  }

  Future<void> _getLocation() async {
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }

    try {
      final locationData = await _location.getLocation();

      if (!mounted) return;

      setState(() {
        _locationData = locationData;
      });

      if (_locationData != null &&
          _locationData!.latitude != null &&
          _locationData!.longitude != null) {
        try {
          _mapController.move(
            LatLng(_locationData!.latitude!, _locationData!.longitude!),
            13.0,
          );

          if (mounted) {
            setState(() {
              // Remove current location marker if exists
              _markers.removeWhere(
                  (marker) => marker.key == const Key('current_location'));

              // Add updated current location marker
              _markers.add(
                Marker(
                  key: const Key('current_location'),
                  point: LatLng(
                      _locationData!.latitude!, _locationData!.longitude!),
                  width: 60,
                  height: 60,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.my_location,
                            color: Colors.white, size: 20),
                      ),
                      const Text(
                        'You',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
          }
        } catch (e) {
          print("Error moving map: $e");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error getting location: $e';
        });
      }
      print("Error getting location: $e");
    }
  }

  void _showHealthCenterDetails(Map<String, dynamic> center) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                center['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    center['address'],
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    center['phone'],
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: (center['services'] as List<String>).map((service) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(service),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to directions
                    Navigator.pop(context);
                  },
                  child: const Text('Get Directions'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHealthCentersList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Health Centers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _healthCenters.length,
                  itemBuilder: (context, index) {
                    final center = _healthCenters[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          center['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(center['address']),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pop(context);
                          _mapController.move(
                            center['position'],
                            15.0,
                          );
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _showHealthCenterDetails(center);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Centers'),
      ),
      body: Stack(
        children: [
          // Main map view
          _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeMap,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _sriLankaCenter,
                    initialZoom: 8.0,
                    maxZoom: 18.0,
                    minZoom: 3.0,
                    onTap: (tapPosition, point) {
                      // Close any open popups when tapping on the map
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sri_lanka_sports_app',
                      // Alternative free tile providers:
                      // ESRI World Map: urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                      // Stamen Terrain: urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}{r}.png',
                      // Carto DB: urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: _markers,
                    ),
                  ],
                ),

          // Info card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Find health centers where you can get free medical check-ups and supplements',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getLocation,
            heroTag: 'location',
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _showHealthCentersList,
            heroTag: 'list',
            child: const Icon(Icons.list),
          ),
        ],
      ),
    );
  }
}
