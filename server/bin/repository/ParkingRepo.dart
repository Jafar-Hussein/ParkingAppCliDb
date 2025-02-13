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
      // Hämta pris per timme från parkeringsplatsen
      var result = await conn.execute(
        'SELECT pricePerHour FROM parkingspace WHERE id = :id',
        {'id': parking.parkingSpace.id},
      );

      if (result.numOfRows == 0) {
        throw Exception(
            "Parkeringsplats ID ${parking.parkingSpace.id} hittades inte.");
      }

      double pricePerHour =
          double.parse(result.rows.first.colByName('pricePerHour')!);

      // Beräkna pris om parkeringen har avslutats
      double totalPrice = parking.endTime != null
          ? (parking.endTime!.difference(parking.startTime).inMinutes / 60) *
              pricePerHour
          : 0.0;

      // Formatera tid till MySQL-format
      String formattedStartTime = _formatDateTime(parking.startTime);
      String? formattedEndTime =
          parking.endTime != null ? _formatDateTime(parking.endTime!) : null;

      // Infoga parkering i databasen
      await conn.execute(
        'INSERT INTO parking (vehicleId, parkingspaceId, startTime, endTime, price) '
        'VALUES (:vehicleId, :parkingspaceId, :startTime, :endTime, :price)',
        {
          'vehicleId': parking.vehicle.id,
          'parkingspaceId': parking.parkingSpace.id,
          'startTime': formattedStartTime,
          'endTime': formattedEndTime,
          'price': totalPrice,
        },
      );

      // Hämta ID på den nyligen skapade parkeringen
      var newParkingResult =
          await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(newParkingResult.rows.first.colByName('id')!);

      print('Ny parkering tillagd: ID $newId, Pris: $totalPrice kr');

      return Parking(
        id: newId,
        vehicle: parking.vehicle,
        parkingSpace: parking.parkingSpace,
        startTime: parking.startTime,
        endTime: parking.endTime,
        price: totalPrice,
      );
    } catch (e) {
      print('Fel: Kunde inte skapa parkering → $e');
      throw Exception('Kunde inte skapa parkering.');
    } finally {
      await conn.close();
    }
  }

  /// **Hämtar alla parkeringar från databasen**
  @override
  Future<List<Parking>> getAll() async {
    var conn = await Database.getConnection();
    List<Parking> parkings = [];
    try {
      var results = await conn.execute(
          'SELECT p.id, p.vehicleId, p.parkingspaceId, p.startTime, p.endTime, p.price, '
          'v.registreringsnummer, v.typ, v.ownerId, '
          'ps.address, ps.pricePerHour, '
          'pr.namn, pr.personnummer '
          'FROM parking p '
          'JOIN vehicle v ON p.vehicleId = v.id '
          'JOIN parkingspace ps ON p.parkingspaceId = ps.id '
          'JOIN person pr ON v.ownerId = pr.id');

      print('Hämtade rader: ${results.numOfRows}');

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

  /// **Hämtar en specifik parkering baserat på ID**
  @override
  Future<Parking?> getById(int id) async {
    var conn = await Database.getConnection();
    try {
      var results = await conn.execute(
        'SELECT p.id, p.vehicleId, p.parkingspaceId, p.startTime, p.endTime, p.price, '
        'v.registreringsnummer, v.typ, v.ownerId, '
        'ps.address, ps.pricePerHour, '
        'pr.namn, pr.personnummer '
        'FROM parking p '
        'JOIN vehicle v ON p.vehicleId = v.id '
        'JOIN parkingspace ps ON p.parkingspaceId = ps.id '
        'JOIN person pr ON v.ownerId = pr.id '
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

  /// **Uppdaterar en befintlig parkering**
  @override
  Future<Parking> update(int id, Parking parking) async {
    var conn = await Database.getConnection();
    try {
      // Fetch ParkingSpace to get correct pricePerHour
      var result = await conn.execute(
        'SELECT pricePerHour FROM parkingspace WHERE id = :id',
        {'id': parking.parkingSpace.id},
      );

      if (result.numOfRows == 0) {
        throw Exception(
            "Parkeringsplats ID ${parking.parkingSpace.id} hittades inte.");
      }

      double pricePerHour =
          double.parse(result.rows.first.colByName('pricePerHour')!);

      // Recalculate price if parking has ended
      double updatedPrice = parking.endTime != null
          ? (parking.endTime!.difference(parking.startTime).inMinutes / 60) *
              pricePerHour
          : 0.0;

      // Format date for MySQL
      String formattedStartTime = _formatDateTime(parking.startTime);
      String? formattedEndTime =
          parking.endTime != null ? _formatDateTime(parking.endTime!) : null;

      // Update parking record
      await conn.execute(
        'UPDATE parking SET vehicleId = :vehicleId, parkingspaceId = :parkingspaceId, '
        'startTime = :startTime, endTime = :endTime, price = :price WHERE id = :id',
        {
          'id': id,
          'vehicleId': parking.vehicle.id,
          'parkingspaceId': parking.parkingSpace.id,
          'startTime': formattedStartTime,
          'endTime': formattedEndTime,
          'price': updatedPrice, // ✅ Fix: Store updated price
        },
      );

      print('Parkering uppdaterad: ID $id, Nytt pris: $updatedPrice kr');

      return await getById(id) ??
          (throw Exception("Parkering kunde inte uppdateras"));
    } catch (e) {
      print('Fel: Kunde inte uppdatera parkering → $e');
      throw Exception('Kunde inte uppdatera parkering.');
    } finally {
      await conn.close();
    }
  }

  /// **Tar bort en parkering**
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

  /// **Konverterar en databasrad till ett `Parking`-objekt**
  Parking _parseParking(dynamic row) {
    return Parking(
      id: int.parse(row.colByName('id')!),
      vehicle: Vehicle(
        id: int.parse(row.colByName('vehicleId')!),
        registreringsnummer: row.colByName('registreringsnummer')!,
        typ: row.colByName('typ')!,
        owner: Person(
          id: int.parse(row.colByName('ownerId')!),
          namn: row.colByName('namn') ?? 'Okänd',
          personnummer: row.colByName('personnummer')!,
        ),
      ),
      parkingSpace: ParkingSpace(
        id: int.parse(row.colByName('parkingspaceId')!),
        address: row.colByName('address')!,
        pricePerHour: double.parse(row.colByName('pricePerHour')!),
      ),
      startTime: DateTime.parse(row.colByName('startTime')!),
      endTime: row.colByName('endTime') != null
          ? DateTime.parse(row.colByName('endTime')!)
          : null,
      price: double.parse(row.colByName('price')!),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
  }

// Hjälpmetod för att alltid få tvåsiffriga nummer (01, 02, ... 09)
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
