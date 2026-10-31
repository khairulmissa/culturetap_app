class WishlistItem {
  int? id; 
  int userId; 
  int destinationId; 
  String destinationName;
  String destinationImage;
  String destinationLocation;
  double destinationPrice;
  DateTime addedDate;

  WishlistItem({
    this.id, 
    required this.userId,
    required this.destinationId,
    required this.destinationName,
    required this.destinationImage,
    required this.destinationLocation,
    required this.destinationPrice,
    required this.addedDate,
  });

  
  Map<String, dynamic> toDatabaseMap() {
    return {
      if (id != null) 'id': id, 
      'user_id': userId, 
      'destination_id': destinationId,
      'destination_name': destinationName,
      'destination_image': destinationImage,
      'destination_location': destinationLocation,
      'destination_price': destinationPrice,
      'added_date': addedDate.toIso8601String(),
    };
    
  }

  
  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString() ?? '',
      'userId': userId.toString(),
      'destinationId': destinationId.toString(),
      'destinationName': destinationName,
      'destinationImage': destinationImage,
      'destinationLocation': destinationLocation,
      'destinationPrice': destinationPrice,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  // Factory untuk baca dari database
  factory WishlistItem.fromDatabaseMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      destinationId: map['destination_id'] as int,
      destinationName: map['destination_name'] as String,
      destinationImage: map['destination_image'] as String,
      destinationLocation: map['destination_location'] as String,
      destinationPrice: (map['destination_price'] as num).toDouble(),
      addedDate: DateTime.parse(map['added_date'] as String),
    );
  }

  // Factory untuk baca dari JSON/API
  factory WishlistItem.fromJson(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      userId: int.tryParse(map['userId'].toString()) ?? 0,
      destinationId: int.tryParse(map['destinationId'].toString()) ?? 0,
      destinationName: map['destinationName'] as String,
      destinationImage: map['destinationImage'] as String,
      destinationLocation: map['destinationLocation'] as String,
      destinationPrice: (map['destinationPrice'] ?? 0.0).toDouble(),
      addedDate: DateTime.parse(map['addedDate'] as String),
    );
  }

  // Copy with untuk update
  WishlistItem copyWith({
    int? id,
    int? userId,
    int? destinationId,
    String? destinationName,
    String? destinationImage,
    String? destinationLocation,
    double? destinationPrice,
    DateTime? addedDate,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destinationId: destinationId ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      destinationImage: destinationImage ?? this.destinationImage,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      destinationPrice: destinationPrice ?? this.destinationPrice,
      addedDate: addedDate ?? this.addedDate,
    );
  }

  
  bool get isRecentlyAdded {
    final daysDifference = DateTime.now().difference(addedDate).inDays;
    return daysDifference <= 7;
  }

  // Format price untuk display
  String get formattedPrice {
    return destinationPrice == 0.0 
        ? 'Free' 
        : 'RM ${destinationPrice.toStringAsFixed(2)}';
  }

  // Format date untuk display
  String get formattedAddedDate {
    final now = DateTime.now();
    final difference = now.difference(addedDate);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${addedDate.day}/${addedDate.month}/${addedDate.year}';
    }
  }

  // Short location (state only)
  String get shortLocation {
    if (destinationLocation.contains(',')) {
      return destinationLocation.split(',').last.trim();
    }
    return destinationLocation;
  }

  @override
  String toString() {
    return 'WishlistItem(id: $id, destination: $destinationName, location: $shortLocation)';
  }
}