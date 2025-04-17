import 'package:latlong2/latlong.dart';
import 'package:sri_lanka_sports_app/models/health_center_model.dart';
import 'package:sri_lanka_sports_app/services/health_center_service.dart';

class HealthCenterRepository {
  final HealthCenterService _healthCenterService = HealthCenterService();
  
  // Get all health centers
  Future<List<HealthCenterModel>> getAllHealthCenters() async {
    return await _healthCenterService.getAllHealthCenters();
  }
  
  // Get health center by ID
  Future<HealthCenterModel?> getHealthCenterById(String centerId) async {
    return await _healthCenterService.getHealthCenterById(centerId);
  }
  
  // Get health centers near a location
  Future<List<HealthCenterModel>> getHealthCentersNearLocation(LatLng location, double radiusKm) async {
    return await _healthCenterService.getHealthCentersNearLocation(location, radiusKm);
  }
}
