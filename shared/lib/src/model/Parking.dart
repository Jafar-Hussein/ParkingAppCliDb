import 'Vehicle.dart';
import 'ParkingSpace.dart';
import 'Person.dart';

class Parking {
  int? _id;
  Vehicle _vehicle;
  ParkingSpace _parkingSpace;
  DateTime _startTime;
  DateTime? _endTime;
  double _price; // Changed to non-nullable

  Parking({
    int? id,
    required Vehicle vehicle,
    required ParkingSpace parkingSpace,
    required DateTime startTime,
    DateTime? endTime,
    double? price, // Nullable in constructor but handled properly
  })  : _id = id,
        _vehicle = vehicle,
        _parkingSpace = parkingSpace,
        _startTime = startTime,
        _endTime = endTime,
        _price = price ?? 0.0; // Default value if null

  // Getters
  int? get id => _id;
  Vehicle get vehicle => _vehicle;
  ParkingSpace get parkingSpace => _parkingSpace;
  DateTime get startTime => _startTime;
  DateTime? get endTime => _endTime;
  double get price => _price; // Now always returns a non-null value

  // Setters
  set price(double value) => _price = value;
  set vehicle(Vehicle value) => _vehicle = value;
  set parkingSpace(ParkingSpace value) => _parkingSpace = value;
  set endTime(DateTime? value) => _endTime = value;

  // Method to calculate parking cost
  double parkingCost() {
    if (_endTime == null) {
      return 0.0; // Ongoing parking, no cost calculated
    }
    Duration duration = _endTime!.difference(_startTime);
    double hours = duration.inMinutes / 60; // Convert minutes to hours
    return hours * _parkingSpace.pricePerHour;
  }

  // Convert from JSON
  factory Parking.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('vehicle') || json['vehicle'] == null) {
      throw Exception("Fel: 'vehicle' saknas i JSON.");
    }

    if (!json.containsKey('parkingSpace') || json['parkingSpace'] == null) {
      throw Exception("Fel: 'parkingSpace' saknas i JSON.");
    }

    return Parking(
      id: json['id'] ?? 0,
      vehicle: Vehicle.fromJson(json['vehicle']),
      parkingSpace: ParkingSpace.fromJson(json['parkingSpace']),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      price: json['price'] ?? 0.0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'vehicle': _vehicle.toJson(), // ✅ Skicka hela objektet
      'parkingSpace': _parkingSpace.toJson(),
      'startTime': _startTime.toIso8601String(),
      'endTime': _endTime != null ? _endTime!.toIso8601String() : null,
      'price': _price,
    };
  }

  factory Parking.fromDatabaseRow(Map<String, dynamic> json) {
    // 🛠 Fix: Kontrollera att alla fält finns i JSON
    if (!json.containsKey('vehicle') || json['vehicle'] == null) {
      throw Exception("Fel: 'vehicle' saknas i JSON.");
    }
    if (!json.containsKey('parkingSpace') || json['parkingSpace'] == null) {
      throw Exception("Fel: 'parkingSpace' saknas i JSON.");
    }
    if (!json.containsKey('price')) {
      throw Exception("Fel: 'price' saknas i JSON.");
    }

    return Parking(
      id: json['id'] ?? 0,

      // ✅ Hämta hela vehicle-objektet direkt från JSON
      vehicle: Vehicle.fromJson(json['vehicle']),

      // ✅ Hämta hela parkingSpace-objektet direkt från JSON
      parkingSpace: ParkingSpace.fromJson(json['parkingSpace']),

      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,

      // ✅ Sätt priset korrekt
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toDatabaseRow() {
    return {
      'id': _id,
      'vehicleId': _vehicle.id,
      'parkingSpaceId': _parkingSpace.id,
      'startTime': _startTime.toString().split('.')[0],
      'endTime': _endTime != null ? _endTime.toString().split('.')[0] : null,
      'price': _price,
    };
  }
}
