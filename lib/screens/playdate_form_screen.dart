import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // For random ID generation
import 'package:intl/intl.dart';
import '../models/playdate_model.dart';
import '../services/playdate_provider.dart';
import '../services/pet_provider.dart';

class PlaydateFormScreen extends StatefulWidget {
  final String petId;
  final Playdate? playdate; // If null, we're adding a new playdate

  const PlaydateFormScreen({
    super.key,
    required this.petId,
    this.playdate,
  });

  @override
  State<PlaydateFormScreen> createState() => _PlaydateFormScreenState();
}

class _PlaydateFormScreenState extends State<PlaydateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _isConfirmed = false;
  
  // List of participants
  final List<String> _participants = [];
  final TextEditingController _participantController = TextEditingController();
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.playdate != null;
    
    if (_isEditing) {
      // Populate form with existing playdate data
      final playdate = widget.playdate!;
      _titleController.text = playdate.title;
      _locationController.text = playdate.location;
      _durationController.text = playdate.durationMinutes.toString();
      _contactInfoController.text = playdate.contactInfo ?? '';
      _notesController.text = playdate.notes ?? '';
      _date = playdate.date;
      _time = TimeOfDay(hour: playdate.date.hour, minute: playdate.date.minute);
      _isConfirmed = playdate.isConfirmed;
      _participants.addAll(playdate.participants);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _contactInfoController.dispose();
    _notesController.dispose();
    _participantController.dispose();
    super.dispose();
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
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

  // Get combined date and time for playdate
  DateTime _getPlaydateDateTime() {
    return DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
  }

  // Add a participant
  void _addParticipant() {
    final name = _participantController.text.trim();
    if (name.isNotEmpty && !_participants.contains(name)) {
      setState(() {
        _participants.add(name);
        _participantController.clear();
      });
    }
  }

  // Remove a participant
  void _removeParticipant(String name) {
    setState(() {
      _participants.remove(name);
    });
  }

  // Save playdate
  void _savePlaydate() {
    if (_formKey.currentState!.validate() && _participants.isNotEmpty) {
      final playdateProvider = Provider.of<PlaydateProvider>(context, listen: false);
      
      // Validate duration
      final duration = int.tryParse(_durationController.text);
      if (duration == null || duration <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid duration')),
        );
        return;
      }
      
      final playdateDateTime = _getPlaydateDateTime();
      
      if (_isEditing) {
        // Update existing playdate
        final updatedPlaydate = widget.playdate!.copyWith(
          title: _titleController.text,
          date: playdateDateTime,
          location: _locationController.text,
          durationMinutes: duration,
          participants: List<String>.from(_participants),
          contactInfo: _contactInfoController.text.isEmpty ? null : _contactInfoController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          isConfirmed: _isConfirmed,
        );
        
        playdateProvider.updatePlaydate(updatedPlaydate);
      } else {
        // Create new playdate
        final newPlaydate = Playdate(
          id: generateRandomId(),
          petId: widget.petId,
          title: _titleController.text,
          date: playdateDateTime,
          location: _locationController.text,
          durationMinutes: duration,
          participants: List<String>.from(_participants),
          contactInfo: _contactInfoController.text.isEmpty ? null : _contactInfoController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          isConfirmed: _isConfirmed,
        );
        
        playdateProvider.addPlaydate(newPlaydate);
      }
      
      Navigator.pop(context);
    } else if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one participant')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets.firstWhere((pet) => pet.id == widget.petId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Playdate' : 'Add Playdate'),
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
              
              // Playdate title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Playdate Title',
                  hintText: 'e.g., Park Meetup, Puppy Playgroup, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
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
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., City Dog Park, Beach, Training Center, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
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
              
              // Contact info (optional)
              TextFormField(
                controller: _contactInfoController,
                decoration: const InputDecoration(
                  labelText: 'Contact Info (Optional)',
                  hintText: 'e.g., John - 555-1234',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Participants section
              const Text(
                'Participants',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              
              // Add participant
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _participantController,
                      decoration: const InputDecoration(
                        labelText: 'Add Participant',
                        hintText: 'e.g., Max, Lucy, etc.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addParticipant,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Participants list
              _buildParticipantsList(),
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
              
              // Confirmed checkbox
              CheckboxListTile(
                title: const Text('Confirmed'),
                value: _isConfirmed,
                onChanged: (value) {
                  setState(() {
                    _isConfirmed = value ?? false;
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
                  onPressed: _savePlaydate,
                  child: Text(
                    _isEditing ? 'Update Playdate' : 'Add Playdate',
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

  Widget _buildParticipantsList() {
    if (_participants.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No participants added yet'),
        ),
      );
    }
    
    return Column(
      children: _participants.map((name) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.pets),
            ),
            title: Text(name),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeParticipant(name),
            ),
          ),
        );
      }).toList(),
    );
  }
}

String generateRandomId() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
} 