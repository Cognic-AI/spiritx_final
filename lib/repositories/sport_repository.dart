import 'package:sri_lanka_sports_app/models/sport_model.dart';
import 'package:sri_lanka_sports_app/services/sport_service.dart';

class SportRepository {
  final SportService _sportService = SportService();
  
  // Get all sports
  Future<List<SportModel>> getAllSports() async {
    return await _sportService.getAllSports();
  }
  
  // Get sport by ID
  Future<SportModel?> getSportById(String sportId) async {
    return await _sportService.getSportById(sportId);
  }
  
  // Submit questionnaire and get recommendations
  Future<List<SportRecommendation>> getRecommendations({
    required double enduranceScore,
    required double strengthScore,
    required double powerScore,
    required double speedScore,
    required double agilityScore,
    required double flexibilityScore,
    required double nervousSystemScore,
    required double durabilityScore,
    required double handlingScore,
  }) async {
    SportQuestionnaireResponse questionnaire = SportQuestionnaireResponse(
      enduranceScore: enduranceScore,
      strengthScore: strengthScore,
      powerScore: powerScore,
      speedScore: speedScore,
      agilityScore: agilityScore,
      flexibilityScore: flexibilityScore,
      nervousSystemScore: nervousSystemScore,
      durabilityScore: durabilityScore,
      handlingScore: handlingScore,
    );
    
    return await _sportService.getRecommendations(questionnaire);
  }
}
