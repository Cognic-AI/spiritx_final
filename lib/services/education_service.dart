import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sri_lanka_sports_app/models/education_model.dart';

class EducationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get all educational content
  Future<List<EducationModel>> getAllEducationalContent() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('education').get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EducationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting educational content: $e');
      return [];
    }
  }
  
  // Get educational content by ID
  Future<EducationModel?> getEducationalContentById(String contentId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('education').doc(contentId).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EducationModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('Error getting educational content: $e');
      return null;
    }
  }
  
  // Get techniques
  Future<List<EducationModel>> getTechniques() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('education')
          .where('type', isEqualTo: 'technique')
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EducationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting techniques: $e');
      return [];
    }
  }
  
  // Get science articles
  Future<List<EducationModel>> getScienceArticles() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('education')
          .where('type', isEqualTo: 'science')
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EducationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting science articles: $e');
      return [];
    }
  }
  
  // Get educational content by sport
  Future<List<EducationModel>> getEducationalContentBySport(String sport) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('education')
          .where('sport', isEqualTo: sport)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EducationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting educational content by sport: $e');
      return [];
    }
  }
  
  // Get educational content by category
  Future<List<EducationModel>> getEducationalContentByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('education')
          .where('category', isEqualTo: category)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EducationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting educational content by category: $e');
      return [];
    }
  }
  
  // Search educational content
  Future<List<EducationModel>> searchEducationalContent(String query) async {
    try {
      // In a real app, you would use Algolia or a similar solution for full-text search
      // For simplicity, we'll just get all content and filter it
      List<EducationModel> allContent = await getAllEducationalContent();
      
      query = query.toLowerCase();
      
      return allContent.where((content) {
        return content.title.toLowerCase().contains(query) ||
               content.description.toLowerCase().contains(query) ||
               (content.sport?.toLowerCase().contains(query) ?? false) ||
               (content.category?.toLowerCase().contains(query) ?? false) ||
               (content.tags?.any((tag) => tag.toLowerCase().contains(query)) ?? false);
      }).toList();
    } catch (e) {
      print('Error searching educational content: $e');
      return [];
    }
  }
  
  // Track content view
  Future<void> trackContentView(String contentId, String userId) async {
    try {
      await _firestore.collection('content_views').add({
        'contentId': contentId,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error tracking content view: $e');
      // Continue even if tracking fails
    }
  }
}
