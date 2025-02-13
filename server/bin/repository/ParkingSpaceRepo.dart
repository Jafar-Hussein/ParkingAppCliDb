import 'package:shared/src/model/ParkingSpace.dart';
import 'package:shared/src/repository/Repository.dart';
import '../db/Database.dart';

class ParkingSpaceRepo implements Repository<ParkingSpace> {
  static final ParkingSpaceRepo _instance = ParkingSpaceRepo._internal();
  ParkingSpaceRepo._internal();
  static ParkingSpaceRepo get instance => _instance;

  @override
  Future<ParkingSpace> create(ParkingSpace parkingSpace) async {
    var conn = await Database.getConnection();
    try {
      await conn.execute(
        'INSERT INTO parking_space (address, price_per_hour) VALUES (:address, :price_per_hour)',
        {
          'address': parkingSpace.address,
          'price_per_hour': parkingSpace.pricePerHour,
        },
      );

      var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(result.rows.first.colByName('id')!);

      print('Ny parkeringsplats tillagd: ID $newId, Adress: ${parkingSpace.address}, Pris per timme: ${parkingSpace.pricePerHour}');

      return ParkingSpace(id: newId, address: parkingSpace.address, pricePerHour: parkingSpace.pricePerHour);
    } catch (e) {
      print('Fel: Kunde inte lägga till parkeringsplats → $e');
      throw Exception('Kunde inte skapa parkeringsplats');
    } finally {
      await conn.close();
    }
  }

  @override
  Future<ParkingSpace> delete(int id) async {
    var conn = await Database.getConnection();
    try {
      var result = await conn.execute(
        'SELECT * FROM parking_space WHERE id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception('Ingen parkeringsplats hittades med ID: $id');
      }

      var deletedParkingSpace = ParkingSpace(
        id: int.parse(result.rows.first.colByName('id')!),
        address: result.rows.first.colByName('address')!,
        pricePerHour: double.parse(result.rows.first.colByName('price_per_hour')!),
      );

      await conn.execute(
        'DELETE FROM parking_space WHERE id = :id',
        {'id': id},
      );

      print('Parkeringsplats raderad: ID $id, Adress: ${deletedParkingSpace.address}, Pris per timme: ${deletedParkingSpace.pricePerHour}');

      return deletedParkingSpace;
    } catch (e) {
      print('Fel: Kunde inte radera parkeringsplats → $e');
      throw Exception('Kunde inte radera parkeringsplats');
    } finally {
      await conn.close();
    }
  }

  @override
  Future<List<ParkingSpace>> getAll() async {
    var conn = await Database.getConnection();
    List<ParkingSpace> parkingSpaces = [];
    try {
      var results = await conn.execute('SELECT * FROM parking_space');
      for (final row in results.rows) {
        int id = int.parse(row.colByName('id')!);
        String address = row.colByName('address')!;
        double pricePerHour = double.parse(row.colByName('price_per_hour')!);

        print('Hämtad parkeringsplats: ID $id, Adress: $address, Pris per timme: $pricePerHour');

        parkingSpaces.add(ParkingSpace(id: id, address: address, pricePerHour: pricePerHour));
      }
    } catch (e) {
      print('Fel: Kunde inte hämta parkeringsplatser → $e');
      return [];
    } finally {
      await conn.close();
    }
    return parkingSpaces;
  }

  @override
  Future<ParkingSpace?> getById(int id) async {
    var conn = await Database.getConnection();
    try {
      var results = await conn.execute(
        'SELECT * FROM parking_space WHERE id = :id',
        {'id': id},
      );

      if (results.rows.isNotEmpty) {
        var row = results.rows.first;
        int fetchedId = int.parse(row.colByName('id')!);
        String address = row.colByName('address')!;
        double pricePerHour = double.parse(row.colByName('price_per_hour')!);

        print('Hämtad parkeringsplats: ID $fetchedId, Adress: $address, Pris per timme: $pricePerHour');

        return ParkingSpace(id: fetchedId, address: address, pricePerHour: pricePerHour);
      }
      return null;
    } catch (e) {
      print('Fel: Kunde inte hämta parkeringsplats → $e');
      return Future.error('Misslyckades med att hämta parkeringsplats');
    } finally {
      await conn.close();
    }
  }

  @override
  Future<ParkingSpace> update(int id, ParkingSpace item) async {
    var conn = await Database.getConnection();
    try {
      await conn.execute(
        'UPDATE parking_space SET address = :address, price_per_hour = :price_per_hour WHERE id = :id',
        {
          'id': id,
          'address': item.address,
          'price_per_hour': item.pricePerHour,
        },
      );

      var result = await conn.execute(
        'SELECT * FROM parking_space WHERE id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception("Ingen parkeringsplats hittades med ID $id.");
      }

      var row = result.rows.first;
      int updatedId = int.parse(row.colByName('id')!);
      String updatedAddress = row.colByName('address')!;
      double updatedPricePerHour = double.parse(row.colByName('price_per_hour')!);

      print('Uppdaterad parkeringsplats: ID $updatedId, Adress: $updatedAddress, Pris per timme: $updatedPricePerHour');

      return ParkingSpace(id: updatedId, address: updatedAddress, pricePerHour: updatedPricePerHour);
    } catch (e) {
      print('Fel: Kunde inte uppdatera parkeringsplats → $e');
      throw Exception('Kunde inte uppdatera parkeringsplats.');
    } finally {
      await conn.close();
    }
  }
}
