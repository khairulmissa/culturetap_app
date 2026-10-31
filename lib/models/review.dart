class Review {
  String id;
  String userId;
  String userName;
  String? userImage;
  String destinationId;
  double rating;
  String comment;
  DateTime date;
  List<String>? reviewImages;
  int likes;
  bool isVerified; 

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.destinationId,
    required this.rating,
    required this.comment,
    required this.date,
    this.reviewImages,
    this.likes = 0,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'destinationId': destinationId,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'reviewImages': reviewImages,
      'likes': likes,
      'isVerified': isVerified,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'],
      destinationId: map['destinationId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      reviewImages: map['reviewImages'] != null 
          ? List<String>.from(map['reviewImages']) 
          : null,
      likes: (map['likes'] ?? 0).toInt(),
      isVerified: map['isVerified'] ?? false,
    );
  }

  
  String get starRating {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    
    String stars = '';
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars += '★';
      } else if (i == fullStars && hasHalfStar) {
        stars += '½';
      } else {
        stars += '☆';
      }
    }
    return stars;
  }

  
  bool get isRecent {
    final daysDifference = DateTime.now().difference(date).inDays;
    return daysDifference <= 30;
  }

  @override
  String toString() {
    return 'Review(id: $id, user: $userName, rating: $rating, destination: $destinationId)';
  }
}