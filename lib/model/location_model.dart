class Location {
  final String name;
  final String region;
  final String country;
  final double latitude;
  final double longitude;

  Location({
    this.name = '',
    this.region = '',
    this.country = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'],
      region: json['admin1'],
      country: json['country'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  static List<Location> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Location.fromJson(json)).toList();
  }

  @override
  String toString() {
    if (region.isEmpty) {
      return "$name - $country";
    } else {
      return "$name, $region - $country";
    }
  }
}
