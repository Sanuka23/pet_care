import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_model.dart';
import '../services/feeding_provider.dart';
import '../services/pet_provider.dart';
import 'feeding_form_screen.dart';

class FeedingScreen extends StatelessWidget {
  const FeedingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PetProvider, FeedingProvider>(
      builder: (context, petProvider, feedingProvider, child) {
        final currentPet = petProvider.currentPet;

        if (currentPet == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Feeding Schedule'),
            ),
            body: const Center(
              child: Text('Please add a pet first to manage feeding schedules'),
            ),
          );
        }

        // Get feedings for the current pet
        final feedings = feedingProvider.getFeedingsForPet(currentPet.id);
        
        return Scaffold(
          appBar: AppBar(
            title: Text('${currentPet.name}\'s Feeding'),
          ),
          body: feedings.isEmpty 
              ? _buildEmptyState(context, currentPet.id)
              : _buildFeedingList(context, feedings),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addFeedingSchedule(context, currentPet.id),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String petId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.restaurant,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Feeding Schedules',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a feeding schedule for your pet',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addFeedingSchedule(context, petId),
            icon: const Icon(Icons.add),
            label: const Text('Add Feeding Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingList(BuildContext context, List<Feeding> feedings) {
    // Sort feedings by time of day
    feedings.sort((a, b) {
      if (a.feedingTimes.isEmpty) return 1;
      if (b.feedingTimes.isEmpty) return -1;
      return a.feedingTimes.first.hour.compareTo(b.feedingTimes.first.hour);
    });
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feeding Schedules',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: feedings.length,
            itemBuilder: (context, index) => _buildFeedingCard(context, feedings[index]),
          ),
          const SizedBox(height: 24),
          _buildTodaysFeedingRecords(context),
        ],
      ),
    );
  }

  Widget _buildFeedingCard(BuildContext context, Feeding feeding) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    feeding.foodName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Active/inactive toggle
                Switch(
                  value: feeding.isActive,
                  onChanged: (value) => _toggleFeedingActive(context, feeding.id),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit schedule',
                  onPressed: () => _editFeedingSchedule(context, feeding),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete schedule',
                  onPressed: () => _deleteFeedingSchedule(context, feeding),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Portion: ${feeding.portionSize}'),
            const SizedBox(height: 4),
            const Text(
              'Feeding Times:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: feeding.feedingTimes.map((time) {
                return Chip(
                  label: Text(time.format(context)),
                  backgroundColor: feeding.isActive 
                      ? Colors.blue.shade100
                      : Colors.grey.shade300,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            if (feeding.isActive) ...[
              ElevatedButton.icon(
                onPressed: () => _recordFeeding(context, feeding),
                icon: const Icon(Icons.check),
                label: const Text('Record Feeding'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysFeedingRecords(BuildContext context) {
    final feedingProvider = Provider.of<FeedingProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final currentPet = petProvider.currentPet;
    
    if (currentPet == null) return const SizedBox.shrink();
    
    final todaysRecords = feedingProvider.getTodaysFeedingRecords(currentPet.id);
    
    if (todaysRecords.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Feedings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('No feedings recorded today'),
            ],
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Feedings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...todaysRecords.map((record) {
              final time = DateFormat('h:mm a').format(record.timestamp);
              return ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: record.completed ? Colors.green : Colors.grey,
                ),
                title: Text(time),
                subtitle: record.notes != null && record.notes!.isNotEmpty
                    ? Text(record.notes!)
                    : null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _addFeedingSchedule(BuildContext context, String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedingFormScreen(petId: petId),
      ),
    );
  }

  void _editFeedingSchedule(BuildContext context, Feeding feeding) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedingFormScreen(
          petId: feeding.petId,
          feeding: feeding,
        ),
      ),
    );
  }

  void _toggleFeedingActive(BuildContext context, String feedingId) {
    final feedingProvider = Provider.of<FeedingProvider>(context, listen: false);
    feedingProvider.toggleFeedingActive(feedingId);
  }

  void _deleteFeedingSchedule(BuildContext context, Feeding feeding) {
    final feedingProvider = Provider.of<FeedingProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feeding Schedule'),
        content: Text('Are you sure you want to delete "${feeding.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              feedingProvider.deleteFeeding(feeding.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _recordFeeding(BuildContext context, Feeding feeding) {
    final feedingProvider = Provider.of<FeedingProvider>(context, listen: false);
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Feeding'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Food: ${feeding.foodName}'),
            Text('Portion: ${feeding.portionSize}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Create a new feeding record
              final record = FeedingRecord(
                id: const Uuid().v4(),
                timestamp: DateTime.now(),
                completed: true,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );
              
              feedingProvider.addFeedingRecord(feeding.id, record);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 