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
      // Load pets
      Provider.of<PetProvider>(context, listen: false).loadPets();
      // Load vaccinations
      Provider.of<VaccinationProvider>(context, listen: false).loadVaccinations();
      // Load appointments
      Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
      // Load feeding data
      Provider.of<FeedingProvider>(context, listen: false).loadData();
      // Load playdates
      Provider.of<PlaydateProvider>(context, listen: false).loadPlaydates();
      // Load activities
      Provider.of<ActivityProvider>(context, listen: false).loadActivities();
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
                child: Icon(Icons.pets, color: Theme.of(context).primaryColor),
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
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.pets,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  pet.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
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
              // Will be implemented later
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    // If this is the Vaccinations card, show next vaccination date if available
    if (title == 'Vaccinations') {
      // Get current pet and vaccination provider
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final vaccinationProvider = Provider.of<VaccinationProvider>(context, listen: false);
      final currentPet = petProvider.currentPet;
      
      if (currentPet != null) {
        // Get next vaccination for current pet
        final nextVaccination = vaccinationProvider.getNextVaccinationForPet(currentPet.id);
        
        if (nextVaccination != null) {
          // Format date for display
          final formattedDate = DateFormat('MMM dd, yyyy').format(nextVaccination.nextDueDate);
          
          return InkWell(
            onTap: onTap,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 32, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next: $formattedDate',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      nextVaccination.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }
    
    // If this is the Appointments card, show next appointment if available
    if (title == 'Appointments') {
      // Get current pet and appointment provider
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final currentPet = petProvider.currentPet;
      
      if (currentPet != null) {
        // Get next appointment for current pet
        final nextAppointment = appointmentProvider.getNextAppointmentForPet(currentPet.id);
        
        if (nextAppointment != null) {
          // Format date and time for display
          final formattedDate = DateFormat('MMM dd').format(nextAppointment.dateTime);
          final formattedTime = DateFormat('h:mm a').format(nextAppointment.dateTime);
          
          return InkWell(
            onTap: onTap,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 32, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next: $formattedDate $formattedTime',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      nextAppointment.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }
    
    // If this is the Playdates card, show next playdate if available
    if (title == 'Playdates') {
      // Get current pet and playdate provider
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final playdateProvider = Provider.of<PlaydateProvider>(context, listen: false);
      final currentPet = petProvider.currentPet;
      
      if (currentPet != null) {
        // Get upcoming playdates for current pet
        final upcomingPlaydates = playdateProvider.getUpcomingPlaydatesForPet(currentPet.id);
        
        // Sort by date to get the next one
        if (upcomingPlaydates.isNotEmpty) {
          upcomingPlaydates.sort((a, b) => a.date.compareTo(b.date));
          final nextPlaydate = upcomingPlaydates.first;
          
          // Format date and time for display
          final formattedDate = DateFormat('MMM dd').format(nextPlaydate.date);
          final formattedTime = DateFormat('h:mm a').format(nextPlaydate.date);
          
          return InkWell(
            onTap: onTap,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 32, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next: $formattedDate $formattedTime',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      nextPlaydate.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }
    
    // If this is the Feeding card, show next feeding time if available
    if (title == 'Feeding') {
      // Get current pet and feeding provider
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final feedingProvider = Provider.of<FeedingProvider>(context, listen: false);
      final currentPet = petProvider.currentPet;
      
      if (currentPet != null) {
        // Get active schedules for current pet
        final activeSchedules = feedingProvider.getActiveSchedulesForPet(currentPet.id);
        
        if (activeSchedules.isNotEmpty) {
          // Find the next feeding time
          final now = DateTime.now();
          final currentHour = now.hour;
          final currentMinute = now.minute;
          
          // Flatten all feeding times from all schedules
          final allFeedingTimes = <Map<String, dynamic>>[];
          
          for (final schedule in activeSchedules) {
            for (final time in schedule.times) {
              // Calculate when the next occurrence of this time will be
              var nextOccurrence = DateTime(
                now.year, 
                now.month, 
                now.day, 
                time.hour, 
                time.minute
              );
              
              // If this time is already past for today, set it for tomorrow
              if (time.hour < currentHour || (time.hour == currentHour && time.minute <= currentMinute)) {
                nextOccurrence = nextOccurrence.add(const Duration(days: 1));
              }
              
              allFeedingTimes.add({
                'schedule': schedule,
                'time': time,
                'nextOccurrence': nextOccurrence,
              });
            }
          }
          
          // Sort by next occurrence time
          allFeedingTimes.sort((a, b) {
            return (a['nextOccurrence'] as DateTime).compareTo(b['nextOccurrence'] as DateTime);
          });
          
          if (allFeedingTimes.isNotEmpty) {
            final nextFeeding = allFeedingTimes.first;
            final schedule = nextFeeding['schedule'] as FeedingSchedule;
            final nextOccurrence = nextFeeding['nextOccurrence'] as DateTime;
            
            // Format date and time for display
            final isToday = nextOccurrence.day == now.day && 
                          nextOccurrence.month == now.month &&
                          nextOccurrence.year == now.year;
            
            final formattedDate = isToday ? 'Today' : 'Tomorrow';
            final formattedTime = DateFormat('h:mm a').format(nextOccurrence);
            
            return InkWell(
              onTap: onTap,
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 32, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Next: $formattedDate, $formattedTime',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        schedule.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      }
    }
    
    // If this is the Activity card, show next activity if available
    if (title == 'Activity') {
      // Get current pet and activity provider
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      final currentPet = petProvider.currentPet;
      
      if (currentPet != null) {
        // Get upcoming activities for current pet
        final upcomingActivities = activityProvider.getUpcomingActivitiesForPet(currentPet.id);
        
        // Sort by date to get the next one
        if (upcomingActivities.isNotEmpty) {
          upcomingActivities.sort((a, b) => a.date.compareTo(b.date));
          final nextActivity = upcomingActivities.first;
          
          // Format date and time for display
          final formattedDate = DateFormat('MMM dd').format(nextActivity.date);
          final formattedTime = DateFormat('h:mm a').format(nextActivity.date);
          
          return InkWell(
            onTap: onTap,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 32, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next: $formattedDate $formattedTime',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${nextActivity.name} (${nextActivity.type})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }
    
    // Default card without special info
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
            allActivities.sort((a, b) => 
              (b['date'] as DateTime).compareTo(a['date'] as DateTime)
            );
            
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