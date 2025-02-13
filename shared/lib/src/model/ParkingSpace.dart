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
      id: (json['id'] == null || json['id'] == "") ? null 
          : (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString())),
      address: json['address'] ?? '', // Hanterar null genom att sätta en tom sträng
      pricePerHour: json['pricePerHour'] is double
          ? json['pricePerHour']
          : double.tryParse(json['pricePerHour'].toString()) ?? 0.0, // Standardvärde om konvertering misslyckas
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
}
