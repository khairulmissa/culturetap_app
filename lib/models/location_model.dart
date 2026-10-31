class Location {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final String imageUrl;
  final String state;
  final String category;

  Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.imageUrl,
    required this.state,
    required this.category,
  });

  @override
  String toString() {
    return 'Location{id: $id, name: $name, state: $state}';
  }
}