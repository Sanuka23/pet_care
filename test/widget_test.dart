import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/main.dart';
import 'package:provider/provider.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/services/vaccination_provider.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('App initializes properly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => MockPetProvider()),
          ChangeNotifierProvider(create: (context) => MockVaccinationProvider()),
        ],
        child: const PetCareApp(),
      ),
    );

    // Verify that the app renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Verify that Quick Actions section exists
    expect(find.text('Quick Actions'), findsOneWidget);
    
    // Verify Add Pet button exists
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
} 