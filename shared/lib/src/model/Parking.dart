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
    return Parking(
      id: json.containsKey('id') && json['id'] != null
          ? int.tryParse(json['id'].toString()) ?? 0
          : 0,
      vehicle: Vehicle.fromJson(json['vehicle']),
      parkingSpace: ParkingSpace.fromJson(json['parkingSpace']),
      startTime: json.containsKey('startTime') && json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json.containsKey('endTime') && json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null,
      price: json.containsKey('price') && json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'vehicle': {'id': _vehicle.id},
      'parkingSpace': {'id': _parkingSpace.id},
      'startTime':
          _startTime.toString().split('.')[0], // Ensures correct format
      'endTime': _endTime != null ? _endTime.toString().split('.')[0] : null,
      'price': _price,
    };
  }

  factory Parking.fromDatabaseRow(Map<String, dynamic> row) {
    return Parking(
      id: row['id'],
      vehicle: Vehicle(
        id: row['vehicleId'],
        registreringsnummer: row['registreringsnummer'] ?? 'Okänd',
        typ: row['typ'] ?? 'Okänd',
        owner: Person(
          id: row['ownerId'] ?? 0,
          namn: row['namn'] ?? 'Okänd',
          personnummer: row['personnummer'] ?? '',
        ),
      ),
      parkingSpace: ParkingSpace(
        id: row['parkingSpaceId'],
        address: row['address'] ?? 'Okänd',
        pricePerHour: row['pricePerHour'] != null
            ? double.tryParse(row['pricePerHour'].toString()) ?? 0.0
            : 0.0,
      ),
      startTime: DateTime.parse(row['startTime']),
      endTime: row['endTime'] != null ? DateTime.parse(row['endTime']) : null,
      price: row['price'] ?? 0.0,
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
