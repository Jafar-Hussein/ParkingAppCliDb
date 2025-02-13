import 'Vehicle.dart';
import 'ParkingSpace.dart';

class Parking {
  int _id;
  Vehicle _vehicle;
  ParkingSpace _parkingSpace;
  DateTime _startTime;
  DateTime? _endTime;
  double? _price;

  Parking({
    required int id,
    required Vehicle vehicle,
    required ParkingSpace parkingSpace,
    required DateTime startTime,
    DateTime? endTime,
  })  : _id = id,
        _vehicle = vehicle,
        _parkingSpace = parkingSpace,
        _startTime = startTime,
        _endTime = endTime;

  // Getters
  int get id => _id;
  Vehicle get vehicle => _vehicle;
  ParkingSpace get parkingSpace => _parkingSpace;
  DateTime get startTime => _startTime;
  DateTime? get endTime => _endTime;
  double? get price => _price;

  // Setters
  set id(int value) => _id = value;
  set vehicle(Vehicle value) => _vehicle = value;
  set parkingSpace(ParkingSpace value) => _parkingSpace = value;
  set startTime(DateTime value) => _startTime = value;
  set endTime(DateTime? value) => _endTime = value;
  set price(double? value) => _price = value;

  double parkingCost() {
    DateTime now = DateTime.now();
    DateTime exitTime =
        _endTime ?? now; // Om parkeringen är pågående, använd nuvarande tid

    double durationInHours = exitTime.difference(_startTime).inMinutes / 60.0;
    double costPerHour = _parkingSpace.pricePerHour;

    // Extra avgift under rusningstid (07:00-09:00, vardagar)
    if (_startTime.hour >= 7 &&
        _startTime.hour <= 9 &&
        _startTime.weekday <= 5) {
      costPerHour *= 1.5;
    }

    return durationInHours * costPerHour;
  }

  
   /// **Konverterar från JSON till ett `Parking`-objekt**
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'],
      vehicle: Vehicle.fromJson(json['vehicle']),
      parkingSpace: ParkingSpace.fromJson(json['parkingSpace']),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    ).._price = json['price'] != null ? json['price'].toDouble() : null;
  }

  /// **Konverterar `Parking`-objektet till JSON**
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'vehicle': _vehicle.toJson(), // Vehicle måste ha en toJson()-metod
      'parkingSpace': _parkingSpace.toJson(), // ParkingSpace måste ha en toJson()-metod
      'startTime': _startTime.toIso8601String(),
      'endTime': _endTime?.toIso8601String(),
      'price': _price,
    };
  }
}
