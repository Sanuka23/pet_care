import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/feeding_provider.dart';
import '../services/pet_provider.dart';
import '../models/feeding_model.dart';
import '../screens/feeding_form_screen.dart';
import '../screens/feeding_log_screen.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final currentPet = petProvider.currentPet;
    
    if (currentPet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Feeding Schedule'),
        ),
        body: const Center(
          child: Text('Please select a pet first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Schedules'),
            Tab(text: 'Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSchedulesTab(currentPet.id),
          _buildLogsTab(currentPet.id),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new feeding schedule or log
          _showAddOptions(context, currentPet.id);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSchedulesTab(String petId) {
    return Consumer<FeedingProvider>(
      builder: (context, provider, child) {
        final schedules = provider.getSchedulesForPet(petId);
        
        if (schedules.isEmpty) {
          return const Center(
            child: Text('No feeding schedules yet. Add one!'),
          );
        }
        
        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(schedule.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${schedule.amount} ${schedule.unit} of ${schedule.foodType}'),
                    const SizedBox(height: 4),
                    Text('Times: ${schedule.times.map((t) => t.toString()).join(', ')}'),
                    if (schedule.notes != null) Text('Notes: ${schedule.notes}'),
                  ],
                ),
                isThreeLine: true,
                leading: const CircleAvatar(
                  child: Icon(Icons.restaurant),
                ),
                trailing: Switch(
                  value: schedule.isActive,
                  onChanged: (value) {
                    Provider.of<FeedingProvider>(context, listen: false)
                        .toggleScheduleActive(schedule.id);
                  },
                ),
                onTap: () {
                  // View or edit schedule
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedingFormScreen(
                        petId: petId,
                        schedule: schedule,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLogsTab(String petId) {
    return Consumer<FeedingProvider>(
      builder: (context, provider, child) {
        final logs = provider.getLogsForPet(petId);
        
        if (logs.isEmpty) {
          return const Center(
            child: Text('No feeding logs found. Tap the + button to add a log.'),
          );
        }
        
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(log.foodType),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${log.amount} ${log.unit}'),
                    if (log.notes != null && log.notes!.isNotEmpty) 
                      Text(log.notes!),
                    Text(
                      'Logged on: ${DateFormat('MMM d, yyyy - h:mm a').format(log.timestamp)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    _confirmDeleteLog(context, log);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteLog(BuildContext context, FeedingLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log'),
        content: const Text('Are you sure you want to delete this feeding log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<FeedingProvider>(context, listen: false)
                  .deleteLog(log.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feeding log deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context, String petId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Add Feeding Schedule'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedingFormScreen(petId: petId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Log Feeding'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedingLogScreen(petId: petId),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
} 