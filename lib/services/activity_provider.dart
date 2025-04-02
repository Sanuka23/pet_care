import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/activity_model.dart';

class ActivityProvider with ChangeNotifier {
  List<Activity> _activities = [];
  final Uuid _uuid = const Uuid();

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
  Future<void> addActivity(Activity activity) async {
    // Generate ID if not provided
    final activityWithId = activity.id.isEmpty 
        ? activity.copyWith(id: _uuid.v4()) 
        : activity;
        
    _activities.add(activityWithId);
    // For testing, we'll skip saving to storage
    // await _saveActivities();
    notifyListeners();
  }

  // Update an existing activity
  Future<void> updateActivity(Activity activity) async {
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index >= 0) {
      _activities[index] = activity;
      // For testing, we'll skip saving to storage
      // await _saveActivities();
      notifyListeners();
    }
  }

  // Delete an activity
  Future<void> deleteActivity(String id) async {
    _activities.removeWhere((a) => a.id == id);
    // For testing, we'll skip saving to storage
    // await _saveActivities();
    notifyListeners();
  }

  // Mark activity as completed
  Future<void> markActivityAsCompleted(String id) async {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _activities[index] = _activities[index].copyWith(isCompleted: true);
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

  // Load activities from storage
  Future<void> loadActivities() async {
    // For testing, we'll add some mock data instead of loading from storage
    if (_activities.isEmpty) {
      final now = DateTime.now();
      
      // Mock activity types
      final activityTypes = [
        'Walk',
        'Play',
        'Training',
        'Grooming',
        'Socialization',
        'Dog Park'
      ];
      
      // Add some mock activities for two pets
      _activities = [
        Activity(
          id: 'act1',
          petId: '1',
          name: 'Morning Walk',
          type: 'Walk',
          date: DateTime(now.year, now.month, now.day, 8, 0),
          durationMinutes: 30,
          location: 'Neighborhood Park',
        ),
        Activity(
          id: 'act2',
          petId: '1',
          name: 'Training Session',
          type: 'Training',
          date: DateTime(now.year, now.month, now.day, 15, 0),
          durationMinutes: 20,
          notes: 'Focus on sit, stay, and recall commands',
        ),
        Activity(
          id: 'act3',
          petId: '2',
          name: 'Dog Park Meetup',
          type: 'Socialization',
          date: DateTime(now.year, now.month, now.day + 1, 10, 0),
          durationMinutes: 60,
          location: 'Central Dog Park',
          notes: 'Meeting with the dog group',
        ),
        Activity(
          id: 'act4',
          petId: '1',
          name: 'Evening Walk',
          type: 'Walk',
          date: DateTime(now.year, now.month, now.day - 1, 19, 0),
          durationMinutes: 45,
          location: 'River Trail',
          isCompleted: true,
        ),
      ];
      
      notifyListeners();
    }
  }

  // Save activities to storage
  Future<void> _saveActivities() async {
    // For testing, we'll skip saving to storage
    debugPrint('Saving activities data (skipped for testing)');
  }
} 