class Playdate {
  final String id;
  final String title;
  final DateTime dateTime;
  final String location;
  final List<String> participants; // Names or IDs of other pets
  final String? notes;

  Playdate({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.participants,
    this.notes,
  });
} 