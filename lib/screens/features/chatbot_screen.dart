import 'package:flutter/material.dart';
import 'package:sri_lanka_sports_app/models/chatbot_model.dart';
import 'package:sri_lanka_sports_app/repositories/chatbot_repository.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class ChatbotScreen extends StatefulWidget {
  final VoidCallback? onChatPageChanged;
  final Function(String)? onSessionSelected;
  final String? sessionId;

  const ChatbotScreen({
    super.key,
    this.sessionId,
    this.onChatPageChanged,
    this.onSessionSelected,
  });

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
  String _selectedLanguage = 'english';

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
      widget.onSessionSelected?.call(_sessionId);
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

  Future<void> _sendMessage(String language) async {
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
      // Send message to chatbot with selected language and get response
      final botMessage = await _chatbotRepository.sendMessage(
          _sessionId, userMessage, language);

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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.79,
      child: Column(
        children: [
          // Language Selector Dropdown
          DropdownButton<String>(
            value: _selectedLanguage,
            items: <String>['English', 'Sinhala', 'Tamil']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
              });
            },
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'new_chat',
                      child: ListTile(
                        leading: Icon(Icons.add_circle_outline),
                        title: Text('New Chat'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'history',
                      child: ListTile(
                        leading: Icon(Icons.history),
                        title: Text('Chat History'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'info',
                      child: ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('App Info'),
                      ),
                    ),
                  ],
                  onSelected: (String value) {
                    if (value == 'history') {
                      widget.onChatPageChanged?.call();
                    } else if (value == 'info') {
                      _showInfoDialog();
                    } else if (value == 'new_chat') {
                      _initChatSession();
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    controller: _messageController,
                    hintText: 'Ask me anything about sports...',
                    onSubmitted: (_) => _sendMessage(_selectedLanguage),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _sendMessage(_selectedLanguage),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
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
  final Function(String)? onSessionSelected;
  final Function(String)? onChatPageChanged;

  const ChatSessionsScreen(
      {super.key, this.onSessionSelected, this.onChatPageChanged});

  @override
  State<ChatSessionsScreen> createState() => _ChatSessionsScreenState();
}

class _ChatSessionsScreenState extends State<ChatSessionsScreen> {
  final ChatbotRepository _chatbotRepository = ChatbotRepository();

  bool _isLoading = true;
  List<ChatSession> _sessions = [];
  String? _errorMessage;
  String _sessionId = '';

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  Future<void> _initChatSession() async {
    try {
      // Create a new chat session
      _sessionId = await _chatbotRepository.createChatSession();

      // Get the welcome message
      final session = await _chatbotRepository.getChatSession(_sessionId);
      if (session != null) {
        setState(() {});
      } else {
        // Fallback welcome message if session creation failed
        setState(() {
          _sessionId = const Uuid().v4();
        });
      }
      widget.onSessionSelected?.call(_sessionId);
    } catch (e) {
      print('Error initializing chat session: $e');

      // Fallback welcome message if session creation failed
      setState(() {
        _sessionId = const Uuid().v4();
      });
    }
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
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
          ),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: _buildEmptyState(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                // Start new conversation logic
                _initChatSession();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Start New Conversation'),
            ),
          ),
          ..._sessions.map((session) {
            final topic = _getSessionTopic(session);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Dismissible(
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
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
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
                          onPressed: () => _deleteSession(session.id),
                          tooltip: 'Delete',
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      widget.onSessionSelected?.call(session.id);
                    },
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
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
