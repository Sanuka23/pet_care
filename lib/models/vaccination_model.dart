class Vaccination {
  final String id;
  final String name;
  final DateTime administeredDate;
  final DateTime nextDueDate;
  final String petId;
  final String? notes;
  final bool isCompleted;

  Vaccination({
    required this.id,
    required this.name,
    required this.administeredDate,
    required this.nextDueDate,
    required this.petId,
    this.notes,
    this.isCompleted = false,
  });

  // Create a copy of this vaccination with modified fields
  Vaccination copyWith({
    String? id,
    String? name,
    DateTime? administeredDate,
    DateTime? nextDueDate,
    String? petId,
    String? notes,
    bool? isCompleted,
  }) {
    return Vaccination(
      id: id ?? this.id,
      name: name ?? this.name,
      administeredDate: administeredDate ?? this.administeredDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      petId: petId ?? this.petId,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'administeredDate': administeredDate.millisecondsSinceEpoch,
      'nextDueDate': nextDueDate.millisecondsSinceEpoch,
      'petId': petId,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  // Create from JSON
  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'],
      name: json['name'],
      administeredDate: DateTime.fromMillisecondsSinceEpoch(json['administeredDate']),
      nextDueDate: DateTime.fromMillisecondsSinceEpoch(json['nextDueDate']),
      petId: json['petId'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
} 