import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pet_care/models/vaccination_model.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/services/vaccination_provider.dart';
import 'package:pet_care/screens/vaccination_screen.dart';
import 'package:pet_care/models/pet_model.dart';

void main() {
  group('Vaccination Provider Tests', () {
    test('Should add a vaccination', () {
      final provider = VaccinationProvider(isTest: true);
      
      final vaccination = Vaccination(
        id: '1',
        petId: 'pet1',
        name: 'Rabies',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: DateTime(2024, 1, 1),
      );
      
      provider.addVaccination(vaccination);
      
      expect(provider.vaccinations.length, 1);
      expect(provider.vaccinations.first.name, 'Rabies');
    });
    
    test('Should get vaccinations for a pet', () {
      final provider = VaccinationProvider(isTest: true);
      
      // Add vaccinations for different pets
      provider.addVaccination(Vaccination(
        id: '1',
        petId: 'pet1',
        name: 'Rabies',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: DateTime(2024, 1, 1),
      ));
      
      provider.addVaccination(Vaccination(
        id: '2',
        petId: 'pet2',
        name: 'Distemper',
        administeredDate: DateTime(2023, 2, 1),
        nextDueDate: DateTime(2024, 2, 1),
      ));
      
      provider.addVaccination(Vaccination(
        id: '3',
        petId: 'pet1',
        name: 'Parvo',
        administeredDate: DateTime(2023, 3, 1),
        nextDueDate: DateTime(2024, 3, 1),
      ));
      
      final pet1Vaccinations = provider.getVaccinationsForPet('pet1');
      
      expect(pet1Vaccinations.length, 2);
      expect(pet1Vaccinations.map((v) => v.name).toList(), contains('Rabies'));
      expect(pet1Vaccinations.map((v) => v.name).toList(), contains('Parvo'));
    });
    
    test('Should get next upcoming vaccination for a pet', () {
      final provider = VaccinationProvider(isTest: true);
      
      // Add vaccinations with different due dates
      provider.addVaccination(Vaccination(
        id: '1',
        petId: 'pet1',
        name: 'Rabies',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: DateTime.now().add(const Duration(days: 30)), // Due in 30 days
      ));
      
      provider.addVaccination(Vaccination(
        id: '2',
        petId: 'pet1',
        name: 'Parvo',
        administeredDate: DateTime(2023, 2, 1),
        nextDueDate: DateTime.now().add(const Duration(days: 10)), // Due in 10 days
      ));
      
      provider.addVaccination(Vaccination(
        id: '3',
        petId: 'pet1',
        name: 'Distemper',
        administeredDate: DateTime(2023, 3, 1),
        nextDueDate: DateTime.now().add(const Duration(days: 60)), // Due in 60 days
      ));
      
      final nextVaccination = provider.getNextVaccinationForPet('pet1');
      
      expect(nextVaccination, isNotNull);
      expect(nextVaccination!.name, 'Parvo'); // Should be the one due in 10 days
    });
  });

  testWidgets('VaccinationScreen shows empty state when no vaccinations', (WidgetTester tester) async {
    // Create a test pet
    final testPet = Pet(
      id: '1',
      name: 'Max',
      breed: 'Golden Retriever',
      age: 3,
      weight: 25.5,
    );

    // Build the widget with providers
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => PetProvider(isTest: true)..setPet(testPet),
            ),
            ChangeNotifierProvider(
              create: (_) => VaccinationProvider(isTest: true),
            ),
          ],
          child: const VaccinationScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100)); // Wait for the UI to settle

    // Verify empty state is displayed
    expect(find.text('No Vaccinations Yet'), findsOneWidget);
    expect(find.text('Tap + to add your pet\'s first vaccination'), findsOneWidget);
    
    // Don't look for ElevatedButton, which might be rendered differently in tests
    expect(find.text('Add Vaccination'), findsOneWidget);
  });
} 