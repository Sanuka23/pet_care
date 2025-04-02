import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/main.dart';
import 'package:provider/provider.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/services/vaccination_provider.dart';

void main() {
  testWidgets('App initializes properly', (WidgetTester tester) async {
    // Build our app with providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => PetProvider()),
          ChangeNotifierProvider(create: (context) => VaccinationProvider(isTest: true)),
        ],
        child: const PetCareApp(),
      ),
    );

    // Wait for the UI to settle
    await tester.pump();

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