import 'package:sri_lanka_sports_app/models/chatbot_model.dart';
import 'package:sri_lanka_sports_app/services/chatbot_service.dart';

class ChatbotRepository {
  final ChatbotService _chatbotService = ChatbotService();

  // Send message to chatbot
  Future<ChatMessage> sendMessage(String sessionId, String message) async {
    return await _chatbotService.sendMessage(sessionId, message);
  }

  // Get chat session
  Future<ChatSession?> getChatSession(String sessionId) async {
    return await _chatbotService.getChatSession(sessionId);
  }

  // Get user's chat sessions
  Future<List<ChatSession>> getUserChatSessions() async {
    return await _chatbotService.getUserChatSessions();
  }

  // Create new chat session
  Future<String> createChatSession() async {
    return await _chatbotService.createChatSession();
  }

  // Delete chat session
  Future<void> deleteChatSession(String sessionId) async {
    await _chatbotService.deleteChatSession(sessionId);
  }

  // Update session topic
  Future<void> updateSessionTopic(String sessionId, String topic) async {
    await _chatbotService.updateSessionTopic(sessionId, topic);
  }
}
