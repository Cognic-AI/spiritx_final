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
    required int height,
    required int weight,
    required int age,
    required String gender,
    required int fitnessLevel,
    required int teamPreference,
    required int competitiveness,
    required List<String> interests,
    required String userId,
  }) async {
    SportQuestionnaireResponse questionnaire = SportQuestionnaireResponse(
      height: height,
      weight: weight,
      age: age,
      gender: gender,
      fitnessLevel: fitnessLevel,
      teamPreference: teamPreference,
      competitiveness: competitiveness,
      interests: interests,
      userId: userId,
    );
    
    return await _sportService.getRecommendations(questionnaire);
  }
}
