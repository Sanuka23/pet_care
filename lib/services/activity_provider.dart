import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import '../models/activity_model.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ActivityProvider with ChangeNotifier {
  List<Activity> _activities = [];
  late NotificationService _notificationService;
  final activityTypes = [
    'Walk',
    'Play',
    'Training',
    'Grooming',
    'Other'
  ];
  
  ActivityProvider() {
    _notificationService = NotificationService();
  }
  
  // Generate a random ID (replaces UUID)
  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Getters
  List<Activity> get activities => _activities;

  // Get activities for a specific pet
  List<Activity> getActivitiesForPet(String petId) {
    return _activities.where((activity) => activity.petId == petId).toList();
  }

  // Get upcoming activities for a specific pet
  List<Activity> getUpcomingActivitiesForPet(String petId) {
    final now = DateTime.now();
    return _activities.where((activity) => 
      activity.petId == petId && 
      activity.date.isAfter(now) &&
      !activity.isCompleted
    ).toList();
  }

  // Get activities by type for a specific pet
  List<Activity> getActivitiesByTypeForPet(String petId, String type) {
    return _activities.where((activity) => 
      activity.petId == petId && 
      activity.type == type
    ).toList();
  }

  // Get recent activities (last 30 days) for a specific pet
  List<Activity> getRecentActivitiesForPet(String petId, {int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _activities.where((activity) => 
      activity.petId == petId && 
      activity.date.isAfter(cutoffDate)
    ).toList();
  }

  // Add a new activity
  Future<void> addActivity(Activity activity, {int? reminderMinutesBefore}) async {
    // Generate ID if not provided
    final activityWithId = activity.id.isEmpty 
        ? activity.copyWith(id: _generateRandomId()) 
        : activity;
        
    _activities.add(activityWithId);
    
    // Schedule notification for this activity if reminder is enabled
    if (reminderMinutesBefore != null && !activityWithId.isCompleted) {
      await _scheduleNotification(activityWithId, reminderMinutesBefore);
    }
    
    // For testing, we'll skip saving to storage
    // await _saveActivities();
    notifyListeners();
  }

  // Update an existing activity
  Future<void> updateActivity(Activity activity, {int? reminderMinutesBefore}) async {
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index >= 0) {
      _activities[index] = activity;
      
      // Update notification for this activity
      await _updateNotification(activity, reminderMinutesBefore);
      
      // For testing, we'll skip saving to storage
      // await _saveActivities();
      notifyListeners();
    }
  }

  // Delete an activity
  Future<void> deleteActivity(String id) async {
    _activities.removeWhere((a) => a.id == id);
    
    // Cancel notification for this activity
    await _cancelNotification(id);
    
    // For testing, we'll skip saving to storage
    // await _saveActivities();
    notifyListeners();
  }

  // Mark activity as completed
  Future<void> markActivityAsCompleted(String id) async {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _activities[index] = _activities[index].copyWith(isCompleted: true);
      
      // Cancel notification as activity is completed
      await _cancelNotification(id);
      
      // For testing, we'll skip saving to storage
      // await _saveActivities();
      notifyListeners();
    }
  }

  // Add photo to activity
  Future<void> addPhotoToActivity(String id, String photoPath) async {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index >= 0) {
      final currentPhotos = _activities[index].photos ?? [];
      final updatedPhotos = List<String>.from(currentPhotos)..add(photoPath);
      
      _activities[index] = _activities[index].copyWith(photos: updatedPhotos);
      // For testing, we'll skip saving to storage
      // await _saveActivities();
      notifyListeners();
    }
  }
  
  // Schedule a notification for an activity
  Future<void> _scheduleNotification(Activity activity, int minutesBefore) async {
    try {
      await _notificationService.scheduleActivityReminder(activity, minutesBefore);
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }
  
  // Update a scheduled notification
  Future<void> _updateNotification(Activity activity, int? minutesBefore) async {
    // First cancel existing notification
    await _cancelNotification(activity.id);
    
    // Then schedule a new one if needed and activity is not completed
    if (minutesBefore != null && !activity.isCompleted) {
      await _scheduleNotification(activity, minutesBefore);
    }
  }
  
  // Cancel a scheduled notification
  Future<void> _cancelNotification(String activityId) async {
    try {
      await _notificationService.cancelActivityReminder(activityId);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  // Load activities from storage
  Future<void> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getStringList('activities') ?? [];
    
    if (activitiesJson.isNotEmpty) {
      _activities = activitiesJson
          .map((json) => Activity.fromJson(jsonDecode(json)))
          .toList();
    } else {
      // Add sample activities if none exist
      _addSampleActivities();
    }
    
    notifyListeners();
  }

  void _addSampleActivities() {
    final now = DateTime.now();
    
    // Sample activity for today (walking)
    final todayWalk = Activity(
      id: '1',
      petId: '1', // Buddy's ID
      name: 'Evening Walk',
      type: 'Walk',
      date: DateTime(now.year, now.month, now.day, 18, 30),
      durationMinutes: 30,
      notes: 'Regular evening walk in the park',
      isReminder: true,
      isCompleted: false,
    );
    
    // Sample activity for tomorrow (training)
    final tomorrowTraining = Activity(
      id: '2',
      petId: '1', // Buddy's ID
      name: 'Basic Commands Training',
      type: 'Training',
      date: DateTime(now.year, now.month, now.day + 1, 10, 0),
      durationMinutes: 20,
      notes: 'Practice sit, stay, and fetch commands',
      isReminder: true,
      isCompleted: false,
    );
    
    // Sample activity for 2 days later (grooming)
    final groomingDay = Activity(
      id: '3',
      petId: '1', // Buddy's ID
      name: 'Bath Time',
      type: 'Grooming',
      date: DateTime(now.year, now.month, now.day + 2, 14, 0),
      durationMinutes: 45,
      notes: 'Monthly bath and nail trimming',
      isReminder: true,
      isCompleted: false,
    );
    
    // Sample completed activity (yesterday)
    final yesterdayActivity = Activity(
      id: '4',
      petId: '1', // Buddy's ID
      name: 'Morning Walk',
      type: 'Walk',
      date: DateTime(now.year, now.month, now.day - 1, 8, 0),
      durationMinutes: 25,
      notes: 'Quick morning walk around the block',
      isReminder: false,
      isCompleted: true,
    );
    
    // Sample activity for cat
    final catPlayTime = Activity(
      id: '5',
      petId: '2', // Whiskers' ID
      name: 'Play Time',
      type: 'Play',
      date: DateTime(now.year, now.month, now.day, 17, 0),
      durationMinutes: 15,
      notes: 'Play with new toys',
      isReminder: true,
      isCompleted: false,
    );
    
    _activities.addAll([
      todayWalk,
      tomorrowTraining,
      groomingDay,
      yesterdayActivity,
      catPlayTime,
    ]);
    
    _saveActivities();
  }

  // Save activities to storage
  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = _activities.map((activity) => 
      jsonEncode(activity.toJson())
    ).toList();
    await prefs.setStringList('activities', activitiesJson);
  }
} 