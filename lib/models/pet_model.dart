class Pet {
  final String id;
  final String name;
  final String breed;
  final int age;
  final double weight;
  final String? imageUrl;
  final List<String>? specialNeeds;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.weight,
    this.imageUrl,
    this.specialNeeds,
  });
} 