import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pet_model.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];
  Pet? _currentPet;
  bool _isTestEnvironment = false;

  PetProvider({bool isTest = false}) {
    _isTestEnvironment = isTest;
  }

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
    
    // Save pets to local storage
    _savePets();
    
    notifyListeners();
  }

  // Remove a pet
  void removePet(String petId) {
    _pets.removeWhere((p) => p.id == petId);
    
    // If current pet was removed, set current to first pet or null
    if (_currentPet != null && _currentPet!.id == petId) {
      _currentPet = _pets.isNotEmpty ? _pets[0] : null;
    }
    
    // Save pets to local storage
    _savePets();
    
    notifyListeners();
  }

  // Set current pet
  void setCurrentPet(Pet pet) {
    _currentPet = pet;
    notifyListeners();
  }

  // Load pets from local storage
  Future<void> loadPets() async {
    if (_isTestEnvironment) {
      // Skip loading in test environment
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final petsJson = prefs.getStringList('pets') ?? [];
      
      _pets = petsJson.map((json) => _petFromJson(jsonDecode(json))).toList();
      
      if (_pets.isNotEmpty && _currentPet == null) {
        _currentPet = _pets[0];
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pets: $e');
    }
  }

  // Save pets to local storage
  Future<void> _savePets() async {
    if (_isTestEnvironment) {
      // Skip saving in test environment
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final petsJson = _pets.map((pet) => jsonEncode(_petToJson(pet))).toList();
      
      await prefs.setStringList('pets', petsJson);
    } catch (e) {
      debugPrint('Error saving pets: $e');
    }
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