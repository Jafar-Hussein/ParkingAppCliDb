import '../../../shared/lib/src/model/Vehicle.dart';
import '../../../shared/lib/src/repository/Repository.dart';

class VehicleRepo implements Repository<Vehicle> {
  static final VehicleRepo _instance = VehicleRepo._internal();
  VehicleRepo._internal();
  static VehicleRepo get instance => _instance;

  @override
  Future<Vehicle> create(Vehicle vehicle) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<Vehicle> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<Vehicle>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Vehicle?> getById(int id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<Vehicle> update(int id, Vehicle vehicle) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
