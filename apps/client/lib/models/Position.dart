class PositionInterface {
  int? createdAt;
  String? locationId;
  String? userId;
  double? latitude;
  double? longitude;

  PositionInterface() {
    createdAt = 0;
    locationId = "";
    userId = "";
    latitude = 0;
    longitude = 0;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  PositionInterface.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return;
    }

    createdAt = map['createdAt'];
    locationId = map['locationId'];
    latitude = map['latitude'];
    userId = map['userId'];
    longitude = map['longitude'];
  }

  Map toJson() => {
        'createdAt': createdAt,
        'locationId': locationId,
        'latitude': latitude,
        'userId': userId,
        'longitude': longitude,
      };

  compareTo(PositionInterface b) {
    return (createdAt?.compareTo(b.createdAt as num));
  }
}
