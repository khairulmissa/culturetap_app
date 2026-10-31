import 'package:flutter/material.dart';
import 'places_list_screen.dart'; 
import '../models/location_model.dart';
import '../models/user.dart'; 
import 'data/locations_data.dart'; 

class StateSelectionScreen extends StatelessWidget {
  final User currentUser; 

  const StateSelectionScreen({
    super.key, 
    required this.currentUser, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CultureTap'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select State:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: allStates.map((state) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () {
                        final stateLocations = allLocations
                            .where((location) => location.state == state)
                            .toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlacesListScreen(
                              state: state,
                              locations: stateLocations,
                              currentUser: currentUser, 
                            ),
                          ),
                        );
                      },
                      title: Text(
                        state,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}