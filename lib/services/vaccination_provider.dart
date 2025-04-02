import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/vaccination_model.dart';

class VaccinationProvider with ChangeNotifier {
  List<Vaccination> _vaccinations = [];

  List<Vaccination> get vaccinations => _vaccinations;

  // Get vaccinations for a specific pet
  List<Vaccination> getVaccinationsForPet(String petId) {
    return _vaccinations.where((v) => v.petId == petId).toList();
  }

  // Get upcoming vaccinations for a specific pet
  List<Vaccination> getUpcomingVaccinationsForPet(String petId) {
    final now = DateTime.now();
    return _vaccinations
        .where((v) => v.petId == petId && 
                      v.nextDueDate.isAfter(now) && 
                      !v.isCompleted)
        .toList()
        ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  }

  // Get nearest upcoming vaccination for a pet
  Vaccination? getNextVaccinationForPet(String petId) {
    final upcomingVaccinations = getUpcomingVaccinationsForPet(petId);
    return upcomingVaccinations.isNotEmpty ? upcomingVaccinations.first : null;
  }

  // Add a new vaccination
  void addVaccination(Vaccination vaccination) {
    _vaccinations.add(vaccination);
    _saveVaccinations();
    notifyListeners();
  }

  // Update an existing vaccination
  void updateVaccination(Vaccination vaccination) {
    final index = _vaccinations.indexWhere((v) => v.id == vaccination.id);
    if (index >= 0) {
      _vaccinations[index] = vaccination;
      _saveVaccinations();
      notifyListeners();
    }
  }

  // Delete a vaccination
  void deleteVaccination(String vaccinationId) {
    _vaccinations.removeWhere((v) => v.id == vaccinationId);
    _saveVaccinations();
    notifyListeners();
  }

  // Mark a vaccination as completed
  void markVaccinationAsCompleted(String vaccinationId, {bool completed = true}) {
    final index = _vaccinations.indexWhere((v) => v.id == vaccinationId);
    if (index >= 0) {
      _vaccinations[index] = _vaccinations[index].copyWith(isCompleted: completed);
      _saveVaccinations();
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