import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/pet_model.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];
  Pet? _currentPet;

  List<Pet> get pets => _pets;
  Pet? get currentPet => _currentPet;

  // Add a new pet or update existing pet
  void setPet(Pet pet) {
    final index = _pets.indexWhere((p) => p.id == pet.id);
    
    if (index >= 0) {
      // Update existing pet
      _pets[index] = pet;
    } else {
      // Add new pet
      _pets.add(pet);
    }
    
    // Set as current pet
    _currentPet = pet;
    
    // For testing, we'll skip saving to storage
    // _savePets();
    
    notifyListeners();
  }

  // Remove a pet
  void removePet(String petId) {
    _pets.removeWhere((p) => p.id == petId);
    
    // If current pet was removed, set current to first pet or null
    if (_currentPet != null && _currentPet!.id == petId) {
      _currentPet = _pets.isNotEmpty ? _pets[0] : null;
    }
    
    // For testing, we'll skip saving to storage
    // _savePets();
    
    notifyListeners();
  }

  // Set current pet
  void setCurrentPet(Pet pet) {
    _currentPet = pet;
    notifyListeners();
  }

  // Load pets from local storage
  Future<void> loadPets() async {
    // For testing, we'll add some mock data instead of loading from storage
    if (_pets.isEmpty) {
      _pets = [
        Pet(
          id: '1',
          name: 'Buddy',
          breed: 'Golden Retriever',
          age: 3,
          weight: 25.5,
        ),
        Pet(
          id: '2',
          name: 'Max',
          breed: 'German Shepherd',
          age: 2,
          weight: 30.0,
        ),
      ];
      
      // Set first pet as current
      if (_pets.isNotEmpty && _currentPet == null) {
        _currentPet = _pets[0];
      }
      
      notifyListeners();
    }
  }

  // Save pets to local storage - not used for testing
  Future<void> _savePets() async {
    // For testing, we'll skip saving to storage
    debugPrint('Saving pets (skipped for testing)');
  }

  // Convert Pet to JSON
  Map<String, dynamic> _petToJson(Pet pet) {
    return {
      'id': pet.id,
      'name': pet.name,
      'breed': pet.breed,
      'age': pet.age,
      'weight': pet.weight,
      'imageUrl': pet.imageUrl,
      'specialNeeds': pet.specialNeeds,
    };
  }

  // Convert JSON to Pet
  Pet _petFromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      breed: json['breed'],
      age: json['age'],
      weight: json['weight'].toDouble(),
      imageUrl: json['imageUrl'],
      specialNeeds: json['specialNeeds'] != null 
          ? List<String>.from(json['specialNeeds']) 
          : null,
    );
  }
} 