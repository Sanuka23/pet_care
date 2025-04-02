import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_model.dart';
import '../services/feeding_provider.dart';
import '../services/pet_provider.dart';

class FeedingFormScreen extends StatefulWidget {
  final String petId;
  final FeedingSchedule? schedule; // If null, we're adding a new schedule

  const FeedingFormScreen({
    super.key,
    required this.petId,
    this.schedule,
  });

  @override
  State<FeedingFormScreen> createState() => _FeedingFormScreenState();
}

class _FeedingFormScreenState extends State<FeedingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _foodTypeController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _unit = 'cups';
  final List<TimeOfDay> _feedingTimes = [];
  
  bool _isEditing = false;
  final _uuid = const Uuid();

  final List<String> _unitOptions = ['cups', 'grams', 'ounces', 'cans', 'servings'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.schedule != null;
    
    if (_isEditing) {
      // Populate form with existing schedule data
      _nameController.text = widget.schedule!.name;
      _foodTypeController.text = widget.schedule!.foodType;
      _amountController.text = widget.schedule!.amount.toString();
      _unit = widget.schedule!.unit;
      _notesController.text = widget.schedule!.notes ?? '';
      
      // Convert FeedingTime to Flutter's TimeOfDay
      _feedingTimes.addAll(widget.schedule!.times.map((feedTime) => 
        TimeOfDay(hour: feedTime.hour, minute: feedTime.minute)
      ));
    } else {
      // Default for new schedule - add one time slot
      _feedingTimes.add(const TimeOfDay(hour: 8, minute: 0));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _foodTypeController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Add a new feeding time
  void _addFeedingTime() {
    setState(() {
      _feedingTimes.add(const TimeOfDay(hour: 12, minute: 0));
    });
  }

  // Remove a feeding time
  void _removeFeedingTime(int index) {
    setState(() {
      _feedingTimes.removeAt(index);
    });
  }

  // Show time picker
  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _feedingTimes[index],
    );
    
    if (pickedTime != null) {
      setState(() {
        _feedingTimes[index] = pickedTime;
      });
    }
  }

  // Save feeding schedule
  void _saveSchedule() {
    if (_formKey.currentState!.validate() && _feedingTimes.isNotEmpty) {
      final feedingProvider = Provider.of<FeedingProvider>(context, listen: false);
      
      // Validate amount
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }
      
      // Convert TimeOfDay to FeedingTime
      final feedingTimes = _feedingTimes.map((time) => 
        FeedingTime(hour: time.hour, minute: time.minute)
      ).toList();
      
      if (_isEditing) {
        // Update existing schedule
        final updatedSchedule = widget.schedule!.copyWith(
          name: _nameController.text,
          foodType: _foodTypeController.text,
          amount: amount,
          unit: _unit,
          times: feedingTimes,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        
        feedingProvider.updateSchedule(updatedSchedule);
      } else {
        // Create new schedule
        final newSchedule = FeedingSchedule(
          id: _uuid.v4(),
          petId: widget.petId,
          name: _nameController.text,
          foodType: _foodTypeController.text,
          amount: amount,
          unit: _unit,
          times: feedingTimes,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        
        feedingProvider.addSchedule(newSchedule);
      }
      
      Navigator.pop(context);
    } else if (_feedingTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one feeding time')),
      );
    }
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
              
              // Schedule name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Schedule Name',
                  hintText: 'e.g., Morning Feed, Dinner, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Food type
              TextFormField(
                controller: _foodTypeController,
                decoration: const InputDecoration(
                  labelText: 'Food Type',
                  hintText: 'e.g., Dry Kibble, Wet Food, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter food type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Amount and unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Unit
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      value: _unit,
                      items: _unitOptions.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _unit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Feeding times section
              const Text(
                'Feeding Times',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              
              // Times list
              ..._buildFeedingTimesList(),
              
              // Add time button
              Center(
                child: OutlinedButton.icon(
                  onPressed: _addFeedingTime,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Feeding Time'),
                ),
              ),
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Any additional information',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveSchedule,
                  child: Text(
                    _isEditing ? 'Update Schedule' : 'Add Schedule',
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

  List<Widget> _buildFeedingTimesList() {
    return _feedingTimes.asMap().entries.map((entry) {
      final index = entry.key;
      final time = entry.value;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _selectTime(context, index),
                ),
                Expanded(
                  child: Text(
                    time.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeFeedingTime(index),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
} 