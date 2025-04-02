class Activity {
  final String id;
  final String type; // e.g., walk, play, training
  final DateTime date;
  final int durationMinutes;
  final String? notes;

  Activity({
    required this.id,
    required this.type,
    required this.date,
    required this.durationMinutes,
    this.notes,
  });
} 