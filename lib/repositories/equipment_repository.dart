import 'package:sri_lanka_sports_app/models/equipment_model.dart';
import 'package:sri_lanka_sports_app/services/equipment_service.dart';

class EquipmentRepository {
  final EquipmentService _equipmentService = EquipmentService();
  
  // Search for equipment
  Future<List<EquipmentModel>> searchEquipment({
    String? searchTerm,
    List<String>? tags,
    List<String>? stores,
  }) async {
    EquipmentSearchQuery query = EquipmentSearchQuery(
      searchTerm: searchTerm,
      tags: tags,
      stores: stores,
    );
    
    return await _equipmentService.searchEquipment(query);
  }
  
  // Get user's favorite equipment sites
  Future<List<String>> getFavoriteEquipmentSites() async {
    return await _equipmentService.getFavoriteEquipmentSites();
  }
  
  // Update user's favorite equipment sites
  Future<void> updateFavoriteEquipmentSites(List<String> sites) async {
    await _equipmentService.updateFavoriteEquipmentSites(sites);
  }
}
