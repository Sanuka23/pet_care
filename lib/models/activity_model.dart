import 'package:uuid/uuid.dart';

class Activity {
  final String id;
  final String petId;
  final String name;
  final String type;
  final DateTime date;
  final int durationMinutes;
  final String? location;
  final String? notes;
  final bool isCompleted;
  final List<String>? photos;

  Activity({
    required this.id,
    required this.petId,
    required this.name,
    required this.type,
    required this.date,
    required this.durationMinutes,
    this.location,
    this.notes,
    this.isCompleted = false,
    this.photos,
  });

  // Create a copy with modifications
  Activity copyWith({
    String? id,
    String? petId,
    String? name,
    String? type,
    DateTime? date,
    int? durationMinutes,
    String? location,
    String? notes,
    bool? isCompleted,
    List<String>? photos,
  }) {
    return Activity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      photos: photos ?? this.photos,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'type': type,
      'date': date.millisecondsSinceEpoch,
      'durationMinutes': durationMinutes,
      'location': location,
      'notes': notes,
      'isCompleted': isCompleted,
      'photos': photos,
    };
  }

  // Create from JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      petId: json['petId'],
      name: json['name'],
      type: json['type'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      durationMinutes: json['durationMinutes'],
      location: json['location'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
      photos: json['photos'] != null 
          ? List<String>.from(json['photos']) 
          : null,
    );
  }
} 