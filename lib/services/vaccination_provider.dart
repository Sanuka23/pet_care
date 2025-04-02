import 'package:flutter/foundation.dart';
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
    // For testing, we'll skip saving to storage
    // await _saveVaccinations();
    notifyListeners();
  }

  // Update an existing vaccination
  Future<void> updateVaccination(Vaccination vaccination) async {
    final index = _vaccinations.indexWhere((v) => v.id == vaccination.id);
    if (index >= 0) {
      _vaccinations[index] = vaccination;
      // For testing, we'll skip saving to storage
      // await _saveVaccinations();
      notifyListeners();
    }
  }

  // Delete a vaccination
  Future<void> deleteVaccination(String id) async {
    _vaccinations.removeWhere((v) => v.id == id);
    // For testing, we'll skip saving to storage
    // await _saveVaccinations();
    notifyListeners();
  }

  // Mark vaccination as completed
  Future<void> completeVaccination(String id) async {
    final index = _vaccinations.indexWhere((v) => v.id == id);
    if (index >= 0) {
      _vaccinations[index] = _vaccinations[index].copyWith(isCompleted: true);
      // For testing, we'll skip saving to storage
      // await _saveVaccinations();
      notifyListeners();
    }
  }

  // Load vaccinations from local storage
  Future<void> loadVaccinations() async {
    // For testing, we'll add some mock data instead of loading from storage
    if (_vaccinations.isEmpty) {
      final now = DateTime.now();
      _vaccinations = [
        Vaccination(
          id: 'vac1',
          name: 'Rabies',
          administeredDate: DateTime(now.year, now.month - 6, now.day),
          nextDueDate: DateTime(now.year, now.month + 6, now.day),
          petId: '1',
        ),
        Vaccination(
          id: 'vac2',
          name: 'Distemper',
          administeredDate: DateTime(now.year, now.month - 3, now.day),
          nextDueDate: DateTime(now.year + 1, now.month - 3, now.day),
          petId: '1',
        ),
        Vaccination(
          id: 'vac3',
          name: 'Parvovirus',
          administeredDate: DateTime(now.year - 1, now.month, now.day),
          nextDueDate: DateTime(now.year - 1, now.month, now.day).add(const Duration(days: 365)),
          petId: '2',
          isCompleted: true,
        ),
      ];
      
      notifyListeners();
    }
  }

  // Save vaccinations to local storage
  Future<void> _saveVaccinations() async {
    // For testing, we'll skip saving to storage
    debugPrint('Saving vaccinations (skipped for testing)');
  }
} 