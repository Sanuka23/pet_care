import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/feeding_model.dart';

class FeedingProvider with ChangeNotifier {
  List<FeedingSchedule> _schedules = [];
  List<FeedingLog> _logs = [];
  final Uuid _uuid = const Uuid();

  // Getters
  List<FeedingSchedule> get schedules => _schedules;
  List<FeedingLog> get logs => _logs;

  // Get schedules for a specific pet
  List<FeedingSchedule> getSchedulesForPet(String petId) {
    return _schedules.where((schedule) => schedule.petId == petId).toList();
  }

  // Get active schedules for a specific pet
  List<FeedingSchedule> getActiveSchedulesForPet(String petId) {
    return _schedules.where((schedule) => 
      schedule.petId == petId && schedule.isActive
    ).toList();
  }

  // Get logs for a specific pet
  List<FeedingLog> getLogsForPet(String petId) {
    return _logs.where((log) => log.petId == petId).toList();
  }

  // Get logs for a specific schedule
  List<FeedingLog> getLogsForSchedule(String scheduleId) {
    return _logs.where((log) => log.scheduleId == scheduleId).toList();
  }

  // Get recent logs (last 30 days) for a specific pet
  List<FeedingLog> getRecentLogsForPet(String petId, {int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _logs.where((log) => 
      log.petId == petId && log.timestamp.isAfter(cutoffDate)
    ).toList();
  }

  // Get logs for today for a specific pet
  List<FeedingLog> getTodayLogsForPet(String petId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _logs.where((log) => 
      log.petId == petId && 
      log.timestamp.isAfter(today)
    ).toList();
  }

  // Add a new feeding schedule
  Future<void> addSchedule(FeedingSchedule schedule) async {
    // Generate ID if not provided
    final scheduleWithId = schedule.id.isEmpty 
        ? schedule.copyWith(id: _uuid.v4()) 
        : schedule;
        
    _schedules.add(scheduleWithId);
    // For testing, we'll skip saving to storage
    // await _saveData();
    notifyListeners();
  }

  // Update an existing feeding schedule
  Future<void> updateSchedule(FeedingSchedule schedule) async {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index >= 0) {
      _schedules[index] = schedule;
      // For testing, we'll skip saving to storage
      // await _saveData();
      notifyListeners();
    }
  }

  // Delete a feeding schedule
  Future<void> deleteSchedule(String id) async {
    _schedules.removeWhere((s) => s.id == id);
    // For testing, we'll skip saving to storage
    // await _saveData();
    notifyListeners();
  }

  // Toggle active state of a feeding schedule
  Future<void> toggleScheduleActive(String id) async {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index >= 0) {
      _schedules[index] = _schedules[index].copyWith(
        isActive: !_schedules[index].isActive,
      );
      // For testing, we'll skip saving to storage
      // await _saveData();
      notifyListeners();
    }
  }

  // Add a new feeding log entry
  Future<void> addLog(FeedingLog log) async {
    // Generate ID if not provided
    final logWithId = log.id.isEmpty 
        ? log.copyWith(id: _uuid.v4()) 
        : log;
        
    _logs.add(logWithId);
    // For testing, we'll skip saving to storage
    // await _saveData();
    notifyListeners();
  }

  // Delete a feeding log entry
  Future<void> deleteLog(String id) async {
    _logs.removeWhere((log) => log.id == id);
    // For testing, we'll skip saving to storage
    // await _saveData();
    notifyListeners();
  }

  // Load data from storage
  Future<void> loadData() async {
    // For testing, we'll add some mock data instead of loading from storage
    if (_schedules.isEmpty) {
      // Mock schedules
      _schedules = [
        FeedingSchedule(
          id: 'feed1',
          petId: '1',
          name: 'Morning Kibble',
          foodType: 'Dry Food',
          amount: 1.5,
          unit: 'cups',
          times: [FeedingTime(hour: 8, minute: 0)],
          notes: 'Mix with warm water',
        ),
        FeedingSchedule(
          id: 'feed2',
          petId: '1',
          name: 'Evening Meal',
          foodType: 'Wet Food',
          amount: 1.0,
          unit: 'cans',
          times: [FeedingTime(hour: 18, minute: 0)],
        ),
        FeedingSchedule(
          id: 'feed3',
          petId: '2',
          name: 'Three Meals',
          foodType: 'Premium Kibble',
          amount: 0.5,
          unit: 'cups',
          times: [
            FeedingTime(hour: 7, minute: 0),
            FeedingTime(hour: 13, minute: 0),
            FeedingTime(hour: 19, minute: 0),
          ],
        ),
      ];

      // Mock logs
      final now = DateTime.now();
      _logs = [
        FeedingLog(
          id: 'log1',
          scheduleId: 'feed1',
          petId: '1',
          timestamp: DateTime(now.year, now.month, now.day, 8, 5),
          amount: 1.5,
          unit: 'cups',
          foodType: 'Dry Food',
        ),
        FeedingLog(
          id: 'log2',
          scheduleId: 'feed2',
          petId: '1',
          timestamp: DateTime(now.year, now.month, now.day - 1, 18, 0),
          amount: 1.0,
          unit: 'cans',
          foodType: 'Wet Food',
          notes: 'Ate everything quickly',
        ),
        FeedingLog(
          id: 'log3',
          scheduleId: 'feed3',
          petId: '2',
          timestamp: DateTime(now.year, now.month, now.day - 1, 7, 0),
          amount: 0.5,
          unit: 'cups',
          foodType: 'Premium Kibble',
        ),
      ];
      
      notifyListeners();
    }
  }

  // Save data to storage
  Future<void> _saveData() async {
    // For testing, we'll skip saving to storage
    debugPrint('Saving feeding data (skipped for testing)');
  }
} 