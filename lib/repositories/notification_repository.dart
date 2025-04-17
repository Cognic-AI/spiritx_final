import 'package:sri_lanka_sports_app/models/notification_model.dart';
import 'package:sri_lanka_sports_app/services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService = NotificationService();
  
  // Get all notifications for current user
  Future<List<NotificationModel>> getAllNotifications() async {
    return await _notificationService.getAllNotifications();
  }
  
  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationService.markNotificationAsRead(notificationId);
  }
  
  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    await _notificationService.markAllNotificationsAsRead();
  }
  
  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
  }
  
  // Subscribe to notification topic
  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }
  
  // Unsubscribe from notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }
  
  // Get user's subscribed topics
  Future<List<String>> getSubscribedTopics() async {
    return await _notificationService.getSubscribedTopics();
  }
}
