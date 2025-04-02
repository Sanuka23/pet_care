import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/playdate_model.dart';

class PlaydateProvider with ChangeNotifier {
  List<Playdate> _playdates = [];
  final Uuid _uuid = const Uuid();

  // Getters
  List<Playdate> get playdates => _playdates;

  // Get playdates for a specific pet
  List<Playdate> getPlaydatesForPet(String petId) {
    return _playdates.where((playdate) => playdate.petId == petId).toList();
  }

  // Get upcoming playdates for a specific pet
  List<Playdate> getUpcomingPlaydatesForPet(String petId) {
    final now = DateTime.now();
    return _playdates.where((playdate) => 
      playdate.petId == petId && 
      playdate.date.isAfter(now)
    ).toList();
  }

  // Get past playdates for a specific pet
  List<Playdate> getPastPlaydatesForPet(String petId) {
    final now = DateTime.now();
    return _playdates.where((playdate) => 
      playdate.petId == petId && 
      playdate.date.isBefore(now)
    ).toList();
  }

  // Get confirmed playdates for a specific pet
  List<Playdate> getConfirmedPlaydatesForPet(String petId) {
    return _playdates.where((playdate) => 
      playdate.petId == petId && 
      playdate.isConfirmed
    ).toList();
  }

  // Get playdates by location
  List<Playdate> getPlaydatesByLocation(String location) {
    return _playdates.where((playdate) => 
      playdate.location.toLowerCase().contains(location.toLowerCase())
    ).toList();
  }

  // Add a new playdate
  Future<void> addPlaydate(Playdate playdate) async {
    // Generate ID if not provided
    final playdateWithId = playdate.id.isEmpty 
        ? playdate.copyWith(id: _uuid.v4()) 
        : playdate;
        
    _playdates.add(playdateWithId);
    // For testing, we'll skip saving to storage
    // await _savePlaydates();
    notifyListeners();
  }

  // Update an existing playdate
  Future<void> updatePlaydate(Playdate playdate) async {
    final index = _playdates.indexWhere((p) => p.id == playdate.id);
    if (index >= 0) {
      _playdates[index] = playdate;
      // For testing, we'll skip saving to storage
      // await _savePlaydates();
      notifyListeners();
    }
  }

  // Delete a playdate
  Future<void> deletePlaydate(String id) async {
    _playdates.removeWhere((p) => p.id == id);
    // For testing, we'll skip saving to storage
    // await _savePlaydates();
    notifyListeners();
  }

  // Mark playdate as confirmed
  Future<void> confirmPlaydate(String id) async {
    final index = _playdates.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _playdates[index] = _playdates[index].copyWith(isConfirmed: true);
      // For testing, we'll skip saving to storage
      // await _savePlaydates();
      notifyListeners();
    }
  }

  // Add photo to playdate
  Future<void> addPhotoToPlaydate(String id, String photoPath) async {
    final index = _playdates.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final currentPhotos = _playdates[index].photos ?? [];
      final updatedPhotos = List<String>.from(currentPhotos)..add(photoPath);
      
      _playdates[index] = _playdates[index].copyWith(photos: updatedPhotos);
      // For testing, we'll skip saving to storage
      // await _savePlaydates();
      notifyListeners();
    }
  }

  // Add participant to playdate
  Future<void> addParticipantToPlaydate(String id, String participant) async {
    final index = _playdates.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final currentParticipants = _playdates[index].participants;
      if (!currentParticipants.contains(participant)) {
        final updatedParticipants = List<String>.from(currentParticipants)..add(participant);
        
        _playdates[index] = _playdates[index].copyWith(participants: updatedParticipants);
        // For testing, we'll skip saving to storage
        // await _savePlaydates();
        notifyListeners();
      }
    }
  }

  // Remove participant from playdate
  Future<void> removeParticipantFromPlaydate(String id, String participant) async {
    final index = _playdates.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final currentParticipants = _playdates[index].participants;
      if (currentParticipants.contains(participant)) {
        final updatedParticipants = List<String>.from(currentParticipants)..remove(participant);
        
        _playdates[index] = _playdates[index].copyWith(participants: updatedParticipants);
        // For testing, we'll skip saving to storage
        // await _savePlaydates();
        notifyListeners();
      }
    }
  }

  // Load playdates from storage
  Future<void> loadPlaydates() async {
    // For testing, we'll add some mock data instead of loading from storage
    if (_playdates.isEmpty) {
      final now = DateTime.now();
      
      // Mock playdates
      _playdates = [
        Playdate(
          id: 'pd1',
          petId: '1',
          title: 'Park Meetup',
          date: DateTime(now.year, now.month, now.day + 3, 14, 0),
          location: 'Central Park Dog Run',
          durationMinutes: 60,
          participants: ['Max', 'Luna', 'Cooper'],
          contactInfo: 'John - 555-1234',
          notes: 'Bring water and toys',
        ),
        Playdate(
          id: 'pd2',
          petId: '1',
          title: 'Puppy Playgroup',
          date: DateTime(now.year, now.month, now.day - 5, 10, 0),
          location: 'Happy Tails Training Center',
          durationMinutes: 45,
          participants: ['Bella', 'Daisy'],
          isConfirmed: true,
        ),
        Playdate(
          id: 'pd3',
          petId: '2',
          title: 'Beach Day',
          date: DateTime(now.year, now.month, now.day + 10, 11, 0),
          location: 'Dog Beach',
          durationMinutes: 120,
          participants: ['Rocky', 'Charlie', 'Bailey'],
          contactInfo: 'Sarah - 555-5678',
          notes: 'Bring beach towels and sunscreen',
          isConfirmed: true,
        ),
      ];
      
      notifyListeners();
    }
  }

  // Save playdates to storage
  Future<void> _savePlaydates() async {
    // For testing, we'll skip saving to storage
    debugPrint('Saving playdates data (skipped for testing)');
  }
} 