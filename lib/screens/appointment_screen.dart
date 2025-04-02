import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../services/appointment_provider.dart';
import '../services/pet_provider.dart';
import 'appointment_form_screen.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PetProvider, AppointmentProvider>(
      builder: (context, petProvider, appointmentProvider, child) {
        final currentPet = petProvider.currentPet;

        if (currentPet == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Vet Appointments'),
            ),
            body: const Center(
              child: Text('Please add a pet first to manage appointments'),
            ),
          );
        }

        // Get appointments for the current pet
        final appointments = appointmentProvider.getAppointmentsForPet(currentPet.id);
        
        // Sort by date
        appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        
        // Separate upcoming and completed appointments
        final upcomingAppointments = appointments.where((a) => !a.isCompleted).toList();
        final completedAppointments = appointments.where((a) => a.isCompleted).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('${currentPet.name}\'s Appointments'),
          ),
          body: appointments.isEmpty 
              ? _buildEmptyState(context, currentPet.id)
              : _buildAppointmentList(context, upcomingAppointments, completedAppointments),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addAppointment(context, currentPet.id),
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
            Icons.calendar_today,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Appointments Scheduled',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Schedule a vet appointment for your pet',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addAppointment(context, petId),
            icon: const Icon(Icons.add),
            label: const Text('Add Appointment'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(
    BuildContext context, 
    List<Appointment> upcomingAppointments, 
    List<Appointment> completedAppointments
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming appointments section
          if (upcomingAppointments.isNotEmpty) ...[
            const Text(
              'Upcoming',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...upcomingAppointments.map((appointment) => 
              _buildAppointmentCard(context, appointment)
            ),
            const SizedBox(height: 16),
          ],
          
          // Completed appointments section
          if (completedAppointments.isNotEmpty) ...[
            const Text(
              'Completed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...completedAppointments.map((appointment) => 
              _buildAppointmentCard(context, appointment)
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(appointment.dateTime);
    final formattedTime = DateFormat('h:mm a').format(appointment.dateTime);
    final now = DateTime.now();
    final daysUntil = appointment.dateTime.difference(now).inDays;
    
    // Determine card color based on date
    Color cardColor = Colors.white;
    if (!appointment.isCompleted) {
      if (appointment.dateTime.isBefore(now)) {
        cardColor = Colors.red.shade50; // Overdue
      } else if (daysUntil < 3) {
        cardColor = Colors.orange.shade50; // Upcoming soon
      } else {
        cardColor = Colors.blue.shade50; // Future appointment
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
                    appointment.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!appointment.isCompleted)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Mark as completed',
                    onPressed: () => _markAsCompleted(context, appointment),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit appointment',
                  onPressed: () => _editAppointment(context, appointment),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete appointment',
                  onPressed: () => _deleteAppointment(context, appointment),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Date', formattedDate),
            _buildInfoRow('Time', formattedTime),
            _buildInfoRow('Vet', appointment.vetName),
            _buildInfoRow('Location', appointment.vetLocation),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              _buildInfoRow('Notes', appointment.notes!),
            if (!appointment.isCompleted) ...[
              const SizedBox(height: 8),
              _buildDueIndicator(daysUntil),
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
            width: 80,
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

  Widget _buildDueIndicator(int daysUntil) {
    String message;
    Color color;
    
    if (daysUntil < 0) {
      message = 'Missed';
      color = Colors.red;
    } else if (daysUntil == 0) {
      message = 'Today';
      color = Colors.orange;
    } else if (daysUntil == 1) {
      message = 'Tomorrow';
      color = Colors.orange;
    } else if (daysUntil < 7) {
      message = 'In $daysUntil days';
      color = Colors.orange;
    } else {
      message = 'In $daysUntil days';
      color = Colors.blue;
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

  void _addAppointment(BuildContext context, String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentFormScreen(petId: petId),
      ),
    );
  }

  void _editAppointment(BuildContext context, Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentFormScreen(
          petId: appointment.petId,
          appointment: appointment,
        ),
      ),
    );
  }

  void _markAsCompleted(BuildContext context, Appointment appointment) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    appointmentProvider.completeAppointment(appointment.id);
  }

  void _deleteAppointment(BuildContext context, Appointment appointment) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text('Are you sure you want to delete "${appointment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appointmentProvider.deleteAppointment(appointment.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 