import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_main.dart';
import 'services/auth_service.dart'; 
import 'services/database_service.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/my_booking.dart';
import 'screens/state_selection_screen.dart';
import 'models/user.dart';

// IMPORT SCREENS ADMIN
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/manage_experiences_screen.dart';
import 'screens/admin/manage_booking_screen.dart';
import 'screens/admin/manage_users_screen.dart';
import 'screens/admin/reports_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    print('🔧 Initializing database...');
    final dbService = DatabaseService();
    await dbService.database;
    
    
    final db = await dbService.database;
    
   
    await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@culturetap.com'],
    );
    
    
    final hashedPassword = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'; // admin123 hashed
    
    await db.insert('users', {
      'name': 'System Admin',
      'email': 'admin@culturetap.com',
      'password': hashedPassword,
      'join_date': DateTime.now().toIso8601String(),
      'is_admin': 1, 
    });
    
    print('✅ ADMIN USER RECREATED: admin@culturetap.com / admin123 (is_admin: 1)');
    
    // Verify
    final adminCheck = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@culturetap.com'],
    );
    
    print('📋 Admin verification:');
    print('   - Found: ${adminCheck.length} users');
    if (adminCheck.isNotEmpty) {
      print('   - is_admin: ${adminCheck.first['is_admin']}');
      print('   - Name: ${adminCheck.first['name']}');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CultureTap',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      
      home: const LoginScreen(),
      
      routes: {
        // User routes
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        
        
        '/select-state': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          
          print('🔄 Route /select-state accessed');
          print('📦 Arguments received: $args');
          
          if (args is User) {
            print('✅ User found: ${args.name}, navigating to StateSelectionScreen');
            return StateSelectionScreen(currentUser: args);
          } else {
            print('❌ No user arguments, showing empty screen');
            
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Unable to load state selection',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please login again',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        
        '/booking': (context) => BookingScreen(),
        '/my_booking': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return MyBookingsScreen(currentUser: args);
          }
          return const MyBookingsScreen();
        },
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is User) {
            return HomeMain(currentUser: args);
          }
          return HomeMain();
        },
        
        
        '/profile': (context) => const ProfileScreen(),
        
        // ✅ ADMIN ROUTES
        '/admin/login': (context) => const AdminLoginScreen(),
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/admin/experiences': (context) => const ManageExperiencesScreen(),
        '/admin/bookings': (context) => const ManageBookingsScreen(),
        '/admin/users': (context) => const ManageUsersScreen(),
        '/admin/reports': (context) => const ReportsScreen(),
      },
      
      debugShowCheckedModeBanner: false,
    );
  }
}