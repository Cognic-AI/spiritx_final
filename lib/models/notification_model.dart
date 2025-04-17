class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'fundraising', 'match', 'training', 'donation', 'workshop', etc.
  final bool isRead;
  final DateTime timestamp;
  final String? imageUrl;
  final String? actionUrl; // URL to open when notification is tapped
  final Map<String, dynamic>? additionalData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.timestamp,
    this.imageUrl,
    this.actionUrl,
    this.additionalData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is DateTime
              ? json['timestamp']
              : DateTime.parse(json['timestamp']))
          : DateTime.now(),
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'additionalData': additionalData,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? timestamp,
    String? imageUrl,
    String? actionUrl,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
