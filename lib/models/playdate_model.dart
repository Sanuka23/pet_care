import 'package:uuid/uuid.dart';

class Playdate {
  final String id;
  final String petId;
  final String title;
  final DateTime date;
  final String location;
  final int durationMinutes;
  final List<String> participants; // List of pet names or IDs
  final String? contactInfo;
  final String? notes;
  final bool isConfirmed;
  final List<String>? photos;

  Playdate({
    required this.id,
    required this.petId,
    required this.title,
    required this.date,
    required this.location,
    required this.durationMinutes,
    required this.participants,
    this.contactInfo,
    this.notes,
    this.isConfirmed = false,
    this.photos,
  });

  // Create a copy with modifications
  Playdate copyWith({
    String? id,
    String? petId,
    String? title,
    DateTime? date,
    String? location,
    int? durationMinutes,
    List<String>? participants,
    String? contactInfo,
    String? notes,
    bool? isConfirmed,
    List<String>? photos,
  }) {
    return Playdate(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      participants: participants ?? this.participants,
      contactInfo: contactInfo ?? this.contactInfo,
      notes: notes ?? this.notes,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      photos: photos ?? this.photos,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'location': location,
      'durationMinutes': durationMinutes,
      'participants': participants,
      'contactInfo': contactInfo,
      'notes': notes,
      'isConfirmed': isConfirmed,
      'photos': photos,
    };
  }

  // Create from JSON
  factory Playdate.fromJson(Map<String, dynamic> json) {
    return Playdate(
      id: json['id'],
      petId: json['petId'],
      title: json['title'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      location: json['location'],
      durationMinutes: json['durationMinutes'],
      participants: List<String>.from(json['participants']),
      contactInfo: json['contactInfo'],
      notes: json['notes'],
      isConfirmed: json['isConfirmed'] ?? false,
      photos: json['photos'] != null 
          ? List<String>.from(json['photos']) 
          : null,
    );
  }
} 