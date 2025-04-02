import 'package:flutter/material.dart';

class FeedingSchedule {
  final String id;
  final String foodType;
  final double amount;
  final String unit; // e.g., cups, grams
  final TimeOfDay time;
  final List<String> daysOfWeek; // e.g., ["Monday", "Wednesday", "Friday"]
  final bool isCompleted;

  FeedingSchedule({
    required this.id,
    required this.foodType,
    required this.amount,
    required this.unit,
    required this.time,
    required this.daysOfWeek,
    this.isCompleted = false,
  });
}

class Feeding {
  final String id;
  final String petId;
  final String foodName;
  final String portionSize;
  final FeedingFrequency frequency;
  final List<TimeOfDay> feedingTimes;
  final bool isActive;
  final List<FeedingRecord> feedingHistory;

  Feeding({
    required this.id,
    required this.petId,
    required this.foodName,
    required this.portionSize,
    required this.frequency,
    required this.feedingTimes,
    this.isActive = true,
    List<FeedingRecord>? feedingHistory,
  }) : feedingHistory = feedingHistory ?? [];

  // Create a copy of this feeding with modified fields
  Feeding copyWith({
    String? id,
    String? petId,
    String? foodName,
    String? portionSize,
    FeedingFrequency? frequency,
    List<TimeOfDay>? feedingTimes,
    bool? isActive,
    List<FeedingRecord>? feedingHistory,
  }) {
    return Feeding(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      foodName: foodName ?? this.foodName,
      portionSize: portionSize ?? this.portionSize,
      frequency: frequency ?? this.frequency,
      feedingTimes: feedingTimes ?? this.feedingTimes,
      isActive: isActive ?? this.isActive,
      feedingHistory: feedingHistory ?? this.feedingHistory,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'foodName': foodName,
      'portionSize': portionSize,
      'frequency': frequency.toString(),
      'feedingTimes': feedingTimes.map((time) => '${time.hour}:${time.minute}').toList(),
      'isActive': isActive,
      'feedingHistory': feedingHistory.map((record) => record.toJson()).toList(),
    };
  }

  // Create from JSON
  factory Feeding.fromJson(Map<String, dynamic> json) {
    return Feeding(
      id: json['id'],
      petId: json['petId'],
      foodName: json['foodName'],
      portionSize: json['portionSize'],
      frequency: _parseFrequency(json['frequency']),
      feedingTimes: _parseTimeOfDayList(json['feedingTimes']),
      isActive: json['isActive'] ?? true,
      feedingHistory: _parseFeedingHistory(json['feedingHistory']),
    );
  }

  static FeedingFrequency _parseFrequency(String frequency) {
    return FeedingFrequency.values.firstWhere(
      (f) => f.toString() == frequency,
      orElse: () => FeedingFrequency.daily,
    );
  }

  static List<TimeOfDay> _parseTimeOfDayList(List<dynamic> timeStrings) {
    return timeStrings.map((timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();
  }

  static List<FeedingRecord> _parseFeedingHistory(List<dynamic>? history) {
    if (history == null) return [];
    return history.map((item) => FeedingRecord.fromJson(item)).toList();
  }
}

// Enum to represent feeding frequency options
enum FeedingFrequency {
  daily,
  custom
}

// Class to represent a single feeding event
class FeedingRecord {
  final String id;
  final DateTime timestamp;
  final bool completed;
  final String? notes;

  FeedingRecord({
    required this.id,
    required this.timestamp,
    this.completed = false,
    this.notes,
  });

  FeedingRecord copyWith({
    String? id,
    DateTime? timestamp,
    bool? completed,
    String? notes,
  }) {
    return FeedingRecord(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'completed': completed,
      'notes': notes,
    };
  }

  factory FeedingRecord.fromJson(Map<String, dynamic> json) {
    return FeedingRecord(
      id: json['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      completed: json['completed'] ?? false,
      notes: json['notes'],
    );
  }
} 