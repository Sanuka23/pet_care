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
  final dateFormatter = DateFormat('MMM d');
  final weekdayFormatter = DateFormat('E');
  final now = DateTime.now();

  List<DateTime> _getDaysOfWeek() {
    final today = DateTime.now();
    final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

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
            icon: Icon(Icons.notifications_outlined, size: 28),
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
          IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.pets, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            onPressed: _showPetSelector,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              activeIcon: Icon(Icons.medical_services),
              label: 'Medical',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Feeding',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_walk_outlined),
              activeIcon: Icon(Icons.directions_walk),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Schedule',
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
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const VaccinationScreen();
      case 2:
        return const FeedingScreen();
      case 3:
        return const PlaydateScreen();
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
        final greeting = _getGreeting();
        final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
        
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      today,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF8F919B),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    currentPet != null
                      ? _buildPetProfileCard(currentPet)
                      : _buildAddPetCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              _buildQuickActions(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUpcomingActivities(currentPet),
                    if (currentPet != null) const SizedBox(height: 24),
                    _buildRecentActivities(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    final days = _getDaysOfWeek();
    final today = DateTime.now();
    
    return SizedBox(
      height: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 6.0),
            child: Text(
              'Calendar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isToday = day.day == today.day && 
                                day.month == today.month && 
                                day.year == today.year;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    onTap: () {
                      // Handle date selection
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: isToday 
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                              ],
                            )
                          : null,
                        color: isToday ? null : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weekdayFormatter.format(day),
                              style: TextStyle(
                                color: isToday ? Colors.white : const Color(0xFF8F919B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                color: isToday ? Colors.white : const Color(0xFF303030),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetProfileCard(Pet pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Hero(
                  tag: 'pet-avatar-${pet.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFEEF2FB),
                      backgroundImage: pet.imageUrl != null ? FileImage(File(pet.imageUrl!)) : null,
                      child: pet.imageUrl == null
                          ? Icon(
                              Icons.pets,
                              size: 30,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.pets,
                            size: 16,
                            color: const Color(0xFF8F919B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pet.breed,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF8F919B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.cake,
                            size: 16,
                            color: const Color(0xFF8F919B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pet.age} years old',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF8F919B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatsChip('${pet.weight} kg', Icons.monitor_weight_outlined),
                          const SizedBox(width: 8),
                          if (pet.specialNeeds != null && pet.specialNeeds!.isNotEmpty)
                            _buildStatsChip('Special Needs', Icons.healing_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
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
                const SizedBox(width: 12),
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

  Widget _buildStatsChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.pets, 
                size: 40, 
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Your Pet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your pet\'s health and activities',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF8F919B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
          padding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildQuickActionCard('Medical', Icons.medical_services_outlined, () {
                setState(() => _currentIndex = 1);
              }),
              _buildQuickActionCard('Feeding', Icons.restaurant_outlined, () {
                setState(() => _currentIndex = 2);
              }),
              _buildQuickActionCard('Playdates', Icons.people_outline, () {
                setState(() => _currentIndex = 3);
              }),
              _buildQuickActionCard('Activity', Icons.directions_walk_outlined, () {
                setState(() => _currentIndex = 4);
              }),
              _buildQuickActionCard('Reminders', Icons.notifications_outlined, () {
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

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingActivities(Pet? currentPet) {
    if (currentPet == null) {
      return const SizedBox.shrink();
    }

    return Consumer2<ActivityProvider, AppointmentProvider>(
      builder: (context, activityProvider, appointmentProvider, child) {
        final upcomingActivities = activityProvider.getUpcomingActivitiesForPet(currentPet.id);
        final upcomingAppointments = appointmentProvider.getUpcomingAppointmentsForPet(currentPet.id);
        
        if (upcomingActivities.isEmpty && upcomingAppointments.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Combine and sort by date
        final allUpcoming = [
          ...upcomingActivities.map((activity) => ({
            'type': 'activity',
            'title': activity.name,
            'subtitle': activity.type,
            'date': activity.date,
            'icon': Icons.directions_walk_outlined,
          })),
          ...upcomingAppointments.map((appointment) => ({
            'type': 'appointment',
            'title': appointment.title,
            'subtitle': appointment.notes ?? 'Vet Appointment',
            'date': appointment.dateTime,
            'icon': Icons.medical_services_outlined,
          })),
        ];
        
        // Sort by date (soonest first)
        allUpcoming.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
        
        // Take only the next 3 events
        final nextEvents = allUpcoming.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
              child: Text(
                'Upcoming Events',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...nextEvents.map((event) => _buildUpcomingEventCard(event)),
          ],
        );
      },
    );
  }
  
  Widget _buildUpcomingEventCard(Map<String, dynamic> event) {
    final date = event['date'] as DateTime;
    final formattedDate = DateFormat('MMM d, h:mm a').format(date);
    final type = (event['type'] as String).capitalize();
    final icon = event['icon'] as IconData;
    final title = event['title'] as String;
    
    // Calculate how many days from now
    final daysFromNow = date.difference(DateTime.now()).inDays;
    final isToday = daysFromNow == 0;
    final isTomorrow = daysFromNow == 1;
    String timeLabel;
    
    if (isToday) {
      timeLabel = 'Today';
    } else if (isTomorrow) {
      timeLabel = 'Tomorrow';
    } else {
      timeLabel = '$daysFromNow days';
    }
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: const Color(0xFF8F919B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: const Color(0xFF8F919B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final currentPet = petProvider.currentPet;
        
        if (currentPet == null) {
          return const SizedBox.shrink();
        }
        
        return Consumer4<AppointmentProvider, PlaydateProvider, FeedingProvider, ActivityProvider>(
          builder: (context, appointmentProvider, playdateProvider, feedingProvider, activityProvider, child) {
            // Get all recent activity data (using existing code)
            // ... existing activity collection code ...
            
            // Combine activities from different providers
            final completedAppointments = appointmentProvider.appointments
                .where((appointment) => 
                    appointment.petId == currentPet.id && 
                    appointment.isCompleted)
                .toList();
                
            completedAppointments.sort((a, b) => 
                b.dateTime.compareTo(a.dateTime));
                
            final recentAppointments = completedAppointments.take(3).toList();
            
            final pastPlaydates = playdateProvider.getPastPlaydatesForPet(currentPet.id);
            pastPlaydates.sort((a, b) => b.date.compareTo(a.date));
            final recentPlaydates = pastPlaydates.take(3).toList();
            
            final recentLogs = feedingProvider.getRecentLogsForPet(currentPet.id);
            recentLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            final recentFeedingLogs = recentLogs.take(3).toList();
            
            final recentActivities = activityProvider.getRecentActivitiesForPet(currentPet.id);
            final completedActivities = recentActivities.where((activity) => activity.isCompleted).toList();
            completedActivities.sort((a, b) => b.date.compareTo(a.date));
            final recentActivityLogs = completedActivities.take(3).toList();
            
            final allActivities = [
              ...recentAppointments.map((appointment) => {
                'type': 'appointment',
                'title': appointment.title,
                'date': appointment.dateTime,
                'icon': Icons.medical_services,
                'color': const Color(0xFFF89D93),
              }),
              ...recentPlaydates.map((playdate) => {
                'type': 'playdate',
                'title': playdate.title,
                'date': playdate.date,
                'icon': Icons.people,
                'color': const Color(0xFF77A4AF),
              }),
              ...recentFeedingLogs.map((log) => {
                'type': 'feeding',
                'title': '${log.amount} ${log.unit} of ${log.foodType}',
                'date': log.timestamp,
                'icon': Icons.restaurant,
                'color': const Color(0xFFDD8970),
              }),
              ...recentActivityLogs.map((activity) => {
                'type': 'activity',
                'title': '${activity.name} (${activity.durationMinutes} min)',
                'date': activity.date,
                'icon': Icons.directions_walk,
                'color': const Color(0xFF4A80F0),
              }),
            ];
            
            allActivities.sort((a, b) {
              return (b['date'] as DateTime).compareTo(a['date'] as DateTime);
            });
            
            if (allActivities.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                  child: Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ...allActivities.take(4).map((activity) => _buildActivityCard(activity)),
                if (allActivities.length > 4)
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.history),
                      label: const Text('View All Activities'),
                      onPressed: () {
                        // Navigate to full activity history
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final date = activity['date'] as DateTime;
    final formattedDate = DateFormat('MMM d, h:mm a').format(date);
    final color = activity['color'] as Color;
    final title = activity['title'] as String;
    final type = _getActivityTypeLabel(activity['type'] as String);
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  activity['icon'] as IconData,
                  color: color,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: const Color(0xFF8F919B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            color: const Color(0xFF8F919B),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getActivityTypeLabel(String type) {
    switch (type) {
      case 'appointment':
        return 'Medical';
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
} 