import 'Vehicle.dart';
import 'Person.dart';

class Truck extends Vehicle {
  Truck({
    required int id,
    required String registreringsnummer,
    required Person owner,
  }) : super(id: id, registreringsnummer: registreringsnummer, type: 'Truck', owner: owner);
}