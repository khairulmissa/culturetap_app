import 'package:flutter/material.dart';
import '../../models/destination.dart';
import '../../services/database_service.dart';
import '../admin/add_edit_experiences_screen.dart'; 

class ManageExperiencesScreen extends StatefulWidget {
  const ManageExperiencesScreen({super.key});

  @override
  State<ManageExperiencesScreen> createState() => _ManageExperiencesScreenState();
}

class _ManageExperiencesScreenState extends State<ManageExperiencesScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Destination> _destinations = [];
  List<Destination> _filteredDestinations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedState = 'All';

  
  final List<String> _states = [
    'All',
    'Kuala Lumpur',
    'Selangor',
    'Johor',
    'Penang',
    'Melaka',
    'Terengganu',
    'Kelantan',
    'Pahang',
    'Perak',
    'Kedah',
    'Negeri Sembilan',
    'Perlis',
    'Sabah',
    'Sarawak',
  ];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final destinations = await _dbService.getAllDestinations();
      setState(() {
        _destinations = destinations;
        _filteredDestinations = destinations;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading destinations: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load destinations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterDestinations() {
    List<Destination> filtered = _destinations;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((dest) =>
          dest.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dest.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dest.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filter by state
    if (_selectedState != 'All') {
      filtered = filtered.where((dest) => dest.state == _selectedState).toList();
    }

    setState(() {
      _filteredDestinations = filtered;
    });
  }

  Future<void> _deleteDestination(int destinationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this destination? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbService.deleteDestination(destinationId);
        
        
        setState(() {
          _destinations.removeWhere((dest) => dest.id == destinationId);
        });
        
        _filterDestinations(); 
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Destination deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete destination: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToAddEditScreen({Destination? destination}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExperienceScreen(
          destination: destination,
          onSave: _loadDestinations,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Experiences'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDestinations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      
      body: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal[50],
            child: Column(
              children: [
               
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterDestinations();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search destinations...',
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _states.map((state) {
                      final isSelected = state == _selectedState;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(state),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedState = selected ? state : 'All';
                            });
                            _filterDestinations();
                          },
                          selectedColor: Colors.teal,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.teal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredDestinations.length} destinations found',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  'Total: ${_destinations.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : _filteredDestinations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.place,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No destinations found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty || _selectedState != 'All'
                                  ? 'Try adjusting your search or filter'
                                  : 'Add your first destination using the + button',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredDestinations.length,
                        itemBuilder: (context, index) {
                          final destination = _filteredDestinations[index];
                          return _buildDestinationCard(destination);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildDestinationCard(Destination destination) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Destination Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(destination.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Destination Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              destination.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              destination.state,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            destination.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        destination.description.length > 100
                            ? '${destination.description.substring(0, 100)}...'
                            : destination.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                          const SizedBox(width: 4),
                          Text(
                            destination.ratingDisplay,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            destination.formattedPrice,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _navigateToAddEditScreen(destination: destination),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _deleteDestination(destination.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, size: 18),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.category, size: 14, color: Colors.teal.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Categories: ${destination.categoriesDisplay}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.teal.shade600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 14, color: Colors.teal.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Updated: ${destination.updatedAt.day}/${destination.updatedAt.month}/${destination.updatedAt.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.teal.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}