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
  MockFeedingProvider() : super(isTest: true);
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
      feedingProvider.addFeeding(Feeding(
        id: 'feed1',
        petId: 'pet1',
        foodName: 'Morning Kibble',
        portionSize: '1 cup',
        frequency: FeedingFrequency.daily,
        feedingTimes: [const TimeOfDay(hour: 8, minute: 0)],
      ));
      
      feedingProvider.addFeeding(Feeding(
        id: 'feed2',
        petId: 'pet1',
        foodName: 'Evening Meal',
        portionSize: '1.5 cups',
        frequency: FeedingFrequency.daily,
        feedingTimes: [const TimeOfDay(hour: 18, minute: 0)],
        isActive: false,
      ));
    });
    
    testWidgets('FeedingScreen displays feeding schedules correctly', (WidgetTester tester) async {
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
      
      // Verify that both feeding schedules are displayed
      expect(find.text('Morning Kibble'), findsOneWidget);
      expect(find.text('Evening Meal'), findsOneWidget);
      
      // Verify that the portion sizes are displayed
      expect(find.text('Portion: 1 cup'), findsOneWidget);
      expect(find.text('Portion: 1.5 cups'), findsOneWidget);
      
      // Verify that the active feeding has a "Record Feeding" button
      expect(find.text('Record Feeding'), findsOneWidget);
      
      // Verify that there's a floating action button to add feeding schedules
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // Verify section headings
      expect(find.text('Feeding Schedules'), findsOneWidget);
      expect(find.text('Today\'s Feedings'), findsOneWidget);
    });
    
    testWidgets('FeedingScreen shows empty state when no feedings', (WidgetTester tester) async {
      // Clear all feedings
      feedingProvider = MockFeedingProvider();
      
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
      
      // Verify that the empty state message is displayed
      expect(find.text('No Feeding Schedules'), findsOneWidget);
      expect(find.text('Add a feeding schedule for your pet'), findsOneWidget);
      
      // Verify that the add button is displayed
      expect(find.text('Add Feeding Schedule'), findsOneWidget);
    });
  });
} 