class User {
  int id; 
  String name;
  String email;
  String password;
  String? phone;
  String? nationality; 
  String? preferences; 
  String? profileImage;
  DateTime joinDate;
  List<int> wishlistIds;
  List<int> bookingIds;
  int isAdmin; 

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.nationality, 
    this.preferences, 
    this.profileImage,
    required this.joinDate,
    this.wishlistIds = const [],
    this.bookingIds = const [],
    this.isAdmin = 0,
  });

  
  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  // ✅ Untuk SQLite database
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'nationality': nationality, // ✅ TAMBAH INI
      'preferences': preferences, // ✅ TAMBAH INI
      'profile_image': profileImage,
      'join_date': joinDate.toIso8601String(),
      'wishlist_ids': wishlistIds.join(','),
      'booking_ids': bookingIds.join(','),
      'is_admin': isAdmin,
    };
  }

  // ✅ Untuk AuthService
  Map<String, dynamic> toAuthMap() {
    return {
      'id': id.toString(),
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'nationality': nationality, // ✅ TAMBAH INI
      'preferences': preferences, // ✅ TAMBAH INI
      'profile_image': profileImage,
      'join_date': joinDate.toIso8601String(),
      'is_admin': isAdmin.toString(),
    };
  }

  // ✅ Factory untuk baca dari database
  factory User.fromDatabaseMap(Map<String, dynamic> map) {
    
    final id = _safeParseInt(map['id']);
    
    
    List<int> wishlistList = [];
    if (map['wishlist_ids'] != null && map['wishlist_ids'].toString().isNotEmpty) {
      wishlistList = map['wishlist_ids'].toString()
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.tryParse(s) ?? 0)
          .where((id) => id > 0)
          .toList();
    }

    List<int> bookingList = [];
    if (map['booking_ids'] != null && map['booking_ids'].toString().isNotEmpty) {
      bookingList = map['booking_ids'].toString()
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.tryParse(s) ?? 0)
          .where((id) => id > 0)
          .toList();
    }

    return User(
      id: id,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      phone: map['phone']?.toString(),
      nationality: map['nationality']?.toString(), 
      preferences: map['preferences']?.toString(), 
      profileImage: map['profile_image']?.toString(),
      joinDate: map['join_date'] != null 
          ? DateTime.tryParse(map['join_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      wishlistIds: wishlistList,
      bookingIds: bookingList,
      isAdmin: _safeParseInt(map['is_admin']),
    );
  }

  
  factory User.fromAuthMap(Map<String, dynamic> map) {
    return User(
      id: _safeParseInt(map['id']),
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      phone: map['phone']?.toString(),
      nationality: map['nationality']?.toString(), 
      preferences: map['preferences']?.toString(), 
      profileImage: map['profile_image']?.toString(),
      joinDate: map['join_date'] != null 
          ? DateTime.tryParse(map['join_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isAdmin: _safeParseInt(map['is_admin']),
    );
  }

  
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? nationality, 
    String? preferences, 
    String? profileImage,
    DateTime? joinDate,
    List<int>? wishlistIds,
    List<int>? bookingIds,
    int? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality, 
      preferences: preferences ?? this.preferences, 
      profileImage: profileImage ?? this.profileImage,
      joinDate: joinDate ?? this.joinDate,
      wishlistIds: wishlistIds ?? this.wishlistIds,
      bookingIds: bookingIds ?? this.bookingIds,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  
  bool get isUserAdmin => isAdmin == 1;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, nationality: $nationality, preferences: $preferences, isAdmin: $isAdmin)';
  }
}