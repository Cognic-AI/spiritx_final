import 'package:flutter/material.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_text_field.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I\'m your Sports Assistant. How can I help you today?',
      'isUser': false,
      'timestamp': DateTime.now(),
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({
        'text': userMessage,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      // In a real app, this would be a call to your AI chatbot API
      // For demo purposes, we'll simulate a response
      await Future.delayed(const Duration(seconds: 1));

      // Simulated response based on user message
      String botResponse = '';

      if (userMessage.toLowerCase().contains('cricket')) {
        botResponse =
            'Cricket is the most popular sport in Sri Lanka. The Sri Lanka national cricket team won the Cricket World Cup in 1996, and has been a force in international cricket since then.';
      } else if (userMessage.toLowerCase().contains('football') ||
          userMessage.toLowerCase().contains('soccer')) {
        botResponse =
            'Football is growing in popularity in Sri Lanka. The Sri Lanka national football team competes in tournaments like the South Asian Football Federation Cup.';
      } else if (userMessage.toLowerCase().contains('training') ||
          userMessage.toLowerCase().contains('practice')) {
        botResponse =
            'Regular training is essential for sports development. I recommend at least 3-4 training sessions per week, with a mix of skill practice, strength training, and cardio exercises.';
      } else if (userMessage.toLowerCase().contains('nutrition') ||
          userMessage.toLowerCase().contains('diet')) {
        botResponse =
            'Proper nutrition is crucial for athletes. Focus on a balanced diet with adequate protein for muscle recovery, complex carbohydrates for energy, and plenty of fruits and vegetables for vitamins and minerals.';
      } else if (userMessage.toLowerCase().contains('injury') ||
          userMessage.toLowerCase().contains('pain')) {
        botResponse =
            'If you\'re experiencing pain or injury, it\'s important to rest and seek professional medical advice. RICE (Rest, Ice, Compression, Elevation) is a good first aid approach for many sports injuries.';
      } else {
        botResponse =
            'Thank you for your question about sports. Is there something specific about training, nutrition, or a particular sport you\'d like to know more about?';
      }

      setState(() {
        _messages.add({
          'text': botResponse,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          'text': 'Sorry, I encountered an error. Please try again later.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isTyping = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),

            // Typing indicator
            if (_isTyping)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

            // Message input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _messageController,
                      hintText: 'Ask me anything about sports...',
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(
                Icons.sports,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Text(
                message['text'] as String,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Sports Assistant'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This AI assistant is specialized in sports and health topics. You can ask questions about:',
              ),
              SizedBox(height: 16),
              Text('• Sports techniques and rules'),
              Text('• Training methods and programs'),
              Text('• Nutrition and supplements'),
              Text('• Injury prevention and recovery'),
              Text('• Sports equipment recommendations'),
              SizedBox(height: 16),
              Text(
                'The assistant is continuously learning to provide better answers to your questions.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
