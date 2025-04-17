import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:sri_lanka_sports_app/models/health_center_model.dart';
import 'package:sri_lanka_sports_app/repositories/health_center_repository.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';

class HealthCentersScreen extends StatefulWidget {
  const HealthCentersScreen({Key? key}) : super(key: key);

  @override
  State<HealthCentersScreen> createState() => _HealthCentersScreenState();
}

class _HealthCentersScreenState extends State<HealthCentersScreen>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final HealthCenterRepository _healthCenterRepository =
      HealthCenterRepository();

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;
  bool _isLoading = true;
  String _errorMessage = '';

  // Sri Lanka center coordinates
  final LatLng _sriLankaCenter = const LatLng(7.8731, 80.7718);
  final List<Marker> _markers = [];

  // Health centers data
  List<HealthCenterModel> _healthCenters = [];
  List<HealthCenterWithDistance> _healthCentersWithDistance = [];
  HealthCenterModel? _nearestHealthCenter;

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

    try {
      // Fetch health centers from repository
      _healthCenters = await _healthCenterRepository.getAllHealthCenters();

      // Add health center markers
      for (var center in _healthCenters) {
        _markers.add(
          Marker(
            point: center.position,
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
                      center.name.split(' ')[0],
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

      await _checkLocationPermission();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading health centers: $e';
        _isLoading = false;
      });
      print("Error loading health centers: $e");
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

          // Get nearby health centers
          if (_locationData != null) {
            _findNearbyHealthCenters();
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

  Future<void> _findNearbyHealthCenters() async {
    if (_locationData == null ||
        _locationData!.latitude == null ||
        _locationData!.longitude == null) {
      return;
    }

    try {
      final userLocation =
          LatLng(_locationData!.latitude!, _locationData!.longitude!);

      // Calculate distance for each health center
      _healthCentersWithDistance = _healthCenters.map((center) {
        final distance = _calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            center.position.latitude,
            center.position.longitude);
        return HealthCenterWithDistance(center: center, distance: distance);
      }).toList();

      // Sort by distance
      _healthCentersWithDistance
          .sort((a, b) => a.distance.compareTo(b.distance));

      // Set nearest health center
      if (_healthCentersWithDistance.isNotEmpty) {
        setState(() {
          _nearestHealthCenter = _healthCentersWithDistance.first.center;
        });

        // Show a snackbar with the nearest health center
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Nearest health center: ${_nearestHealthCenter!.name} (${_healthCentersWithDistance.first.distance.toStringAsFixed(1)} km)'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  _showHealthCenterDetails(_nearestHealthCenter!);
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error finding nearby health centers: $e');
    }
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the earth in km

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Helper functions for the Haversine formula
  double sin(double x) {
    return _sin(x);
  }

  double cos(double x) {
    return _cos(x);
  }

  double atan2(double y, double x) {
    return _atan2(y, x);
  }

  double sqrt(double x) {
    return _sqrt(x);
  }

  // Implementations of math functions
  double _sin(double x) {
    return x -
        (x * x * x) / 6 +
        (x * x * x * x * x) / 120 -
        (x * x * x * x * x * x * x) / 5040;
  }

  double _cos(double x) {
    return 1 -
        (x * x) / 2 +
        (x * x * x * x) / 24 -
        (x * x * x * x * x * x) / 720;
  }

  double _atan2(double y, double x) {
    if (x > 0) {
      return _atan(y / x);
    } else if (x < 0) {
      return y >= 0 ? _atan(y / x) + pi : _atan(y / x) - pi;
    } else {
      return y > 0 ? pi / 2 : -pi / 2;
    }
  }

  double _atan(double x) {
    return x -
        (x * x * x) / 3 +
        (x * x * x * x * x) / 5 -
        (x * x * x * x * x * x * x) / 7;
  }

  double _sqrt(double x) {
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  // Constants
  static const double pi = 3.14159265358979323846;

  void _showHealthCenterDetails(HealthCenterModel center) {
    // Calculate distance if we have user location
    String distanceText = '';
    if (_locationData != null &&
        _locationData!.latitude != null &&
        _locationData!.longitude != null) {
      final distance = _calculateDistance(
          _locationData!.latitude!,
          _locationData!.longitude!,
          center.position.latitude,
          center.position.longitude);
      distanceText = ' (${distance.toStringAsFixed(1)} km away)';
    }

    // Check if this is the nearest center
    final isNearest =
        _nearestHealthCenter != null && center.id == _nearestHealthCenter!.id;

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
              if (isNearest)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Nearest Health Center',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                center.name + distanceText,
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
                    center.address,
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
                    center.phone,
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
                children: center.services.map((service) {
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

              // Operating hours if available
              if (center.operatingHours != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Operating Hours',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...center.operatingHours!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(entry.value.toString()),
                      ],
                    ),
                  );
                }).toList(),
              ],

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Get directions to health center
                    Navigator.pop(context);
                    _getDirectionsToHealthCenter(center);
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
                'Health Centers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _locationData != null
                    ? ListView.builder(
                        itemCount: _healthCentersWithDistance.length,
                        itemBuilder: (context, index) {
                          final item = _healthCentersWithDistance[index];
                          final center = item.center;
                          final distance = item.distance;
                          final isNearest = _nearestHealthCenter != null &&
                              center.id == _nearestHealthCenter!.id;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: isNearest
                                ? Colors.green.withOpacity(0.1)
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isNearest
                                  ? const BorderSide(
                                      color: Colors.green, width: 1.5)
                                  : BorderSide.none,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: isNearest
                                    ? Colors.green
                                    : AppTheme.primaryColor,
                                child: Icon(
                                  isNearest
                                      ? Icons.location_on
                                      : Icons.local_hospital,
                                  color: Colors.white,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      center.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isNearest)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Nearest',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(center.address),
                                  Text(
                                    '${distance.toStringAsFixed(1)} km away',
                                    style: TextStyle(
                                      color: isNearest
                                          ? Colors.green
                                          : Colors.grey[600],
                                      fontWeight:
                                          isNearest ? FontWeight.bold : null,
                                    ),
                                  ),
                                ],
                              ),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.pop(context);
                                _mapController.move(
                                  center.position,
                                  15.0,
                                );
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  _showHealthCenterDetails(center);
                                });
                              },
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: _healthCenters.length,
                        itemBuilder: (context, index) {
                          final center = _healthCenters[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                center.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(center.address),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.pop(context);
                                _mapController.move(
                                  center.position,
                                  15.0,
                                );
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
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

  void _getDirectionsToHealthCenter(HealthCenterModel center) {
    // In a real app, this would open a maps app with directions
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Getting directions to ${center.name}'),
      ),
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

class HealthCenterWithDistance {
  final HealthCenterModel center;
  final double distance;

  HealthCenterWithDistance({
    required this.center,
    required this.distance,
  });
}
