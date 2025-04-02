import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pet_care/models/vaccination_model.dart';
import 'package:pet_care/models/pet_model.dart';
import 'package:pet_care/services/vaccination_provider.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/screens/vaccination_screen.dart';

class MockPetProvider extends PetProvider {
  @override
  Future<void> loadPets() async {
    // Do nothing in tests
    return;
  }
  
  @override
  Future<void> _savePets() async {
    // Do nothing in tests
    return;
  }
}

class MockVaccinationProvider extends VaccinationProvider {
  @override
  Future<void> loadVaccinations() async {
    // Do nothing in tests
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

  group('VaccinationScreen Widget Tests', () {
    late MockPetProvider petProvider;
    late MockVaccinationProvider vaccinationProvider;
    
    setUp(() {
      petProvider = MockPetProvider();
      vaccinationProvider = MockVaccinationProvider();
      
      // Add a test pet
      final testPet = Pet(
        id: 'pet1',
        name: 'Buddy',
        breed: 'Golden Retriever',
        age: 3,
        weight: 25.5,
      );
      
      // Set the pet using the setPet method
      petProvider.setPet(testPet);
      
      // Add some test vaccinations
      vaccinationProvider.addVaccination(Vaccination(
        id: 'vac1',
        name: 'Rabies',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: DateTime.now().add(const Duration(days: 30)),
        petId: 'pet1',
      ));
      
      vaccinationProvider.addVaccination(Vaccination(
        id: 'vac2',
        name: 'Distemper',
        administeredDate: DateTime(2023, 1, 1),
        nextDueDate: DateTime.now().subtract(const Duration(days: 30)),
        petId: 'pet1',
        isCompleted: true,
      ));
    });
    
    testWidgets('VaccinationScreen displays vaccinations correctly', (WidgetTester tester) async {
      // Build the VaccinationScreen widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PetProvider>.value(value: petProvider),
            ChangeNotifierProvider<VaccinationProvider>.value(value: vaccinationProvider),
          ],
          child: const MaterialApp(
            home: VaccinationScreen(),
          ),
        ),
      );
      
      // Wait for the widget to build
      await tester.pumpAndSettle();
      
      // Verify that the AppBar shows correctly
      expect(find.text('Buddy\'s Vaccinations'), findsOneWidget);
      
      // Verify that both vaccinations are displayed
      expect(find.text('Rabies'), findsOneWidget);
      expect(find.text('Distemper'), findsOneWidget);
      
      // Verify section headings
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      
      // Verify that there's a floating action button to add vaccinations
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
} 