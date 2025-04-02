import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/playdate_model.dart';
import '../services/playdate_provider.dart';
import '../services/pet_provider.dart';
import 'playdate_form_screen.dart';

class PlaydateScreen extends StatefulWidget {
  const PlaydateScreen({super.key});

  @override
  State<PlaydateScreen> createState() => _PlaydateScreenState();
}

class _PlaydateScreenState extends State<PlaydateScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load playdate data
      Provider.of<PlaydateProvider>(context, listen: false).loadPlaydates();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PetProvider, PlaydateProvider>(
      builder: (context, petProvider, playdateProvider, child) {
        final currentPet = petProvider.currentPet;

        if (currentPet == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Playdates'),
            ),
            body: const Center(
              child: Text('Please add a pet first to manage playdates'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${currentPet.name}\'s Playdates'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by location',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPlaydatesTab(currentPet.id, playdateProvider, true),
                    _buildPlaydatesTab(currentPet.id, playdateProvider, false),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addPlaydate(context, currentPet.id),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildPlaydatesTab(String petId, PlaydateProvider playdateProvider, bool showUpcoming) {
    final now = DateTime.now();
    
    // Get all playdates for the pet
    List<Playdate> allPlaydates = playdateProvider.getPlaydatesForPet(petId);
    
    // Filter by upcoming or past
    if (showUpcoming) {
      allPlaydates = allPlaydates.where((playdate) => 
        playdate.date.isAfter(now)
      ).toList();
    } else {
      allPlaydates = allPlaydates.where((playdate) => 
        playdate.date.isBefore(now)
      ).toList();
    }
    
    // Apply search filter if any
    if (_searchQuery.isNotEmpty) {
      allPlaydates = allPlaydates.where((playdate) => 
        playdate.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Sort by date
    allPlaydates.sort((a, b) => 
      showUpcoming ? a.date.compareTo(b.date) : b.date.compareTo(a.date)
    );
    
    if (allPlaydates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              showUpcoming 
                ? 'No Upcoming Playdates'
                : 'No Past Playdates',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              showUpcoming
                ? 'Schedule new playdates for your pet'
                : 'Playdates will appear here after they happen',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (showUpcoming)
              ElevatedButton.icon(
                onPressed: () => _addPlaydate(context, petId),
                icon: const Icon(Icons.add),
                label: const Text('Add Playdate'),
              ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: allPlaydates.length,
      itemBuilder: (context, index) {
        final playdate = allPlaydates[index];
        return _buildPlaydateCard(playdate);
      },
    );
  }

  Widget _buildPlaydateCard(Playdate playdate) {
    final now = DateTime.now();
    final isToday = playdate.date.year == now.year && 
                   playdate.date.month == now.month && 
                   playdate.date.day == now.day;
                   
    final isPast = playdate.date.isBefore(now);
    
    // Determine card color based on status
    Color cardColor = Colors.white;
    if (playdate.isConfirmed) {
      cardColor = Colors.green.shade50;
    } else if (!isPast) {
      cardColor = Colors.blue.shade50;
    }
    
    final formattedTime = DateFormat('h:mm a').format(playdate.date);
    final formattedDate = isToday 
        ? 'Today' 
        : DateFormat('EEE, MMM d').format(playdate.date);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side with date/time
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${playdate.durationMinutes} min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Playdate details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playdate.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              playdate.location,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      if (playdate.contactInfo != null && playdate.contactInfo!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.contact_phone, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              playdate.contactInfo!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Action menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, playdate),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    if (!playdate.isConfirmed)
                      const PopupMenuItem(
                        value: 'confirm',
                        child: Text('Confirm'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            
            // Participants section
            const SizedBox(height: 12),
            const Text(
              'Participants:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: playdate.participants.map((name) {
                return Chip(
                  avatar: const CircleAvatar(
                    child: Icon(Icons.pets, size: 16),
                  ),
                  label: Text(name),
                  backgroundColor: Colors.grey.shade100,
                );
              }).toList(),
            ),
            
            // Notes if available
            if (playdate.notes != null && playdate.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                playdate.notes!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            
            // Status badge
            const SizedBox(height: 8),
            if (playdate.isConfirmed)
              const Chip(
                label: Text('Confirmed'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              )
            else if (isPast)
              const Chip(
                label: Text('Past'),
                backgroundColor: Colors.grey,
                labelStyle: TextStyle(color: Colors.white),
              )
            else
              const Chip(
                label: Text('Upcoming'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  void _addPlaydate(BuildContext context, String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaydateFormScreen(petId: petId),
      ),
    );
  }

  void _editPlaydate(Playdate playdate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaydateFormScreen(
          petId: playdate.petId,
          playdate: playdate,
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Playdate playdate) {
    final playdateProvider = Provider.of<PlaydateProvider>(context, listen: false);
    
    switch (action) {
      case 'edit':
        _editPlaydate(playdate);
        break;
      case 'confirm':
        playdateProvider.confirmPlaydate(playdate.id);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(playdate);
        break;
    }
  }

  void _showDeleteConfirmationDialog(Playdate playdate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playdate'),
        content: Text('Are you sure you want to delete "${playdate.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PlaydateProvider>(context, listen: false)
                .deletePlaydate(playdate.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 