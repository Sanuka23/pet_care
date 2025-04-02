import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/models/playdate_model.dart';
import 'package:pet_care/services/playdate_provider.dart';

class MockPlaydateProvider extends PlaydateProvider {
  @override
  Future<void> loadPlaydates() async {
    // Do nothing in tests
    return;
  }
  
  @override
  Future<void> _savePlaydates() async {
    // Do nothing in tests
    return;
  }
}

void main() {
  group('PlaydateProvider Tests', () {
    late MockPlaydateProvider provider;
    
    setUp(() {
      provider = MockPlaydateProvider();
    });
    
    test('Initial state has empty playdates list', () {
      expect(provider.playdates.isEmpty, true);
    });
    
    test('Adding a playdate works correctly', () async {
      final now = DateTime.now();
      final testPlaydate = Playdate(
        id: '1',
        petId: 'pet1',
        title: 'Park Meetup',
        date: now,
        location: 'Central Park',
        durationMinutes: 60,
        participants: ['Max', 'Luna'],
      );
      
      await provider.addPlaydate(testPlaydate);
      
      expect(provider.playdates.length, 1);
      expect(provider.playdates[0].title, 'Park Meetup');
      expect(provider.playdates[0].petId, 'pet1');
    });
    
    test('Getting playdates for specific pet works correctly', () async {
      final now = DateTime.now();
      
      // Add playdate for pet1
      await provider.addPlaydate(Playdate(
        id: '1',
        petId: 'pet1',
        title: 'Park Meetup',
        date: now,
        location: 'Central Park',
        durationMinutes: 60,
        participants: ['Max', 'Luna'],
      ));
      
      // Add playdate for pet2
      await provider.addPlaydate(Playdate(
        id: '2',
        petId: 'pet2',
        title: 'Beach Day',
        date: now,
        location: 'Dog Beach',
        durationMinutes: 90,
        participants: ['Rocky', 'Charlie'],
      ));
      
      final pet1Playdates = provider.getPlaydatesForPet('pet1');
      final pet2Playdates = provider.getPlaydatesForPet('pet2');
      
      expect(pet1Playdates.length, 1);
      expect(pet2Playdates.length, 1);
      expect(pet1Playdates[0].title, 'Park Meetup');
      expect(pet2Playdates[0].title, 'Beach Day');
    });
    
    test('Getting playdates by date range works correctly', () async {
      final now = DateTime.now();
      
      // Add past playdate
      await provider.addPlaydate(Playdate(
        id: '1',
        petId: 'pet1',
        title: 'Past Meetup',
        date: now.subtract(const Duration(days: 2)),
        location: 'Central Park',
        durationMinutes: 60,
        participants: ['Max', 'Luna'],
      ));
      
      // Add future playdate
      await provider.addPlaydate(Playdate(
        id: '2',
        petId: 'pet1',
        title: 'Future Meetup',
        date: now.add(const Duration(days: 2)),
        location: 'Dog Beach',
        durationMinutes: 90,
        participants: ['Rocky', 'Charlie'],
      ));
      
      final pastPlaydates = provider.getPastPlaydatesForPet('pet1');
      final upcomingPlaydates = provider.getUpcomingPlaydatesForPet('pet1');
      
      expect(pastPlaydates.length, 1);
      expect(upcomingPlaydates.length, 1);
      expect(pastPlaydates[0].title, 'Past Meetup');
      expect(upcomingPlaydates[0].title, 'Future Meetup');
    });
    
    test('Confirming a playdate works correctly', () async {
      final now = DateTime.now();
      
      await provider.addPlaydate(Playdate(
        id: '1',
        petId: 'pet1',
        title: 'Park Meetup',
        date: now,
        location: 'Central Park',
        durationMinutes: 60,
        participants: ['Max', 'Luna'],
        isConfirmed: false,
      ));
      
      expect(provider.playdates[0].isConfirmed, false);
      
      await provider.confirmPlaydate('1');
      
      expect(provider.playdates[0].isConfirmed, true);
    });
    
    test('Updating a playdate works correctly', () async {
      final now = DateTime.now();
      
      await provider.addPlaydate(Playdate(
        id: '1',
        petId: 'pet1',
        title: 'Park Meetup',
        date: now,
        location: 'Central Park',
        durationMinutes: 60,
        participants: ['Max', 'Luna'],
      ));
      
      final updatedPlaydate = Playdate(
        id: '1',
        petId: 'pet1',
        title: 'Updated Meetup',
        date: now,
        location: 'Dog Park',
        durationMinutes: 90,
        participants: ['Max', 'Luna', 'Cooper'],
      );
      
      await provider.updatePlaydate(updatedPlaydate);
      
      expect(provider.playdates[0].title, 'Updated Meetup');
      expect(provider.playdates[0].location, 'Dog Park');
      expect(provider.playdates[0].durationMinutes, 90);
      expect(provider.playdates[0].participants.length, 3);
    });
    
    test('Deleting a playdate works correctly', () async {
      final now = DateTime.now();
      
      await provider.addPlaydate(Playdate(
        id: '1',
        petId: 'pet1',
        title: 'Park Meetup',
        date: now,
        location: 'Central Park',
        durationMinutes: 60,
        participants: ['Max', 'Luna'],
      ));
      
      expect(provider.playdates.length, 1);
      
      await provider.deletePlaydate('1');
      
      expect(provider.playdates.isEmpty, true);
    });
    
    test('Adding and removing participants works correctly', () async {
      final now = DateTime.now();
      
      await provider.addPlaydate(Playdate(
        id: '1',
        petId: 'pet1',
        title: 'Park Meetup',
        date: now,
        location: 'Central Park',
        durationMinutes: 60,
        participants: ['Max', 'Luna'],
      ));
      
      await provider.addParticipantToPlaydate('1', 'Cooper');
      
      expect(provider.playdates[0].participants.length, 3);
      expect(provider.playdates[0].participants.contains('Cooper'), true);
      
      await provider.removeParticipantFromPlaydate('1', 'Luna');
      
      expect(provider.playdates[0].participants.length, 2);
      expect(provider.playdates[0].participants.contains('Luna'), false);
    });
    
    test('Getting playdates by location works correctly', () async {
      final now = DateTime.now();
      
      // Add playdates with different locations
      await provider.addPlaydate(Playdate(
        id: '1',
        petId: 'pet1',
        title: 'Park Meetup',
        date: now,
        location: 'Central Park',
        durationMinutes: 60,
        participants: ['Max', 'Luna'],
      ));
      
      await provider.addPlaydate(Playdate(
        id: '2',
        petId: 'pet1',
        title: 'Beach Day',
        date: now,
        location: 'Dog Beach',
        durationMinutes: 90,
        participants: ['Rocky', 'Charlie'],
      ));
      
      await provider.addPlaydate(Playdate(
        id: '3',
        petId: 'pet2',
        title: 'Training Session',
        date: now,
        location: 'Pet Training Center',
        durationMinutes: 45,
        participants: ['Bella'],
      ));
      
      final parkPlaydates = provider.getPlaydatesByLocation('park');
      
      expect(parkPlaydates.length, 1);
      expect(parkPlaydates[0].title, 'Park Meetup');
    });
  });
} 