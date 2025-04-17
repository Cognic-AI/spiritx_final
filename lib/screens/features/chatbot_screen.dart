import 'package:flutter/material.dart';
import 'package:sri_lanka_sports_app/models/chatbot_model.dart';
import 'package:sri_lanka_sports_app/repositories/chatbot_repository.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class ChatbotScreen extends StatefulWidget {
  final String? sessionId;

  const ChatbotScreen({Key? key, this.sessionId}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ChatbotRepository _chatbotRepository = ChatbotRepository();

  bool _isTyping = false;
  String _sessionId = '';
  List<ChatMessage> _messages = [];
  String _sessionTopic = '';

  @override
  void initState() {
    super.initState();
    if (widget.sessionId != null) {
      _sessionId = widget.sessionId!;
      _loadExistingSession();
    } else {
      _initChatSession();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingSession() async {
    try {
      final session = await _chatbotRepository.getChatSession(_sessionId);
      if (session != null) {
        setState(() {
          _messages = session.messages;
          _sessionTopic =
              session.topic ?? _generateSessionTopic(session.messages);
        });
      } else {
        // Fallback if session not found
        _initChatSession();
      }
    } catch (e) {
      print('Error loading chat session: $e');
      _initChatSession();
    }
  }

  Future<void> _initChatSession() async {
    try {
      // Create a new chat session
      _sessionId = await _chatbotRepository.createChatSession();

      // Get the welcome message
      final session = await _chatbotRepository.getChatSession(_sessionId);
      if (session != null) {
        setState(() {
          _messages = session.messages;
          _sessionTopic = session.topic ?? 'New Conversation';
        });
      } else {
        // Fallback welcome message if session creation failed
        setState(() {
          _sessionId = const Uuid().v4();
          _messages = [
            ChatMessage(
              id: const Uuid().v4(),
              text:
                  'Hello! I\'m your Sports Assistant. How can I help you today?',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ];
          _sessionTopic = 'New Conversation';
        });
      }
    } catch (e) {
      print('Error initializing chat session: $e');

      // Fallback welcome message if session creation failed
      setState(() {
        _sessionId = const Uuid().v4();
        _messages = [
          ChatMessage(
            id: const Uuid().v4(),
            text:
                'Hello! I\'m your Sports Assistant. How can I help you today?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
        _sessionTopic = 'New Conversation';
      });
    }
  }

  String _generateSessionTopic(List<ChatMessage> messages) {
    // Find the first user message to use as a topic
    final userMessage = messages.firstWhere((msg) => msg.isUser,
        orElse: () => ChatMessage(
            id: '', text: '', isUser: true, timestamp: DateTime.now()));

    if (userMessage.text.isEmpty) {
      return 'New Conversation';
    }

    // Limit topic length
    String topic = userMessage.text;
    if (topic.length > 30) {
      topic = '${topic.substring(0, 27)}...';
    }

    return topic;
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Create user message
    final userChatMessage = ChatMessage(
      id: const Uuid().v4(),
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userChatMessage);
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      // Send message to chatbot and get response
      final botMessage =
          await _chatbotRepository.sendMessage(_sessionId, userMessage);

      // Update session topic if this is the first user message
      if (_sessionTopic == 'New Conversation' &&
          _messages.where((msg) => msg.isUser).length == 1) {
        final newTopic = _generateSessionTopic([userChatMessage]);
        await _chatbotRepository.updateSessionTopic(_sessionId, newTopic);
        setState(() {
          _sessionTopic = newTopic;
        });
      }

      setState(() {
        _messages.add(botMessage);
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');

      // Fallback response if API call fails
      setState(() {
        _messages.add(
          ChatMessage(
            id: const Uuid().v4(),
            text: 'Sorry, I encountered an error. Please try again later.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sports Assistant'),
            Text(
              _sessionTopic,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatSessionsScreen(),
                ),
              ).then((value) {
                // Refresh if we came back from selecting a session
                if (value == true) {
                  Navigator.pop(context);
                }
              });
            },
            tooltip: 'Chat History',
          ),
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

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

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
                message.text,
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

class ChatSessionsScreen extends StatefulWidget {
  const ChatSessionsScreen({Key? key}) : super(key: key);

  @override
  State<ChatSessionsScreen> createState() => _ChatSessionsScreenState();
}

class _ChatSessionsScreenState extends State<ChatSessionsScreen> {
  final ChatbotRepository _chatbotRepository = ChatbotRepository();

  bool _isLoading = true;
  List<ChatSession> _sessions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  Future<void> _loadChatSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sessions = await _chatbotRepository.getUserChatSessions();

      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chat sessions: $e');
      setState(() {
        _errorMessage = 'Failed to load chat sessions. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      await _chatbotRepository.deleteChatSession(sessionId);

      setState(() {
        _sessions.removeWhere((session) => session.id == sessionId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat session deleted'),
        ),
      );
    } catch (e) {
      print('Error deleting chat session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting chat session: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day/$month/$year';
    }
  }

  String _getSessionTopic(ChatSession session) {
    if (session.topic != null && session.topic!.isNotEmpty) {
      return session.topic!;
    }

    // Find the first user message to use as a topic
    final userMessages = session.messages.where((msg) => msg.isUser);
    if (userMessages.isNotEmpty) {
      String topic = userMessages.first.text;
      if (topic.length > 30) {
        topic = '${topic.substring(0, 27)}...';
      }
      return topic;
    }

    return 'New Conversation';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChatSessions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadChatSessions,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _sessions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final topic = _getSessionTopic(session);

                        return Dismissible(
                          key: Key(session.id),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Chat Session'),
                                  content: const Text(
                                      'Are you sure you want to delete this chat session?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            _deleteSession(session.id);
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor,
                                child: const Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                topic,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${session.messages.length} messages • ${_formatDate(session.lastUpdatedAt ?? session.createdAt)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteSession(session.id);
                                    },
                                    tooltip: 'Delete',
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChatbotScreen(sessionId: session.id),
                                  ),
                                ).then((_) {
                                  // Return true to indicate we selected a session
                                  Navigator.pop(context, true);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatbotScreen(),
            ),
          ).then((_) {
            Navigator.pop(context, true);
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'New Chat',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Chat History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new conversation with the Sports Assistant',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New Chat'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatbotScreen(),
                ),
              ).then((_) {
                Navigator.pop(context, true);
              });
            },
          ),
        ],
      ),
    );
  }
}
