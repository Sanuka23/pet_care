import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/feeding_provider.dart';
import '../services/pet_provider.dart';
import '../models/feeding_model.dart';
import '../screens/feeding_form_screen.dart';

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
            child: Text('No feeding logs yet. Add one!'),
          );
        }
        
        // Sort logs by timestamp (most recent first)
        logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('${log.amount} ${log.unit} of ${log.foodType}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('MMM d, yyyy - h:mm a').format(log.timestamp)),
                    if (log.notes != null) 
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Notes: ${log.notes}'),
                      ),
                  ],
                ),
                isThreeLine: log.notes != null,
                leading: const CircleAvatar(
                  child: Icon(Icons.fastfood),
                ),
                onTap: () {
                  // View log details
                },
              ),
            );
          },
        );
      },
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
                // Navigate to add schedule screen
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
                // We'll implement this later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Log Feeding functionality coming soon')),
                );
              },
            ),
          ],
        );
      },
    );
  }
} 