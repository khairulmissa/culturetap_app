import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert'; 
import '../models/user.dart';
import 'package:crypto/crypto.dart' as crypto;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static Database? _database;
  User? _currentUser;
  bool _isLoggedIn = false;

  
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn && _currentUser != null && _currentUser!.id > 0;
  bool get isUserValid => _currentUser != null && 
                       _currentUser!.id > 0 && 
                       _currentUser!.email.isNotEmpty;
  
  
  bool get isAdmin => _currentUser != null && _currentUser!.isUserAdmin;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'culture_tap.db');
    
    print('🎯 AUTH SERVICE: Initializing database...');
    print('📁 Path: $path');

    return await openDatabase(
      path,
      version: 5, 
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            join_date TEXT,
            phone TEXT,
            profile_image TEXT,
            wishlist_ids TEXT DEFAULT '',
            booking_ids TEXT DEFAULT '',
            is_admin INTEGER DEFAULT 0
          )
        ''');
        
        print('✅ AuthService: Users table created');
      },
    );
  }

  //HASH PASSWORD
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }

  // REGISTER
  Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    try {
      final db = await database;
      
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (existingUser.isNotEmpty) {
        return {'success': false, 'message': 'Email already registered'};
      }
      
      String hashedPassword = _hashPassword(password);
      
      final id = await db.insert(
        'users',
        {
          'name': name,
          'email': email,
          'password': hashedPassword,
          'join_date': DateTime.now().toIso8601String(),
          'is_admin': 0, 
        },
      );
      
      User newUser = User(
        id: id,
        name: name,
        email: email,
        password: hashedPassword,
        joinDate: DateTime.now(),
        isAdmin: 0, 
      );
      
      _currentUser = newUser;
      _isLoggedIn = true;
      
      print("✅ User registered: ${newUser.name} (ID: $id)");
      
      return {
        'success': true, 
        'message': 'Registration successful', 
        'userId': id,
        'user': newUser.toAuthMap()
      };
    } catch (e) {
      print("Error registering user: $e");
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  
Future<Map<String, dynamic>> loginUser(String email, String password) async {
  print('🔐 USER LOGIN ATTEMPT: $email');
  
  try {
    final db = await database;
    String hashedPassword = _hashPassword(password);
    
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );
    
    print('📊 Query result: ${result.length} rows');
    
    if (result.isNotEmpty) {
      final userData = result.first;
      
      
      final isAdmin = userData['is_admin'] == 1;
      
      if (isAdmin) {
        print('⚠️ WARNING: Admin trying to login via user login');
        print('   Redirecting to admin login flow...');
      }
      
      User user = User.fromDatabaseMap(userData);
      
      _currentUser = user;
      _isLoggedIn = true;
      
      print("✅ Login successful: ${user.name} (ID: ${user.id}, Admin: ${user.isAdmin})");
      
      return {
        'success': true, 
        'message': 'Login successful',
        'user': user.toAuthMap(),
        'isAdmin': user.isUserAdmin,
      };
      
    } else {
      
      print('❌ Invalid email or password for regular user');
      return {'success': false, 'message': 'Invalid email or password'};
    }
  } catch (e) {
    print("❌ ERROR in loginUser: $e");
    return {'success': false, 'message': 'Login failed: $e'};
  }
}

  
  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    print('🔐 ===== ADMIN LOGIN ATTEMPT =====');
    print('📧 Email: $email');
    
    try {
      final db = await database;
      String hashedPassword = _hashPassword(password);
      print('🔑 Password hash: ${hashedPassword.substring(0, 20)}...');
      
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ? AND is_admin = 1',
        whereArgs: [email, hashedPassword],
      );
      
      print('📊 Admin query result: ${result.length} rows');
      
      if (result.isNotEmpty) {
      final userData = result.first;
      print('✅ ADMIN FOUND:');
      print('   - ID: ${userData['id']}');
      print('   - Name: ${userData['name']}');
      print('   - is_admin: ${userData['is_admin']}');
      
      User user = User.fromDatabaseMap(userData);
      
      _currentUser = user;
      _isLoggedIn = true;
      
      print('🎯 Admin login SUCCESSFUL, setting currentUser');
      print('🎯 User isAdmin: ${user.isUserAdmin}');
      
      return {
        'success': true, 
        'message': 'Admin login successful',
        'user': user.toAuthMap(),
        'isAdmin': true,
      };
      
    } else {
      print('❌ NO ADMIN FOUND with these credentials');
      print('❌ OR is_admin != 1');
      return {'success': false, 'message': 'Invalid admin credentials'};
    }
  } catch (e) {
    print("❌ ERROR in loginAdmin: $e");
    return {'success': false, 'message': 'Admin login failed: $e'};
  }
}

  
  Future<void> createTestUser() async {
    try {
      final db = await database;
      
      
      await db.delete(
        'users',
        where: 'email IN (?, ?)',
        whereArgs: ['test@example.com', 'admin@culturetap.com'],
      );
      
      String hashedPassword = _hashPassword('password123');
      String adminHashedPassword = _hashPassword('admin123');
      
      // Create regular test user
      final userId = await db.insert('users', {
        'name': 'Test User',
        'email': 'test@example.com',
        'password': hashedPassword,
        'join_date': DateTime.now().toIso8601String(),
        'phone': '0123456789',
        'is_admin': 0,
      });
      
      
      final adminResult = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: ['admin@culturetap.com'],
      );
      
      if (adminResult.isEmpty) {
        await db.insert('users', {
          'name': 'System Admin',
          'email': 'admin@culturetap.com',
          'password': adminHashedPassword,
          'join_date': DateTime.now().toIso8601String(),
          'is_admin': 1,
        });
        print('✅ Admin user created: admin@culturetap.com / admin123');
      }
      
      print('✅ Test user created: test@example.com / password123 (ID: $userId)');
      
      
      User testUser = User(
        id: userId,
        name: 'Test User',
        email: 'test@example.com',
        password: hashedPassword,
        phone: '0123456789',
        joinDate: DateTime.now(),
        isAdmin: 0,
      );
      
      _currentUser = testUser;
      _isLoggedIn = true;
      
    } catch (e) {
      print('❌ Error creating test user: $e');
    }
  }

  // LOGOUT
  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    print("✅ User logged out");
  }

  
  void setCurrentUser(User user) {
    _currentUser = user;
    _isLoggedIn = true;
    print("✅ AuthService: Current user updated to ${user.name}");
  }

 
  Future<List<User>> getAllUsers() async {
    try {
      final db = await database;
      final results = await db.query('users');
      
      return results.map((userData) => User.fromDatabaseMap(userData)).toList();
    } catch (e) {
      print("Error getting users: $e");
      return [];
    }
  }

  
  Future<bool> isEmailAdmin(String email) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'email = ? AND is_admin = 1',
        whereArgs: [email],
      );
      
      return result.isNotEmpty;
    } catch (e) {
      print("Error checking admin status: $e");
      return false;
    }
  }
}