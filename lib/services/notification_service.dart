import 'package:flutter/material.dart';
import '../models/activity_model.dart';

/// A simplified mock notification service that logs notification events
/// but doesn't actually show notifications due to compatibility issues
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  final List<Map<String, dynamic>> _scheduledNotifications = [];
  
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    debugPrint('🔔 Mock Notification Service initialized');
    _isInitialized = true;
  }
  
  Future<void> requestPermissions() async {
    if (!_isInitialized) await initialize();
    debugPrint('🔔 Mock Notification permissions requested (always granted)');
  }
  
  Future<void> scheduleActivityReminder(Activity activity, int minutesBefore) async {
    if (!_isInitialized) await initialize();
    
    // Calculate notification time
    final scheduledTime = activity.date.subtract(Duration(minutes: minutesBefore));
    
    // Skip if the scheduled time is in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('🔔 Skipping notification for ${activity.name}: scheduled time is in the past');
      return;
    }
    
    // Store notification details
    final notificationId = activity.id.hashCode;
    final notificationInfo = {
      'id': notificationId,
      'title': '${activity.name} Reminder',
      'body': _createNotificationBody(activity, minutesBefore),
      'activityId': activity.id,
      'scheduledTime': scheduledTime,
    };
    
    // Remove existing notification with same ID
    _scheduledNotifications.removeWhere((n) => n['id'] == notificationId);
    
    // Add new notification
    _scheduledNotifications.add(notificationInfo);
    
    debugPrint('🔔 Mock notification scheduled:');
    debugPrint('   Title: ${notificationInfo['title']}');
    debugPrint('   Body: ${notificationInfo['body']}');
    debugPrint('   Time: ${notificationInfo['scheduledTime']}');
  }
  
  String _createNotificationBody(Activity activity, int minutesBefore) {
    String body = 'Reminder for ${activity.type} in ${minutesBefore} minutes';
    
    if (activity.location != null && activity.location!.isNotEmpty) {
      body += ' at ${activity.location}';
    }
    
    return body;
  }
  
  Future<void> cancelActivityReminder(String activityId) async {
    if (!_isInitialized) await initialize();
    
    final notificationId = activityId.hashCode;
    final initialCount = _scheduledNotifications.length;
    
    _scheduledNotifications.removeWhere((n) => n['id'] == notificationId);
    
    final removedCount = initialCount - _scheduledNotifications.length;
    
    debugPrint('🔔 Canceled $removedCount notification(s) for activity ID: $activityId');
  }
  
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    
    final count = _scheduledNotifications.length;
    _scheduledNotifications.clear();
    
    debugPrint('🔔 Canceled all $count notifications');
  }
  
  // For debugging - get all scheduled notifications
  List<Map<String, dynamic>> get scheduledNotifications => List.unmodifiable(_scheduledNotifications);
} 