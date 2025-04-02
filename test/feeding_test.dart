import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/models/feeding_model.dart';
import 'package:pet_care/services/feeding_provider.dart';

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
  group('FeedingProvider Tests', () {
    late MockFeedingProvider provider;
    
    setUp(() {
      provider = MockFeedingProvider();
    });
    
    test('Initial state has empty schedules and logs lists', () {
      expect(provider.schedules.isEmpty, true);
      expect(provider.logs.isEmpty, true);
    });
    
    test('Adding a feeding schedule works correctly', () async {
      final testSchedule = FeedingSchedule(
        id: '1',
        petId: 'pet1',
        name: 'Morning Feed',
        foodType: 'Dry Food',
        amount: 1.5,
        unit: 'cups',
        times: [FeedingTime(hour: 8, minute: 0)],
      );
      
      await provider.addSchedule(testSchedule);
      
      expect(provider.schedules.length, 1);
      expect(provider.schedules[0].name, 'Morning Feed');
      expect(provider.schedules[0].petId, 'pet1');
    });
    
    test('Getting schedules for specific pet works correctly', () async {
      // Add schedule for pet1
      await provider.addSchedule(FeedingSchedule(
        id: '1',
        petId: 'pet1',
        name: 'Morning Feed',
        foodType: 'Dry Food',
        amount: 1.5,
        unit: 'cups',
        times: [FeedingTime(hour: 8, minute: 0)],
      ));
      
      // Add schedule for pet2
      await provider.addSchedule(FeedingSchedule(
        id: '2',
        petId: 'pet2',
        name: 'Evening Feed',
        foodType: 'Wet Food',
        amount: 1.0,
        unit: 'cans',
        times: [FeedingTime(hour: 18, minute: 0)],
      ));
      
      final pet1Schedules = provider.getSchedulesForPet('pet1');
      final pet2Schedules = provider.getSchedulesForPet('pet2');
      
      expect(pet1Schedules.length, 1);
      expect(pet2Schedules.length, 1);
      expect(pet1Schedules[0].name, 'Morning Feed');
      expect(pet2Schedules[0].name, 'Evening Feed');
    });
    
    test('Toggling active state of a schedule works correctly', () async {
      await provider.addSchedule(FeedingSchedule(
        id: '1',
        petId: 'pet1',
        name: 'Morning Feed',
        foodType: 'Dry Food',
        amount: 1.5,
        unit: 'cups',
        times: [FeedingTime(hour: 8, minute: 0)],
        isActive: true,
      ));
      
      await provider.toggleScheduleActive('1');
      
      expect(provider.schedules[0].isActive, false);
      
      await provider.toggleScheduleActive('1');
      
      expect(provider.schedules[0].isActive, true);
    });
    
    test('Adding and retrieving feeding logs works correctly', () async {
      // Add a schedule
      await provider.addSchedule(FeedingSchedule(
        id: 'schedule1',
        petId: 'pet1',
        name: 'Morning Feed',
        foodType: 'Dry Food',
        amount: 1.5,
        unit: 'cups',
        times: [FeedingTime(hour: 8, minute: 0)],
      ));
      
      // Add a log entry
      final now = DateTime.now();
      await provider.addLog(FeedingLog(
        id: 'log1',
        scheduleId: 'schedule1',
        petId: 'pet1',
        timestamp: now,
        amount: 1.5,
        unit: 'cups',
        foodType: 'Dry Food',
      ));
      
      expect(provider.logs.length, 1);
      
      // Get logs for the pet
      final petLogs = provider.getLogsForPet('pet1');
      expect(petLogs.length, 1);
      
      // Get logs for the schedule
      final scheduleLogs = provider.getLogsForSchedule('schedule1');
      expect(scheduleLogs.length, 1);
      
      // Get today's logs
      final todayLogs = provider.getTodayLogsForPet('pet1');
      expect(todayLogs.length, 1);
      
      // Add a log for yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await provider.addLog(FeedingLog(
        id: 'log2',
        scheduleId: 'schedule1',
        petId: 'pet1',
        timestamp: yesterday,
        amount: 1.5,
        unit: 'cups',
        foodType: 'Dry Food',
      ));
      
      // Today's logs should still be 1
      final todayLogsAfterAdd = provider.getTodayLogsForPet('pet1');
      expect(todayLogsAfterAdd.length, 1);
      
      // Recent logs (30 days) should be 2
      final recentLogs = provider.getRecentLogsForPet('pet1');
      expect(recentLogs.length, 2);
    });
    
    test('Deleting a schedule works correctly', () async {
      await provider.addSchedule(FeedingSchedule(
        id: '1',
        petId: 'pet1',
        name: 'Morning Feed',
        foodType: 'Dry Food',
        amount: 1.5,
        unit: 'cups',
        times: [FeedingTime(hour: 8, minute: 0)],
      ));
      
      expect(provider.schedules.length, 1);
      
      await provider.deleteSchedule('1');
      
      expect(provider.schedules.isEmpty, true);
    });
    
    test('Deleting a log works correctly', () async {
      await provider.addLog(FeedingLog(
        id: 'log1',
        scheduleId: 'schedule1',
        petId: 'pet1',
        timestamp: DateTime.now(),
        amount: 1.5,
        unit: 'cups',
        foodType: 'Dry Food',
      ));
      
      expect(provider.logs.length, 1);
      
      await provider.deleteLog('log1');
      
      expect(provider.logs.isEmpty, true);
    });
  });
} 