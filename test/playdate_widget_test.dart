import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/models/pet_model.dart';
import 'package:pet_care/models/playdate_model.dart';
import 'package:pet_care/screens/playdate_form_screen.dart';
import 'package:pet_care/screens/playdate_screen.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/services/playdate_provider.dart';
import 'package:provider/provider.dart';

class MockPlaydateProvider extends PlaydateProvider {
  List<Playdate> mockPlaydates = [];
  
  @override
  List<Playdate> get playdates => mockPlaydates;
  
  @override
  Future<void> loadPlaydates() async {
    // Load mock data for testing
    final now = DateTime.now();
    
    // Directly create mock data
    final park = Playdate(
      id: '1',
      petId: 'pet1',
      title: 'Park Meetup',
      date: now.add(const Duration(days: 2)),
      location: 'Central Park',
      durationMinutes: 60,
      participants: ['Max', 'Luna'],
      isConfirmed: true,
    );
    
    final beach = Playdate(
      id: '2',
      petId: 'pet1',
      title: 'Beach Day',
      date: now.subtract(const Duration(days: 5)),
      location: 'Dog Beach',
      durationMinutes: 90,
      participants: ['Rocky', 'Charlie'],
      isConfirmed: false,
    );
    
    // Add using the add method
    mockPlaydates = [park, beach];
    
    notifyListeners();
    return;
  }
  
  @override
  Future<void> _savePlaydates() async {
    // Do nothing in tests
    return;
  }
}

class MockPetProvider extends PetProvider {
  Pet? mockCurrentPet;
  List<Pet> mockPets = [];
  
  @override
  Pet? get currentPet => mockCurrentPet;
  
  @override
  List<Pet> get pets => mockPets;
  
  @override
  Future<void> loadPets() async {
    mockCurrentPet = Pet(
      id: 'pet1',
      name: 'Buddy',
      breed: 'Golden Retriever',
      age: 3,
      weight: 25.5,
    );
    
    mockPets = [mockCurrentPet!];
    notifyListeners();
    return;
  }
  
  @override
  Future<void> _savePets() async {
    // Do nothing in tests
    return;
  }
}

void main() {
  group('Playdate Provider Tests', () {
    testWidgets('PlaydateScreen builds without error', (WidgetTester tester) async {
      final petProvider = MockPetProvider();
      final playdateProvider = MockPlaydateProvider();
      
      await petProvider.loadPets();
      await playdateProvider.loadPlaydates();
      
      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<PetProvider>.value(value: petProvider),
              ChangeNotifierProvider<PlaydateProvider>.value(value: playdateProvider),
            ],
            child: const PlaydateScreen(),
          ),
        ),
      );
      
      // Just verify the widget builds without errors
      await tester.pumpAndSettle();
      expect(find.byType(PlaydateScreen), findsOneWidget);
    });

    testWidgets('PlaydateFormScreen builds without error', (WidgetTester tester) async {
      final petProvider = MockPetProvider();
      
      await petProvider.loadPets();
      
      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<PetProvider>.value(value: petProvider),
              ChangeNotifierProvider<PlaydateProvider>(create: (_) => PlaydateProvider()),
            ],
            child: const PlaydateFormScreen(petId: 'pet1'),
          ),
        ),
      );
      
      // Just verify the widget builds without errors
      await tester.pumpAndSettle();
      expect(find.byType(PlaydateFormScreen), findsOneWidget);
    });
  });
} 