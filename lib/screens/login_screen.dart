import 'package:flutter/material.dart';
import 'package:culturetap_app/services/auth_service.dart';
import 'package:culturetap_app/models/user.dart';
import 'package:culturetap_app/screens/home_main.dart';
import 'package:culturetap_app/screens/admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    
  }

  void _login() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  // Validation
  if (email.isEmpty || password.isEmpty) {
    setState(() {
      _errorMessage = 'Please fill in all fields';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  
  print('🔐 ===== LOGIN ATTEMPT =====');
  print('📧 Email: $email');
  
  try {
    
    if (email == 'admin@culturetap.com') {
      print('⚡ ADMIN EMAIL DETECTED - Checking admin credentials...');
      final adminResult = await _authService.loginAdmin(email, password);
      
      if (adminResult['success'] == true) {
        print('🎯 ADMIN LOGIN SUCCESSFUL');
        print('✅ Navigating to ADMIN DASHBOARD');
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(),
          ),
          (route) => false,
        );
        return; 
      } else {
        print('⚠️ Admin login failed: ${adminResult['message']}');
        
      }
    }
    
    
    print('👤 Attempting regular user login...');
    final result = await _authService.loginUser(email, password);

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      try {
        final userData = result['user'] as Map<String, dynamic>;
        final user = User.fromAuthMap(userData);
        
        print('✅ USER LOGIN SUCCESS - Name: ${user.name}');
        
        Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        arguments: user, 
        (route) => false,
        );
        
      } catch (e) {
        print('❌ Error processing user data: $e');
        setState(() {
          _errorMessage = 'Error processing user data: $e';
        });
      }
      
    } else {
      print('❌ Login failed: ${result['message']}');
      setState(() {
        _errorMessage = result['message'] ?? 'Unknown error';
      });
    }
    
  } catch (e) {
    print('❌ Exception during login: $e');
    setState(() {
      _isLoading = false;
      _errorMessage = 'An error occurred: $e';
    });
  }
}

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.explore,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // App Title
                const Text(
                  'CultureTap',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                const Text(
                  'Discover Malaysian Culture',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Error Message
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                if (_errorMessage.isNotEmpty) const SizedBox(height: 20),
                
                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: 'Enter your email', // Hint yang netral
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: 'Enter your password', // Hint yang netral
                  ),
                  obscureText: true,
                  onSubmitted: (_) => _login(),
                ),
                
                const SizedBox(height: 10),
                
                // Forgot Password 
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot password functionality
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _navigateToRegister,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.teal),
                    ),
                    child: const Text(
                      'REGISTER NOW',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}