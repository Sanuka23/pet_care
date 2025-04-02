import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/activity_model.dart';
import '../services/activity_provider.dart';
import '../services/pet_provider.dart';
import 'activity_form_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedActivityType;
  final List<String> _activityTypes = [
    'All Types',
    'Walk',
    'Play',
    'Training',
    'Grooming',
    'Socialization',
    'Dog Park',
    'Vet Visit',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedActivityType = _activityTypes[0];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load activity data
      Provider.of<ActivityProvider>(context, listen: false).loadActivities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PetProvider, ActivityProvider>(
      builder: (context, petProvider, activityProvider, child) {
        final currentPet = petProvider.currentPet;

        if (currentPet == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Activities'),
            ),
            body: const Center(
              child: Text('Please add a pet first to manage activities'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${currentPet.name}\'s Activities'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Filter by activity type
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Filter by Type',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedActivityType,
                  items: _activityTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivityType = value;
                    });
                  },
                ),
              ),
              
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActivitiesTab(currentPet.id, activityProvider, false),
                    _buildActivitiesTab(currentPet.id, activityProvider, true),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addActivity(context, currentPet.id),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildActivitiesTab(String petId, ActivityProvider activityProvider, bool showCompleted) {
    // Get all activities for the pet
    List<Activity> allActivities = activityProvider.getActivitiesForPet(petId);
    
    // Filter by completion status
    allActivities = allActivities.where((activity) => 
      activity.isCompleted == showCompleted
    ).toList();
    
    // Filter by activity type if not 'All Types'
    if (_selectedActivityType != 'All Types') {
      allActivities = allActivities.where((activity) => 
        activity.type == _selectedActivityType
      ).toList();
    }
    
    // Sort by date (upcoming first, then completed)
    allActivities.sort((a, b) => a.date.compareTo(b.date));
    
    if (allActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_run,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              showCompleted 
                ? 'No Completed Activities'
                : 'No Upcoming Activities',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              showCompleted
                ? 'Activities will appear here when completed'
                : 'Schedule new activities for your pet',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (!showCompleted)
              ElevatedButton.icon(
                onPressed: () => _addActivity(context, petId),
                icon: const Icon(Icons.add),
                label: const Text('Add Activity'),
              ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: allActivities.length,
      itemBuilder: (context, index) {
        final activity = allActivities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final now = DateTime.now();
    final isToday = activity.date.year == now.year && 
                   activity.date.month == now.month && 
                   activity.date.day == now.day;
                   
    final isUpcoming = activity.date.isAfter(now) && !activity.isCompleted;
    final isPast = activity.date.isBefore(now) && !activity.isCompleted;
    
    // Determine card color based on status
    Color cardColor = Colors.white;
    if (isUpcoming) {
      cardColor = Colors.blue.shade50;
    } else if (isPast && !activity.isCompleted) {
      cardColor = Colors.orange.shade50;
    } else if (activity.isCompleted) {
      cardColor = Colors.green.shade50;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity type icon
                CircleAvatar(
                  backgroundColor: _getActivityTypeColor(activity.type),
                  child: Icon(
                    _getActivityTypeIcon(activity.type),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                // Activity details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.type,
                        style: TextStyle(
                          color: _getActivityTypeColor(activity.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.durationMinutes} min',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status indicator or menu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, activity),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        if (!activity.isCompleted)
                          const PopupMenuItem(
                            value: 'complete',
                            child: Text('Mark as Completed'),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Date/time label
                    Text(
                      isToday 
                        ? 'Today, ${DateFormat('h:mm a').format(activity.date)}'
                        : DateFormat('MMM d, h:mm a').format(activity.date),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            
            // Location if available
            if (activity.location != null && activity.location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    activity.location!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
            
            // Notes if available
            if (activity.notes != null && activity.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                activity.notes!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            
            // Status badges
            const SizedBox(height: 8),
            if (activity.isCompleted)
              const Chip(
                label: Text('Completed'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              )
            else if (isPast)
              const Chip(
                label: Text('Missed'),
                backgroundColor: Colors.orange,
                labelStyle: TextStyle(color: Colors.white),
              )
            else if (isUpcoming)
              const Chip(
                label: Text('Upcoming'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Color _getActivityTypeColor(String type) {
    switch (type) {
      case 'Walk':
        return Colors.blue;
      case 'Play':
        return Colors.amber;
      case 'Training':
        return Colors.deepPurple;
      case 'Grooming':
        return Colors.teal;
      case 'Socialization':
        return Colors.pink;
      case 'Dog Park':
        return Colors.green;
      case 'Vet Visit':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getActivityTypeIcon(String type) {
    switch (type) {
      case 'Walk':
        return Icons.directions_walk;
      case 'Play':
        return Icons.sports_baseball;
      case 'Training':
        return Icons.school;
      case 'Grooming':
        return Icons.brush;
      case 'Socialization':
        return Icons.people;
      case 'Dog Park':
        return Icons.park;
      case 'Vet Visit':
        return Icons.local_hospital;
      default:
        return Icons.pets;
    }
  }

  void _addActivity(BuildContext context, String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityFormScreen(petId: petId),
      ),
    );
  }

  void _editActivity(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityFormScreen(
          petId: activity.petId,
          activity: activity,
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Activity activity) {
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    
    switch (action) {
      case 'edit':
        _editActivity(activity);
        break;
      case 'complete':
        activityProvider.markActivityAsCompleted(activity.id);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(activity);
        break;
    }
  }

  void _showDeleteConfirmationDialog(Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "${activity.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ActivityProvider>(context, listen: false)
                .deleteActivity(activity.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 