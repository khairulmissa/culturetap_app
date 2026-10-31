import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/booking.dart';
import '../../models/destination.dart';
import '../../models/user.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DatabaseService _dbService = DatabaseService();
  
  List<Booking> _bookings = [];
  List<Destination> _destinations = [];
  List<User> _users = [];
  
  int _totalUsers = 0;
  int _totalBookings = 0;
  int _totalDestinations = 0;
  double _totalRevenue = 0.0;
  double _avgBookingValue = 0.0;
  int _pendingBookings = 0;
  int _confirmedBookings = 0;
  int _cancelledBookings = 0;
  int _completedBookings = 0;
  
  Map<String, double> _monthlyRevenue = {};
  Map<String, int> _monthlyBookings = {};
  Map<int, int> _destinationBookings = {};
  List<Map<String, dynamic>> _topDestinations = [];
  
  bool _isLoading = true;
  String _selectedPeriod = 'This Month';
  
  final List<String> _periodOptions = ['This Week', 'This Month', 'Last Month', 'This Year', 'All Time'];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _dbService.getAllBookings(),
        _dbService.getAllDestinations(),
        _dbService.getAllUsers(),
      ]);

      final bookings = results[0] as List<Booking>;
      final destinations = results[1] as List<Destination>;
      final users = results[2] as List<User>;

      _calculateStatistics(bookings, destinations, users);
      _calculateMonthlyData(bookings);
      _calculateTopDestinations(bookings, destinations);

      setState(() {
        _bookings = bookings;
        _destinations = destinations;
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _calculateStatistics(List<Booking> bookings, List<Destination> destinations, List<User> users) {
    _totalUsers = users.length;
    _totalBookings = bookings.length;
    _totalDestinations = destinations.length;
    
    _totalRevenue = bookings
        .where((b) => b.status == 'confirmed' || b.status == 'completed')
        .fold(0.0, (sum, booking) => sum + booking.totalPrice);
    
    _avgBookingValue = _totalBookings > 0 ? _totalRevenue / _totalBookings : 0;
    
    _pendingBookings = bookings.where((b) => b.status == 'pending').length;
    _confirmedBookings = bookings.where((b) => b.status == 'confirmed').length;
    _cancelledBookings = bookings.where((b) => b.status == 'cancelled').length;
    _completedBookings = bookings.where((b) => b.status == 'completed').length;
  }

  void _calculateMonthlyData(List<Booking> bookings) {
    _monthlyRevenue.clear();
    _monthlyBookings.clear();
    
    for (final booking in bookings.where((b) => b.status == 'confirmed' || b.status == 'completed')) {
      final monthKey = '${booking.createdAt.year}-${booking.createdAt.month.toString().padLeft(2, '0')}';
      _monthlyRevenue[monthKey] = (_monthlyRevenue[monthKey] ?? 0) + booking.totalPrice;
      _monthlyBookings[monthKey] = (_monthlyBookings[monthKey] ?? 0) + 1;
    }
  }

  void _calculateTopDestinations(List<Booking> bookings, List<Destination> destinations) {
    _destinationBookings.clear();
    for (final booking in bookings) {
      _destinationBookings[booking.destinationId] = 
          (_destinationBookings[booking.destinationId] ?? 0) + 1;
    }
    
    _topDestinations = [];
    for (final dest in destinations) {
      final bookingCount = _destinationBookings[dest.id] ?? 0;
      if (bookingCount > 0) {
        _topDestinations.add({
          'destination': dest,
          'bookingCount': bookingCount,
          'revenue': bookings
              .where((b) => b.destinationId == dest.id && (b.status == 'confirmed' || b.status == 'completed'))
              .fold(0.0, (sum, booking) => sum + booking.totalPrice),
        });
      }
    }
    
    _topDestinations.sort((a, b) => b['bookingCount'].compareTo(a['bookingCount']));
    _topDestinations = _topDestinations.take(3).toList(); // Only top 3
  }

  String _formatCurrency(double amount) => 'RM ${amount.toStringAsFixed(0)}';

  String _formatMonth(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    final month = int.parse(parts[1]);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadReportData,
            tooltip: 'Refresh',
          ),
          DropdownButton<String>(
            value: _selectedPeriod,
            dropdownColor: Colors.teal[700],
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white),
            style: const TextStyle(fontSize: 12, color: Colors.white),
            items: _periodOptions.map((period) {
              return DropdownMenuItem(
                value: period,
                child: Text(period, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedPeriod = value!),
          ),
          const SizedBox(width: 4),
        ],
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Platform Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 4),
                  const Text('Key metrics', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        title: 'Total Revenue',
                        value: _formatCurrency(_totalRevenue),
                        icon: Icons.attach_money,
                        color: Colors.green,
                        subtitle: 'Confirmed',
                      ),
                      _buildStatCard(
                        title: 'Total Bookings',
                        value: _totalBookings.toString(),
                        icon: Icons.book_online,
                        color: Colors.blue,
                        subtitle: 'All time',
                      ),
                      _buildStatCard(
                        title: 'Total Users',
                        value: _totalUsers.toString(),
                        icon: Icons.people,
                        color: Colors.orange,
                        subtitle: 'Registered',
                      ),
                      _buildStatCard(
                        title: 'Avg. Booking',
                        value: _formatCurrency(_avgBookingValue),
                        icon: Icons.trending_up,
                        color: Colors.purple,
                        subtitle: 'Average',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  const Text('Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 4),
                  const Text('Visual data', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),
                  
                  _buildMonthlyRevenueChart(),
                  const SizedBox(height: 12),
                  
                  
                  _buildBookingStatusChart(),
                  const SizedBox(height: 12),
                  
                  _buildTopDestinations(),
                  
                  const SizedBox(height: 20),
                  const Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 12),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.5,
                    children: [
                      _buildQuickActionCard(
                        icon: Icons.download,
                        title: 'Export',
                        subtitle: 'CSV/PDF',
                        color: Colors.blue,
                        onTap: () => _showSnackbar('Export feature coming soon'),
                      ),
                      _buildQuickActionCard(
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: 'Send report',
                        color: Colors.green,
                        onTap: () => _showSnackbar('Email feature coming soon'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 14, color: Colors.teal.shade600),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Data updated in real-time', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(fontSize: 12)), duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                      Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyRevenueChart() {
    if (_monthlyRevenue.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text('No revenue data', style: TextStyle(fontSize: 12, color: Colors.grey))),
      );
    }

    final sortedMonths = _monthlyRevenue.keys.toList()..sort((a, b) => b.compareTo(a));
    final recentMonths = sortedMonths.take(5).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Revenue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 4),
            const Text('Last 5 months', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 12),
            
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: recentMonths.map((monthKey) {
                  final revenue = _monthlyRevenue[monthKey] ?? 0;
                  double calculatedHeight = 0;
                  if (_monthlyRevenue.isNotEmpty) {
                    final maxRevenue = _monthlyRevenue.values.reduce((a, b) => a > b ? a : b);
                    if (maxRevenue > 0) calculatedHeight = (revenue / maxRevenue) * 80;
                  }
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: '${_formatCurrency(revenue)}',
                            child: Container(
                              width: 20,
                              height: calculatedHeight,
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(3), topRight: Radius.circular(3)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatMonth(monthKey),
                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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

  Widget _buildBookingStatusChart() {
    final total = _pendingBookings + _confirmedBookings + _cancelledBookings + _completedBookings;
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text('No bookings', style: TextStyle(fontSize: 12, color: Colors.grey))),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 4),
            const Text('Distribution', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 12),
            
            _buildStatusBar('Pending', _pendingBookings, total, Colors.orange),
            _buildStatusBar('Confirmed', _confirmedBookings, total, Colors.green),
            _buildStatusBar('Cancelled', _cancelledBookings, total, Colors.red),
            _buildStatusBar('Completed', _completedBookings, total, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) * 100 : 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              Text('$count (${percentage.toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(height: 6, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(3))),
              Container(height: 6, width: percentage * 2, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopDestinations() {
    if (_topDestinations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text('No destinations', style: TextStyle(fontSize: 12, color: Colors.grey))),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Destinations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 4),
            const Text('Most booked', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 12),
            
            ..._topDestinations.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final dest = data['destination'] as Destination;
              final bookingCount = data['bookingCount'] as int;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(11)),
                      child: Center(
                        child: Text((index + 1).toString(), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dest.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(dest.location, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text('$bookingCount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}