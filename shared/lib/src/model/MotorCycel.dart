import 'Vehicle.dart';
import 'Person.dart';

class MotorCycel extends Vehicle {
  MotorCycel({
    required int id,
    required String registreringsnummer,
    required Person owner,
  }) : super(
            id: id,
            registreringsnummer: registreringsnummer,
            typ: 'Motorcycel',
            owner: owner);
}
