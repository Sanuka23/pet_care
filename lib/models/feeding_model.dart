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