import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/booking.dart';
import '../models/wishlist_item.dart';
import '../models/user.dart';
import '../models/destination.dart';
import '../screens/data/locations_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'culture_tap.db');
    
    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        join_date TEXT NOT NULL,
        phone TEXT,
        nationality TEXT,
        preferences TEXT,
        profile_image TEXT,
        wishlist_ids TEXT DEFAULT '',
        booking_ids TEXT DEFAULT '',
        is_admin INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        destination_id INTEGER NOT NULL,
        destination_name TEXT NOT NULL,
        destination_image TEXT,
        booking_date TEXT NOT NULL,
        visit_date TEXT NOT NULL,
        number_of_people INTEGER DEFAULT 1,
        total_price REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        special_request TEXT,
        booking_reference TEXT UNIQUE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE wishlist(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        destination_id INTEGER NOT NULL,
        destination_name TEXT NOT NULL,
        destination_image TEXT,
        destination_location TEXT,
        destination_price REAL DEFAULT 0.0,
        added_date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE destinations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        state TEXT,
        description TEXT,
        location TEXT,
        entry_fee REAL DEFAULT 0.0,
        image_url TEXT,
        category TEXT,
        rating REAL DEFAULT 0.0,
        total_reviews INTEGER DEFAULT 0,
        operating_hours TEXT,
        contact_info TEXT,
        categories TEXT DEFAULT '',
        gallery_images TEXT DEFAULT '',
        coordinates TEXT DEFAULT '',
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_bookings_user ON bookings(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_wishlist_user ON wishlist(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_destinations_state ON destinations(state)');
    
    print('✅ DatabaseService: All tables created successfully');
    
    await _createDefaultAdmin(db);
    await _importSeedData(db);
  }

  Future<void> _createDefaultAdmin(Database db) async {
    try {
      await db.delete(
        'users',
        where: 'email = ?',
        whereArgs: ['admin@culturetap.com'],
      );
      
      String hashedPassword = _hashPassword('admin123');
      
      await db.insert('users', {
        'name': 'System Admin',
        'email': 'admin@culturetap.com',
        'password': hashedPassword,
        'join_date': DateTime.now().toIso8601String(),
        'is_admin': 1,
      });
      
      print('✅ Default admin created: admin@culturetap.com / admin123 (is_admin: 1)');
    } catch (e) {
      print('❌ Error creating default admin: $e');
    }
  }

  Future<void> _importSeedData(Database db) async {
    try {
      final now = DateTime.now().toIso8601String();
      int importedCount = 0;
      
      for (final location in allLocations) {
        final existing = await db.query(
          'destinations',
          where: 'name = ? AND state = ?',
          whereArgs: [location.name, location.state],
        );

        if (existing.isEmpty) {
          final categoriesList = [location.category];
          
          await db.insert('destinations', {
            'name': location.name,
            'state': location.state,
            'location': location.state,
            'description': location.description,
            'image_url': location.imageUrl,
            'rating': 4.5,
            'total_reviews': 10,
            'entry_fee': 0.0,
            'category': location.category,
            'categories': categoriesList.join(','),
            'latitude': location.latitude,
            'longitude': location.longitude,
            'created_at': now,
            'updated_at': now,
          });
          importedCount++;
        }
      }
      
      print('✅ Successfully imported $importedCount locations from seed data');
    } catch (e) {
      print('❌ Error importing seed data: $e');
    }
  }

  String _hashPassword(String password) {
    return password;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Database upgrade from $oldVersion to $newVersion');
    
    for (int version = oldVersion; version < newVersion; version++) {
      switch (version) {
        case 4:
          try {
            await db.execute('ALTER TABLE users ADD COLUMN is_admin INTEGER DEFAULT 0');
            print('✅ Added is_admin column to users table');
          } catch (e) {
            print('❌ Error adding is_admin column: $e');
          }
          break;
        case 5:
          try {
            await db.execute('ALTER TABLE users ADD COLUMN nationality TEXT');
            print('✅ Added nationality column to users table');
            
            await db.execute('ALTER TABLE users ADD COLUMN preferences TEXT');
            print('✅ Added preferences column to users table');
          } catch (e) {
            print('❌ Error adding columns: $e');
          }
          break;
        case 6:
          try {
            await db.execute('ALTER TABLE destinations ADD COLUMN latitude REAL');
            await db.execute('ALTER TABLE destinations ADD COLUMN longitude REAL');
            print('✅ Added latitude & longitude columns to destinations table');
            
            final count = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM destinations')
            ) ?? 0;
            
            if (count == 0) {
              await _importSeedData(db);
            }
          } catch (e) {
            print('❌ Error adding latitude/longitude columns: $e');
          }
          break;
      }
    }
    
    print('✅ Database upgrade completed');
  }

  Future<void> importSeedLocations() async {
    final db = await database;
    await _importSeedData(db);
  }

  Future<List<User>> getAllUsers() async {
    Database db = await database;
    
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'users',
        orderBy: 'join_date DESC',
      );
      
      return maps.map((map) => User.fromDatabaseMap(map)).toList();
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  Future<List<Booking>> getAllBookings() async {
    Database db = await database;
    
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'bookings',
        orderBy: 'created_at DESC',
      );
      
      return maps.map((map) => Booking.fromDatabaseMap(map)).toList();
    } catch (e) {
      print('❌ Error getting all bookings: $e');
      return [];
    }
  }

  Future<List<Booking>> getBookingsByStatus(String status) async {
    Database db = await database;
    
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'bookings',
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'created_at DESC',
      );
      
      return maps.map((map) => Booking.fromDatabaseMap(map)).toList();
    } catch (e) {
      print('❌ Error getting bookings by status: $e');
      return [];
    }
  }

  Future<int> updateUserAdminStatus(int userId, bool isAdmin) async {
    Database db = await database;
    
    try {
      return await db.update(
        'users',
        {'is_admin': isAdmin ? 1 : 0},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('❌ Error updating user admin status: $e');
      return 0;
    }
  }

  Future<int> insertDestination(Destination destination) async {
    Database db = await database;
    
    try {
      final now = DateTime.now().toIso8601String();
      final map = destination.toDatabaseMap();
      map['created_at'] = now;
      map['updated_at'] = now;
      
      return await db.insert('destinations', map);
    } catch (e) {
      print('❌ Error inserting destination: $e');
      return 0;
    }
  }

  Future<List<Destination>> getAllDestinations() async {
    Database db = await database;
    
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'destinations',
        orderBy: 'name ASC',
      );
      
      return maps.map((map) => Destination.fromDatabaseMap(map)).toList();
    } catch (e) {
      print('❌ Error getting all destinations: $e');
      return [];
    }
  }

  Future<int> updateDestination(Destination destination) async {
    Database db = await database;
    
    try {
      final map = destination.toDatabaseMap();
      map['updated_at'] = DateTime.now().toIso8601String();
      
      return await db.update(
        'destinations',
        map,
        where: 'id = ?',
        whereArgs: [destination.id],
      );
    } catch (e) {
      print('❌ Error updating destination: $e');
      return 0;
    }
  }

  Future<int> deleteDestination(int destinationId) async {
    Database db = await database;
    
    try {
      return await db.delete(
        'destinations',
        where: 'id = ?',
        whereArgs: [destinationId],
      );
    } catch (e) {
      print('❌ Error deleting destination: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> getAdminStatistics() async {
    Database db = await database;
    
    try {
      final usersResult = await db.rawQuery('SELECT COUNT(*) as count FROM users');
      final totalUsers = usersResult.first['count'] as int;
      
      final bookingsResult = await db.rawQuery('SELECT COUNT(*) as count FROM bookings');
      final totalBookings = bookingsResult.first['count'] as int;
      
      final destResult = await db.rawQuery('SELECT COUNT(*) as count FROM destinations');
      final totalDestinations = destResult.first['count'] as int;
      
      final revenueResult = await db.rawQuery(
        'SELECT SUM(total_price) as revenue FROM bookings WHERE status = "confirmed"'
      );
      final totalRevenue = (revenueResult.first['revenue'] as num?)?.toDouble() ?? 0.0;
      
      final weekAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
      final recentBookingsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM bookings WHERE created_at > ?',
        [weekAgo]
      );
      final recentBookings = recentBookingsResult.first['count'] as int;
      
      return {
        'totalUsers': totalUsers,
        'totalBookings': totalBookings,
        'totalDestinations': totalDestinations,
        'totalRevenue': totalRevenue,
        'recentBookings': recentBookings,
      };
    } catch (e) {
      print('❌ Error getting admin statistics: $e');
      return {
        'totalUsers': 0,
        'totalBookings': 0,
        'totalDestinations': 0,
        'totalRevenue': 0.0,
        'recentBookings': 0,
      };
    }
  }

  Future<int> insertBooking(Booking booking) async {
    Database db = await database;
    
    try {
      final bookingMap = booking.toDatabaseMap();
      
      print('📊 Inserting booking to database:');
      print('   - User ID: ${booking.userId}');
      print('   - Destination: ${booking.destinationName}');
      
      int bookingId = await db.insert(
        'bookings', 
        bookingMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('✅ Booking inserted with ID: $bookingId');
      return bookingId;
    } catch (e) {
      print('❌ Error inserting booking: $e');
      
      if (e.toString().contains('NOT NULL')) {
        print('⚠️ Likely missing required field in booking');
        final bookingMap = booking.toDatabaseMap();
        print('Booking map keys: ${bookingMap.keys}');
        print('Booking map values: ${bookingMap.values}');
      }
      
      rethrow;
    }
  }

  Future<List<Booking>> getBookingsByUser(int userId) async {
    return await getUserBookings(userId);
  }

  Future<List<Booking>> getUserBookings(int userId) async {
    Database db = await database;
    
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'bookings',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'visit_date DESC',
      );
      
      return maps.map((map) => Booking.fromDatabaseMap(map)).toList();
    } catch (e) {
      print('❌ Error getting user bookings: $e');
      return [];
    }
  }

  Future<Booking?> getBookingById(int bookingId) async {
    Database db = await database;
    
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'bookings',
        where: 'id = ?',
        whereArgs: [bookingId],
      );
      
      if (maps.isNotEmpty) {
        return Booking.fromDatabaseMap(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting booking: $e');
      return null;
    }
  }

  Future<int> updateBooking(Booking booking) async {
    Database db = await database;
    
    try {
      return await db.update(
        'bookings',
        booking.toDatabaseMap(),
        where: 'id = ?',
        whereArgs: [booking.id],
      );
    } catch (e) {
      print('❌ Error updating booking: $e');
      return 0;
    }
  }

  Future<int> updateBookingStatus(int bookingId, String status) async {
    Database db = await database;
    
    try {
      return await db.update(
        'bookings',
        {'status': status},
        where: 'id = ?',
        whereArgs: [bookingId],
      );
    } catch (e) {
      print('❌ Error updating booking status: $e');
      return 0;
    }
  }

  Future<int> deleteBooking(int bookingId) async {
    Database db = await database;
    
    try {
      return await db.delete(
        'bookings',
        where: 'id = ?',
        whereArgs: [bookingId],
      );
    } catch (e) {
      print('❌ Error deleting booking: $e');
      return 0;
    }
  }

  Future<int> addToWishlist(WishlistItem item) async {
    Database db = await database;
    
    try {
      final alreadyExists = await isInWishlist(item.userId, item.destinationId);
      
      if (alreadyExists) {
        print('⚠️ Destination ${item.destinationId} already in wishlist for user ${item.userId}');
        return 0;
      }
      
      return await db.insert('wishlist', item.toDatabaseMap());
    } catch (e) {
      print('❌ Error adding to wishlist: $e');
      return 0;
    }
  }

  Future<List<WishlistItem>> getUserWishlist(int userId) async {
    Database db = await database;
    
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'wishlist',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'added_date DESC',
      );
      
      return maps.map((map) => WishlistItem.fromDatabaseMap(map)).toList();
    } catch (e) {
      print('❌ Error getting wishlist: $e');
      return [];
    }
  }

  Future<bool> isInWishlist(int userId, int destinationId) async {
    Database db = await database;
    
    try {
      List<Map> maps = await db.query(
        'wishlist',
        where: 'user_id = ? AND destination_id = ?',
        whereArgs: [userId, destinationId],
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('❌ Error checking wishlist: $e');
      return false;
    }
  }

  Future<int> removeFromWishlist(int userId, int destinationId) async {
    Database db = await database;
    
    try {
      return await db.delete(
        'wishlist',
        where: 'user_id = ? AND destination_id = ?',
        whereArgs: [userId, destinationId],
      );
    } catch (e) {
      print('❌ Error removing from wishlist: $e');
      return 0;
    }
  }

  Future<int> removeFromWishlistById(int wishlistItemId) async {
    Database db = await database;
    
    try {
      return await db.delete(
        'wishlist',
        where: 'id = ?',
        whereArgs: [wishlistItemId],
      );
    } catch (e) {
      print('❌ Error removing from wishlist by id: $e');
      return 0;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await database;
    
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (maps.isNotEmpty) {
        return User.fromDatabaseMap(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  Future<User?> getUserById(int userId) async {
    Database db = await database;
    
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      if (maps.isNotEmpty) {
        return User.fromDatabaseMap(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user by id: $e');
      return null;
    }
  }

  Future<int> insertUser(User user) async {
    Database db = await database;
    
    try {
      return await db.insert(
        'users',
        user.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Error inserting user: $e');
      return 0;
    }
  }

  Future<int> updateUserProfile(User user) async {
    Database db = await database;
    
    try {
      return await db.update(
        'users',
        user.toDatabaseMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      print('❌ Error updating user: $e');
      return 0;
    }
  }

  Future<int> updateUser(User user) async {
  Database db = await database;
  
  try {
    final result = await db.update(
      'users',
      user.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    
    print('✅ User updated in database: ${user.name} (ID: ${user.id})');
    return result;
  } catch (e) {
    print('❌ Error updating user: $e');
    return 0;
  }
}

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> resetDatabase() async {
    await closeDatabase();
    String path = join(await getDatabasesPath(), 'culture_tap.db');
    await deleteDatabase(path);
    _database = null;
    await database;
  }

  Future<void> printDatabaseSchema() async {
    try {
      Database db = await database;
      
      List<Map> tables = await db.rawQuery(
        "SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
      );
      
      print('📋 DATABASE SCHEMA:');
      for (var table in tables) {
        print('📁 TABLE: ${table['name']}');
        print('🔧 SQL: ${table['sql']}');
        print('─' * 50);
      }
    } catch (e) {
      print('❌ Error printing schema: $e');
    }
  }
}