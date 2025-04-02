import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FeedingSchedule {
  final String id;
  final String petId;
  final String name;
  final String foodType;
  final double amount;
  final String unit;
  final List<FeedingTime> times;
  final String? notes;
  final bool isActive;

  FeedingSchedule({
    required this.id,
    required this.petId,
    required this.name,
    required this.foodType,
    required this.amount,
    required this.unit,
    required this.times,
    this.notes,
    this.isActive = true,
  });

  // Create a copy with modifications
  FeedingSchedule copyWith({
    String? id,
    String? petId,
    String? name,
    String? foodType,
    double? amount,
    String? unit,
    List<FeedingTime>? times,
    String? notes,
    bool? isActive,
  }) {
    return FeedingSchedule(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      foodType: foodType ?? this.foodType,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      times: times ?? this.times,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'foodType': foodType,
      'amount': amount,
      'unit': unit,
      'times': times.map((time) => '${time.hour}:${time.minute}').toList(),
      'notes': notes,
      'isActive': isActive,
    };
  }

  // Create from JSON
  factory FeedingSchedule.fromJson(Map<String, dynamic> json) {
    final timesList = (json['times'] as List<dynamic>).map((timeStr) {
      final parts = timeStr.split(':');
      return FeedingTime(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();

    return FeedingSchedule(
      id: json['id'],
      petId: json['petId'],
      name: json['name'],
      foodType: json['foodType'],
      amount: json['amount'],
      unit: json['unit'],
      times: timesList,
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
    );
  }
}

class FeedingLog {
  final String id;
  final String scheduleId;
  final String petId;
  final DateTime timestamp;
  final double amount;
  final String unit;
  final String foodType;
  final String? notes;

  FeedingLog({
    required this.id,
    required this.scheduleId,
    required this.petId,
    required this.timestamp,
    required this.amount,
    required this.unit,
    required this.foodType,
    this.notes,
  });

  // Create a copy with modifications
  FeedingLog copyWith({
    String? id,
    String? scheduleId,
    String? petId,
    DateTime? timestamp,
    double? amount,
    String? unit,
    String? foodType,
    String? notes,
  }) {
    return FeedingLog(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      petId: petId ?? this.petId,
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      foodType: foodType ?? this.foodType,
      notes: notes ?? this.notes,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'petId': petId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'amount': amount,
      'unit': unit,
      'foodType': foodType,
      'notes': notes,
    };
  }

  // Create from JSON
  factory FeedingLog.fromJson(Map<String, dynamic> json) {
    return FeedingLog(
      id: json['id'],
      scheduleId: json['scheduleId'],
      petId: json['petId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      amount: json['amount'],
      unit: json['unit'],
      foodType: json['foodType'],
      notes: json['notes'],
    );
  }
}

// Helper class to represent time of day for serialization
class FeedingTime {
  final int hour;
  final int minute;

  const FeedingTime({required this.hour, required this.minute});

  @override
  String toString() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
} 