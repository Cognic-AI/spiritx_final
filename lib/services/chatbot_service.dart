import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sri_lanka_sports_app/models/chatbot_model.dart';

class ChatbotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // URL for the chatbot API
  final String _chatbotApiUrl = 'https://your-chatbot-api-endpoint.com/chat';

  // Send message to chatbot
  Future<ChatMessage> sendMessage(String sessionId, String message) async {
    try {
      // Create user message
      ChatMessage userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      // Save user message to Firestore
      await _saveMessage(sessionId, userMessage);

      // Call chatbot API to get response
      final response = await http.post(
        Uri.parse(_chatbotApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'sessionId': sessionId,
          'userId': _auth.currentUser?.uid,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['response'] != null) {
          // Create bot message
          ChatMessage botMessage = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: data['response'],
            isUser: false,
            timestamp: DateTime.now(),
          );

          // Save bot message to Firestore
          await _saveMessage(sessionId, botMessage);

          return botMessage;
        }
      }

      // If API call fails or returns invalid data, use fallback response
      return await _getFallbackResponse(message);
    } catch (e) {
      print('Error sending message to chatbot: $e');

      // Use fallback response in case of error
      return await _getFallbackResponse(message);
    }
  }

  // Save message to Firestore
  Future<void> _saveMessage(String sessionId, ChatMessage message) async {
    try {
      // Check if session exists
      DocumentSnapshot sessionDoc =
          await _firestore.collection('chat_sessions').doc(sessionId).get();

      if (sessionDoc.exists) {
        // Update existing session
        await _firestore.collection('chat_sessions').doc(sessionId).update({
          'messages': FieldValue.arrayUnion([message.toJson()]),
          'lastUpdatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        // Create new session
        await _firestore.collection('chat_sessions').doc(sessionId).set({
          'id': sessionId,
          'userId': _auth.currentUser?.uid,
          'messages': [message.toJson()],
          'createdAt': DateTime.now().toIso8601String(),
          'lastUpdatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error saving message: $e');
      // Continue even if saving fails
    }
  }

  // Update session topic
  Future<void> updateSessionTopic(String sessionId, String topic) async {
    try {
      await _firestore.collection('chat_sessions').doc(sessionId).update({
        'topic': topic,
      });
    } catch (e) {
      print('Error updating session topic: $e');
    }
  }

  // Get fallback response
  Future<ChatMessage> _getFallbackResponse(String message) async {
    try {
      // Simple keyword-based fallback responses
      String response = '';

      message = message.toLowerCase();

      if (message.contains('cricket')) {
        response =
            'Cricket is the most popular sport in Sri Lanka. The Sri Lanka national cricket team won the Cricket World Cup in 1996, and has been a force in international cricket since then.';
      } else if (message.contains('football') || message.contains('soccer')) {
        response =
            'Football is growing in popularity in Sri Lanka. The Sri Lanka national football team competes in tournaments like the South Asian Football Federation Cup.';
      } else if (message.contains('training') || message.contains('practice')) {
        response =
            'Regular training is essential for sports development. I recommend at least 3-4 training sessions per week, with a mix of skill practice, strength training, and cardio exercises.';
      } else if (message.contains('nutrition') || message.contains('diet')) {
        response =
            'Proper nutrition is crucial for athletes. Focus on a balanced diet with adequate protein for muscle recovery, complex carbohydrates for energy, and plenty of fruits and vegetables for vitamins and minerals.';
      } else if (message.contains('injury') || message.contains('pain')) {
        response =
            'If you\'re experiencing pain or injury, it\'s important to rest and seek professional medical advice. RICE (Rest, Ice, Compression, Elevation) is a good first aid approach for many sports injuries.';
      } else {
        response =
            'Thank you for your question about sports. Is there something specific about training, nutrition, or a particular sport you\'d like to know more about?';
      }

      // Create bot message
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Error getting fallback response: $e');

      // Return generic response if all else fails
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            'I apologize, but I\'m having trouble processing your request right now. Please try again later.',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }

  // Get chat session
  Future<ChatSession?> getChatSession(String sessionId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('chat_sessions').doc(sessionId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ChatSession.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Error getting chat session: $e');
      return null;
    }
  }

  // Get user's chat sessions
  Future<List<ChatSession>> getUserChatSessions() async {
    try {
      if (_auth.currentUser == null) {
        return [];
      }

      QuerySnapshot snapshot = await _firestore
          .collection('chat_sessions')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('lastUpdatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ChatSession.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting user chat sessions: $e');
      return [];
    }
  }

  // Create new chat session
  Future<String> createChatSession() async {
    try {
      // Generate session ID
      String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create welcome message
      ChatMessage welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Hello! I\'m your Sports Assistant. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Create session
      await _firestore.collection('chat_sessions').doc(sessionId).set({
        'id': sessionId,
        'userId': _auth.currentUser?.uid,
        'messages': [welcomeMessage.toJson()],
        'createdAt': DateTime.now().toIso8601String(),
        'lastUpdatedAt': DateTime.now().toIso8601String(),
        'topic': 'New Conversation',
      });

      return sessionId;
    } catch (e) {
      print('Error creating chat session: $e');
      rethrow;
    }
  }

  // Delete chat session
  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _firestore.collection('chat_sessions').doc(sessionId).delete();
    } catch (e) {
      print('Error deleting chat session: $e');
      rethrow;
    }
  }
}
