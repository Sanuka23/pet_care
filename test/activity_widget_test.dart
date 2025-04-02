import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pet_care/models/activity_model.dart';
import 'package:pet_care/models/pet_model.dart';
import 'package:pet_care/services/activity_provider.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/screens/activity_screen.dart';

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

class MockActivityProvider extends ActivityProvider {
  @override
  Future<void> loadActivities() async {
    // Do nothing in tests
    return;
  }
  
  @override
  Future<void> _saveActivities() async {
    // Do nothing in tests
    return;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ActivityScreen Widget Tests', () {
    late MockPetProvider petProvider;
    late MockActivityProvider activityProvider;
    
    setUp(() {
      petProvider = MockPetProvider();
      activityProvider = MockActivityProvider();
      
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
      
      final now = DateTime.now();
      
      // Add upcoming activity
      activityProvider.addActivity(Activity(
        id: 'activity1',
        petId: 'pet1',
        name: 'Morning Walk',
        type: 'Walk',
        date: now.add(const Duration(hours: 2)),
        durationMinutes: 30,
        location: 'Park',
        isCompleted: false,
      ));
      
      // Add completed activity
      activityProvider.addActivity(Activity(
        id: 'activity2',
        petId: 'pet1',
        name: 'Training Session',
        type: 'Training',
        date: now.subtract(const Duration(days: 1)),
        durationMinutes: 45,
        isCompleted: true,
      ));
    });
    
    testWidgets('ActivityScreen displays activities correctly', (WidgetTester tester) async {
      // Build the ActivityScreen widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PetProvider>.value(value: petProvider),
            ChangeNotifierProvider<ActivityProvider>.value(value: activityProvider),
          ],
          child: const MaterialApp(
            home: ActivityScreen(),
          ),
        ),
      );
      
      // Wait for the widget to build
      await tester.pumpAndSettle();
      
      // Verify that the AppBar shows correctly
      expect(find.text('Buddy\'s Activities'), findsOneWidget);
      
      // Verify that both tabs exist
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      
      // Verify that the upcoming activity is displayed
      expect(find.text('Morning Walk'), findsOneWidget);
      expect(find.text('Walk'), findsAtLeastNWidgets(1));
      expect(find.text('Park'), findsOneWidget);
      
      // Verify that there's a floating action button to add activities
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // Switch to Completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      
      // Verify that completed activity is displayed
      expect(find.text('Training Session'), findsOneWidget);
      expect(find.text('Training'), findsAtLeastNWidgets(1));
    });
    
    testWidgets('ActivityScreen filters by activity type', (WidgetTester tester) async {
      // Build the ActivityScreen widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PetProvider>.value(value: petProvider),
            ChangeNotifierProvider<ActivityProvider>.value(value: activityProvider),
          ],
          child: const MaterialApp(
            home: ActivityScreen(),
          ),
        ),
      );
      
      // Wait for the widget to build
      await tester.pumpAndSettle();
      
      // Initially we should see the Walk activity
      expect(find.text('Morning Walk'), findsOneWidget);
      
      // Open the filter dropdown
      await tester.tap(find.text('All Types'));
      await tester.pumpAndSettle();
      
      // Select Training filter
      await tester.tap(find.text('Training').last);
      await tester.pumpAndSettle();
      
      // We should no longer see the Walk activity in the Upcoming tab
      expect(find.text('Morning Walk'), findsNothing);
      
      // Switch to Completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      
      // We should see the Training activity in the Completed tab
      expect(find.text('Training Session'), findsOneWidget);
    });
  });
} 