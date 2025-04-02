import 'package:flutter/material.dart';
import 'vaccination_screen.dart';
import 'appointment_screen.dart';
import 'feeding_screen.dart';
import 'activity_screen.dart';
import 'playdate_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Care'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Vaccinations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Feeding',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Activity',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const VaccinationScreen();
      case 2:
        return const AppointmentScreen();
      case 3:
        return const FeedingScreen();
      case 4:
        return const ActivityScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildPetProfile(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildPetProfile() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.pets, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add Your Pet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Tap to add pet profile',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Profile creation will be implemented later
              },
              child: const Text('Add Pet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _buildQuickActionCard('Vaccinations', Icons.medical_services, () {
              setState(() => _currentIndex = 1);
            }),
            _buildQuickActionCard('Appointments', Icons.calendar_today, () {
              setState(() => _currentIndex = 2);
            }),
            _buildQuickActionCard('Feeding', Icons.restaurant, () {
              setState(() => _currentIndex = 3);
            }),
            _buildQuickActionCard('Activity', Icons.directions_walk, () {
              setState(() => _currentIndex = 4);
            }),
            _buildQuickActionCard('Playdates', Icons.people, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlaydateScreen()),
              );
            }),
            _buildQuickActionCard('Reminders', Icons.notifications, () {
              // Will be implemented later
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('No recent activities'),
            subtitle: const Text('Add a pet to get started'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Will be implemented later
            },
          ),
        ),
      ],
    );
  }
} 