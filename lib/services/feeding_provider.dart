import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/feeding_model.dart';

class FeedingProvider with ChangeNotifier {
  List<Feeding> _feedings = [];
  final Uuid _uuid = const Uuid();
  final bool _isTest;

  FeedingProvider({bool isTest = false}) : _isTest = isTest;

  List<Feeding> get feedings => _feedings;

  // Get feedings for a specific pet
  List<Feeding> getFeedingsForPet(String petId) {
    return _feedings.where((f) => f.petId == petId).toList();
  }

  // Get active feedings for a specific pet
  List<Feeding> getActiveFeedingsForPet(String petId) {
    return _feedings.where((f) => f.petId == petId && f.isActive).toList();
  }

  // Add a new feeding schedule
  Future<void> addFeeding(Feeding feeding) async {
    // Generate ID if not provided
    final feedingWithId = feeding.id.isEmpty 
        ? feeding.copyWith(id: _uuid.v4()) 
        : feeding;
        
    _feedings.add(feedingWithId);
    await _saveFeedings();
    notifyListeners();
  }

  // Update an existing feeding schedule
  Future<void> updateFeeding(Feeding feeding) async {
    final index = _feedings.indexWhere((f) => f.id == feeding.id);
    if (index >= 0) {
      _feedings[index] = feeding;
      await _saveFeedings();
      notifyListeners();
    }
  }

  // Delete a feeding schedule
  Future<void> deleteFeeding(String id) async {
    _feedings.removeWhere((f) => f.id == id);
    await _saveFeedings();
    notifyListeners();
  }

  // Toggle active status of a feeding schedule
  Future<void> toggleFeedingActive(String id) async {
    final index = _feedings.indexWhere((f) => f.id == id);
    if (index >= 0) {
      _feedings[index] = _feedings[index].copyWith(isActive: !_feedings[index].isActive);
      await _saveFeedings();
      notifyListeners();
    }
  }

  // Add a feeding record to a specific feeding schedule
  Future<void> addFeedingRecord(String feedingId, FeedingRecord record) async {
    final index = _feedings.indexWhere((f) => f.id == feedingId);
    if (index >= 0) {
      final feeding = _feedings[index];
      final updatedHistory = List<FeedingRecord>.from(feeding.feedingHistory)..add(record);
      _feedings[index] = feeding.copyWith(feedingHistory: updatedHistory);
      await _saveFeedings();
      notifyListeners();
    }
  }

  // Mark a feeding record as completed
  Future<void> completeFeedingRecord(String feedingId, String recordId) async {
    final feedingIndex = _feedings.indexWhere((f) => f.id == feedingId);
    if (feedingIndex >= 0) {
      final feeding = _feedings[feedingIndex];
      final recordIndex = feeding.feedingHistory.indexWhere((r) => r.id == recordId);
      
      if (recordIndex >= 0) {
        final updatedHistory = List<FeedingRecord>.from(feeding.feedingHistory);
        updatedHistory[recordIndex] = updatedHistory[recordIndex].copyWith(completed: true);
        _feedings[feedingIndex] = feeding.copyWith(feedingHistory: updatedHistory);
        await _saveFeedings();
        notifyListeners();
      }
    }
  }

  // Get today's feeding records for a pet
  List<FeedingRecord> getTodaysFeedingRecords(String petId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final records = <FeedingRecord>[];
    
    for (final feeding in getFeedingsForPet(petId)) {
      for (final record in feeding.feedingHistory) {
        if (record.timestamp.isAfter(startOfDay) && 
            record.timestamp.isBefore(endOfDay)) {
          records.add(record);
        }
      }
    }
    
    return records;
  }

  // Get upcoming feeding time for a pet
  DateTime? getNextFeedingTime(String petId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get all active feedings for this pet
    final activeFeedings = getActiveFeedingsForPet(petId);
    if (activeFeedings.isEmpty) return null;
    
    final feedingTimes = <DateTime>[];
    
    for (final feeding in activeFeedings) {
      for (final time in feeding.feedingTimes) {
        final feedingDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          time.hour,
          time.minute,
        );
        
        // If this feeding time is already past for today, add it for tomorrow
        if (feedingDateTime.isBefore(now)) {
          feedingTimes.add(feedingDateTime.add(const Duration(days: 1)));
        } else {
          feedingTimes.add(feedingDateTime);
        }
      }
    }
    
    if (feedingTimes.isEmpty) return null;
    
    // Sort by time (earliest first)
    feedingTimes.sort();
    return feedingTimes.first;
  }

  // Load feedings from local storage
  Future<void> loadFeedings() async {
    if (_isTest) {
      // Skip loading from storage in tests
      if (_feedings.isEmpty) {
        _addMockData();
      }
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedingsJson = prefs.getString('feedings');
      
      if (feedingsJson != null) {
        final List<dynamic> decoded = jsonDecode(feedingsJson);
        _feedings = decoded.map((f) => Feeding.fromJson(f)).toList();
        notifyListeners();
      } else {
        // For demo/first-time use, add some mock data
        if (_feedings.isEmpty) {
          _addMockData();
        }
      }
    } catch (e) {
      debugPrint('Error loading feedings: $e');
      if (_feedings.isEmpty) {
        _addMockData();
      }
    }
  }

  void _addMockData() {
    final mockFeeding = Feeding(
      id: _uuid.v4(),
      petId: '1', // Assuming pet with ID '1' exists
      foodName: 'Premium Dry Food',
      portionSize: '1 cup',
      frequency: FeedingFrequency.daily,
      feedingTimes: [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 18, minute: 0),
      ],
    );
    
    _feedings.add(mockFeeding);
    notifyListeners();
  }

  // Save feedings to local storage
  Future<void> _saveFeedings() async {
    if (_isTest) {
      // Skip saving to storage in tests
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedingsJson = jsonEncode(_feedings.map((f) => f.toJson()).toList());
      await prefs.setString('feedings', feedingsJson);
    } catch (e) {
      debugPrint('Error saving feedings: $e');
    }
  }
} 