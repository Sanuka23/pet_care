import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/models/appointment_model.dart';
import 'package:pet_care/services/appointment_provider.dart';

class MockAppointmentProvider extends AppointmentProvider {
  @override
  Future<void> loadAppointments() async {
    // Do nothing in tests
    return;
  }
  
  @override
  Future<void> _saveAppointments() async {
    // Do nothing in tests
    return;
  }
}

void main() {
  group('AppointmentProvider Tests', () {
    late MockAppointmentProvider provider;
    
    setUp(() {
      provider = MockAppointmentProvider();
    });
    
    test('Initial state has empty appointments list', () {
      expect(provider.appointments.isEmpty, true);
    });
    
    test('Adding an appointment works correctly', () async {
      final testAppointment = Appointment(
        id: '1',
        title: 'Annual Checkup',
        dateTime: DateTime(2023, 1, 1, 14, 30),
        vetName: 'Dr. Smith',
        vetLocation: 'City Vet Clinic',
        petId: 'pet1',
      );
      
      await provider.addAppointment(testAppointment);
      
      expect(provider.appointments.length, 1);
      expect(provider.appointments[0].title, 'Annual Checkup');
      expect(provider.appointments[0].petId, 'pet1');
    });
    
    test('Getting appointments for specific pet works correctly', () async {
      // Add appointment for pet1
      await provider.addAppointment(Appointment(
        id: '1',
        title: 'Annual Checkup',
        dateTime: DateTime(2023, 1, 1, 14, 30),
        vetName: 'Dr. Smith',
        vetLocation: 'City Vet Clinic',
        petId: 'pet1',
      ));
      
      // Add appointment for pet2
      await provider.addAppointment(Appointment(
        id: '2',
        title: 'Dental Cleaning',
        dateTime: DateTime(2023, 2, 1, 10, 0),
        vetName: 'Dr. Johnson',
        vetLocation: 'Pet Hospital',
        petId: 'pet2',
      ));
      
      final pet1Appointments = provider.getAppointmentsForPet('pet1');
      final pet2Appointments = provider.getAppointmentsForPet('pet2');
      
      expect(pet1Appointments.length, 1);
      expect(pet2Appointments.length, 1);
      expect(pet1Appointments[0].title, 'Annual Checkup');
      expect(pet2Appointments[0].title, 'Dental Cleaning');
    });
    
    test('Marking an appointment as completed works correctly', () async {
      await provider.addAppointment(Appointment(
        id: '1',
        title: 'Annual Checkup',
        dateTime: DateTime(2023, 1, 1, 14, 30),
        vetName: 'Dr. Smith',
        vetLocation: 'City Vet Clinic',
        petId: 'pet1',
        isCompleted: false,
      ));
      
      await provider.completeAppointment('1');
      
      expect(provider.appointments[0].isCompleted, true);
    });
    
    test('Deleting an appointment works correctly', () async {
      await provider.addAppointment(Appointment(
        id: '1',
        title: 'Annual Checkup',
        dateTime: DateTime(2023, 1, 1, 14, 30),
        vetName: 'Dr. Smith',
        vetLocation: 'City Vet Clinic',
        petId: 'pet1',
      ));
      
      expect(provider.appointments.length, 1);
      
      await provider.deleteAppointment('1');
      
      expect(provider.appointments.isEmpty, true);
    });
    
    test('Getting upcoming appointments works correctly', () async {
      final now = DateTime.now();
      
      // Past appointment (already completed)
      await provider.addAppointment(Appointment(
        id: '1',
        title: 'Past Appointment',
        dateTime: now.subtract(const Duration(days: 30)),
        vetName: 'Dr. Smith',
        vetLocation: 'City Vet Clinic',
        petId: 'pet1',
        isCompleted: true,
      ));
      
      // Upcoming appointment
      await provider.addAppointment(Appointment(
        id: '2',
        title: 'Future Appointment',
        dateTime: now.add(const Duration(days: 30)),
        vetName: 'Dr. Johnson',
        vetLocation: 'Pet Hospital',
        petId: 'pet1',
        isCompleted: false,
      ));
      
      final upcomingAppointments = provider.getUpcomingAppointmentsForPet('pet1');
      
      expect(upcomingAppointments.length, 1);
      expect(upcomingAppointments[0].title, 'Future Appointment');
    });
    
    test('Getting next appointment works correctly', () async {
      final now = DateTime.now();
      
      // Add two future appointments
      await provider.addAppointment(Appointment(
        id: '1',
        title: 'Later Appointment',
        dateTime: now.add(const Duration(days: 30)),
        vetName: 'Dr. Smith',
        vetLocation: 'City Vet Clinic',
        petId: 'pet1',
      ));
      
      await provider.addAppointment(Appointment(
        id: '2',
        title: 'Sooner Appointment',
        dateTime: now.add(const Duration(days: 7)),
        vetName: 'Dr. Johnson',
        vetLocation: 'Pet Hospital',
        petId: 'pet1',
      ));
      
      final nextAppointment = provider.getNextAppointmentForPet('pet1');
      
      expect(nextAppointment, isNotNull);
      expect(nextAppointment!.title, 'Sooner Appointment');
    });
  });
} 