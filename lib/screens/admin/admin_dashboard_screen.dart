import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/user.dart';
import '../../models/booking.dart';
import '../../models/destination.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  
  int _totalUsers = 0;
  int _totalBookings = 0;
  int _totalDestinations = 0;
  double _totalRevenue = 0.0;
  int _recentBookings = 0;
  
  List<Booking> _recentBookingsList = [];
  List<User> _recentUsers = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() { _isLoading = true; });

    try {
      final stats = await _dbService.getAdminStatistics();
      final allBookings = await _dbService.getAllBookings();
      final recentBookings = allBookings.take(5).toList();
      final allUsers = await _dbService.getAllUsers();
      final recentUsers = allUsers.take(5).toList();
      
      setState(() {
        _totalUsers = stats['totalUsers'] ?? 0;
        _totalBookings = stats['totalBookings'] ?? 0;
        _totalDestinations = stats['totalDestinations'] ?? 0;
        _totalRevenue = stats['totalRevenue'] ?? 0.0;
        _recentBookings = stats['recentBookings'] ?? 0;
        _recentBookingsList = recentBookings;
        _recentUsers = recentUsers;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Admin', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'DASHBOARD',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      
      drawer: _buildAdminDrawer(context),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  _buildWelcomeCard(),
                  const SizedBox(height: 16),
                  
                  
                  const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 4),
                  const Text('Quick stats', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  
                  
                  _buildStatisticsGrid(),
                  const SizedBox(height: 20),
                  
                  
                  _buildRecentBookingsSection(),
                  const SizedBox(height: 20),
                  
                  
                  _buildRecentUsersSection(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  
  Widget _buildWelcomeCard() {
    final currentUser = _authService.currentUser;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[400]!, Colors.teal[700]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings, size: 32, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser != null ? 'Hi, ${currentUser.name.split(' ').first}' : 'Hi, Admin',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Manage your platform',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildStatisticsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1, 
      children: [
        _buildStatCard(
          icon: Icons.people,
          title: 'Users',
          value: _totalUsers.toString(),
          color: Colors.blue,
          subtitle: 'Registered',
        ),
        _buildStatCard(
          icon: Icons.book_online,
          title: 'Bookings',
          value: _totalBookings.toString(),
          color: Colors.green,
          subtitle: 'All-time',
        ),
        _buildStatCard(
          icon: Icons.place,
          title: 'Experiences',
          value: _totalDestinations.toString(),
          color: Colors.orange,
          subtitle: 'Available',
        ),
        _buildStatCard(
          icon: Icons.attach_money,
          title: 'Revenue',
          value: 'RM ${_totalRevenue.toStringAsFixed(0)}',
          color: Colors.purple,
          subtitle: 'Total',
        ),
      ],
    );
  }

  
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildRecentBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/bookings'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Row(
                children: [
                  Text('All', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward, size: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_recentBookingsList.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text('No bookings', style: TextStyle(fontSize: 12, color: Colors.grey))),
          )
        else
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: _recentBookingsList.map((booking) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.book_online, color: _getStatusColor(booking.status), size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.destinationName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _formatDate(booking.visitDate),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            booking.status.length > 3 ? booking.status.substring(0, 3).toUpperCase() : booking.status.toUpperCase(),
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getStatusColor(booking.status)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  
  Widget _buildRecentUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/users'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Row(
                children: [
                  Text('All', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward, size: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_recentUsers.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text('No users', style: TextStyle(fontSize: 12, color: Colors.grey))),
          )
        else
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: _recentUsers.map((user) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.teal[100],
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 11, color: Colors.teal),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(user.email, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (user.isUserAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('ADM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber)),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  
  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      width: 250, 
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.teal[400]!, Colors.teal[700]!]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.admin_panel_settings, size: 36, color: Colors.white),
                const SizedBox(height: 8),
                const Text('Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('CultureTap', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
          
          _buildDrawerItem(icon: Icons.dashboard, title: 'Dashboard', onTap: () => Navigator.pop(context), isSelected: true),
          _buildDrawerItem(icon: Icons.place, title: 'Experiences', onTap: () => Navigator.pushNamed(context, '/admin/experiences')),
          _buildDrawerItem(icon: Icons.book_online, title: 'Bookings', onTap: () => Navigator.pushNamed(context, '/admin/bookings')),
          _buildDrawerItem(icon: Icons.people, title: 'Users', onTap: () => Navigator.pushNamed(context, '/admin/users')),
          _buildDrawerItem(icon: Icons.bar_chart, title: 'Reports', onTap: () => Navigator.pushNamed(context, '/admin/reports')),
          
          const Divider(height: 20),
          
          _buildDrawerItem(icon: Icons.home, title: 'User App', onTap: () {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(context, '/select-state', (route) => false);
          }),
          
          _buildDrawerItem(icon: Icons.logout, title: 'Logout', onTap: () {
            _authService.logout();
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(context, '/admin/login', (route) => false);
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? color,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: color ?? (isSelected ? Colors.teal : Colors.grey[700])),
      title: Text(title, style: TextStyle(fontSize: 13, color: color ?? (isSelected ? Colors.teal : Colors.grey[700]))),
      trailing: isSelected ? Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle)) : null,
      onTap: onTap,
      tileColor: isSelected ? Colors.teal.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}