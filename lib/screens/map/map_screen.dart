import 'package:flutter/material.dart';
import '../../models/location_model.dart';
import 'location_detail.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Location> _locations = [
    Location(
      id: '1',
      name: 'Handicraft Workshop',
      latitude: 3.1390,
      longitude: 101.6869,
      description: 'Traditional Malaysian handicraft making workshop.',
      imageUrl: 'assets/images/workshop.jpg',
      state: 'Kuala Lumpur',
      category: 'Workshop',
    ),
    Location(
      id: '2',
      name: 'Musim Negara',
      latitude: 3.0738,
      longitude: 101.5183,
      description: 'Cultural festival showcasing Malaysian arts.',
      imageUrl: 'assets/images/musim_negara.jpg',
      state: 'Selangor',
      category: 'Festival',
    ),
    Location(
      id: '3',
      name: 'Petrosains',
      latitude: 3.1579,
      longitude: 101.7120,
      description: 'Interactive science discovery centre.',
      imageUrl: 'assets/images/petrosains.jpg',
      state: 'Kuala Lumpur',
      category: 'Museum',
    ),
    Location(
      id: '4',
      name: 'Batu Caves',
      latitude: 3.2373,
      longitude: 101.6839,
      description: 'Limestone hills with Hindu temples.',
      imageUrl: 'assets/images/batu_caves.jpg',
      state: 'Selangor',
      category: 'Historical Site',
    ),
    Location(
      id: '5',
      name: 'Penang Street Art',
      latitude: 5.4141,
      longitude: 100.3288,
      description: 'Famous street art in Georgetown.',
      imageUrl: 'assets/images/penang_art.jpg',
      state: 'Penang',
      category: 'Art',
    ),
  ];

  String _selectedState = 'All';
  final List<String> _states = [
    'All',
    'Kuala Lumpur',
    'Selangor',
    'Penang',
    'Johor',
    'Melaka',
    'Sabah',
    'Sarawak',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLocations = _selectedState == 'All'
        ? _locations
        : _locations.where((loc) => loc.state == _selectedState).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cultural Map'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        children: [
          // State Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by State:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _states.length,
                    itemBuilder: (context, index) {
                      final state = _states[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(state),
                          selected: _selectedState == state,
                          onSelected: (selected) {
                            setState(() {
                              _selectedState = selected ? state : 'All';
                            });
                          },
                          selectedColor: Colors.deepOrangeAccent,
                          checkmarkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Malaysia Map Image with Pins (Static)
          Expanded(
            child: Stack(
              children: [
                // Malaysia Map Image
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.map,
                          size: 80,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Malaysia Cultural Map',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Selected: $_selectedState',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${filteredLocations.length} locations',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // State pins (dummy positions)
                ..._getStatePositions().map((statePos) {
                  return Positioned(
                    left: statePos['x'] as double,
                    top: statePos['y']as double,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedState = statePos['state']!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedState == statePos['state']
                              ? Colors.deepOrangeAccent
                              : Colors.red.withOpacity(0.7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          statePos['state']!.substring(0, 2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Locations List
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cultural Locations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${filteredLocations.length} found',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredLocations.length,
                          itemBuilder: (context, index) {
                            final location = filteredLocations[index];
                            return _buildLocationCard(location, context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Location location, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationDetail(location: location),
            ),
          );
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getCategoryIcon(location.category),
            color: Colors.orange,
          ),
        ),
        title: Text(
          location.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.state,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              location.description,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'workshop':
        return Icons.brush;
      case 'festival':
        return Icons.celebration;
      case 'museum':
        return Icons.museum;
      case 'historical site':
        return Icons.landscape;
      case 'art':
        return Icons.palette;
      default:
        return Icons.place;
    }
  }

  List<Map<String, String>> _getStatePositions() {
    return [
      {'state': 'Kuala Lumpur', 'x': '180.0', 'y': '120.0'},
      {'state': 'Selangor', 'x': '160.0', 'y': '140.0'},
      {'state': 'Penang', 'x': '120.0', 'y': '80.0'},
      {'state': 'Johor', 'x': '200.0', 'y': '200.0'},
      {'state': 'Melaka', 'x': '170.0', 'y': '180.0'},
      {'state': 'Sabah', 'x': '250.0', 'y': '100.0'},
      {'state': 'Sarawak', 'x': '220.0', 'y': '130.0'},
    ];
  }
}