import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'my_booking.dart';
import 'wishlist_screen.dart';
import '../login_screen.dart'; 
import '../../models/user.dart';
import '../../services/auth_service.dart'; 

class ProfileScreen extends StatefulWidget { 
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    
    final authService = AuthService();
    final user = authService.currentUser;
    
    if (user != null) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } else {
      
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.purple[800],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(context),
                const SizedBox(height: 20),
                
                // Account Settings Section
                _buildSectionTitle('Account Settings'),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.person_outline,
                  title: 'Edit Profile Information',
                  subtitle: 'Update your personal details',
                  onTap: () => _navigateToEditProfile(context),
                ),
                _buildMenuCard(
                  icon: Icons.visibility,
                  title: 'View Account Information',
                  subtitle: 'Check your account details',
                  onTap: () => _showAccountInfo(context),
                ),
                
                const SizedBox(height: 16),
                
                // My Activities Section
                _buildSectionTitle('My Activities'),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.bookmark_border,
                  title: 'My Wishlist',
                  subtitle: 'View saved cultural experiences',
                  onTap: () => _navigateTo(
                    context, 
                    WishlistScreen(currentUser: _currentUser),
                  ),
                ),
                _buildMenuCard(
                  icon: Icons.calendar_today,
                  title: 'My Bookings',
                  subtitle: 'View booking history and details',
                  onTap: () => _navigateTo(
                    context, 
                    MyBookingsScreen(currentUser: _currentUser),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // App Settings Section
                _buildSectionTitle('App Settings'),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'Notification, language, etc.',
                  onTap: () => _showSettings(context),
                ),
                _buildMenuCard(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'FAQs and contact support',
                  onTap: () => _showHelpSupport(context),
                ),
                
                const SizedBox(height: 30),
                
                // Logout Button
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(fontSize: 14),
                      ),
                      onPressed: () => _showLogoutConfirmation(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.purple[800]!, width: 2),
            ),
            child: Icon(
              Icons.person,
              size: 30,
              color: Colors.purple[800],
            ),
          ),
          const SizedBox(width: 16),
          
          // User Info - ✅ GUNA _currentUser
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser.name, // NAMA AKAN UPDATE
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser.email, // EMAIL AKAN UPDATE
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber[700]!),
                  ),
                  child: Text(
                    'Cultural Explorer',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
          letterSpacing: 0.5,
        ),
      )
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.purple[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.purple, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // NAVIGATE KE EDIT PROFILE DAN TUNGGU RESULT
  Future<void> _navigateToEditProfile(BuildContext context) async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(currentUser: _currentUser),
      ),
    );
    
    // JIKA ADA USER YANG DIUPDATE, REFRESH SCREEN
    if (updatedUser != null && updatedUser is User) {
      setState(() {
        _currentUser = updatedUser;
      });
      
      
      final authService = AuthService();
      authService.setCurrentUser(updatedUser);
    }
  }

  void _showAccountInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Account Information',
          style: TextStyle(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Full Name', _currentUser.name),
              _buildInfoRow('Email', _currentUser.email),
              _buildInfoRow('Phone', _currentUser.phone ?? 'Not set'),
              _buildInfoRow('Nationality', _currentUser.nationality ?? 'Not set'),
              _buildInfoRow('Member Since', 'January 2024'),
              _buildInfoRow('Total Bookings', '12'),
              _buildInfoRow('Points Earned', '1,250'),
              _buildInfoRow('Account Status', 'Active'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.purple[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings page coming soon'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Help & Support page coming soon'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Log Out',
          style: TextStyle(fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}