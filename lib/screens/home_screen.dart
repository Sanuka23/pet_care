import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'vaccination_screen.dart';
import 'appointment_screen.dart';
import 'feeding_screen.dart';
import 'activity_screen.dart';
import 'playdate_screen.dart';
import 'pet_profile_screen.dart';
import '../services/pet_provider.dart';
import '../services/vaccination_provider.dart';
import '../models/pet_model.dart';
import '../models/vaccination_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Pet loading is now done in main.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Care'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pets),
            onPressed: _showPetSelector,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Vaccinations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Feeding',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Activity',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void _showPetSelector() {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pets = petProvider.pets;
    
    if (pets.isEmpty) {
      // If no pets, navigate directly to add pet screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PetProfileScreen()),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Select Pet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ...pets.map((pet) => ListTile(
              leading: pet.imageUrl != null
                ? CircleAvatar(
                    backgroundImage: FileImage(File(pet.imageUrl!)),
                  )
                : const CircleAvatar(
                    child: Icon(Icons.pets),
                  ),
              title: Text(pet.name),
              subtitle: Text('${pet.breed}, ${pet.age} years'),
              onTap: () {
                petProvider.setCurrentPet(pet);
                Navigator.pop(context);
              },
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetProfileScreen(pet: pet),
                    ),
                  );
                },
              ),
            )),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.add),
              ),
              title: const Text('Add New Pet'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PetProfileScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const VaccinationScreen();
      case 2:
        return const AppointmentScreen();
      case 3:
        return const FeedingScreen();
      case 4:
        return const ActivityScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final currentPet = petProvider.currentPet;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              currentPet != null
                ? _buildPetProfileCard(currentPet)
                : _buildAddPetCard(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildRecentActivities(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPetProfileCard(Pet pet) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (pet.imageUrl != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(File(pet.imageUrl!)),
              )
            else
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.pets, size: 50, color: Colors.white),
              ),
            const SizedBox(height: 10),
            Text(
              pet.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              '${pet.breed}, ${pet.age} years old, ${pet.weight} kg',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (pet.specialNeeds != null && pet.specialNeeds!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: pet.specialNeeds!.map((need) => Chip(
                  label: Text(need),
                  backgroundColor: Colors.blue.shade50,
                )).toList(),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetProfileScreen(pet: pet),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _showPetSelector,
                  icon: const Icon(Icons.pets),
                  label: const Text('Switch Pet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPetCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.pets, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add Your Pet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Tap to add pet profile',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PetProfileScreen(),
                  ),
                );
              },
              child: const Text('Add Pet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final currentPet = Provider.of<PetProvider>(context).currentPet;
    final vaccinationProvider = Provider.of<VaccinationProvider>(context);
    
    Vaccination? nextVaccination;
    String? nextVaccinationText;
    
    if (currentPet != null) {
      nextVaccination = vaccinationProvider.getNextVaccinationForPet(currentPet.id);
      if (nextVaccination != null) {
        nextVaccinationText = 'Due: ${DateFormat('MMM d').format(nextVaccination.nextDueDate)}';
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _buildQuickActionCard(
              'Vaccinations', 
              Icons.medical_services, 
              () {
                setState(() => _currentIndex = 1);
              },
              subtitle: nextVaccinationText,
              subtitleColor: nextVaccination != null && 
                            nextVaccination.nextDueDate.isBefore(DateTime.now()) ? 
                            Colors.red : null,
            ),
            _buildQuickActionCard('Appointments', Icons.calendar_today, () {
              setState(() => _currentIndex = 2);
            }),
            _buildQuickActionCard('Feeding', Icons.restaurant, () {
              setState(() => _currentIndex = 3);
            }),
            _buildQuickActionCard('Activity', Icons.directions_walk, () {
              setState(() => _currentIndex = 4);
            }),
            _buildQuickActionCard('Playdates', Icons.people, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlaydateScreen()),
              );
            }),
            _buildQuickActionCard('Reminders', Icons.notifications, () {
              // Will be implemented later
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title, 
    IconData icon, 
    VoidCallback onTap, {
    String? subtitle,
    Color? subtitleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor ?? Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final currentPet = petProvider.currentPet;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: currentPet == null
                ? const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('No recent activities'),
                    subtitle: Text('Add a pet to get started'),
                  )
                : const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('No recent activities'),
                    subtitle: Text('Your activities will appear here'),
                  ),
            ),
          ],
        );
      },
    );
  }
} 