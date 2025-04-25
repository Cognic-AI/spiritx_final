import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionnaireAnswer {
  final String question;
  final String answer;
  final int score;
  final String category;

  QuestionnaireAnswer({
    required this.question,
    required this.answer,
    required this.score,
    required this.category,
  });

  factory QuestionnaireAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionnaireAnswer(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      score: json['score'] ?? 0,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'score': score,
      'category': category,
    };
  }
}

class ProgressEntry {
  final String id;
  final String userId;
  final DateTime date;
  final double physicalScore;
  final double technicalScore;
  final double mentalScore;
  final double nutritionScore;
  final double overallScore;
  final String notes;
  final List<QuestionnaireAnswer> answers;

  ProgressEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.physicalScore,
    required this.technicalScore,
    required this.mentalScore,
    required this.nutritionScore,
    required this.overallScore,
    required this.notes,
    required this.answers,
  });

  factory ProgressEntry.fromJson(Map<String, dynamic> json) {
    return ProgressEntry(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: json['date'] != null 
          ? (json['date'] as Timestamp).toDate() 
          : DateTime.now(),
      physicalScore: (json['physicalScore'] ?? 0.0).toDouble(),
      technicalScore: (json['technicalScore'] ?? 0.0).toDouble(),
      mentalScore: (json['mentalScore'] ?? 0.0).toDouble(),
      nutritionScore: (json['nutritionScore'] ?? 0.0).toDouble(),
      overallScore: (json['overallScore'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
      answers: json['answers'] != null 
          ? List<QuestionnaireAnswer>.from(
              (json['answers'] as List).map(
                (answer) => QuestionnaireAnswer.fromJson(answer),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'physicalScore': physicalScore,
      'technicalScore': technicalScore,
      'mentalScore': mentalScore,
      'nutritionScore': nutritionScore,
      'overallScore': overallScore,
      'notes': notes,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }

  ProgressEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? physicalScore,
    double? technicalScore,
    double? mentalScore,
    double? nutritionScore,
    double? overallScore,
    String? notes,
    List<QuestionnaireAnswer>? answers,
  }) {
    return ProgressEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      physicalScore: physicalScore ?? this.physicalScore,
      technicalScore: technicalScore ?? this.technicalScore,
      mentalScore: mentalScore ?? this.mentalScore,
      nutritionScore: nutritionScore ?? this.nutritionScore,
      overallScore: overallScore ?? this.overallScore,
      notes: notes ?? this.notes,
      answers: answers ?? this.answers,
    );
  }
}
