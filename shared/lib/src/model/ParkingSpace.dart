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
    // Kontrollera att ID finns och är korrekt
    int parsedId = 0;
    if (json.containsKey('id') && json['id'] != null) {
      parsedId = int.tryParse(json['id'].toString()) ?? 0;
    }

    // 🛠 Kontrollera att address är en sträng
    String parsedAddress = json['address']?.toString() ?? 'Okänd';

    // 🛠 Kontrollera att pricePerHour är en giltig double
    double parsedPricePerHour = 0.0;
    if (json.containsKey('pricePerHour') && json['pricePerHour'] != null) {
      try {
        parsedPricePerHour =
            double.tryParse(json['pricePerHour'].toString()) ?? 0.0;
      } catch (e) {
        print(
            "Varning: Kunde inte parsa 'pricePerHour', satt till 0.0 → $e");
      }
    }

    return ParkingSpace(
      id: parsedId,
      address: parsedAddress,
      pricePerHour: parsedPricePerHour,
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
      id: int.tryParse(row['id'].toString()) ?? 0,
      address: row['address']?.toString() ?? 'Okänd Adress', // 🛠 Undvik null
      pricePerHour: double.tryParse(row['pricePerHour'].toString()) ??
          0.0, // 🛠 Undvik null
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
