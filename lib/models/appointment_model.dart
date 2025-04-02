class Appointment {
  final String id;
  final String title;
  final DateTime dateTime;
  final String vetName;
  final String vetLocation;
  final String petId;
  final String? notes;
  final bool isCompleted;

  Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.vetName,
    required this.vetLocation,
    required this.petId,
    this.notes,
    this.isCompleted = false,
  });

  // Create a copy of this appointment with modified fields
  Appointment copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? vetName,
    String? vetLocation,
    String? petId,
    String? notes,
    bool? isCompleted,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      vetName: vetName ?? this.vetName,
      vetLocation: vetLocation ?? this.vetLocation,
      petId: petId ?? this.petId,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'vetName': vetName,
      'vetLocation': vetLocation,
      'petId': petId,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  // Create from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      title: json['title'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dateTime']),
      vetName: json['vetName'],
      vetLocation: json['vetLocation'],
      petId: json['petId'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
} 