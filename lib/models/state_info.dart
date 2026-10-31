class StateInfo {
  String id;
  String name;
  String capital;
  String description;
  String flagImage;
  List<String> popularDestinations;
  String? culturalTip;
  Map<String, dynamic>? mapCoordinates;

  StateInfo({
    required this.id,
    required this.name,
    required this.capital,
    required this.description,
    required this.flagImage,
    this.popularDestinations = const [],
    this.culturalTip,
    this.mapCoordinates,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'capital': capital,
      'description': description,
      'flagImage': flagImage,
      'popularDestinations': popularDestinations,
      'culturalTip': culturalTip,
      'mapCoordinates': mapCoordinates,
    };
  }

  factory StateInfo.fromMap(Map<String, dynamic> map) {
    return StateInfo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      capital: map['capital'] ?? '',
      description: map['description'] ?? '',
      flagImage: map['flagImage'] ?? '',
      popularDestinations: List<String>.from(map['popularDestinations'] ?? []),
      culturalTip: map['culturalTip'],
      mapCoordinates: map['mapCoordinates'] != null 
          ? Map<String, dynamic>.from(map['mapCoordinates']) 
          : null,
    );
  }

  
  int get destinationCount => popularDestinations.length;

  @override
  String toString() {
    return 'StateInfo(id: $id, name: $name, capital: $capital)';
  }
}