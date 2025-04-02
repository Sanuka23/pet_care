import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/activity_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
      
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize timezone
    tz_data.initializeTimeZones();
    
    // Initialize notification settings
    const AndroidInitializationSettings androidInitializationSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings iosInitializationSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
    
    _isInitialized = true;
  }
  
  // Request notification permissions
  Future<void> requestPermissions() async {
    if (!_isInitialized) await initialize();
    
    // iOS-specific
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
    // Android-specific (for Android 13+)
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }
  
  // Schedule a notification for an activity
  Future<void> scheduleActivityReminder(Activity activity, int minutesBefore) async {
    if (!_isInitialized) await initialize();
    
    // Calculate notification time (activity time - minutes before)
    final scheduledTime = tz.TZDateTime.from(
      activity.date.subtract(Duration(minutes: minutesBefore)),
      tz.local,
    );
    
    // Skip if the scheduled time is in the past
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('Skipping notification for ${activity.name}: scheduled time is in the past');
      return;
    }
    
    // Configure notification details
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'activity_reminders',
      'Activity Reminders',
      channelDescription: 'Notifications for pet activity reminders',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.blue,
      enableLights: true,
    );
    
    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    
    // Create notification title and body
    final String title = '${activity.name} Reminder';
    String body = 'Reminder for ${activity.type} in ${minutesBefore} minutes';
    
    if (activity.location != null && activity.location!.isNotEmpty) {
      body += ' at ${activity.location}';
    }
    
    // Schedule the notification
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      activity.id.hashCode, // Use activity ID hash as notification ID
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: activity.id, // Store activity ID in payload for handling taps
    );
    
    debugPrint('Scheduled notification for ${activity.name} at $scheduledTime');
  }
  
  // Cancel a notification for an activity
  Future<void> cancelActivityReminder(String activityId) async {
    if (!_isInitialized) await initialize();
    
    await _flutterLocalNotificationsPlugin.cancel(activityId.hashCode);
    debugPrint('Canceled notification for activity ID: $activityId');
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    
    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('Canceled all notifications');
  }
} 