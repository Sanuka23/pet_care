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

  // Convert Pet to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'weight': weight,
      'imageUrl': imageUrl,
      'specialNeeds': specialNeeds,
    };
  }

  // Create Pet from JSON
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String,
      age: json['age'] as int,
      weight: json['weight'] as double,
      imageUrl: json['imageUrl'] as String?,
      specialNeeds: json['specialNeeds'] != null
          ? List<String>.from(json['specialNeeds'] as List)
          : null,
    );
  }
} 