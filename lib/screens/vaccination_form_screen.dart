import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/vaccination_model.dart';
import '../services/vaccination_provider.dart';
import '../services/pet_provider.dart';

class VaccinationFormScreen extends StatefulWidget {
  final String petId;
  final Vaccination? vaccination; // If null, we're adding a new vaccination

  const VaccinationFormScreen({
    super.key,
    required this.petId,
    this.vaccination,
  });

  @override
  State<VaccinationFormScreen> createState() => _VaccinationFormScreenState();
}

class _VaccinationFormScreenState extends State<VaccinationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _administeredDate = DateTime.now();
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 365));
  
  bool _isEditing = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.vaccination != null;
    
    if (_isEditing) {
      // Populate form with existing vaccination data
      _nameController.text = widget.vaccination!.name;
      _notesController.text = widget.vaccination!.notes ?? '';
      _administeredDate = widget.vaccination!.administeredDate;
      _nextDueDate = widget.vaccination!.nextDueDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Save vaccination data
  void _saveVaccination() {
    if (_formKey.currentState!.validate()) {
      final vaccinationProvider = Provider.of<VaccinationProvider>(context, listen: false);
      
      if (_isEditing) {
        // Update existing vaccination
        final updatedVaccination = widget.vaccination!.copyWith(
          name: _nameController.text,
          administeredDate: _administeredDate,
          nextDueDate: _nextDueDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        
        vaccinationProvider.updateVaccination(updatedVaccination);
      } else {
        // Create new vaccination
        final newVaccination = Vaccination(
          id: _uuid.v4(),
          name: _nameController.text,
          administeredDate: _administeredDate,
          nextDueDate: _nextDueDate,
          petId: widget.petId,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        
        vaccinationProvider.addVaccination(newVaccination);
      }
      
      Navigator.pop(context);
    }
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context, bool isAdministeredDate) async {
    final DateTime initialDate = isAdministeredDate ? _administeredDate : _nextDueDate;
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isAdministeredDate) {
          _administeredDate = pickedDate;
        } else {
          _nextDueDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets.firstWhere((pet) => pet.id == widget.petId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Vaccination' : 'Add Vaccination'),
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
              
              // Vaccination name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vaccination Name',
                  hintText: 'e.g., Rabies, Distemper, etc.',
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
              
              // Administered date
              _buildDateField(
                'Date Administered',
                DateFormat('MMM dd, yyyy').format(_administeredDate),
                () => _selectDate(context, true),
              ),
              const SizedBox(height: 16),
              
              // Next due date
              _buildDateField(
                'Next Due Date',
                DateFormat('MMM dd, yyyy').format(_nextDueDate),
                () => _selectDate(context, false),
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
                  onPressed: _saveVaccination,
                  child: Text(
                    _isEditing ? 'Update Vaccination' : 'Add Vaccination',
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

  Widget _buildDateField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
} 