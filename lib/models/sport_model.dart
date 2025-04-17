class SportModel {
  final String id;
  final String name;
  final String description;
  final List<String> skills;
  final String imageUrl;
  final Map<String, dynamic>? attributes; // For additional attributes like physical requirements

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
      skills: json['skills'] != null 
          ? List<String>.from(json['skills']) 
          : [],
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
  final int height;
  final int weight;
  final int age;
  final String gender;
  final int fitnessLevel;
  final int teamPreference;
  final int competitiveness;
  final List<String> interests;
  final String userId;

  SportQuestionnaireResponse({
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.fitnessLevel,
    required this.teamPreference,
    required this.competitiveness,
    required this.interests,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'fitnessLevel': fitnessLevel,
      'teamPreference': teamPreference,
      'competitiveness': competitiveness,
      'interests': interests,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
