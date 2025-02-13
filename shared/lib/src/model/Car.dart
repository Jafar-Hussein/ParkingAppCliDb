import 'Vehicle.dart';
import 'Person.dart';

class Car extends Vehicle {
  Car({
    required int id,
    required String registreringsnummer,
    required Person owner,
  }) : super(
            id: id,
            registreringsnummer: registreringsnummer,
            typ: 'Car',
            owner: owner);
}
