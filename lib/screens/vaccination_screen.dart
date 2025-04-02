import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/vaccination_model.dart';
import '../services/vaccination_provider.dart';
import '../services/pet_provider.dart';
import 'vaccination_form_screen.dart';

class VaccinationScreen extends StatelessWidget {
  const VaccinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PetProvider, VaccinationProvider>(
      builder: (context, petProvider, vaccinationProvider, child) {
        final currentPet = petProvider.currentPet;

        if (currentPet == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Vaccinations'),
            ),
            body: const Center(
              child: Text('Please add a pet first to manage vaccinations'),
            ),
          );
        }

        // Get vaccinations for the current pet
        final vaccinations = vaccinationProvider.getVaccinationsForPet(currentPet.id);
        
        // Sort by next due date
        vaccinations.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
        
        // Separate upcoming and completed vaccinations
        final upcomingVaccinations = vaccinations.where((v) => !v.isCompleted).toList();
        final completedVaccinations = vaccinations.where((v) => v.isCompleted).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('${currentPet.name}\'s Vaccinations'),
          ),
          body: vaccinations.isEmpty 
              ? _buildEmptyState(context, currentPet.id)
              : _buildVaccinationList(context, upcomingVaccinations, completedVaccinations),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addVaccination(context, currentPet.id),
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
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Vaccinations Added Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add vaccination records to keep track of your pet\'s health',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addVaccination(context, petId),
            icon: const Icon(Icons.add),
            label: const Text('Add Vaccination'),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationList(
    BuildContext context, 
    List<Vaccination> upcomingVaccinations, 
    List<Vaccination> completedVaccinations
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming vaccinations section
          if (upcomingVaccinations.isNotEmpty) ...[
            const Text(
              'Upcoming',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...upcomingVaccinations.map((vaccination) => 
              _buildVaccinationCard(context, vaccination)
            ),
            const SizedBox(height: 16),
          ],
          
          // Completed vaccinations section
          if (completedVaccinations.isNotEmpty) ...[
            const Text(
              'Completed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...completedVaccinations.map((vaccination) => 
              _buildVaccinationCard(context, vaccination)
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(BuildContext context, Vaccination vaccination) {
    final formattedAdministeredDate = DateFormat('MMM dd, yyyy').format(vaccination.administeredDate);
    final formattedNextDueDate = DateFormat('MMM dd, yyyy').format(vaccination.nextDueDate);
    final now = DateTime.now();
    final daysUntilDue = vaccination.nextDueDate.difference(now).inDays;
    
    // Determine card color based on due date
    Color cardColor = Colors.white;
    if (!vaccination.isCompleted) {
      if (daysUntilDue < 0) {
        cardColor = Colors.red.shade50; // Overdue
      } else if (daysUntilDue < 30) {
        cardColor = Colors.orange.shade50; // Due soon
      } else {
        cardColor = Colors.green.shade50; // Not due yet
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                if (!vaccination.isCompleted)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Mark as completed',
                    onPressed: () => _markAsCompleted(context, vaccination),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit vaccination',
                  onPressed: () => _editVaccination(context, vaccination),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete vaccination',
                  onPressed: () => _deleteVaccination(context, vaccination),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Administered', formattedAdministeredDate),
            _buildInfoRow('Next Due', formattedNextDueDate),
            if (vaccination.notes != null && vaccination.notes!.isNotEmpty)
              _buildInfoRow('Notes', vaccination.notes!),
            if (!vaccination.isCompleted) ...[
              const SizedBox(height: 8),
              _buildDueIndicator(daysUntilDue),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDueIndicator(int daysUntilDue) {
    String message;
    Color color;
    
    if (daysUntilDue < 0) {
      message = 'Overdue by ${-daysUntilDue} days';
      color = Colors.red;
    } else if (daysUntilDue == 0) {
      message = 'Due today';
      color = Colors.orange;
    } else if (daysUntilDue <= 30) {
      message = 'Due in $daysUntilDue days';
      color = Colors.orange;
    } else {
      message = 'Due in $daysUntilDue days';
      color = Colors.green;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _addVaccination(BuildContext context, String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccinationFormScreen(petId: petId),
      ),
    );
  }

  void _editVaccination(BuildContext context, Vaccination vaccination) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccinationFormScreen(
          petId: vaccination.petId,
          vaccination: vaccination,
        ),
      ),
    );
  }

  void _markAsCompleted(BuildContext context, Vaccination vaccination) {
    final vaccinationProvider = Provider.of<VaccinationProvider>(context, listen: false);
    vaccinationProvider.completeVaccination(vaccination.id);
  }

  void _deleteVaccination(BuildContext context, Vaccination vaccination) {
    final vaccinationProvider = Provider.of<VaccinationProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vaccination'),
        content: Text('Are you sure you want to delete "${vaccination.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              vaccinationProvider.deleteVaccination(vaccination.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 