class Vaccination {
  final String id;
  final String petId;
  final String name;
  final DateTime administeredDate;
  final DateTime nextDueDate;
  final String? veterinarian;
  final String? notes;
  final bool isCompleted;

  Vaccination({
    required this.id,
    required this.petId,
    required this.name,
    required this.administeredDate,
    required this.nextDueDate,
    this.veterinarian,
    this.notes,
    this.isCompleted = false,
  });

  // Create a copy of this Vaccination with modified fields
  Vaccination copyWith({
    String? id,
    String? petId,
    String? name,
    DateTime? administeredDate,
    DateTime? nextDueDate,
    String? veterinarian,
    String? notes,
    bool? isCompleted,
  }) {
    return Vaccination(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      administeredDate: administeredDate ?? this.administeredDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      veterinarian: veterinarian ?? this.veterinarian,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'administeredDate': administeredDate.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'veterinarian': veterinarian,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  // Create from JSON
  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'],
      petId: json['petId'],
      name: json['name'],
      administeredDate: DateTime.parse(json['administeredDate']),
      nextDueDate: DateTime.parse(json['nextDueDate']),
      veterinarian: json['veterinarian'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
} 