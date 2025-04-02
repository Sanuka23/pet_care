import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/models/activity_model.dart';
import 'package:pet_care/services/activity_provider.dart';

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
  group('ActivityProvider Tests', () {
    late MockActivityProvider provider;
    
    setUp(() {
      provider = MockActivityProvider();
    });
    
    test('Initial state has empty activities list', () {
      expect(provider.activities.isEmpty, true);
    });
    
    test('Adding an activity works correctly', () async {
      final now = DateTime.now();
      final testActivity = Activity(
        id: '1',
        petId: 'pet1',
        name: 'Morning Walk',
        type: 'Walk',
        date: now,
        durationMinutes: 30,
      );
      
      await provider.addActivity(testActivity);
      
      expect(provider.activities.length, 1);
      expect(provider.activities[0].name, 'Morning Walk');
      expect(provider.activities[0].petId, 'pet1');
    });
    
    test('Getting activities for specific pet works correctly', () async {
      final now = DateTime.now();
      
      // Add activity for pet1
      await provider.addActivity(Activity(
        id: '1',
        petId: 'pet1',
        name: 'Morning Walk',
        type: 'Walk',
        date: now,
        durationMinutes: 30,
      ));
      
      // Add activity for pet2
      await provider.addActivity(Activity(
        id: '2',
        petId: 'pet2',
        name: 'Training Session',
        type: 'Training',
        date: now,
        durationMinutes: 20,
      ));
      
      final pet1Activities = provider.getActivitiesForPet('pet1');
      final pet2Activities = provider.getActivitiesForPet('pet2');
      
      expect(pet1Activities.length, 1);
      expect(pet2Activities.length, 1);
      expect(pet1Activities[0].name, 'Morning Walk');
      expect(pet2Activities[0].name, 'Training Session');
    });
    
    test('Getting activities by type works correctly', () async {
      final now = DateTime.now();
      
      // Add walk activity
      await provider.addActivity(Activity(
        id: '1',
        petId: 'pet1',
        name: 'Morning Walk',
        type: 'Walk',
        date: now,
        durationMinutes: 30,
      ));
      
      // Add training activity
      await provider.addActivity(Activity(
        id: '2',
        petId: 'pet1',
        name: 'Training Session',
        type: 'Training',
        date: now,
        durationMinutes: 20,
      ));
      
      // Add another walk activity
      await provider.addActivity(Activity(
        id: '3',
        petId: 'pet1',
        name: 'Evening Walk',
        type: 'Walk',
        date: now,
        durationMinutes: 45,
      ));
      
      final walkActivities = provider.getActivitiesByTypeForPet('pet1', 'Walk');
      final trainingActivities = provider.getActivitiesByTypeForPet('pet1', 'Training');
      
      expect(walkActivities.length, 2);
      expect(trainingActivities.length, 1);
    });
    
    test('Marking activity as completed works correctly', () async {
      final now = DateTime.now();
      
      await provider.addActivity(Activity(
        id: '1',
        petId: 'pet1',
        name: 'Morning Walk',
        type: 'Walk',
        date: now,
        durationMinutes: 30,
        isCompleted: false,
      ));
      
      expect(provider.activities[0].isCompleted, false);
      
      await provider.markActivityAsCompleted('1');
      
      expect(provider.activities[0].isCompleted, true);
    });
    
    test('Updating an activity works correctly', () async {
      final now = DateTime.now();
      
      await provider.addActivity(Activity(
        id: '1',
        petId: 'pet1',
        name: 'Morning Walk',
        type: 'Walk',
        date: now,
        durationMinutes: 30,
      ));
      
      final updatedActivity = Activity(
        id: '1',
        petId: 'pet1',
        name: 'Afternoon Walk',
        type: 'Walk',
        date: now.add(const Duration(hours: 6)),
        durationMinutes: 45,
      );
      
      await provider.updateActivity(updatedActivity);
      
      expect(provider.activities[0].name, 'Afternoon Walk');
      expect(provider.activities[0].durationMinutes, 45);
    });
    
    test('Deleting an activity works correctly', () async {
      final now = DateTime.now();
      
      await provider.addActivity(Activity(
        id: '1',
        petId: 'pet1',
        name: 'Morning Walk',
        type: 'Walk',
        date: now,
        durationMinutes: 30,
      ));
      
      expect(provider.activities.length, 1);
      
      await provider.deleteActivity('1');
      
      expect(provider.activities.isEmpty, true);
    });
    
    test('Adding photo to activity works correctly', () async {
      final now = DateTime.now();
      
      await provider.addActivity(Activity(
        id: '1',
        petId: 'pet1',
        name: 'Morning Walk',
        type: 'Walk',
        date: now,
        durationMinutes: 30,
      ));
      
      await provider.addPhotoToActivity('1', 'photo1.jpg');
      
      expect(provider.activities[0].photos?.length, 1);
      expect(provider.activities[0].photos?[0], 'photo1.jpg');
      
      await provider.addPhotoToActivity('1', 'photo2.jpg');
      
      expect(provider.activities[0].photos?.length, 2);
      expect(provider.activities[0].photos?[1], 'photo2.jpg');
    });
    
    test('Getting upcoming activities works correctly', () async {
      final now = DateTime.now();
      
      // Past activity
      await provider.addActivity(Activity(
        id: '1',
        petId: 'pet1',
        name: 'Morning Walk',
        type: 'Walk',
        date: now.subtract(const Duration(days: 1)),
        durationMinutes: 30,
        isCompleted: false,
      ));
      
      // Completed activity
      await provider.addActivity(Activity(
        id: '2',
        petId: 'pet1',
        name: 'Training Session',
        type: 'Training',
        date: now.add(const Duration(days: 1)),
        durationMinutes: 20,
        isCompleted: true,
      ));
      
      // Upcoming activity
      await provider.addActivity(Activity(
        id: '3',
        petId: 'pet1',
        name: 'Evening Walk',
        type: 'Walk',
        date: now.add(const Duration(days: 2)),
        durationMinutes: 45,
        isCompleted: false,
      ));
      
      final upcomingActivities = provider.getUpcomingActivitiesForPet('pet1');
      
      expect(upcomingActivities.length, 1);
      expect(upcomingActivities[0].id, '3');
    });
  });
} 