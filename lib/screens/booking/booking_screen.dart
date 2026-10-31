import 'package:flutter/material.dart';
import 'package:culturetap_app/models/destination.dart';
import 'package:culturetap_app/models/user.dart';
import 'booking_form.dart';
import '../login_screen.dart'; 
import 'package:culturetap_app/services/auth_service.dart';

class BookingScreen extends StatefulWidget {
  final User? currentUser;
  final Destination? selectedDestination;
  
  const BookingScreen({
    super.key,
    this.currentUser,
    this.selectedDestination,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<Destination> _destinations = [];
  Destination? _selectedDestination;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
    _selectedDestination = widget.selectedDestination;
  }

  void _loadDestinations() {
    
    setState(() {
      _destinations = [
        Destination(
          id: 1,
          name: 'Muzium Negara',
          description: 'National Museum of Malaysia',
          location: 'Kuala Lumpur',
          state: 'Kuala Lumpur',
          imageUrl: 'assets/images/Muzium_Negara.jpg',
          rating: 4.5,
          ticketPrice: 5.00,
          categories: ['Museum', 'Historical'],
        ),
        Destination(
          id: 2,
          name: 'Batik Workshop',
          description: 'Traditional Batik Making Experience',
          location: 'Kuala Terengganu',
          state: 'Terengganu',
          imageUrl: 'assets/images/Batik_Workshop.jpg',
          rating: 4.8,
          ticketPrice: 75.00,
          categories: ['Workshop', 'Cultural'],
        ),
        Destination(
          id: 3,
          name: 'Petrosains',
          description: 'Interactive Science Discovery Centre',
          location: 'KLCC',
          state: 'Kuala Lumpur',
          imageUrl: 'assets/images/Petrosains.jpg',
          rating: 4.7,
          ticketPrice: 25.00,
          categories: ['Science', 'Interactive'],
        ),
        Destination(
          id: 4,
          name: 'Stadthuys & History and Ethnography Museum',
          description: 'One Of The Oldest Surviving Dutch structures in Southeast Asia.',
          location: 'Bandar Hilir',
          state: 'Melaka',
          imageUrl: 'assets/images/Stadthuys_&_History_and_Ethnography_Museum.jpg',
          rating: 4.3,
          ticketPrice: 10.00,
          categories: ['Historical', 'Museum'],
        ),
        Destination(
          id: 5,
          name: 'Kellie\'s Castle',
          description: 'An unfinished Historic Mansion built in the Early 20th Century',
          location: 'Batu Gajah',
          state: 'Perak',
          imageUrl: 'assets/images/Kellies_Castle.jpg',
          rating: 4.5,
          ticketPrice: 13.00,
          categories: ['Historical', 'Architectural'],
        ),
        Destination(
          id: 6,
          name: 'Islamic Arts Museum Malaysia',
          description: 'One of Southeast Asia\'s largest Islamic Art Museums',
          location: 'Kuala Lumpur',
          state: 'Kuala Lumpur',
          imageUrl: 'assets/images/Islamic_Arts_Museum_Malaysia.jpg',
          rating: 4.8,
          ticketPrice: 15.00,
          categories: ['Historical', 'Cultural'],
        ),
      ];
    });
  }

  void _navigateToBookingForm(Destination destination) {
    final user = AuthService().currentUser;
    
    print('🔍 Booking Debug - User check:');
    print('   - User object: $user');
    print('   - User name: ${user?.name ?? "null"}');
    print('   - User email: ${user?.email ?? "null"}');
    print('   - User ID: ${user?.id ?? "null"}');
    
    if (user == null || user.id <= 0) {
      print('❌ User is null or invalid! Redirecting to login...');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to book an experience'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }
    
    print('✅ User OK, navigating to booking form...');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFormScreen(
          currentUser: user,
          destination: destination,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final userName = user?.name ?? widget.currentUser?.name ?? 'Explorer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Cultural Experience'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $userName!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.currentUser == null 
                                ? 'Login to book experiences'
                                : 'Select a cultural experience to book',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Destination List
              const Text(
                'Available Experiences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Discover and book unique Malaysian cultural experiences',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Destination Cards
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _destinations.length,
                itemBuilder: (context, index) {
                  final destination = _destinations[index];
                  return _buildDestinationCard(destination);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Destination destination) {
    final user = AuthService().currentUser;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Image
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(destination.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Destination Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            destination.location,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'RM ${destination.ticketPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text(
                      'per person',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${destination.rating} (${destination.totalReviews})',
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                Text(
                  destination.categories.join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToBookingForm(destination),
                style: ElevatedButton.styleFrom(
                  backgroundColor: user == null ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_online, size: 20),
                    SizedBox(width: 8),
                    Text(
                      user == null ? 'Login to Book' : 'Book Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}