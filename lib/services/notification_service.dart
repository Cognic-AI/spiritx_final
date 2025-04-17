import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sri_lanka_sports_app/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user notifications
  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      if (_auth.currentUser == null) {
        return [];
      }

      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NotificationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting user notifications: $e');
      return [];
    }
  }

  // Get global notifications
  Future<List<NotificationModel>> getGlobalNotifications() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('isGlobal', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NotificationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting global notifications: $e');
      return [];
    }
  }

  // Get all notifications for current user (both user-specific and global)
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      List<NotificationModel> userNotifications = await getUserNotifications();
      List<NotificationModel> globalNotifications =
          await getGlobalNotifications();

      print(userNotifications);
      print(globalNotifications);

      // Combine and sort by timestamp (newest first)
      List<NotificationModel> allNotifications = [
        ...userNotifications,
        ...globalNotifications
      ];
      allNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allNotifications;
    } catch (e) {
      print('Error getting all notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      if (_auth.currentUser == null) {
        return;
      }

      // Get all unread user notifications
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .where('isRead', isEqualTo: false)
          .get();

      // Update each notification
      for (var doc in snapshot.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Subscribe to notification topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      if (_auth.currentUser == null) {
        return;
      }

      await _firestore.collection('notification_subscriptions').add({
        'userId': _auth.currentUser!.uid,
        'topic': topic,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error subscribing to topic: $e');
      rethrow;
    }
  }

  // Unsubscribe from notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (_auth.currentUser == null) {
        return;
      }

      QuerySnapshot snapshot = await _firestore
          .collection('notification_subscriptions')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .where('topic', isEqualTo: topic)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error unsubscribing from topic: $e');
      rethrow;
    }
  }

  // Get user's subscribed topics
  Future<List<String>> getSubscribedTopics() async {
    try {
      if (_auth.currentUser == null) {
        return [];
      }

      QuerySnapshot snapshot = await _firestore
          .collection('notification_subscriptions')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['topic'] as String;
      }).toList();
    } catch (e) {
      print('Error getting subscribed topics: $e');
      return [];
    }
  }
}
