import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/main.dart';
import 'package:provider/provider.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/services/vaccination_provider.dart';
import 'package:pet_care/services/appointment_provider.dart';
import 'package:pet_care/services/feeding_provider.dart';
import 'package:pet_care/services/activity_provider.dart';
import 'package:pet_care/screens/home_screen.dart';

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

class MockVaccinationProvider extends VaccinationProvider {
  @override
  Future<void> loadVaccinations() async {
    // Do nothing in tests
    return;
  }
  
  @override
  Future<void> _saveVaccinations() async {
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
  
  testWidgets('App initializes with providers correctly', (WidgetTester tester) async {
    final mockPetProvider = MockPetProvider();
    final mockVaccinationProvider = MockVaccinationProvider();
    final mockAppointmentProvider = MockAppointmentProvider();
    final mockFeedingProvider = MockFeedingProvider();
    final mockActivityProvider = MockActivityProvider();
    
    // Build our app with mock providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PetProvider>.value(value: mockPetProvider),
          ChangeNotifierProvider<VaccinationProvider>.value(value: mockVaccinationProvider),
          ChangeNotifierProvider<AppointmentProvider>.value(value: mockAppointmentProvider),
          ChangeNotifierProvider<FeedingProvider>.value(value: mockFeedingProvider),
          ChangeNotifierProvider<ActivityProvider>.value(value: mockActivityProvider),
        ],
        child: MaterialApp(
          home: HomeScreen(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              secondary: Colors.amber,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            useMaterial3: true,
          ),
        ),
      ),
    );

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify that basic structure is in place
    expect(find.byType(AppBar), findsOneWidget);
    
    // Should be using bottom navigation bar
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
} 