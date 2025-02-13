import '../../../shared/lib/src/repository/Repository.dart';
import '../../../shared/lib/src/model/ParkingSpace.dart';

class ParkingSpaceRepo implements Repository<ParkingSpace> {
  static final ParkingSpaceRepo _instance = ParkingSpaceRepo._internal();
  ParkingSpaceRepo._internal();
  static ParkingSpaceRepo get instance => _instance;
  
  @override
  Future<ParkingSpace> create(ParkingSpace parkingSpace) {
    // TODO: implement create
    throw UnimplementedError();
  }
  
  @override
  Future<ParkingSpace> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }
  
  @override
  Future<List<ParkingSpace>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }
  
  @override
  Future<ParkingSpace?> getById(int id) {
    // TODO: implement getById
    throw UnimplementedError();
  }
  
  @override
  Future<ParkingSpace> update(int id, ParkingSpace parkingSpace) {
    // TODO: implement update
    throw UnimplementedError();
  }

 
}
