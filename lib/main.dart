import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/pet_provider.dart';
import 'services/vaccination_provider.dart';
import 'services/appointment_provider.dart';
import 'services/feeding_provider.dart';
import 'services/activity_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PetProvider()),
        ChangeNotifierProvider(create: (context) => VaccinationProvider()),
        ChangeNotifierProvider(create: (context) => AppointmentProvider()),
        ChangeNotifierProvider(create: (context) => FeedingProvider()),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
      ],
      child: const PetCareApp(),
    ),
  );
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Care',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          secondary: Colors.amber,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
