import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/pet_provider.dart';
import '../services/vaccination_provider.dart';
import '../models/vaccination_model.dart';
import 'vaccination_form_screen.dart';

class VaccinationScreen extends StatelessWidget {
  const VaccinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccinations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addVaccination(context),
          ),
        ],
      ),
      body: _buildVaccinationList(context),
    );
  }

  Widget _buildVaccinationList(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final vaccinationProvider = Provider.of<VaccinationProvider>(context);
    final currentPet = petProvider.currentPet;

    if (currentPet == null) {
      return const Center(
        child: Text('Please add a pet first'),
      );
    }

    final vaccinations = vaccinationProvider.getVaccinationsForPet(currentPet.id);

    if (vaccinations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Vaccinations Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Tap + to add your pet\'s first vaccination'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _addVaccination(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Vaccination'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Upcoming Vaccinations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: vaccinations.length,
            itemBuilder: (context, index) {
              final vaccination = vaccinations[index];
              return _buildVaccinationCard(context, vaccination);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVaccinationCard(BuildContext context, Vaccination vaccination) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final dueDate = dateFormat.format(vaccination.nextDueDate);
    final isDue = vaccination.nextDueDate.isBefore(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _editVaccination(context, vaccination),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      vaccination.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(vaccination, isDue),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Due: $dueDate',
                    style: TextStyle(
                      color: isDue && !vaccination.isCompleted
                          ? Colors.red
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (vaccination.veterinarian != null && vaccination.veterinarian!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Vet: ${vaccination.veterinarian}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () => _editVaccination(context, vaccination),
                  ),
                  const SizedBox(width: 8),
                  if (!vaccination.isCompleted)
                    TextButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete'),
                      onPressed: () => _markAsCompleted(context, vaccination),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Vaccination vaccination, bool isDue) {
    if (vaccination.isCompleted) {
      return Chip(
        label: const Text('Completed'),
        backgroundColor: Colors.green[100],
        labelStyle: TextStyle(color: Colors.green[800]),
      );
    } else if (isDue) {
      return Chip(
        label: const Text('Overdue'),
        backgroundColor: Colors.red[100],
        labelStyle: TextStyle(color: Colors.red[800]),
      );
    } else {
      return Chip(
        label: const Text('Upcoming'),
        backgroundColor: Colors.blue[100],
        labelStyle: TextStyle(color: Colors.blue[800]),
      );
    }
  }

  void _addVaccination(BuildContext context) {
    final currentPet = Provider.of<PetProvider>(context, listen: false).currentPet;
    
    if (currentPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a pet first')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccinationFormScreen(petId: currentPet.id),
      ),
    );
  }

  void _editVaccination(BuildContext context, Vaccination vaccination) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccinationFormScreen(
          vaccination: vaccination,
          petId: vaccination.petId,
        ),
      ),
    );
  }

  void _markAsCompleted(BuildContext context, Vaccination vaccination) {
    Provider.of<VaccinationProvider>(context, listen: false)
        .markVaccinationAsCompleted(vaccination.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vaccination.name} marked as completed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            Provider.of<VaccinationProvider>(context, listen: false)
                .markVaccinationAsCompleted(vaccination.id, completed: false);
          },
        ),
      ),
    );
  }
} 