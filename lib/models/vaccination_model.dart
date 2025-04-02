class Vaccination {
  final String id;
  final String name;
  final DateTime administeredDate;
  final DateTime nextDueDate;
  final bool isCompleted;

  Vaccination({
    required this.id,
    required this.name,
    required this.administeredDate,
    required this.nextDueDate,
    this.isCompleted = false,
  });
} 