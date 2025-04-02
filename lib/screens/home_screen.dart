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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pet Care',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pets, size: 24),
            onPressed: _showPetSelector,
          ),
          IconButton(
            icon: const Icon(Icons.notifications, size: 24),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show actions sheet based on current tab
          _showAddActionSheet();
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
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
        ),
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

  void _showAddActionSheet() {
    // Different actions based on current tab
    String title = 'Add New';
    IconData icon = Icons.add;
    VoidCallback action = () {};

    switch (_currentIndex) {
      case 0:
        title = 'Add Pet';
        icon = Icons.pets;
        action = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PetProfileScreen(),
            ),
          );
        };
        break;
      case 1:
        title = 'Add Vaccination';
        icon = Icons.medical_services;
        action = () {
          Navigator.pop(context);
          // Navigate to add vaccination
        };
        break;
      case 2:
        title = 'Add Appointment';
        icon = Icons.calendar_today;
        action = () {
          Navigator.pop(context);
          // Navigate to add appointment
        };
        break;
      case 3:
        title = 'Add Feeding Schedule';
        icon = Icons.restaurant;
        action = () {
          Navigator.pop(context);
          // Navigate to add feeding
        };
        break;
      case 4:
        title = 'Add Activity';
        icon = Icons.directions_walk;
        action = () {
          Navigator.pop(context);
          // Navigate to add activity
        };
        break;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                title: Text(title),
                onTap: action,
              ),
            ],
          ),
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
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentPet != null) _buildPetHeader(currentPet),
              currentPet != null
                ? _buildPetProfileCard(currentPet)
                : _buildAddPetCard(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentActivities(),
              const SizedBox(height: 80), // Add padding for FAB
            ],
          ),
        );
      },
    );
  }

  Widget _buildPetHeader(Pet pet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '${pet.name}\'s Dashboard',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPetProfileCard(Pet pet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
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
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: pet.specialNeeds!.map((need) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      need,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildQuickActionItem('Vaccinations', Icons.medical_services, () {
                setState(() => _currentIndex = 1);
              }),
              _buildQuickActionItem('Appointments', Icons.calendar_today, () {
                setState(() => _currentIndex = 2);
              }),
              _buildQuickActionItem('Feeding', Icons.restaurant, () {
                setState(() => _currentIndex = 3);
              }),
              _buildQuickActionItem('Activity', Icons.directions_walk, () {
                setState(() => _currentIndex = 4);
              }),
              _buildQuickActionItem('Playdates', Icons.people, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaydateScreen()),
                );
              }),
              _buildQuickActionItem('Reminders', Icons.notifications, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReminderScreen()),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[50]!,
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[50]!,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No recent activities',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a pet to get started',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PetProfileScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 45),
                            ),
                            child: const Text('Add Pet'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[50]!,
                            Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No recent activities',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your recent activities will appear here',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() => _currentIndex = 4);
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(200, 45),
                                ),
                                child: const Text('Add Activity'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // View all activities
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...allActivities.take(5).map((activity) => _buildActivityItem(activity)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final DateTime date = activity['date'] as DateTime;
    final bool isToday = DateTime.now().year == date.year && 
                          DateTime.now().month == date.month && 
                          DateTime.now().day == date.day;
    final String dateText = isToday 
                          ? 'Today, ${DateFormat('h:mm a').format(date)}'
                          : DateFormat('MMM dd, yyyy').format(date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Open activity details
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateText,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getActivityTypeLabel(activity['type'] as String),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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