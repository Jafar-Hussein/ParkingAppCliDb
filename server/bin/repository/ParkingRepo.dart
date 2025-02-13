import 'package:shared/src/model/Parking.dart';
import 'package:shared/src/repository/Repository.dart';
import '../db/Database.dart';

class ParkingRepo implements Repository<Parking> {
  static final ParkingRepo _instance = ParkingRepo._internal();
  ParkingRepo._internal();
  static ParkingRepo get instance => _instance;

  /// **Lägger till en parkering i databasen och returnerar det skapade objektet.**
  @override
  Future<Parking> create(Parking parking) async {
    var conn = await Database.getConnection();
    try {
      // Lägger till parkeringen i databasen
      await conn.execute(
        'INSERT INTO parking (vehicle_id, parking_space_id, start_time, end_time) '
        'VALUES (:vehicle_id, :parking_space_id, :start_time, :end_time)',
        parking.toJson(), // Använder toJson() för parameterbindning
      );

      // Hämta ID för den senast tillagda parkeringen
      var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(result.rows.first.colByName('id')!);

      print('Parkering tillagd med ID: $newId');

      // Returnera den skapade parkeringen med sitt ID
      return Parking.fromJson({...parking.toJson(), 'id': newId});
    } catch (e) {
      print('Fel: Kunde inte lägga till parkering → $e');
      throw Exception('Kunde inte skapa parkering');
    } finally {
      await conn.close();
    }
  }

  /// **Hämtar alla parkeringar från databasen och returnerar en lista av `Parking`-objekt.**
  @override
  Future<List<Parking>> getAll() async {
    var conn = await Database.getConnection();
    List<Parking> parkings = [];
    try {
      var results = await conn.execute('SELECT * FROM parking');
      for (final row in results.rows) {
        parkings.add(Parking.fromJson({
          'id': int.parse(row.colByName('id')!),
          'vehicle_id': int.parse(row.colByName('vehicle_id')!),
          'parking_space_id': int.parse(row.colByName('parking_space_id')!),
          'start_time': row.colByName('start_time')!,
          'end_time': row.colByName('end_time') ?? null,
        }));
      }
    } catch (e) {
      print('Fel: Kunde inte hämta parkeringar. $e');
      return [];
    } finally {
      await conn.close();
    }
    return parkings;
  }

  /// **Hämtar en parkering baserat på ID och returnerar ett `Parking`-objekt.**
  @override
  Future<Parking?> getById(int id) async {
    var conn = await Database.getConnection();
    try {
      var results = await conn.execute(
        'SELECT * FROM parking WHERE id = :id',
        {'id': id},
      );

      if (results.rows.isNotEmpty) {
        var row = results.rows.first;
        return Parking.fromJson({
          'id': int.parse(row.colByName('id')!),
          'vehicle_id': int.parse(row.colByName('vehicle_id')!),
          'parking_space_id': int.parse(row.colByName('parking_space_id')!),
          'start_time': row.colByName('start_time')!,
          'end_time': row.colByName('end_time') ?? null,
        });
      }
      return null;
    } catch (e) {
      print('Fel: Kunde inte hämta parkering med ID $id. $e');
      return Future.error('Misslyckades med att hämta parkering');
    } finally {
      await conn.close();
    }
  }

  /// **Uppdaterar en befintlig parkering i databasen och returnerar det uppdaterade objektet.**
  @override
  Future<Parking> update(int id, Parking parking) async {
    var conn = await Database.getConnection();
    try {
      await conn.execute(
        'UPDATE parking SET vehicle_id = :vehicle_id, parking_space_id = :parking_space_id, '
        'start_time = :start_time, end_time = :end_time WHERE id = :id',
        parking.toJson()..addAll({'id': id}),
      );

      // Hämta den uppdaterade parkeringen
      var result = await conn.execute(
        'SELECT * FROM parking WHERE id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception("Ingen parkering hittades med ID $id.");
      }

      return Parking.fromJson({
        'id': int.parse(result.rows.first.colByName('id')!),
        'vehicle_id': int.parse(result.rows.first.colByName('vehicle_id')!),
        'parking_space_id':
            int.parse(result.rows.first.colByName('parking_space_id')!),
        'start_time': result.rows.first.colByName('start_time')!,
        'end_time': result.rows.first.colByName('end_time') ?? null,
      });
    } catch (e) {
      print('Fel: Kunde inte uppdatera parkering → $e');
      throw Exception('Kunde inte uppdatera parkering.');
    } finally {
      await conn.close();
    }
  }

  /// **Tar bort en parkering från databasen baserat på ID och returnerar den raderade posten.**
  @override
  Future<Parking> delete(int id) async {
    var conn = await Database.getConnection();
    try {
      // Hämta den existerande parkeringen innan radering
      var result = await conn.execute(
        'SELECT * FROM parking WHERE id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception('Ingen parkering hittades med ID: $id');
      }

      // Konvertera resultatet till en Parking
      var deletedParking = Parking.fromJson({
        'id': int.parse(result.rows.first.colByName('id')!),
        'vehicle_id': int.parse(result.rows.first.colByName('vehicle_id')!),
        'parking_space_id':
            int.parse(result.rows.first.colByName('parking_space_id')!),
        'start_time': result.rows.first.colByName('start_time')!,
        'end_time': result.rows.first.colByName('end_time') ?? null,
      });

      // Radera parkeringen
      await conn.execute(
        'DELETE FROM parking WHERE id = :id',
        {'id': id},
      );

      print('Parkering raderad: ID $id');
      return deletedParking;
    } catch (e) {
      print('Fel: Kunde inte radera parkering → $e');
      throw Exception('Kunde inte radera parkering');
    } finally {
      await conn.close();
    }
  }
}
