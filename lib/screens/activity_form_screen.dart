import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/activity_model.dart';
import '../services/activity_provider.dart';
import '../services/pet_provider.dart';

class ActivityFormScreen extends StatefulWidget {
  final String petId;
  final Activity? activity; // If null, we're adding a new activity

  const ActivityFormScreen({
    super.key,
    required this.petId,
    this.activity,
  });

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _type = 'Walk';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _isCompleted = false;
  
  bool _isEditing = false;
  final _uuid = const Uuid();

  final List<String> _activityTypes = [
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
    _isEditing = widget.activity != null;
    
    if (_isEditing) {
      // Populate form with existing activity data
      final activity = widget.activity!;
      _nameController.text = activity.name;
      _type = activity.type;
      _date = activity.date;
      _time = TimeOfDay(hour: activity.date.hour, minute: activity.date.minute);
      _durationController.text = activity.durationMinutes.toString();
      _locationController.text = activity.location ?? '';
      _notesController.text = activity.notes ?? '';
      _isCompleted = activity.isCompleted;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  // Show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    
    if (pickedTime != null && pickedTime != _time) {
      setState(() {
        _time = pickedTime;
      });
    }
  }

  // Get combined date and time for activity
  DateTime _getActivityDateTime() {
    return DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
  }

  // Save activity
  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      
      // Validate duration
      final duration = int.tryParse(_durationController.text);
      if (duration == null || duration <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid duration')),
        );
        return;
      }
      
      final activityDateTime = _getActivityDateTime();
      
      if (_isEditing) {
        // Update existing activity
        final updatedActivity = widget.activity!.copyWith(
          name: _nameController.text,
          type: _type,
          date: activityDateTime,
          durationMinutes: duration,
          location: _locationController.text.isEmpty ? null : _locationController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          isCompleted: _isCompleted,
        );
        
        activityProvider.updateActivity(updatedActivity);
      } else {
        // Create new activity
        final newActivity = Activity(
          id: _uuid.v4(),
          petId: widget.petId,
          name: _nameController.text,
          type: _type,
          date: activityDateTime,
          durationMinutes: duration,
          location: _locationController.text.isEmpty ? null : _locationController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          isCompleted: _isCompleted,
        );
        
        activityProvider.addActivity(newActivity);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets.firstWhere((pet) => pet.id == widget.petId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Activity' : 'Add Activity'),
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
              
              // Activity name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Activity Name',
                  hintText: 'e.g., Morning Walk, Training Session, etc.',
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
              
              // Activity type
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Activity Type',
                  border: OutlineInputBorder(),
                ),
                value: _type,
                items: _activityTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Date and time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('EEE, MMM d, yyyy').format(_date),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Time
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _time.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Duration
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a duration';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Invalid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Location (optional)
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  hintText: 'e.g., Park, Beach, Training Center, etc.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Notes (optional)
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Any additional information',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Completed checkbox
              CheckboxListTile(
                title: const Text('Mark as Completed'),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveActivity,
                  child: Text(
                    _isEditing ? 'Update Activity' : 'Add Activity',
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