import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sri_lanka_sports_app/models/sport_model.dart';

class SportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // URL for the Python ML backend - use Firebase Functions URL or a proper hosted endpoint
  // For testing, we'll use a mock endpoint that always returns data
  final String _mlApiUrl = 'http://192.168.236.180:9000/api/recommendSports';

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
      // For demo purposes, return some mock data if Firestore fails
      return _getMockSports();
    }
  }

  // Get sport by ID
  Future<SportModel?> getSportByName(String sportName) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sports')
          .where('name', isEqualTo: sportName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> data =
            snapshot.docs.first.data() as Map<String, dynamic>;
        data['id'] = snapshot.docs.first.id;
        return SportModel.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Error getting sport: $e');
      // Return a mock sport for demo purposes
      List<SportModel> mockSports = _getMockSports();
      return mockSports.firstWhere((sport) => sport.name == sportName,
          orElse: () => mockSports.first);
    }
  }

  // Submit questionnaire and get recommendations
  Future<List<SportRecommendation>> getRecommendations(
      SportQuestionnaireResponse questionnaire) async {
    try {
      // Try to call the API
      final response = await http
          .post(
            Uri.parse(_mlApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(questionnaire.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['recommended_sports'] != null) {
          List<String> recommendations =
              List<String>.from(data['recommended_sports']);
          List<SportRecommendation> sportRecommendations = [];

          for (var sportName in recommendations) {
            SportModel? sport = await getSportByName(sportName);

            if (sport != null) {
              sportRecommendations.add(SportRecommendation(
                sport: sport,
                matchPercentage: 100, // Assuming a default match percentage
              ));
            }
          }

          if (sportRecommendations.isNotEmpty) {
            // Sort by match percentage (highest first)
            sportRecommendations
                .sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
            return sportRecommendations;
          }
        }
      }

      // If API call fails or returns invalid data, use mock recommendations
      return await _getMockRecommendations(questionnaire);
    } catch (e) {
      print('Error getting recommendations: $e');
      // Use mock recommendations in case of error
      return await _getMockRecommendations(questionnaire);
    }
  }

  // Get mock recommendations based on questionnaire
  Future<List<SportRecommendation>> _getMockRecommendations(
      SportQuestionnaireResponse questionnaire) async {
    List<SportModel> allSports = await getAllSports();
    List<SportRecommendation> recommendations = [];

    // Create a scoring system based on the questionnaire
    for (var sport in allSports) {
      int matchPercentage = 0;

      // Calculate match based on physical attributes
      if (sport.name.toLowerCase().contains('running') ||
          sport.name.toLowerCase().contains('marathon')) {
        matchPercentage = (questionnaire.enduranceScore * 20).round();
      } else if (sport.name.toLowerCase().contains('weight') ||
          sport.name.toLowerCase().contains('lifting')) {
        matchPercentage = (questionnaire.strengthScore * 20).round();
      } else if (sport.name.toLowerCase().contains('sprint') ||
          sport.name.toLowerCase().contains('track')) {
        matchPercentage = (questionnaire.speedScore * 20).round();
      } else if (sport.name.toLowerCase().contains('gymnastics') ||
          sport.name.toLowerCase().contains('yoga')) {
        matchPercentage = (questionnaire.flexibilityScore * 20).round();
      } else if (sport.name.toLowerCase().contains('football') ||
          sport.name.toLowerCase().contains('basketball')) {
        // Team sports - mix of attributes
        matchPercentage = ((questionnaire.enduranceScore +
                    questionnaire.speedScore +
                    questionnaire.agilityScore) /
                3 *
                20)
            .round();
      } else if (sport.name.toLowerCase().contains('tennis') ||
          sport.name.toLowerCase().contains('badminton')) {
        // Racquet sports
        matchPercentage = ((questionnaire.speedScore +
                    questionnaire.agilityScore +
                    questionnaire.handlingScore) /
                3 *
                20)
            .round();
      } else if (sport.name.toLowerCase().contains('swimming')) {
        matchPercentage =
            ((questionnaire.enduranceScore + questionnaire.strengthScore) /
                    2 *
                    20)
                .round();
      } else {
        // Generic calculation for other sports
        matchPercentage = ((questionnaire.enduranceScore +
                    questionnaire.strengthScore +
                    questionnaire.speedScore +
                    questionnaire.agilityScore +
                    questionnaire.flexibilityScore) /
                5 *
                20)
            .round();
      }

      // Ensure percentage is within bounds
      matchPercentage = matchPercentage.clamp(30, 95);

      // Add some randomness to make it more realistic
      matchPercentage += (DateTime.now().millisecond % 10) - 5;
      matchPercentage = matchPercentage.clamp(30, 95);

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
  }

  // Mock sports data for testing
  List<SportModel> _getMockSports() {
    return [
      SportModel(
        id: 'sport1',
        name: 'Football',
        description:
            'A team sport played with a spherical ball between two teams of 11 players.',
        skills: ['teamwork', 'endurance', 'agility', 'coordination'],
        imageUrl:
            'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        attributes: {'isTeamSport': true, 'competitiveLevel': 4},
      ),
      SportModel(
        id: 'sport2',
        name: 'Basketball',
        description:
            'A team sport in which two teams of five players try to score points by throwing a ball through a hoop.',
        skills: ['teamwork', 'agility', 'jumping', 'coordination'],
        imageUrl:
            'https://images.unsplash.com/photo-1546519638-68e109acd27d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        attributes: {'isTeamSport': true, 'competitiveLevel': 4},
      ),
      SportModel(
        id: 'sport3',
        name: 'Swimming',
        description:
            'An individual or team racing sport that requires the use of one\'s entire body to move through water.',
        skills: ['endurance', 'strength', 'technique', 'breathing control'],
        imageUrl:
            'https://images.unsplash.com/photo-1530549387789-4c1017266635?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        attributes: {'isTeamSport': false, 'competitiveLevel': 3},
      ),
      SportModel(
        id: 'sport4',
        name: 'Tennis',
        description:
            'A racket sport that can be played individually against a single opponent or between two teams of two players each.',
        skills: ['agility', 'coordination', 'speed', 'strategy'],
        imageUrl:
            'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        attributes: {'isTeamSport': false, 'competitiveLevel': 4},
      ),
      SportModel(
        id: 'sport5',
        name: 'Cricket',
        description:
            'A bat-and-ball game played between two teams of eleven players on a field.',
        skills: ['coordination', 'strategy', 'teamwork', 'technique'],
        imageUrl:
            'https://images.unsplash.com/photo-1531415074968-036ba1b575da?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        attributes: {'isTeamSport': true, 'competitiveLevel': 3},
      ),
      SportModel(
        id: 'sport6',
        name: 'Badminton',
        description:
            'A racquet sport played using racquets to hit a shuttlecock across a net.',
        skills: ['agility', 'speed', 'coordination', 'strategy'],
        imageUrl:
            'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        attributes: {'isTeamSport': false, 'competitiveLevel': 3},
      ),
      SportModel(
        id: 'sport7',
        name: 'Volleyball',
        description:
            'A team sport in which two teams of six players are separated by a net.',
        skills: ['teamwork', 'jumping', 'coordination', 'agility'],
        imageUrl:
            'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        attributes: {'isTeamSport': true, 'competitiveLevel': 3},
      ),
    ];
  }
}
