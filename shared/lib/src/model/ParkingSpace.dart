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

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'],
      address: json['address'],
      pricePerHour: json['pricePerHour'].toDouble(),
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