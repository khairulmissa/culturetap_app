import 'package:flutter/material.dart';
import 'location_detail_screen.dart';
import '../models/location_model.dart';
import '../models/user.dart';

class PlacesListScreen extends StatelessWidget {
  final String state;
  final List<Location> locations;
  final User currentUser;

  const PlacesListScreen({
    super.key,
    required this.state,
    required this.locations,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places in $state'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'List of Places:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: locations.isEmpty
                  ? const Center(
                      child: Text(
                        'No places available for this state',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final location = locations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationDetailScreen(
                                      location: locations[index],
                                      currentUser: currentUser,
                                  ),
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              location.category,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'historical site':
        return Icons.landscape;
      case 'cultural':
        return Icons.celebration;
      case 'natural':
        return Icons.nature;
      case 'museum':
        return Icons.museum;
      default:
        return Icons.place;
    }
  }
}