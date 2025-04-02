import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pet_care/models/feeding_model.dart';
import 'package:pet_care/models/pet_model.dart';
import 'package:pet_care/services/feeding_provider.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/screens/feeding_screen.dart';

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

class MockFeedingProvider extends FeedingProvider {
  @override
  Future<void> loadData() async {
    // Do nothing in tests
    return;
  }
  
  @override
  Future<void> _saveData() async {
    // Do nothing in tests
    return;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedingScreen Widget Tests', () {
    late MockPetProvider petProvider;
    late MockFeedingProvider feedingProvider;
    
    setUp(() {
      petProvider = MockPetProvider();
      feedingProvider = MockFeedingProvider();
      
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
      
      // Add some test feeding schedules
      feedingProvider.addSchedule(FeedingSchedule(
        id: 'feed1',
        petId: 'pet1',
        name: 'Morning Feed',
        foodType: 'Dry Food',
        amount: 1.5,
        unit: 'cups',
        times: [FeedingTime(hour: 8, minute: 0)],
      ));
      
      feedingProvider.addSchedule(FeedingSchedule(
        id: 'feed2',
        petId: 'pet1',
        name: 'Evening Feed',
        foodType: 'Wet Food',
        amount: 1.0,
        unit: 'cans',
        times: [FeedingTime(hour: 18, minute: 0)],
        isActive: false,
      ));
      
      // Add some test feeding logs
      final now = DateTime.now();
      feedingProvider.addLog(FeedingLog(
        id: 'log1',
        scheduleId: 'feed1',
        petId: 'pet1',
        timestamp: now,
        amount: 1.5,
        unit: 'cups',
        foodType: 'Dry Food',
      ));
    });
    
    testWidgets('FeedingScreen displays schedules correctly', (WidgetTester tester) async {
      // Build the FeedingScreen widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PetProvider>.value(value: petProvider),
            ChangeNotifierProvider<FeedingProvider>.value(value: feedingProvider),
          ],
          child: const MaterialApp(
            home: FeedingScreen(),
          ),
        ),
      );
      
      // Wait for the widget to build
      await tester.pumpAndSettle();
      
      // Verify that the AppBar shows correctly
      expect(find.text('Buddy\'s Feeding'), findsOneWidget);
      
      // Verify that both tabs exist
      expect(find.text('Schedules'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      
      // Verify that schedules are displayed
      expect(find.text('Morning Feed'), findsOneWidget);
      expect(find.text('Evening Feed'), findsOneWidget);
      
      // Verify that there's a floating action button to add schedules
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // Switch to History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      
      // Verify that logs are displayed
      expect(find.text('Dry Food'), findsOneWidget);
    });
  });
} 