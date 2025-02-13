import '../../../shared/lib/src/model/Parking.dart';
import '../../../shared/lib/src/model/Vehicle.dart';
import '../../../shared/lib/src/model/ParkingSpace.dart';
import '../../../shared/lib/src/model/Person.dart';
import '../../../shared/lib/src/repository/Repository.dart';

class ParkingRepo implements Repository<Parking> {
  static final ParkingRepo _instance = ParkingRepo._internal();
  ParkingRepo._internal();
  static ParkingRepo get instance => _instance;

  @override
  Future<Parking> create(Parking parking) {
    throw UnimplementedError();
  }

  @override
  Future<Parking> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<Parking>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Parking?> getById(int id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<Parking> update(int id, Parking parking) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
