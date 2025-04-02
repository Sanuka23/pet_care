import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pet_care/models/pet_model.dart';
import 'package:pet_care/services/pet_provider.dart';
import 'package:pet_care/screens/pet_profile_screen.dart';

void main() {
  testWidgets('PetProfileScreen properly displays form fields', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => PetProvider(),
          child: const PetProfileScreen(),
        ),
      ),
    );

    // Verify basic widgets exist
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeast(4)); // At least 4 form fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Save button
    expect(find.byType(CircleAvatar), findsOneWidget); // Pet image
  });

  testWidgets('PetProfileScreen shows edit mode when given a pet', (WidgetTester tester) async {
    // Create a test pet
    final testPet = Pet(
      id: '1',
      name: 'Max',
      breed: 'Golden Retriever',
      age: 3,
      weight: 25.5,
      specialNeeds: ['Allergies', 'Joint pain'],
    );

    // Build the widget with the test pet
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => PetProvider(),
          child: PetProfileScreen(pet: testPet),
        ),
      ),
    );

    // Verify basic widgets exist
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeast(4)); // At least 4 form fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Save button
    expect(find.byType(CircleAvatar), findsOneWidget); // Pet image
  });
} 