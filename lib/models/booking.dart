class Booking {
  int? id; 
  int userId; 
  int destinationId; 
  String destinationName;
  String destinationImage;
  DateTime bookingDate;
  DateTime visitDate;
  int numberOfPeople;
  double totalPrice;
  String status; 
  DateTime createdAt;
  String? specialRequest;
  String? bookingReference;

  Booking ({
    this.id, 
    required this.userId,
    required this.destinationId,
    required this.destinationName,
    required this.destinationImage,
    required this.bookingDate,
    required this.visitDate,
    required this.numberOfPeople,
    required this.totalPrice,
    this.status = "pending",
    required this.createdAt,
    this.specialRequest,
    this.bookingReference,
  });

  // Untuk SQLite database 
  Map<String, dynamic> toDatabaseMap() {
    return {
      if (id != null) 'id': id, 
      'user_id': userId, 
      'destination_id': destinationId,
      'destination_name': destinationName,
      'destination_image': destinationImage,
      'booking_date': bookingDate.toIso8601String(),
      'visit_date': visitDate.toIso8601String(),
      'number_of_people': numberOfPeople,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'special_request': specialRequest,
      'booking_reference': bookingReference ?? _generateBookingRef(),
    };
  }

  
  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString() ?? '',
      'userId': userId.toString(),
      'destinationId': destinationId.toString(),
      'destinationName': destinationName,
      'destinationImage': destinationImage,
      'bookingDate': bookingDate.toIso8601String(),
      'visitDate': visitDate.toIso8601String(),
      'numberOfPeople': numberOfPeople,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'specialRequest': specialRequest,
      'bookingReference': bookingReference,
    };
  }

  // untuk baca dari database
  factory Booking.fromDatabaseMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      destinationId: map['destination_id'] as int,
      destinationName: map['destination_name'] as String,
      destinationImage: map['destination_image'] as String,
      bookingDate: DateTime.parse(map['booking_date'] as String),
      visitDate: DateTime.parse(map['visit_date'] as String),
      numberOfPeople: map['number_of_people'] as int,
      totalPrice: (map['total_price'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      specialRequest: map['special_request'] as String?,
      bookingReference: map['booking_reference'] as String?,
    );
  }

  // Factory untuk baca dari JSON/API
  factory Booking.fromJson(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      userId: int.tryParse(map['userId'].toString()) ?? 0,
      destinationId: int.tryParse(map['destinationId'].toString()) ?? 0,
      destinationName: map['destinationName'] as String,
      destinationImage: map['destinationImage'] as String,
      bookingDate: DateTime.parse(map['bookingDate'] as String),
      visitDate: DateTime.parse(map['visitDate'] as String),
      numberOfPeople: (map['numberOfPeople'] ?? 1) as int,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] as String),
      specialRequest: map['specialRequest'] as String?,
      bookingReference: map['bookingReference'] as String?,
    );
  }

  
String _generateBookingRef() {
  final now = DateTime.now();
  final random = now.millisecond + now.microsecond;
  return 'CT${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$random';
}


Map<String, dynamic> DatabaseMap() {
  final ref = bookingReference ?? _generateBookingRef();
  
  return {
    if (id != null) 'id': id,
    'user_id': userId,
    'destination_id': destinationId,
    'destination_name': destinationName,
    'destination_image': destinationImage,
    'booking_date': bookingDate.toIso8601String(),
    'visit_date': visitDate.toIso8601String(),
    'number_of_people': numberOfPeople,
    'total_price': totalPrice,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'special_request': specialRequest,
    'booking_reference': ref, 
  };
}

  // Check if booking is upcoming
  bool isUpcoming() {
    return visitDate.isAfter(DateTime.now()) && status == "confirmed";
  }

  // Check if booking is past
  bool isPast() {
    return visitDate.isBefore(DateTime.now()) || status == "completed";
  }

  // Check if booking can be cancelled (e.g., 24 hours before visit)
  bool canCancel() {
    final hoursDifference = visitDate.difference(DateTime.now()).inHours;
    return hoursDifference > 24 && (status == "confirmed" || status == "pending");
  }

  // Format price untuk display
  String get formattedPrice {
    return 'RM ${totalPrice.toStringAsFixed(2)}';
  }

  // Format date untuk display
  String get formattedVisitDate {
    return '${visitDate.day}/${visitDate.month}/${visitDate.year}';
  }

  @override
  String toString() {
    return 'Booking(id: $id, destination: $destinationName, status: $status, date: $formattedVisitDate)';
  }
}