import 'Vehicle.dart';
import 'ParkingSpace.dart';

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

  // Method to calculate parking cost
  double parkingCost() {
    if (_endTime == null) {
      return 0.0;
    }
    Duration duration = _endTime!.difference(_startTime);
    return duration.inHours * _parkingSpace.pricePerHour;
  }

  // Convert from JSON
factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
       id: json.containsKey('id') && json['id'] != null
          ? int.tryParse(json['id'].toString()) ?? 0 // Ensure id is never null
          : 0,
      vehicle: Vehicle.fromJson(json['vehicle']),
      parkingSpace: ParkingSpace.fromJson(json['parkingSpace']),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'vehicle': _vehicle.toJson(),
      'parkingSpace': _parkingSpace.toJson(),
      'startTime': _startTime.toIso8601String(),
      'endTime': _endTime?.toIso8601String(),
      'price': _price,
    };
  }
}
