import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pet_care/models/appointment_model.dart';
import 'package:pet_care/models/pet_model.dart';
import 'package:pet_care/services/appointment_provider.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/screens/appointment_screen.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppointmentScreen Widget Tests', () {
    late MockPetProvider petProvider;
    late MockAppointmentProvider appointmentProvider;
    
    setUp(() {
      petProvider = MockPetProvider();
      appointmentProvider = MockAppointmentProvider();
      
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
      
      // Add some test appointments
      final now = DateTime.now();
      appointmentProvider.addAppointment(Appointment(
        id: 'app1',
        title: 'Annual Checkup',
        dateTime: now.add(const Duration(days: 7)),
        vetName: 'Dr. Johnson',
        vetLocation: 'City Vet Clinic',
        petId: 'pet1',
      ));
      
      appointmentProvider.addAppointment(Appointment(
        id: 'app2',
        title: 'Vaccination',
        dateTime: now.subtract(const Duration(days: 30)),
        vetName: 'Dr. Smith',
        vetLocation: 'Pet Hospital',
        petId: 'pet1',
        isCompleted: true,
      ));
    });
    
    testWidgets('AppointmentScreen displays appointments correctly', (WidgetTester tester) async {
      // Build the AppointmentScreen widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PetProvider>.value(value: petProvider),
            ChangeNotifierProvider<AppointmentProvider>.value(value: appointmentProvider),
          ],
          child: const MaterialApp(
            home: AppointmentScreen(),
          ),
        ),
      );
      
      // Wait for the widget to build
      await tester.pumpAndSettle();
      
      // Verify that the AppBar shows correctly
      expect(find.text('Buddy\'s Appointments'), findsOneWidget);
      
      // Verify that both appointments are displayed
      expect(find.text('Annual Checkup'), findsOneWidget);
      expect(find.text('Vaccination'), findsOneWidget);
      
      // Verify section headings
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      
      // Verify that there's a floating action button to add appointments
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
} 