import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'New Fund Raising Event',
      'message': 'A new fund raising event for young cricket players has been announced. Check it out!',
      'type': 'fundraising',
      'isRead': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'title': 'Upcoming Cricket Match',
      'message': 'Sri Lanka vs. India cricket match scheduled for next week. Don\'t miss it!',
      'type': 'match',
      'isRead': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '3',
      'title': 'New Training Program',
      'message': 'A new training program for aspiring athletes has been launched at the National Sports Complex.',
      'type': 'training',
      'isRead': false,
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': '4',
      'title': 'Sports Equipment Donation',
      'message': 'Sports equipment donation drive for underprivileged athletes. Contribute now!',
      'type': 'donation',
      'isRead': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': '5',
      'title': 'Sports Science Workshop',
      'message': 'Attend the upcoming sports science workshop to learn about the latest advancements in sports technology.',
      'type': 'workshop',
      'isRead': false,
      'timestamp': DateTime.now().subtract(const Duration(days: 4)),
    },
  ];

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((notification) => notification['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((notification) => notification['id'] == id);
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'fundraising':
        return Icons.volunteer_activism;
      case 'match':
        return Icons.sports;
      case 'training':
        return Icons.fitness_center;
      case 'donation':
        return Icons.card_giftcard;
      case 'workshop':
        return Icons.school;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'fundraising':
        return Colors.green;
      case 'match':
        return Colors.blue;
      case 'training':
        return Colors.orange;
      case 'donation':
        return Colors.purple;
      case 'workshop':
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification['isRead'] = true;
                }
              });
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Dismissible(
                  key: Key(notification['id']),
                  background: Container(
                    color: AppTheme.errorColor,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteNotification(notification['id']);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: InkWell(
                      onTap: () {
                        _markAsRead(notification['id']);
                        _showNotificationDetails(notification);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Notification icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getNotificationColor(notification['type']).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getNotificationIcon(notification['type']),
                                color: _getNotificationColor(notification['type']),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Notification content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification['title'],
                                          style: TextStyle(
                                            fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (!notification['isRead'])
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification['message'],
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatTimestamp(notification['timestamp']),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any notifications yet',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification['type']).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification['type']),
                      color: _getNotificationColor(notification['type']),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      notification['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _formatTimestamp(notification['timestamp']),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                notification['message'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
