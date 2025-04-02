import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/vaccination_model.dart';

class VaccinationProvider with ChangeNotifier {
  List<Vaccination> _vaccinations = [];
  final Uuid _uuid = const Uuid();

  List<Vaccination> get vaccinations => _vaccinations;

  // Get vaccinations for a specific pet
  List<Vaccination> getVaccinationsForPet(String petId) {
    return _vaccinations.where((v) => v.petId == petId).toList();
  }

  // Get upcoming vaccinations for a specific pet
  List<Vaccination> getUpcomingVaccinationsForPet(String petId) {
    final now = DateTime.now();
    return _vaccinations
        .where((v) => v.petId == petId && v.nextDueDate.isAfter(now) && !v.isCompleted)
        .toList();
  }

  // Get next upcoming vaccination for a specific pet
  Vaccination? getNextVaccinationForPet(String petId) {
    final upcomingVaccinations = getUpcomingVaccinationsForPet(petId);
    if (upcomingVaccinations.isEmpty) return null;
    
    // Sort by due date (earliest first)
    upcomingVaccinations.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return upcomingVaccinations.first;
  }

  // Add a new vaccination
  Future<void> addVaccination(Vaccination vaccination) async {
    // Generate ID if not provided
    final vaccinationWithId = vaccination.id.isEmpty 
        ? vaccination.copyWith(id: _uuid.v4()) 
        : vaccination;
        
    _vaccinations.add(vaccinationWithId);
    await _saveVaccinations();
    notifyListeners();
  }

  // Update an existing vaccination
  Future<void> updateVaccination(Vaccination vaccination) async {
    final index = _vaccinations.indexWhere((v) => v.id == vaccination.id);
    if (index >= 0) {
      _vaccinations[index] = vaccination;
      await _saveVaccinations();
      notifyListeners();
    }
  }

  // Delete a vaccination
  Future<void> deleteVaccination(String id) async {
    _vaccinations.removeWhere((v) => v.id == id);
    await _saveVaccinations();
    notifyListeners();
  }

  // Mark vaccination as completed
  Future<void> completeVaccination(String id) async {
    final index = _vaccinations.indexWhere((v) => v.id == id);
    if (index >= 0) {
      _vaccinations[index] = _vaccinations[index].copyWith(isCompleted: true);
      await _saveVaccinations();
      notifyListeners();
    }
  }

  // Load vaccinations from local storage
  Future<void> loadVaccinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vaccinationsJson = prefs.getStringList('vaccinations') ?? [];
      
      _vaccinations = vaccinationsJson
          .map((json) => Vaccination.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading vaccinations: $e');
    }
  }

  // Save vaccinations to local storage
  Future<void> _saveVaccinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vaccinationsJson = _vaccinations
          .map((vaccination) => jsonEncode(vaccination.toJson()))
          .toList();
      
      await prefs.setStringList('vaccinations', vaccinationsJson);
    } catch (e) {
      debugPrint('Error saving vaccinations: $e');
    }
  }
} 