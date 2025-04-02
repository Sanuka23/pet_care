import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_model.dart';
import '../services/feeding_provider.dart';
import '../services/pet_provider.dart';

class FeedingFormScreen extends StatefulWidget {
  final String petId;
  final Feeding? feeding; // If null, we're adding a new feeding schedule

  const FeedingFormScreen({
    super.key,
    required this.petId,
    this.feeding,
  });

  @override
  State<FeedingFormScreen> createState() => _FeedingFormScreenState();
}

class _FeedingFormScreenState extends State<FeedingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _portionSizeController = TextEditingController();
  
  FeedingFrequency _frequency = FeedingFrequency.daily;
  final List<TimeOfDay> _feedingTimes = [];
  
  bool _isEditing = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.feeding != null;
    
    if (_isEditing) {
      // Populate form with existing feeding data
      _foodNameController.text = widget.feeding!.foodName;
      _portionSizeController.text = widget.feeding!.portionSize;
      _frequency = widget.feeding!.frequency;
      _feedingTimes.addAll(widget.feeding!.feedingTimes);
    } else {
      // For new schedules, add a default feeding time (morning)
      _feedingTimes.add(const TimeOfDay(hour: 8, minute: 0));
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _portionSizeController.dispose();
    super.dispose();
  }

  // Save feeding schedule data
  void _saveFeeding() {
    if (_formKey.currentState!.validate()) {
      final feedingProvider = Provider.of<FeedingProvider>(context, listen: false);
      
      if (_isEditing) {
        // Update existing feeding schedule
        final updatedFeeding = widget.feeding!.copyWith(
          foodName: _foodNameController.text,
          portionSize: _portionSizeController.text,
          frequency: _frequency,
          feedingTimes: _feedingTimes,
        );
        
        feedingProvider.updateFeeding(updatedFeeding);
      } else {
        // Create new feeding schedule
        final newFeeding = Feeding(
          id: _uuid.v4(),
          petId: widget.petId,
          foodName: _foodNameController.text,
          portionSize: _portionSizeController.text,
          frequency: _frequency,
          feedingTimes: _feedingTimes,
        );
        
        feedingProvider.addFeeding(newFeeding);
      }
      
      Navigator.pop(context);
    }
  }

  // Show time picker for adding/editing a feeding time
  Future<void> _selectTime(BuildContext context, [int? index]) async {
    final TimeOfDay initialTime = index != null 
        ? _feedingTimes[index]
        : TimeOfDay.now();
        
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (pickedTime != null) {
      setState(() {
        if (index != null) {
          _feedingTimes[index] = pickedTime;
        } else {
          _feedingTimes.add(pickedTime);
        }
        // Sort feeding times by hour
        _feedingTimes.sort((a, b) => a.hour.compareTo(b.hour));
      });
    }
  }

  // Remove a feeding time
  void _removeTime(int index) {
    setState(() {
      _feedingTimes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets.firstWhere((pet) => pet.id == widget.petId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Feeding Schedule' : 'Add Feeding Schedule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.pets, size: 24),
                      const SizedBox(width: 16),
                      Text(
                        'For: ${pet.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Food name
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'e.g., Premium Dry Food, Wet Food, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Portion size
              TextFormField(
                controller: _portionSizeController,
                decoration: const InputDecoration(
                  labelText: 'Portion Size',
                  hintText: 'e.g., 1 cup, 100g, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a portion size';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Frequency
              const Text(
                'Frequency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RadioListTile<FeedingFrequency>(
                title: const Text('Daily'),
                value: FeedingFrequency.daily,
                groupValue: _frequency,
                onChanged: (FeedingFrequency? value) {
                  if (value != null) {
                    setState(() {
                      _frequency = value;
                    });
                  }
                },
              ),
              RadioListTile<FeedingFrequency>(
                title: const Text('Custom'),
                value: FeedingFrequency.custom,
                groupValue: _frequency,
                onChanged: (FeedingFrequency? value) {
                  if (value != null) {
                    setState(() {
                      _frequency = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Feeding times
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Feeding Times',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _selectTime(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Time'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _feedingTimes.isEmpty
                          ? const Text('No feeding times set')
                          : Column(
                              children: List.generate(
                                _feedingTimes.length,
                                (index) => ListTile(
                                  leading: const Icon(Icons.access_time),
                                  title: Text(_feedingTimes[index].format(context)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _selectTime(context, index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _removeTime(index),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Validate there's at least one feeding time
              if (_feedingTimes.isEmpty) ...[
                const Text(
                  'Please add at least one feeding time',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
              ],
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _feedingTimes.isEmpty ? null : _saveFeeding,
                  child: Text(
                    _isEditing ? 'Update Feeding Schedule' : 'Add Feeding Schedule',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 