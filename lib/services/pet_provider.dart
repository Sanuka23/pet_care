import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/pet_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];
  Pet? _currentPet;
  bool _initialized = false;
  static const String _petsFileName = 'pets.json';

  List<Pet> get pets => _pets;
  Pet? get currentPet => _currentPet;

  // Initialize the provider
  Future<void> initialize() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getStringList('pets') ?? [];
    
    if (petsJson.isNotEmpty) {
      _pets = petsJson.map((json) => Pet.fromJson(jsonDecode(json))).toList();
      
      final currentPetId = prefs.getString('currentPetId');
      if (currentPetId != null) {
        _currentPet = _pets.firstWhere(
          (pet) => pet.id == currentPetId,
          orElse: () => _pets.first,
        );
      } else if (_pets.isNotEmpty) {
        _currentPet = _pets.first;
      }
    } else {
      // Add sample data if no pets exist
      _addSampleData();
    }
    
    _initialized = true;
    notifyListeners();
  }

  void _addSampleData() {
    // Create sample pets
    final maxId = _pets.isEmpty ? 0 : _pets.map((p) => int.parse(p.id)).reduce(max);
    
    final dog = Pet(
      id: (maxId + 1).toString(),
      name: 'Buddy',
      breed: 'Golden Retriever',
      age: 3,
      weight: 28.5,
      specialNeeds: ['Regular Exercise', 'Allergy to Chicken'],
      imageUrl: null,
    );
    
    final cat = Pet(
      id: (maxId + 2).toString(),
      name: 'Whiskers',
      breed: 'Siamese',
      age: 5,
      weight: 4.2,
      specialNeeds: ['Indoor Only', 'Special Diet'],
      imageUrl: null,
    );
    
    _pets.addAll([dog, cat]);
    _currentPet = dog;
    
    // Save sample data
    _savePets();
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
    _saveCurrentPet();
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

  Future<void> _saveCurrentPet() async {
    if (_currentPet == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentPetId', _currentPet!.id);
  }

  Future<void> addPet(Pet pet) async {
    // Create a new ID if none provided
    final newPet = pet.id.isEmpty
      ? pet.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
      : pet;
      
    final existingIndex = _pets.indexWhere((p) => p.id == newPet.id);
    
    if (existingIndex >= 0) {
      // Update existing pet
      _pets[existingIndex] = newPet;
    } else {
      // Add new pet
      _pets.add(newPet);
    }
    
    // Set as current pet if it's the first one
    if (_currentPet == null) {
      _currentPet = newPet;
    }
    
    await _savePets();
    notifyListeners();
  }
  
  Future<void> updatePet(Pet pet) async {
    final index = _pets.indexWhere((p) => p.id == pet.id);
    
    if (index >= 0) {
      _pets[index] = pet;
      
      // Update current pet if that's the one being updated
      if (_currentPet?.id == pet.id) {
        _currentPet = pet;
      }
      
      await _savePets();
      notifyListeners();
    }
  }
  
  Future<void> deletePet(String id) async {
    _pets.removeWhere((pet) => pet.id == id);
    
    // If current pet is deleted, set a new one
    if (_currentPet?.id == id) {
      _currentPet = _pets.isNotEmpty ? _pets.first : null;
    }
    
    await _savePets();
    notifyListeners();
  }
} 