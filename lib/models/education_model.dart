class EducationModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'technique' or 'science'
  final String? sport;
  final String? level; // For techniques: 'beginner', 'intermediate', 'advanced'
  final String? category; // For science: 'physics', 'biology', 'nutrition', etc.
  final String? imageUrl;
  final List<String>? tags;
  final String? content; // Detailed content in HTML or markdown format
  final List<StepModel>? steps; // For techniques
  final String? videoUrl;
  final String? author;
  final DateTime? publishDate;

  EducationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.sport,
    this.level,
    this.category,
    this.imageUrl,
    this.tags,
    this.content,
    this.steps,
    this.videoUrl,
    this.author,
    this.publishDate,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      sport: json['sport'],
      level: json['level'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      content: json['content'],
      steps: json['steps'] != null
          ? (json['steps'] as List).map((step) => StepModel.fromJson(step)).toList()
          : null,
      videoUrl: json['videoUrl'],
      author: json['author'],
      publishDate: json['publishDate'] != null
          ? DateTime.parse(json['publishDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'sport': sport,
      'level': level,
      'category': category,
      'imageUrl': imageUrl,
      'tags': tags,
      'content': content,
      'steps': steps?.map((step) => step.toJson()).toList(),
      'videoUrl': videoUrl,
      'author': author,
      'publishDate': publishDate?.toIso8601String(),
    };
  }
}

class StepModel {
  final int number;
  final String title;
  final String description;
  final String? imageUrl;

  StepModel({
    required this.number,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      number: json['number'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
