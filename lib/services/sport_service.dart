import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sri_lanka_sports_app/models/sport_model.dart';

class SportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // URL for the Python ML backend
  final String _mlApiUrl = 'https://your-ml-api-endpoint.com/predict';

  // Get all sports
  Future<List<SportModel>> getAllSports() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('sports').get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return SportModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting sports: $e');
      return [];
    }
  }

  // Get sport by ID
  Future<SportModel?> getSportById(String sportId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('sports').doc(sportId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return SportModel.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Error getting sport: $e');
      return null;
    }
  }

  // Submit questionnaire and get recommendations
  Future<List<SportRecommendation>> getRecommendations(
      SportQuestionnaireResponse questionnaire) async {
    try {
      // Save questionnaire response to Firestore
      await _saveQuestionnaireResponse(questionnaire);

      // Call ML API to get recommendations
      final response = await http.post(
        Uri.parse(_mlApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(questionnaire.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['recommendations'] != null) {
          List<dynamic> recommendations = data['recommendations'];

          // Fetch sport details from Firestore
          List<SportRecommendation> sportRecommendations = [];

          for (var recommendation in recommendations) {
            String sportId = recommendation['sportId'];
            int matchPercentage = recommendation['matchPercentage'];

            SportModel? sport = await getSportById(sportId);

            if (sport != null) {
              sportRecommendations.add(SportRecommendation(
                sport: sport,
                matchPercentage: matchPercentage,
              ));
            }
          }

          // Sort by match percentage (highest first)
          sportRecommendations
              .sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

          return sportRecommendations;
        }
      }

      // If API call fails or returns invalid data, use fallback recommendations
      return await _getFallbackRecommendations(questionnaire);
    } catch (e) {
      print('Error getting recommendations: $e');

      // Use fallback recommendations in case of error
      return await _getFallbackRecommendations(questionnaire);
    }
  }

  // Save questionnaire response to Firestore
  Future<void> _saveQuestionnaireResponse(
      SportQuestionnaireResponse questionnaire) async {
    try {
      await _firestore
          .collection('questionnaire_responses')
          .add(questionnaire.toJson());
    } catch (e) {
      print('Error saving questionnaire response: $e');
      // Continue even if saving fails
    }
  }

  // Get fallback recommendations based on interests
  Future<List<SportRecommendation>> _getFallbackRecommendations(
      SportQuestionnaireResponse questionnaire) async {
    try {
      List<SportModel> allSports = await getAllSports();
      List<SportRecommendation> recommendations = [];

      // Simple matching algorithm based on interests
      for (var sport in allSports) {
        int matchCount = 0;

        // Count matching skills/interests
        for (var interest in questionnaire.interests) {
          if (sport.skills.contains(interest)) {
            matchCount++;
          }
        }

        // Calculate match percentage
        int matchPercentage = 0;
        if (questionnaire.interests.isNotEmpty) {
          matchPercentage =
              (matchCount / questionnaire.interests.length * 100).round();
        }

        // Adjust based on other factors
        if (sport.attributes != null) {
          // Adjust for team preference
          if (sport.attributes!['isTeamSport'] == true &&
              questionnaire.teamPreference > 3) {
            matchPercentage += 10;
          } else if (sport.attributes!['isTeamSport'] == false &&
              questionnaire.teamPreference < 3) {
            matchPercentage += 10;
          }

          // Adjust for competitiveness
          if (sport.attributes!['competitiveLevel'] != null) {
            int sportCompetitiveness = sport.attributes!['competitiveLevel'];
            int diff = 5 -
                (sportCompetitiveness - questionnaire.competitiveness).abs();
            matchPercentage += diff * 2;
          }
        }

        // Ensure percentage is within bounds
        matchPercentage = matchPercentage.clamp(0, 100);

        recommendations.add(SportRecommendation(
          sport: sport,
          matchPercentage: matchPercentage,
        ));
      }

      // Sort by match percentage (highest first)
      recommendations
          .sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

      // Return top 5 recommendations
      return recommendations.take(5).toList();
    } catch (e) {
      print('Error getting fallback recommendations: $e');

      // Return empty list if all else fails
      return [];
    }
  }
}
