class ParkingSpace {
  int _id;
  String _address;
  double _pricePerHour;

  ParkingSpace({
    required int id,
    required String address,
    required double pricePerHour,
  })  : _id = id,
        _address = address,
        _pricePerHour = pricePerHour;

  // Getters
  int get id => _id;
  String get address => _address;
  double get pricePerHour => _pricePerHour;

  // Setters
  set id(int value) => _id = value;
  set address(String value) => _address = value;
  set pricePerHour(double value) => _pricePerHour = value;

  /// **Konverterar från JSON och hanterar null/tomma strängar**
  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json.containsKey('id') && json['id'] != null
          ? int.tryParse(json['id'].toString()) ?? 0 // Ensure id is never null
          : 0,
      address: json['address'] ?? '',
      pricePerHour: json['pricePerHour'] != null
          ? double.tryParse(json['pricePerHour'].toString()) ?? 0.0
          : 0.0,
    );
  }

  // **Konvertera till JSON**
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'address': _address,
      'pricePerHour': _pricePerHour,
    };
  }

  factory ParkingSpace.fromDatabaseRow(Map<String, dynamic> row) {
    return ParkingSpace(
      id: row['id'] != null ? int.parse(row['id'].toString()) : 0,
      address: row['address'],
      pricePerHour: row['pricePerHour'] != null
          ? double.tryParse(row['pricePerHour'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toDatabaseRow() {
    return {
      'id': _id,
      'address': _address,
      'pricePerHour': _pricePerHour,
    };
  }
  
}
