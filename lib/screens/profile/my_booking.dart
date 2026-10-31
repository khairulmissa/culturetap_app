import 'package:flutter/material.dart';
import 'package:culturetap_app/services/database_service.dart'; 
import 'package:culturetap_app/services/auth_service.dart'; 
import 'package:culturetap_app/models/booking.dart';
import 'package:culturetap_app/models/user.dart';


class MyBookingsScreen extends StatefulWidget {
  final User? currentUser; 
  
  const MyBookingsScreen({Key? key, this.currentUser}) : super(key: key); 

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  User? _currentUser; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveCurrentUser();
    });
  }

  Future<void> _resolveCurrentUser() async {
    User? user = widget.currentUser;
    
    
    if (user != null) {
      _currentUser = user;
      _loadBookings();
      return;
    }
    
    
    try {
      final authService = AuthService();
      user = authService.currentUser;
      
      if (user != null && user.id > 0) {
        _currentUser = user;
        _loadBookings();
        return;
      }
    } catch (e) {
      print('❌ Error getting current user: $e');
    }
    
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadBookings() async {
    if (_currentUser == null || _currentUser!.id <= 0) {
      print('❌ No valid user for loading bookings');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final dbService = DatabaseService();
      final bookings = await dbService.getUserBookings(_currentUser!.id);
      
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
      
      print('📋 Loaded ${_bookings.length} bookings for user ${_currentUser!.name}');
    } catch (e) {
      print('❌ Error loading bookings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  // ✅ FILTER BOOKINGS BY STATUS
  List<Booking> get _upcomingBookings {
    final now = DateTime.now();
    return _bookings.where((booking) {
      return booking.status.toLowerCase() == 'confirmed' && 
             booking.visitDate.isAfter(now);
    }).toList();
  }

  List<Booking> get _completedBookings {
    final now = DateTime.now();
    return _bookings.where((booking) {
      return booking.status.toLowerCase() == 'completed' ||
             (booking.status.toLowerCase() == 'confirmed' && 
              booking.visitDate.isBefore(now));
    }).toList();
  }

  List<Booking> get _cancelledBookings {
    return _bookings.where((booking) {
      return booking.status.toLowerCase() == 'cancelled';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        backgroundColor: Colors.purple[800],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.purple[50],
              child: TabBar(
                labelColor: Colors.purple[800],
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.purple[800],
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _buildUpcomingBookings(context),
                        _buildCompletedBookings(context),
                        _buildCancelledBookings(context),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadBookings,
        backgroundColor: Colors.purple[800],
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildUpcomingBookings(BuildContext context) {
    if (_upcomingBookings.isEmpty) {
      return _buildEmptyState('No upcoming bookings');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingBookings.length,
      itemBuilder: (context, index) {
        final booking = _upcomingBookings[index];
        return _buildBookingCard(context, booking, true);
      },
    );
  }

  Widget _buildCompletedBookings(BuildContext context) {
    if (_completedBookings.isEmpty) {
      return _buildEmptyState('No completed bookings');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedBookings.length,
      itemBuilder: (context, index) {
        final booking = _completedBookings[index];
        return _buildBookingCard(context, booking, false);
      },
    );
  }

  Widget _buildCancelledBookings(BuildContext context) {
    if (_cancelledBookings.isEmpty) {
      return _buildEmptyState('No cancelled bookings');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cancelledBookings.length,
      itemBuilder: (context, index) {
        final booking = _cancelledBookings[index];
        return _buildBookingCard(context, booking, false);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your bookings will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking, bool isUpcoming) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.destinationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(booking.status)),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(booking.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildBookingDetailRow(
              icon: Icons.calendar_today,
              text: '${booking.visitDate.day}/${booking.visitDate.month}/${booking.visitDate.year} • ${booking.visitDate.hour.toString().padLeft(2, '0')}:${booking.visitDate.minute.toString().padLeft(2, '0')}',
            ),
            
            _buildBookingDetailRow(
              icon: Icons.confirmation_number,
              text: 'Ref: ${booking.bookingReference ?? "N/A"}',
            ),
            
            _buildBookingDetailRow(
              icon: Icons.people,
              text: '${booking.numberOfPeople} person(s)',
            ),
            
            _buildBookingDetailRow(
              icon: Icons.attach_money,
              text: 'RM ${booking.totalPrice.toStringAsFixed(2)}',
            ),
            
            if (booking.specialRequest != null && booking.specialRequest!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Special Request:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    booking.specialRequest!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            if (isUpcoming)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _viewBookingDetails(context, booking),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.purple[800]!),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(color: Colors.purple[800]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _cancelBooking(context, booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _viewBookingDetails(context, booking),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.purple[800]!),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(color: Colors.purple[800]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _bookAgain(context, booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[800],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Book Again'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBookingDetailRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _viewBookingDetails(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(booking.destinationName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Booking Date', '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}'),
              _buildDetailItem('Visit Date', '${booking.visitDate.day}/${booking.visitDate.month}/${booking.visitDate.year}'),
              _buildDetailItem('Time', '${booking.visitDate.hour.toString().padLeft(2, '0')}:${booking.visitDate.minute.toString().padLeft(2, '0')}'),
              _buildDetailItem('Number of People', '${booking.numberOfPeople} person(s)'),
              _buildDetailItem('Total Price', 'RM ${booking.totalPrice.toStringAsFixed(2)}'),
              _buildDetailItem('Status', booking.status.toUpperCase()),
              if (booking.bookingReference != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Booking Reference:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(booking.bookingReference!, style: const TextStyle(fontSize: 18)),
                  ],
                ),
              if (booking.specialRequest != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Special Request:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(booking.specialRequest!),
                  ],
                ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[100],
                child: const Text(
                  'Please arrive 15 minutes before the scheduled time. '
                  'Bring your booking confirmation email or reference number.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(BuildContext context, Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel "${booking.destinationName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dbService = DatabaseService();
        await dbService.updateBookingStatus(booking.id!, 'cancelled');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${booking.destinationName}" has been cancelled'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Refresh bookings
        _loadBookings();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _bookAgain(BuildContext context, Booking booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirecting to book "${booking.destinationName}"...'),
        backgroundColor: Colors.green,
      ),
    );
    // TODO: Navigate to booking screen with pre-filled details
  }
}