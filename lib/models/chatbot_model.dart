class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is DateTime
              ? json['timestamp']
              : DateTime.parse(json['timestamp']))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ChatSession {
  final String id;
  final String userId;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final String? topic;

  ChatSession({
    required this.id,
    required this.userId,
    required this.messages,
    required this.createdAt,
    this.lastUpdatedAt,
    this.topic,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((message) => ChatMessage.fromJson(message))
              .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.parse(json['createdAt']))
          : DateTime.now(),
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? (json['lastUpdatedAt'] is DateTime
              ? json['lastUpdatedAt']
              : DateTime.parse(json['lastUpdatedAt']))
          : null,
      topic: json['topic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages.map((message) => message.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'topic': topic,
    };
  }

  ChatSession copyWith({
    String? id,
    String? userId,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    String? topic,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      topic: topic ?? this.topic,
    );
  }
}
