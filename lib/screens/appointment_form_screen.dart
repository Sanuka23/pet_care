import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/appointment_model.dart';
import '../services/appointment_provider.dart';
import '../services/pet_provider.dart';

class AppointmentFormScreen extends StatefulWidget {
  final String petId;
  final Appointment? appointment; // If null, we're adding a new appointment

  const AppointmentFormScreen({
    super.key,
    required this.petId,
    this.appointment,
  });

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _vetNameController = TextEditingController();
  final _vetLocationController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  bool _isEditing = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.appointment != null;
    
    if (_isEditing) {
      // Populate form with existing appointment data
      _titleController.text = widget.appointment!.title;
      _vetNameController.text = widget.appointment!.vetName;
      _vetLocationController.text = widget.appointment!.vetLocation;
      _notesController.text = widget.appointment!.notes ?? '';
      _selectedDate = widget.appointment!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.appointment!.dateTime);
    } else {
      // For new appointments, set time to next full hour
      final now = DateTime.now();
      _selectedTime = TimeOfDay(hour: now.hour + 1, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _vetNameController.dispose();
    _vetLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Save appointment data
  void _saveAppointment() {
    if (_formKey.currentState!.validate()) {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      
      // Combine date and time into a single DateTime
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      if (_isEditing) {
        // Update existing appointment
        final updatedAppointment = widget.appointment!.copyWith(
          title: _titleController.text,
          dateTime: dateTime,
          vetName: _vetNameController.text,
          vetLocation: _vetLocationController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        
        appointmentProvider.updateAppointment(updatedAppointment);
      } else {
        // Create new appointment
        final newAppointment = Appointment(
          id: _uuid.v4(),
          title: _titleController.text,
          dateTime: dateTime,
          vetName: _vetNameController.text,
          vetLocation: _vetLocationController.text,
          petId: widget.petId,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        
        appointmentProvider.addAppointment(newAppointment);
      }
      
      Navigator.pop(context);
    }
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets.firstWhere((pet) => pet.id == widget.petId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Appointment' : 'Add Appointment'),
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
              
              // Appointment title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Appointment Title',
                  hintText: 'e.g., Annual Checkup, Vaccination, etc.',
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
              
              // Date picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Time picker
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedTime.format(context)),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Vet name
              TextFormField(
                controller: _vetNameController,
                decoration: const InputDecoration(
                  labelText: 'Veterinarian Name',
                  hintText: 'e.g., Dr. Smith',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter veterinarian name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Vet location
              TextFormField(
                controller: _vetLocationController,
                decoration: const InputDecoration(
                  labelText: 'Clinic/Hospital Name',
                  hintText: 'e.g., City Pet Clinic',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter clinic/hospital name';
                  }
                  return null;
                },
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
                  onPressed: _saveAppointment,
                  child: Text(
                    _isEditing ? 'Update Appointment' : 'Add Appointment',
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