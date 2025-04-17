import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:sri_lanka_sports_app/models/health_center_model.dart';

class HealthCenterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get all health centers
  Future<List<HealthCenterModel>> getAllHealthCenters() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('health_centers').get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return HealthCenterModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting health centers: $e');
      return [];
    }
  }
  
  // Get health center by ID
  Future<HealthCenterModel?> getHealthCenterById(String centerId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('health_centers').doc(centerId).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return HealthCenterModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('Error getting health center: $e');
      return null;
    }
  }
  
  // Get health centers near a location
  Future<List<HealthCenterModel>> getHealthCentersNearLocation(LatLng location, double radiusKm) async {
    try {
      // Get all health centers (in a real app, you would use GeoFirestore or a similar solution)
      List<HealthCenterModel> allCenters = await getAllHealthCenters();
      
      // Calculate distance for each center and filter by radius
      List<HealthCenterModel> nearbyCenters = allCenters.where((center) {
        double distance = _calculateDistance(
          location.latitude, 
          location.longitude, 
          center.position.latitude, 
          center.position.longitude
        );
        
        return distance <= radiusKm;
      }).toList();
      
      // Sort by distance (closest first)
      nearbyCenters.sort((a, b) {
        double distanceA = _calculateDistance(
          location.latitude, 
          location.longitude, 
          a.position.latitude, 
          a.position.longitude
        );
        
        double distanceB = _calculateDistance(
          location.latitude, 
          location.longitude, 
          b.position.latitude, 
          b.position.longitude
        );
        
        return distanceA.compareTo(distanceB);
      });
      
      return nearbyCenters;
    } catch (e) {
      print('Error getting nearby health centers: $e');
      return [];
    }
  }
  
  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the earth in km
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = 
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * 
      sin(dLon / 2) * sin(dLon / 2);
      
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
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120 - (x * x * x * x * x * x * x) / 5040;
  }
  
  double _cos(double x) {
    return 1 - (x * x) / 2 + (x * x * x * x) / 24 - (x * x * x * x * x * x) / 720;
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
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5 - (x * x * x * x * x * x * x) / 7;
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
}
