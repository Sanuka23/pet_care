class Appointment {
  final String id;
  final String title;
  final DateTime dateTime;
  final String vetName;
  final String? notes;
  final bool isCompleted;

  Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.vetName,
    this.notes,
    this.isCompleted = false,
  });
} 