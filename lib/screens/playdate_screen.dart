import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
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
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Right side with playdate details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playdate.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              playdate.location,
                              style: TextStyle(color: Colors.grey[700]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.people_alt_outlined, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Participants: ${playdate.participants.join(", ")}',
                              style: TextStyle(color: Colors.grey[700]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (playdate.contactInfo != null && playdate.contactInfo!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.contact_phone, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Contact: ${playdate.contactInfo}',
                                style: TextStyle(color: Colors.grey[700]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            // Status chips and action buttons
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status chip
                Chip(
                  label: Text(
                    isPast 
                        ? 'Completed' 
                        : playdate.isConfirmed 
                            ? 'Confirmed' 
                            : 'Unconfirmed',
                    style: TextStyle(
                      color: isPast 
                          ? Colors.grey[700] 
                          : playdate.isConfirmed 
                              ? Colors.green[700] 
                              : Colors.blue[700],
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: isPast 
                      ? Colors.grey[100] 
                      : playdate.isConfirmed 
                          ? Colors.green[50] 
                          : Colors.blue[50],
                ),
                
                // Action buttons
                Row(
                  children: [
                    // Photos button (if past event or has photos)
                    if (isPast || (playdate.photos != null && playdate.photos!.isNotEmpty))
                      IconButton(
                        icon: const Icon(Icons.photo_library, size: 20),
                        tooltip: 'Photos',
                        onPressed: () => _showPlaydatePhotos(playdate),
                      ),
                    
                    // Confirm button (if future event and not confirmed)
                    if (!isPast && !playdate.isConfirmed)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        tooltip: 'Confirm',
                        onPressed: () => _confirmPlaydate(playdate),
                      ),
                    
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit',
                      onPressed: () => _editPlaydate(playdate),
                    ),
                    
                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Delete',
                      onPressed: () => _deletePlaydate(playdate),
                    ),
                  ],
                ),
              ],
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

  void _showPlaydatePhotos(Playdate playdate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Playdate Photos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: () => _addPhotoToPlaydate(playdate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: playdate.photos != null && playdate.photos!.isNotEmpty
                        ? GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: playdate.photos!.length,
                            itemBuilder: (context, index) {
                              final photoPath = playdate.photos![index];
                              return InkWell(
                                onTap: () => _viewPhoto(photoPath),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.photo,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No photos yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _addPhotoToPlaydate(playdate),
                                  icon: const Icon(Icons.add_a_photo),
                                  label: const Text('Add Photo'),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _viewPhoto(String photoPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Placeholder image
                const Icon(
                  Icons.image,
                  size: 150,
                  color: Colors.white54,
                ),
                const SizedBox(height: 16),
                Text(
                  'Simulated photo: $photoPath',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addPhotoToPlaydate(Playdate playdate) async {
    try {
      // For demo purposes, we'll simulate adding a sample photo path
      // In a real app, you would use image_picker to get a real image
      String samplePhotoPath = 'assets/sample_playdate_photo.jpg';
      
      // Show a dialog to explain the simulation
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Photo Simulation'),
          content: const Text(
            'In a real app, this would open the camera or photo gallery. '
            'For demonstration purposes, we\'ll simulate adding a photo.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
      // Add the simulated photo to the playdate
      final playdateProvider = Provider.of<PlaydateProvider>(context, listen: false);
      await playdateProvider.addPhotoToPlaydate(playdate.id, samplePhotoPath);
      
      // Close bottom sheet if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo simulation added successfully')),
      );
      
      // Reopen photo gallery to see the new photo
      _showPlaydatePhotos(playdate);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error simulating photo: $e')),
      );
    }
  }

  void _confirmPlaydate(Playdate playdate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Playdate'),
        content: const Text('Are you sure you want to confirm this playdate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final provider = Provider.of<PlaydateProvider>(context, listen: false);
              provider.confirmPlaydate(playdate.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Playdate confirmed')),
              );
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  void _deletePlaydate(Playdate playdate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playdate'),
        content: const Text('Are you sure you want to delete this playdate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final provider = Provider.of<PlaydateProvider>(context, listen: false);
              provider.deletePlaydate(playdate.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Playdate deleted')),
              );
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
} 