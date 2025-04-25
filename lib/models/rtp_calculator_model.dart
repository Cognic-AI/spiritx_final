class AnkleInjuryAssessment {
  final String injurySeverity;
  final int daysSinceInjury;
  final int painLevel;
  final bool hasSwelling;
  final String rangeOfMotion;
  final String weightBearingStatus;
  final bool hasPreviousInjury;
  final String currentActivityLevel;
  final String injuryType;

  AnkleInjuryAssessment({
    required this.injurySeverity,
    required this.daysSinceInjury,
    required this.painLevel,
    required this.hasSwelling,
    required this.rangeOfMotion,
    required this.weightBearingStatus,
    required this.hasPreviousInjury,
    required this.currentActivityLevel,
    required this.injuryType,
  });

  Map<String, dynamic> toMap() {
    return {
      'injurySeverity': injurySeverity,
      'daysSinceInjury': daysSinceInjury,
      'painLevel': painLevel,
      'hasSwelling': hasSwelling,
      'rangeOfMotion': rangeOfMotion,
      'weightBearingStatus': weightBearingStatus,
      'hasPreviousInjury': hasPreviousInjury,
      'currentActivityLevel': currentActivityLevel,
      'injuryType': injuryType,
    };
  }

  factory AnkleInjuryAssessment.fromMap(Map<String, dynamic> map) {
    return AnkleInjuryAssessment(
      injurySeverity: map['injurySeverity'] ?? '',
      daysSinceInjury: map['daysSinceInjury'] ?? 0,
      painLevel: map['painLevel'] ?? 0,
      hasSwelling: map['hasSwelling'] ?? false,
      rangeOfMotion: map['rangeOfMotion'] ?? '',
      weightBearingStatus: map['weightBearingStatus'] ?? '',
      hasPreviousInjury: map['hasPreviousInjury'] ?? false,
      currentActivityLevel: map['currentActivityLevel'] ?? '',
      injuryType: map['injuryType'] ?? '',
    );
  }
}

class RehabilitationPlan {
  final String title;
  final String description;
  final List<RehabPhase> phases;
  final int estimatedDaysToReturn;
  final List<String> precautions;
  final List<String> followUpRecommendations;
  final List<String> bracingRecommendations; // Add this new field

  RehabilitationPlan({
    required this.title,
    required this.description,
    required this.phases,
    required this.estimatedDaysToReturn,
    required this.precautions,
    required this.followUpRecommendations,
    required this.bracingRecommendations, // Add this to constructor
  });
}

class RehabPhase {
  final String name;
  final String duration;
  final String goal;
  final List<RehabExercise> exercises;
  final List<String> criteria;
  final String? bracingGuidance; // Add this new field

  RehabPhase({
    required this.name,
    required this.duration,
    required this.goal,
    required this.exercises,
    required this.criteria,
    this.bracingGuidance, // Add this to constructor
  });
}

class RehabExercise {
  final String name;
  final String description;
  final String frequency;
  final String? imageUrl;

  RehabExercise({
    required this.name,
    required this.description,
    required this.frequency,
    this.imageUrl,
  });
}
