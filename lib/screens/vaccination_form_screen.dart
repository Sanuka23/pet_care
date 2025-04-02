import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/vaccination_model.dart';
import '../services/vaccination_provider.dart';

class VaccinationFormScreen extends StatefulWidget {
  final String petId;
  final Vaccination? vaccination;

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
  final _veterinarianController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _administeredDate;
  late DateTime _nextDueDate;

  @override
  void initState() {
    super.initState();
    // If editing, populate the fields
    if (widget.vaccination != null) {
      _nameController.text = widget.vaccination!.name;
      _veterinarianController.text = widget.vaccination!.veterinarian ?? '';
      _notesController.text = widget.vaccination!.notes ?? '';
      _administeredDate = widget.vaccination!.administeredDate;
      _nextDueDate = widget.vaccination!.nextDueDate;
    } else {
      // Default values for new vaccinations
      _administeredDate = DateTime.now();
      _nextDueDate = DateTime.now().add(const Duration(days: 365)); // Default to 1 year later
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _veterinarianController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vaccination == null ? 'Add Vaccination' : 'Edit Vaccination'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vaccination Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vaccination Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vaccination name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Administered Date
              InkWell(
                onTap: () => _selectDate(context, isAdministeredDate: true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Administered Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('MMM d, yyyy').format(_administeredDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Next Due Date
              InkWell(
                onTap: () => _selectDate(context, isAdministeredDate: false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Next Due Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('MMM d, yyyy').format(_nextDueDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Veterinarian
              TextFormField(
                controller: _veterinarianController,
                decoration: const InputDecoration(
                  labelText: 'Veterinarian (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveVaccination,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  widget.vaccination == null ? 'Add Vaccination' : 'Save Changes',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // Delete Button (only for editing)
              if (widget.vaccination != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _deleteVaccination,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Delete Vaccination',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isAdministeredDate}) async {
    final initialDate = isAdministeredDate ? _administeredDate : _nextDueDate;

    final pickedDate = await showDatePicker(
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

  void _saveVaccination() {
    if (_formKey.currentState!.validate()) {
      final vaccinationProvider = Provider.of<VaccinationProvider>(context, listen: false);

      final vaccination = Vaccination(
        id: widget.vaccination?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.petId,
        name: _nameController.text,
        administeredDate: _administeredDate,
        nextDueDate: _nextDueDate,
        veterinarian: _veterinarianController.text.isNotEmpty ? _veterinarianController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        isCompleted: widget.vaccination?.isCompleted ?? false,
      );

      if (widget.vaccination == null) {
        // Add new vaccination
        vaccinationProvider.addVaccination(vaccination);
      } else {
        // Update existing vaccination
        vaccinationProvider.updateVaccination(vaccination);
      }

      Navigator.pop(context);
    }
  }

  void _deleteVaccination() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vaccination'),
        content: const Text('Are you sure you want to delete this vaccination record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              if (widget.vaccination != null) {
                Provider.of<VaccinationProvider>(context, listen: false)
                    .deleteVaccination(widget.vaccination!.id);
                Navigator.pop(context); // Go back to vaccination list
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 