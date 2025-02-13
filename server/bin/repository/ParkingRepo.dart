import 'package:shared/src/model/Parking.dart';
import 'package:shared/src/model/Person.dart';
import 'package:shared/src/model/ParkingSpace.dart';
import 'package:shared/src/model/Vehicle.dart';
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
      await conn.execute(
        'INSERT INTO parking (vehicle_id, parking_space_id, start_time, end_time) '
        'VALUES (:vehicle_id, :parking_space_id, :start_time, :end_time)',
        {
          'vehicle_id': parking.vehicle.id,
          'parking_space_id': parking.parkingSpace.id,
          'start_time': parking.startTime.toIso8601String(),
          'end_time': parking.endTime?.toIso8601String(),
        },
      );

      var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(result.rows.first.colByName('id')!);

      print(
          'Ny parkering tillagd: ID $newId, Fordon: ${parking.vehicle.registreringsnummer}, Parkeringsplats: ${parking.parkingSpace.address}, Starttid: ${parking.startTime}, Sluttid: ${parking.endTime ?? "Pågående"}');

      return Parking(
        id: newId,
        vehicle: parking.vehicle,
        parkingSpace: parking.parkingSpace,
        startTime: parking.startTime,
        endTime: parking.endTime,
      );
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
      var results = await conn.execute(
          'SELECT p.id, p.vehicle_id, p.parking_space_id, p.start_time, p.end_time, '
          'v.registreringsnummer, v.type, v.owner_id, '
          'ps.address, ps.price_per_hour '
          'FROM parking p '
          'JOIN vehicle v ON p.vehicle_id = v.id '
          'JOIN parking_space ps ON p.parking_space_id = ps.id');

      for (final row in results.rows) {
        parkings.add(_parseParking(row));
      }
    } catch (e) {
      print('Fel: Kunde inte hämta parkeringar → $e');
      return [];
    } finally {
      await conn.close();
    }
    return parkings;
  }

  /// **Hämtar en specifik parkering baserat på ID och returnerar ett `Parking`-objekt.**
  @override
  Future<Parking?> getById(int id) async {
    var conn = await Database.getConnection();
    try {
      var results = await conn.execute(
        'SELECT p.id, p.vehicle_id, p.parking_space_id, p.start_time, p.end_time, '
        'v.registreringsnummer, v.type, v.owner_id, '
        'ps.address, ps.price_per_hour '
        'FROM parking p '
        'JOIN vehicle v ON p.vehicle_id = v.id '
        'JOIN parking_space ps ON p.parking_space_id = ps.id '
        'WHERE p.id = :id',
        {'id': id},
      );

      if (results.rows.isNotEmpty) {
        return _parseParking(results.rows.first);
      }
      return null;
    } catch (e) {
      print('Fel: Kunde inte hämta parkering med ID $id → $e');
      return Future.error('Misslyckades med att hämta parkering');
    } finally {
      await conn.close();
    }
  }

  /// **Uppdaterar en befintlig parkering och returnerar det uppdaterade objektet.**
  @override
  Future<Parking> update(int id, Parking parking) async {
    var conn = await Database.getConnection();
    try {
      await conn.execute(
        'UPDATE parking SET vehicle_id = :vehicle_id, parking_space_id = :parking_space_id, start_time = :start_time, end_time = :end_time WHERE id = :id',
        {
          'id': id,
          'vehicle_id': parking.vehicle.id,
          'parking_space_id': parking.parkingSpace.id,
          'start_time': parking.startTime.toIso8601String(),
          'end_time': parking.endTime?.toIso8601String(),
        },
      );

      return await getById(id) ??
          (throw Exception("Parkering kunde inte uppdateras"));
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
      var parkingToDelete = await getById(id);
      if (parkingToDelete == null) {
        throw Exception('Ingen parkering hittades med ID: $id');
      }

      await conn.execute('DELETE FROM parking WHERE id = :id', {'id': id});

      print('Parkering raderad: ID $id');
      return parkingToDelete;
    } catch (e) {
      print('Fel: Kunde inte radera parkering → $e');
      throw Exception('Kunde inte radera parkering');
    } finally {
      await conn.close();
    }
  }

  /// **Hjälpfunktion för att konvertera databassvar till `Parking`-objekt.**
  Parking _parseParking(dynamic row) {
    return Parking(
      id: int.parse(row.colByName('id')!),
      vehicle: Vehicle(
        id: int.parse(row.colByName('vehicle_id')!),
        registreringsnummer: row.colByName('registreringsnummer')!,
        typ: row.colByName('type')!,
        owner: Person(
          id: int.parse(row.colByName('owner_id')!),
          namn: row.colByName('namn')!,
          personnummer: row.colByName('personnummer')!,
        ),
      ),
      parkingSpace: ParkingSpace(
        id: int.parse(row.colByName('parking_space_id')!),
        address: row.colByName('address')!,
        pricePerHour: double.parse(row.colByName('price_per_hour')!),
      ),
      startTime: DateTime.parse(row.colByName('start_time')!),
      endTime: row.colByName('end_time') != null
          ? DateTime.parse(row.colByName('end_time')!)
          : null,
    );
  }
}
