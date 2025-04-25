class SportModel {
  final String id;
  final String name;
  final String description;
  final List<String> skills;
  final String imageUrl;
  final Map<String, dynamic>?
      attributes; // For additional attributes like physical requirements

  SportModel({
    required this.id,
    required this.name,
    required this.description,
    required this.skills,
    required this.imageUrl,
    this.attributes,
  });

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      imageUrl: json['imageUrl'] ?? '',
      attributes: json['attributes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'skills': skills,
      'imageUrl': imageUrl,
      'attributes': attributes,
    };
  }
}

class SportRecommendation {
  final SportModel sport;
  final int matchPercentage;

  SportRecommendation({
    required this.sport,
    required this.matchPercentage,
  });

  factory SportRecommendation.fromJson(Map<String, dynamic> json) {
    return SportRecommendation(
      sport: SportModel.fromJson(json['sport']),
      matchPercentage: json['matchPercentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sport': sport.toJson(),
      'matchPercentage': matchPercentage,
    };
  }
}

class SportQuestionnaireResponse {
  final double enduranceScore;
  final double strengthScore;
  final double powerScore;
  final double speedScore;
  final double agilityScore;
  final double flexibilityScore;
  final double nervousSystemScore;
  final double durabilityScore;
  final double handlingScore;
  final List<String> interests;
  final int teamPreference;
  final int competitiveness;

  SportQuestionnaireResponse({
    required this.enduranceScore,
    required this.strengthScore,
    required this.powerScore,
    required this.speedScore,
    required this.agilityScore,
    required this.flexibilityScore,
    required this.nervousSystemScore,
    required this.durabilityScore,
    required this.handlingScore,
    this.interests = const [],
    this.teamPreference = 3,
    this.competitiveness = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'enduranceScore': enduranceScore,
      'strengthScore': strengthScore,
      'powerScore': powerScore,
      'speedScore': speedScore,
      'agilityScore': agilityScore,
      'flexibilityScore': flexibilityScore,
      'nervousSystemScore': nervousSystemScore,
      'durabilityScore': durabilityScore,
      'handlingScore': handlingScore,
      'interests': interests,
      'teamPreference': teamPreference,
      'competitiveness': competitiveness,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
