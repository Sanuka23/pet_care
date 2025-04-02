import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../models/activity_model.dart';
import '../models/pet_model.dart';
import '../services/activity_provider.dart';
import '../services/pet_provider.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    // Ensure the notification service is initialized
    _notificationService.initialize();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<PetProvider, ActivityProvider>(
      builder: (context, petProvider, activityProvider, child) {
        final currentPet = petProvider.currentPet;
        
        if (currentPet == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Upcoming Activities'),
            ),
            body: const Center(
              child: Text('Please select a pet to view activities'),
            ),
          );
        }
        
        // Get upcoming activities for current pet
        final upcomingActivities = activityProvider.getUpcomingActivitiesForPet(currentPet.id);
        
        // Sort by date
        upcomingActivities.sort((a, b) => a.date.compareTo(b.date));
        
        return Scaffold(
          appBar: AppBar(
            title: Text('${currentPet.name}\'s Activities'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear all reminders',
                onPressed: () {
                  _showClearAllConfirmationDialog(context);
                },
              ),
            ],
          ),
          body: upcomingActivities.isEmpty
              ? _buildEmptyState()
              : _buildActivitiesList(upcomingActivities, currentPet),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Upcoming Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add activities to see them here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate back to create an activity
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Activity'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivitiesList(List<Activity> activities, Pet pet) {
    return ListView.builder(
      itemCount: activities.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final activity = activities[index];
        final DateTime scheduledTime = activity.date;
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              backgroundImage: pet.imageUrl != null ? NetworkImage(pet.imageUrl!) : null,
              child: pet.imageUrl == null ? Icon(
                Icons.pets,
                size: 30,
                color: Theme.of(context).primaryColor,
              ) : null,
            ),
            title: Text(
              activity.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Type: ${activity.type}'),
                if (activity.location != null) ...[
                  const SizedBox(height: 4),
                  Text('Location: ${activity.location}'),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(scheduledTime),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getTimeUntilActivityText(scheduledTime),
                  style: TextStyle(
                    color: _getTimeUntilActivityColor(scheduledTime),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                _cancelActivity(context, activity);
              },
            ),
          ),
        );
      },
    );
  }
  
  String _getTimeUntilActivityText(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    
    if (days > 0) {
      return 'In $days ${days == 1 ? 'day' : 'days'}${hours > 0 ? ' and $hours ${hours == 1 ? 'hour' : 'hours'}' : ''}';
    } else if (hours > 0) {
      return 'In $hours ${hours == 1 ? 'hour' : 'hours'}${minutes > 0 ? ' and $minutes ${minutes == 1 ? 'minute' : 'minutes'}' : ''}';
    } else {
      return 'In $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }
  }
  
  Color _getTimeUntilActivityColor(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.isNegative) {
      return Colors.red;
    }
    
    if (difference.inMinutes < 30) {
      return Colors.orange;
    } else if (difference.inHours < 2) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
  
  void _cancelActivity(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Activity?'),
        content: const Text('Are you sure you want to cancel this activity?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              // Cancel the activity
              final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
              await activityProvider.deleteActivity(activity.id);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Activity canceled'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
  
  void _showClearAllConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Activities?'),
        content: const Text('Are you sure you want to cancel all upcoming activities?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
              final currentPet = Provider.of<PetProvider>(context, listen: false).currentPet;
              
              if (currentPet != null) {
                final activities = activityProvider.getUpcomingActivitiesForPet(currentPet.id);
                for (final activity in activities) {
                  await activityProvider.deleteActivity(activity.id);
                }
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All activities cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
} 