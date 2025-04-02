import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pet_care/models/vaccination_model.dart';
import 'package:pet_care/services/vaccination_provider.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/models/pet_model.dart';

class MockVaccinationProvider extends VaccinationProvider {
  // Override storage methods to avoid SharedPreferences issues in tests
  @override
  Future<void> loadVaccinations() async {
    // Do nothing - we'll manually add test data
    return;
  }
  
  @override
  Future<void> _saveVaccinations() async {
    // Do nothing in tests
    return;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VaccinationProvider Tests', () {
    late MockVaccinationProvider provider;
    
    setUp(() {
      provider = MockVaccinationProvider();
    });
    
    test('Initial state has empty vaccinations list', () {
      expect(provider.vaccinations.isEmpty, true);
    });
    
    test('Adding a vaccination works correctly', () async {
      final testVaccination = Vaccination(
        id: '1',
        name: 'Rabies',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: DateTime(2024, 1, 1),
        petId: 'pet1',
      );
      
      await provider.addVaccination(testVaccination);
      
      expect(provider.vaccinations.length, 1);
      expect(provider.vaccinations[0].name, 'Rabies');
      expect(provider.vaccinations[0].petId, 'pet1');
    });
    
    test('Getting vaccinations for specific pet works correctly', () async {
      // Add vaccinations for pet1
      await provider.addVaccination(Vaccination(
        id: '1',
        name: 'Rabies',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: DateTime(2024, 1, 1),
        petId: 'pet1',
      ));
      
      // Add vaccinations for pet2
      await provider.addVaccination(Vaccination(
        id: '2',
        name: 'Distemper',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: DateTime(2024, 1, 1),
        petId: 'pet2',
      ));
      
      final pet1Vaccinations = provider.getVaccinationsForPet('pet1');
      final pet2Vaccinations = provider.getVaccinationsForPet('pet2');
      
      expect(pet1Vaccinations.length, 1);
      expect(pet2Vaccinations.length, 1);
      expect(pet1Vaccinations[0].name, 'Rabies');
      expect(pet2Vaccinations[0].name, 'Distemper');
    });
    
    test('Marking a vaccination as completed works correctly', () async {
      await provider.addVaccination(Vaccination(
        id: '1',
        name: 'Rabies',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: DateTime(2024, 1, 1),
        petId: 'pet1',
        isCompleted: false,
      ));
      
      await provider.completeVaccination('1');
      
      expect(provider.vaccinations[0].isCompleted, true);
    });
    
    test('Deleting a vaccination works correctly', () async {
      await provider.addVaccination(Vaccination(
        id: '1',
        name: 'Rabies',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: DateTime(2024, 1, 1),
        petId: 'pet1',
      ));
      
      expect(provider.vaccinations.length, 1);
      
      await provider.deleteVaccination('1');
      
      expect(provider.vaccinations.isEmpty, true);
    });
    
    test('Getting upcoming vaccinations works correctly', () async {
      final now = DateTime.now();
      
      // Past due vaccination (already completed)
      await provider.addVaccination(Vaccination(
        id: '1',
        name: 'Past Vaccine',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: now.subtract(const Duration(days: 30)),
        petId: 'pet1',
        isCompleted: true,
      ));
      
      // Upcoming vaccination
      await provider.addVaccination(Vaccination(
        id: '2',
        name: 'Future Vaccine',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: now.add(const Duration(days: 30)),
        petId: 'pet1',
        isCompleted: false,
      ));
      
      final upcomingVaccinations = provider.getUpcomingVaccinationsForPet('pet1');
      
      expect(upcomingVaccinations.length, 1);
      expect(upcomingVaccinations[0].name, 'Future Vaccine');
    });
  });
} 