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
  final bool isReminder;
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
    this.isReminder = false,
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
    bool? isReminder,
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
      isReminder: isReminder ?? this.isReminder,
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
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'location': location,
      'notes': notes,
      'isCompleted': isCompleted,
      'isReminder': isReminder,
      'photos': photos,
    };
  }

  // Create from JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      petId: json['petId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isReminder: json['isReminder'] as bool? ?? false,
      photos: json['photos'] != null 
          ? List<String>.from(json['photos']) 
          : null,
    );
  }
} 