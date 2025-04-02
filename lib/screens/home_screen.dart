import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'vaccination_screen.dart';
import 'appointment_screen.dart';
import 'feeding_screen.dart';
import 'activity_screen.dart';
import 'playdate_screen.dart';
import 'pet_profile_screen.dart';
import '../services/pet_provider.dart';
import '../services/vaccination_provider.dart';
import '../services/appointment_provider.dart';
import '../services/feeding_provider.dart';
import '../services/playdate_provider.dart';
import '../services/activity_provider.dart';
import '../models/pet_model.dart';
import '../models/vaccination_model.dart';
import '../models/appointment_model.dart';
import '../models/feeding_model.dart';
import '../models/activity_model.dart';
import 'reminder_screen.dart';
import 'dart:io';

// String extension for capitalize
extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
}

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
    // Load data when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load vaccinations
      Provider.of<VaccinationProvider>(context, listen: false).loadVaccinations();
      // Load appointments
      Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
      // Load feedings
      Provider.of<FeedingProvider>(context, listen: false).loadData();
      // Load activities
      Provider.of<ActivityProvider>(context, listen: false).loadActivities();
      // Load playdates
      Provider.of<PlaydateProvider>(context, listen: false).loadPlaydates();
    });
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
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Reminders',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReminderScreen(),
                ),
              );
            },
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
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                backgroundImage: pet.imageUrl != null
                    ? FileImage(File(pet.imageUrl!))
                    : null,
                child: pet.imageUrl == null
                    ? Icon(Icons.pets, color: Theme.of(context).primaryColor)
                    : null,
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
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: pet.imageUrl != null ? FileImage(File(pet.imageUrl!)) : null,
                  child: pet.imageUrl == null
                      ? Icon(
                          Icons.pets,
                          size: 35,
                          color: Colors.grey[600],
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet.breed}, ${pet.age} years old, ${pet.weight} kg',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (pet.specialNeeds != null && pet.specialNeeds!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: pet.specialNeeds!.map((need) => Chip(
                  label: Text(
                    need,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(color: Colors.grey[800]),
                )).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetProfileScreen(pet: pet),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showPetSelector,
                    icon: const Icon(Icons.pets, size: 18),
                    label: const Text('Switch Pet'),
                  ),
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
            _buildQuickActionCard('Vaccinations', Icons.medical_services, () {
              setState(() => _currentIndex = 1);
            }),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReminderScreen()),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
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
        
        if (currentPet == null) {
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
                child: const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('No recent activities'),
                  subtitle: Text('Add a pet to get started'),
                ),
              ),
            ],
          );
        }
        
        return Consumer4<AppointmentProvider, PlaydateProvider, FeedingProvider, ActivityProvider>(
          builder: (context, appointmentProvider, playdateProvider, feedingProvider, activityProvider, child) {
            // Get recent completed appointments
            final completedAppointments = appointmentProvider.appointments
                .where((appointment) => 
                    appointment.petId == currentPet.id && 
                    appointment.isCompleted)
                .toList();
                
            // Sort by date (newest first)
            completedAppointments.sort((a, b) => 
                b.dateTime.compareTo(a.dateTime));
                
            final recentAppointments = completedAppointments.take(3).toList();
            
            // Get recent playdates (past playdates)
            final pastPlaydates = playdateProvider.getPastPlaydatesForPet(currentPet.id);
            
            // Sort by date (newest first)
            pastPlaydates.sort((a, b) => b.date.compareTo(a.date));
            
            final recentPlaydates = pastPlaydates.take(3).toList();
            
            // Get recent feeding logs
            final recentLogs = feedingProvider.getRecentLogsForPet(currentPet.id);
            
            // Sort by timestamp (newest first)
            recentLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            
            final recentFeedingLogs = recentLogs.take(3).toList();
            
            // Get recent activity logs
            final recentActivities = activityProvider.getRecentActivitiesForPet(currentPet.id);
            
            // Filter completed activities
            final completedActivities = recentActivities.where((activity) => activity.isCompleted).toList();
            
            // Sort by date (newest first)
            completedActivities.sort((a, b) => b.date.compareTo(a.date));
            
            final recentActivityLogs = completedActivities.take(3).toList();
            
            // Combine activities
            final allActivities = [
              ...recentAppointments.map((appointment) => {
                'type': 'appointment',
                'title': appointment.title,
                'date': appointment.dateTime,
                'icon': Icons.calendar_today,
              }),
              ...recentPlaydates.map((playdate) => {
                'type': 'playdate',
                'title': playdate.title,
                'date': playdate.date,
                'icon': Icons.people,
              }),
              ...recentFeedingLogs.map((log) => {
                'type': 'feeding',
                'title': '${log.amount} ${log.unit} of ${log.foodType}',
                'date': log.timestamp,
                'icon': Icons.restaurant,
              }),
              ...recentActivityLogs.map((activity) => {
                'type': 'activity',
                'title': '${activity.name} (${activity.durationMinutes} min)',
                'date': activity.date,
                'icon': Icons.directions_walk,
              }),
            ];
            
            // Sort by date (newest first)
            allActivities.sort((a, b) {
              return (b['date'] as DateTime).compareTo(a['date'] as DateTime);
            });
            
            if (allActivities.isEmpty) {
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
                    child: const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('No recent activities'),
                      subtitle: Text('Your activities will appear here'),
                    ),
                  ),
                ],
              );
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Activities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...allActivities.take(5).map((activity) => Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(
                        activity['icon'] as IconData,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(activity['title'] as String),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(activity['date'] as DateTime),
                    ),
                    trailing: Text(
                      _getActivityTypeLabel(activity['type'] as String),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                )), // Limit to 5 most recent activities
              ],
            );
          },
        );
      },
    );
  }
  
  String _getActivityTypeLabel(String type) {
    switch (type) {
      case 'appointment':
        return 'Appointment';
      case 'playdate':
        return 'Playdate';
      case 'feeding':
        return 'Feeding';
      case 'activity':
        return 'Activity';
      default:
        return type.capitalize();
    }
  }
} 