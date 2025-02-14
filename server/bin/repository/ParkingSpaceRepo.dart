import 'package:shared/src/model/ParkingSpace.dart';
import 'package:shared/src/repository/Repository.dart';
import '../db/Database.dart';

class ParkingSpaceRepo implements Repository<ParkingSpace> {
  static final ParkingSpaceRepo _instance = ParkingSpaceRepo._internal();
  ParkingSpaceRepo._internal();
  static ParkingSpaceRepo get instance => _instance;

  /// **Lägger till en parkering och returnerar den skapade posten**
  @override
  Future<ParkingSpace> create(ParkingSpace parkingSpace) async {
    var conn = await Database.getConnection();
    try {
      // 🔍 Debugging: Print values before insertion
      print(
          'Inserting ParkingSpace → Address: "${parkingSpace.address}", Price: ${parkingSpace.pricePerHour}');

      await conn.execute(
        'INSERT INTO parkingspace (address, pricePerHour) VALUES (:address, :pricePerHour)',
        {
          'address': parkingSpace.address, // Use the exact input address
          'pricePerHour': parkingSpace.pricePerHour,
        },
      );

      var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(result.rows.first.colByName('id')!);

      print(
          'Ny parkeringsplats tillagd: ID $newId, Adress: ${parkingSpace.address}, Pris per timme: ${parkingSpace.pricePerHour}');

      return ParkingSpace(
          id: newId,
          address: parkingSpace
              .address, // Ensure returned object has correct address
          pricePerHour: parkingSpace.pricePerHour);
    } catch (e) {
      print('Fel: Kunde inte skapa parkeringsplats → $e');
      throw Exception('Kunde inte skapa parkeringsplats.');
    } finally {
      await conn.close();
    }
  }

  /// **Tar bort en parkeringsplats och returnerar den raderade posten**
  @override
  Future<ParkingSpace> delete(int id) async {
    var conn = await Database.getConnection();
    try {
      var parkingSpace = await getById(id);
      if (parkingSpace == null) {
        throw Exception('Ingen parkeringsplats hittades med ID: $id');
      }

      await conn.execute('DELETE FROM parkingspace WHERE id = :id', {'id': id});

      print(
          'Parkeringsplats raderad: ID $id, Adress: ${parkingSpace.address}, Pris per timme: ${parkingSpace.pricePerHour}');

      return parkingSpace;
    } catch (e) {
      print('Fel: Kunde inte radera parkeringsplats → $e');
      throw Exception('Kunde inte radera parkeringsplats.');
    } finally {
      await conn.close();
    }
  }

  /// **Hämtar alla parkeringsplatser från databasen**
  @override
  Future<List<ParkingSpace>> getAll() async {
    var conn = await Database.getConnection();
    List<ParkingSpace> parkingSpaces = [];
    try {
      var results = await conn.execute('SELECT * FROM parkingspace');
      for (final row in results.rows) {
        ParkingSpace space = ParkingSpace.fromDatabaseRow({
          'id': row.colByName('id'),
          'address': row.colByName('address'),
          'pricePerHour': row.colByName('pricePerHour'),
        });

        print(
            'Hämtad parkeringsplats: ID ${space.id}, Adress: ${space.address}, Pris per timme: ${space.pricePerHour}');
        parkingSpaces.add(space);
      }
    } catch (e) {
      print('Fel: Kunde inte hämta parkeringsplatser → $e');
      return [];
    } finally {
      await conn.close();
    }
    return parkingSpaces;
  }

  /// **Hämtar en specifik parkeringsplats via ID**
  @override
  Future<ParkingSpace?> getById(int id) async {
    var conn = await Database.getConnection();
    try {
      var results = await conn.execute(
        'SELECT * FROM parkingspace WHERE id = :id',
        {'id': id},
      );

      if (results.rows.isNotEmpty) {
        var row = results.rows.first;
        ParkingSpace space = ParkingSpace.fromDatabaseRow({
          'id': row.colByName('id'),
          'address': row.colByName('address'),
          'pricePerHour': row.colByName('pricePerHour'),
        });

        print(
            'Hämtad parkeringsplats: ID ${space.id}, Adress: ${space.address}, Pris per timme: ${space.pricePerHour}');
        return space;
      }
      return null;
    } catch (e) {
      print('Fel: Kunde inte hämta parkeringsplats → $e');
      return Future.error('Misslyckades med att hämta parkeringsplats.');
    } finally {
      await conn.close();
    }
  }

  /// **Uppdaterar en parkeringsplats och returnerar den uppdaterade posten**
  @override
  Future<ParkingSpace> update(int id, ParkingSpace item) async {
    var conn = await Database.getConnection();
    try {
      await conn.execute(
        'UPDATE parkingspace SET address = :address, pricePerHour = :pricePerHour WHERE id = :id',
        {
          'id': id,
          'address': item.address,
          'pricePerHour': item.pricePerHour,
        },
      );

      var updatedParkingSpace = await getById(id);
      if (updatedParkingSpace == null) {
        throw Exception("Ingen parkeringsplats hittades med ID $id.");
      }

      print(
          'Uppdaterad parkeringsplats: ID ${updatedParkingSpace.id}, Adress: ${updatedParkingSpace.address}, Pris per timme: ${updatedParkingSpace.pricePerHour}');

      return updatedParkingSpace;
    } catch (e) {
      print('Fel: Kunde inte uppdatera parkeringsplats → $e');
      throw Exception('Kunde inte uppdatera parkeringsplats.');
    } finally {
      await conn.close();
    }
  }
}
