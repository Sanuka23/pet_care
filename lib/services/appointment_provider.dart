import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/appointment_model.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  final Uuid _uuid = const Uuid();

  List<Appointment> get appointments => _appointments;

  // Get appointments for a specific pet
  List<Appointment> getAppointmentsForPet(String petId) {
    return _appointments.where((a) => a.petId == petId).toList();
  }

  // Get upcoming appointments for a specific pet
  List<Appointment> getUpcomingAppointmentsForPet(String petId) {
    final now = DateTime.now();
    return _appointments
        .where((a) => a.petId == petId && a.dateTime.isAfter(now) && !a.isCompleted)
        .toList();
  }

  // Get next upcoming appointment for a specific pet
  Appointment? getNextAppointmentForPet(String petId) {
    final upcomingAppointments = getUpcomingAppointmentsForPet(petId);
    if (upcomingAppointments.isEmpty) return null;
    
    // Sort by date (earliest first)
    upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcomingAppointments.first;
  }

  // Add a new appointment
  Future<void> addAppointment(Appointment appointment) async {
    // Generate ID if not provided
    final appointmentWithId = appointment.id.isEmpty 
        ? appointment.copyWith(id: _uuid.v4()) 
        : appointment;
        
    _appointments.add(appointmentWithId);
    // For testing, we'll skip saving to storage
    // await _saveAppointments();
    notifyListeners();
  }

  // Update an existing appointment
  Future<void> updateAppointment(Appointment appointment) async {
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index >= 0) {
      _appointments[index] = appointment;
      // For testing, we'll skip saving to storage
      // await _saveAppointments();
      notifyListeners();
    }
  }

  // Delete an appointment
  Future<void> deleteAppointment(String id) async {
    _appointments.removeWhere((a) => a.id == id);
    // For testing, we'll skip saving to storage
    // await _saveAppointments();
    notifyListeners();
  }

  // Mark appointment as completed
  Future<void> completeAppointment(String id) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _appointments[index] = _appointments[index].copyWith(isCompleted: true);
      // For testing, we'll skip saving to storage
      // await _saveAppointments();
      notifyListeners();
    }
  }

  // Load appointments from local storage
  Future<void> loadAppointments() async {
    // For testing, we'll add some mock data instead of loading from storage
    if (_appointments.isEmpty) {
      final now = DateTime.now();
      _appointments = [
        Appointment(
          id: 'app1',
          title: 'Annual Checkup',
          dateTime: DateTime(now.year, now.month, now.day + 7, 14, 30),
          vetName: 'Dr. Johnson',
          vetLocation: 'City Vet Clinic',
          petId: '1',
          notes: 'Bring vaccination records',
        ),
        Appointment(
          id: 'app2',
          title: 'Dental Cleaning',
          dateTime: DateTime(now.year, now.month, now.day + 14, 10, 0),
          vetName: 'Dr. Martinez',
          vetLocation: 'PetCare Center',
          petId: '1',
        ),
        Appointment(
          id: 'app3',
          title: 'Vaccination Booster',
          dateTime: DateTime(now.year, now.month - 1, now.day, 9, 0),
          vetName: 'Dr. Rodriguez',
          vetLocation: 'Animal Hospital',
          petId: '2',
          isCompleted: true,
        ),
      ];
      
      notifyListeners();
    }
  }

  // Save appointments to local storage
  Future<void> _saveAppointments() async {
    // For testing, we'll skip saving to storage
    debugPrint('Saving appointments (skipped for testing)');
  }
} 