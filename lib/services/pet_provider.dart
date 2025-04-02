import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/pet_model.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];
  Pet? _currentPet;
  static const String _petsFileName = 'pets.json';

  List<Pet> get pets => _pets;
  Pet? get currentPet => _currentPet;

  // Initialize the provider
  Future<void> initialize() async {
    await _loadPets();
  }

  // Load pets from storage
  Future<void> _loadPets() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_petsFileName');
      
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        _pets = jsonList.map((json) => Pet.fromJson(json)).toList();
        
        // Set current pet to the first pet if available
        if (_pets.isNotEmpty && _currentPet == null) {
          _currentPet = _pets[0];
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading pets: $e');
    }
  }

  // Save pets to storage
  Future<void> _savePets() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_petsFileName');
      
      final jsonList = _pets.map((pet) => pet.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving pets: $e');
    }
  }

  // Add a new pet or update existing pet
  Future<void> setPet(Pet pet) async {
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
    
    // Save to storage
    await _savePets();
    
    notifyListeners();
  }

  // Remove a pet
  Future<void> removePet(String petId) async {
    _pets.removeWhere((p) => p.id == petId);
    
    // If current pet was removed, set current to first pet or null
    if (_currentPet != null && _currentPet!.id == petId) {
      _currentPet = _pets.isNotEmpty ? _pets[0] : null;
    }
    
    // Save to storage
    await _savePets();
    
    notifyListeners();
  }

  // Set current pet
  void setCurrentPet(Pet pet) {
    _currentPet = pet;
    notifyListeners();
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