import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/models/feeding_model.dart';
import 'package:pet_care/services/feeding_provider.dart';

class MockFeedingProvider extends FeedingProvider {
  MockFeedingProvider() : super(isTest: true);
}

void main() {
  group('FeedingProvider Tests', () {
    late MockFeedingProvider provider;
    
    setUp(() {
      provider = MockFeedingProvider();
    });
    
    test('Initial state has empty feedings list', () {
      expect(provider.feedings.isEmpty, true);
    });
    
    test('Adding a feeding schedule works correctly', () async {
      final testFeeding = Feeding(
        id: '1',
        petId: 'pet1',
        foodName: 'Premium Dry Food',
        portionSize: '1 cup',
        frequency: FeedingFrequency.daily,
        feedingTimes: [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 18, minute: 0)
        ],
      );
      
      await provider.addFeeding(testFeeding);
      
      expect(provider.feedings.length, 1);
      expect(provider.feedings[0].foodName, 'Premium Dry Food');
      expect(provider.feedings[0].petId, 'pet1');
      expect(provider.feedings[0].feedingTimes.length, 2);
    });
    
    test('Getting feedings for specific pet works correctly', () async {
      // Add feeding for pet1
      await provider.addFeeding(Feeding(
        id: '1',
        petId: 'pet1',
        foodName: 'Premium Dry Food',
        portionSize: '1 cup',
        frequency: FeedingFrequency.daily,
        feedingTimes: [const TimeOfDay(hour: 8, minute: 0)],
      ));
      
      // Add feeding for pet2
      await provider.addFeeding(Feeding(
        id: '2',
        petId: 'pet2',
        foodName: 'Wet Food',
        portionSize: '100g',
        frequency: FeedingFrequency.daily,
        feedingTimes: [const TimeOfDay(hour: 7, minute: 30)],
      ));
      
      final pet1Feedings = provider.getFeedingsForPet('pet1');
      final pet2Feedings = provider.getFeedingsForPet('pet2');
      
      expect(pet1Feedings.length, 1);
      expect(pet2Feedings.length, 1);
      expect(pet1Feedings[0].foodName, 'Premium Dry Food');
      expect(pet2Feedings[0].foodName, 'Wet Food');
    });
    
    test('Toggling active status works correctly', () async {
      await provider.addFeeding(Feeding(
        id: '1',
        petId: 'pet1',
        foodName: 'Premium Dry Food',
        portionSize: '1 cup',
        frequency: FeedingFrequency.daily,
        feedingTimes: [const TimeOfDay(hour: 8, minute: 0)],
        isActive: true,
      ));
      
      await provider.toggleFeedingActive('1');
      
      expect(provider.feedings[0].isActive, false);
      
      await provider.toggleFeedingActive('1');
      
      expect(provider.feedings[0].isActive, true);
    });
    
    test('Adding a feeding record works correctly', () async {
      await provider.addFeeding(Feeding(
        id: '1',
        petId: 'pet1',
        foodName: 'Premium Dry Food',
        portionSize: '1 cup',
        frequency: FeedingFrequency.daily,
        feedingTimes: [const TimeOfDay(hour: 8, minute: 0)],
      ));
      
      final record = FeedingRecord(
        id: 'record1',
        timestamp: DateTime.now(),
        completed: true,
        notes: 'Ate well',
      );
      
      await provider.addFeedingRecord('1', record);
      
      expect(provider.feedings[0].feedingHistory.length, 1);
      expect(provider.feedings[0].feedingHistory[0].notes, 'Ate well');
    });
    
    test('Getting active feedings works correctly', () async {
      await provider.addFeeding(Feeding(
        id: '1',
        petId: 'pet1',
        foodName: 'Active Food',
        portionSize: '1 cup',
        frequency: FeedingFrequency.daily,
        feedingTimes: [const TimeOfDay(hour: 8, minute: 0)],
        isActive: true,
      ));
      
      await provider.addFeeding(Feeding(
        id: '2',
        petId: 'pet1',
        foodName: 'Inactive Food',
        portionSize: '1 cup',
        frequency: FeedingFrequency.daily,
        feedingTimes: [const TimeOfDay(hour: 8, minute: 0)],
        isActive: false,
      ));
      
      final activeFeedings = provider.getActiveFeedingsForPet('pet1');
      
      expect(activeFeedings.length, 1);
      expect(activeFeedings[0].foodName, 'Active Food');
    });
    
    test('Deleting a feeding works correctly', () async {
      await provider.addFeeding(Feeding(
        id: '1',
        petId: 'pet1',
        foodName: 'Premium Dry Food',
        portionSize: '1 cup',
        frequency: FeedingFrequency.daily,
        feedingTimes: [const TimeOfDay(hour: 8, minute: 0)],
      ));
      
      expect(provider.feedings.length, 1);
      
      await provider.deleteFeeding('1');
      
      expect(provider.feedings.isEmpty, true);
    });
  });
} 