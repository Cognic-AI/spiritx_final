import 'package:sri_lanka_sports_app/models/education_model.dart';
import 'package:sri_lanka_sports_app/services/education_service.dart';

class EducationRepository {
  final EducationService _educationService = EducationService();
  
  // Get all educational content
  Future<List<EducationModel>> getAllEducationalContent() async {
    return await _educationService.getAllEducationalContent();
  }
  
  // Get educational content by ID
  Future<EducationModel?> getEducationalContentById(String contentId) async {
    return await _educationService.getEducationalContentById(contentId);
  }
  
  // Get techniques
  Future<List<EducationModel>> getTechniques() async {
    return await _educationService.getTechniques();
  }
  
  // Get science articles
  Future<List<EducationModel>> getScienceArticles() async {
    return await _educationService.getScienceArticles();
  }
  
  // Get educational content by sport
  Future<List<EducationModel>> getEducationalContentBySport(String sport) async {
    return await _educationService.getEducationalContentBySport(sport);
  }
  
  // Get educational content by category
  Future<List<EducationModel>> getEducationalContentByCategory(String category) async {
    return await _educationService.getEducationalContentByCategory(category);
  }
  
  // Search educational content
  Future<List<EducationModel>> searchEducationalContent(String query) async {
    return await _educationService.searchEducationalContent(query);
  }
  
  // Track content view
  Future<void> trackContentView(String contentId, String userId) async {
    await _educationService.trackContentView(contentId, userId);
  }
}
