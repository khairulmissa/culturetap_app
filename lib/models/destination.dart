import 'dart:convert';

class Destination {
  int id;
  String name;
  String description;
  String location;
  String state;
  String imageUrl;
  double rating;
  int totalReviews;
  List<String> categories;
  double ticketPrice;
  String? openingHours;
  String? contactInfo;
  List<String> galleryImages;
  Map<String, dynamic>? coordinates;
  DateTime createdAt;
  DateTime updatedAt;
  double? latitude;
  double? longitude;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.state,
    required this.imageUrl,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.categories = const [],
    this.ticketPrice = 0.0,
    this.openingHours,
    this.contactInfo,
    this.galleryImages = const [],
    this.coordinates,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.latitude,
    this.longitude,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get ratingDisplay {
    return '${rating.toStringAsFixed(1)} ⭐ ($totalReviews reviews)';
  }

  String get formattedPrice {
    return ticketPrice == 0 ? 'FREE' : 'RM ${ticketPrice.toStringAsFixed(2)}';
  }

  String get categoriesDisplay {
    return categories.join(', ');
  }

  String get formattedUpdatedDate {
    return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'state': state,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'categories': categories,
      'ticketPrice': ticketPrice,
      'openingHours': openingHours,
      'contactInfo': contactInfo,
      'galleryImages': galleryImages,
      'coordinates': coordinates,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'state': state,
      'image_url': imageUrl,
      'rating': rating,
      'total_reviews': totalReviews,
      'ticket_price': ticketPrice,
      'operating_hours': openingHours,
      'contact_info': contactInfo,
      'categories': categories.join(','),
      'gallery_images': galleryImages.join(','),
      'coordinates': coordinates != null ? jsonEncode(coordinates) : '',
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Destination.fromDatabaseMap(Map<String, dynamic> map) {
    List<String> categoriesList = [];
    if (map['categories'] != null && map['categories'].toString().isNotEmpty) {
      categoriesList = map['categories'].toString().split(',');
    }

    List<String> galleryList = [];
    if (map['gallery_images'] != null && map['gallery_images'].toString().isNotEmpty) {
      galleryList = map['gallery_images'].toString().split(',');
    }

    Map<String, dynamic>? coordMap;
    if (map['coordinates'] != null && map['coordinates'].toString().isNotEmpty) {
      try {
        final coordStr = map['coordinates'].toString();
        if (coordStr.startsWith('{')) {
          coordMap = jsonDecode(coordStr);
        }
      } catch (e) {
        print('Error parsing coordinates: $e');
      }
    }

    return Destination(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? map['state'] ?? '',
      state: map['state'] ?? '',
      imageUrl: map['image_url'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: (map['total_reviews'] ?? 0).toInt(),
      categories: categoriesList,
      ticketPrice: (map['ticket_price'] ?? (map['entry_fee'] ?? 0.0)).toDouble(),
      openingHours: map['operating_hours'],
      contactInfo: map['contact_info'],
      galleryImages: galleryList,
      coordinates: coordMap,
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
    );
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      state: map['state'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: (map['totalReviews'] ?? 0).toInt(),
      categories: List<String>.from(map['categories'] ?? []),
      ticketPrice: (map['ticketPrice'] ?? 0.0).toDouble(),
      openingHours: map['openingHours'],
      contactInfo: map['contactInfo'],
      galleryImages: List<String>.from(map['galleryImages'] ?? []),
      coordinates: map['coordinates'] != null 
          ? Map<String, dynamic>.from(map['coordinates']) 
          : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
    );
  }

  Destination copyWith({
    int? id,
    String? name,
    String? description,
    String? location,
    String? state,
    String? imageUrl,
    double? rating,
    int? totalReviews,
    List<String>? categories,
    double? ticketPrice,
    String? openingHours,
    String? contactInfo,
    List<String>? galleryImages,
    Map<String, dynamic>? coordinates,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      state: state ?? this.state,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      categories: categories ?? this.categories,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      openingHours: openingHours ?? this.openingHours,
      contactInfo: contactInfo ?? this.contactInfo,
      galleryImages: galleryImages ?? this.galleryImages,
      coordinates: coordinates ?? this.coordinates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'Destination(id: $id, name: $name, state: $state, price: $formattedPrice)';
  }
}