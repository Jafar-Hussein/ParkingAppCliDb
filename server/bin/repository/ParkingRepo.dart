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
      // Fetch ParkingSpace to get correct pricePerHour
      var result = await conn.execute(
        'SELECT pricePerHour FROM parkingspace WHERE id = :id',
        {'id': parking.parkingSpace.id},
      );

      if (result.numOfRows == 0) {
        throw Exception(
            "Parkingspace ID ${parking.parkingSpace.id} not found.");
      }

      double pricePerHour =
          double.parse(result.rows.first.colByName('pricePerHour')!);

      // Calculate price (if parking is finished)
      double totalPrice = parking.endTime != null
          ? (parking.endTime!.difference(parking.startTime).inMinutes / 60) *
              pricePerHour
          : 0.0;

      // Insert into database
      await conn.execute(
        'INSERT INTO parking (vehicleId, parkingspaceId, startTime, endTime, price) '
        'VALUES (:vehicleId, :parkingspaceId, STR_TO_DATE(:startTime, "%Y-%m-%d %H:%i:%s"), '
        'STR_TO_DATE(:endTime, "%Y-%m-%d %H:%i:%s"), :price)',
        {
          'vehicleId': parking.vehicle.id,
          'parkingspaceId': parking.parkingSpace.id,
          'startTime': parking.startTime.toLocal().toString().split('.')[0],
          'endTime': parking.endTime != null
              ? parking.endTime!.toLocal().toString().split('.')[0]
              : null,
          'price': totalPrice, // Store calculated price
        },
      );

      // Retrieve the inserted parking record including the price
      var newParkingResult = await conn.execute(
        'SELECT id, vehicleId, parkingspaceId, startTime, endTime, price FROM parking WHERE id = LAST_INSERT_ID()',
      );

      if (newParkingResult.numOfRows == 0) {
        throw Exception("Could not retrieve inserted parking.");
      }

      var newRow = newParkingResult.rows.first;
      int newId = int.parse(newRow.colByName('id')!);
      double savedPrice = double.parse(newRow.colByName('price')!);

      print('Ny parkering tillagd: ID $newId, Pris: $savedPrice kr');

      return Parking(
        id: newId,
        vehicle: parking.vehicle,
        parkingSpace: parking.parkingSpace,
        startTime: parking.startTime,
        endTime: parking.endTime,
        price: savedPrice, // Ensure the correct price is returned
      );
    } catch (e) {
      print('Fel: Kunde inte skapa parkering → $e');
      throw Exception('Kunde inte skapa parkering.');
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
          'SELECT p.id, p.vehicleId, p.parkingspaceId, p.startTime, p.endTime, '
          'v.registreringsnummer, v.typ, v.ownerId, '
          'ps.address, ps.pricePerHour, '
          'pr.namn, pr.personnummer '
          'FROM parking p '
          'JOIN vehicle v ON p.vehicleId = v.id '
          'JOIN parkingspace ps ON p.parkingspaceId = ps.id '
          'JOIN person pr ON v.ownerId = pr.id'); // Check table names!

      print('Fetched rows count: ${results.numOfRows}');

      for (final row in results.rows) {
        print('Row data: ${row.toString()}'); // Print each row for debugging

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

  /// **Uppdaterar en befintlig parkering och returnerar det uppdaterade objektet.**
  @override
  Future<Parking> update(int id, Parking parking) async {
    var conn = await Database.getConnection();
    try {
      await conn.execute(
        'UPDATE parking SET vehicleId = :vehicleId, parkingspaceId = :parkingspaceId, '
        'startTime = STR_TO_DATE(:startTime, "%Y-%m-%d %H:%i:%s"), '
        'endTime = STR_TO_DATE(:endTime, "%Y-%m-%d %H:%i:%s") WHERE id = :id',
        {
          'id': id,
          'vehicleId': parking.vehicle.id,
          'parkingspaceId': parking.parkingSpace.id,
          'startTime': parking.startTime
              .toLocal()
              .toString()
              .split('.')[0], 
          'endTime': parking.endTime != null
              ? parking.endTime!.toLocal().toString().split('.')[0]
              : null, 
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
      id: int.parse(row.colByName('id')!), // Parking ID
      vehicle: Vehicle(
        id: int.parse(row.colByName('vehicleId')!), // Vehicle ID
        registreringsnummer:
            row.colByName('registreringsnummer')!, // Vehicle reg num
        typ: row.colByName('typ')!, // Vehicle type
        owner: Person(
          id: int.parse(row.colByName('ownerId')!), // Owner ID
          namn: row.colByName('namn') ?? 'Okänd', // Fetch owner name
          personnummer:
              row.colByName('personnummer')!, // Fetch owner personnummer
        ),
      ),
      parkingSpace: ParkingSpace(
        id: int.parse(row.colByName('parkingspaceId')!), // ParkingSpace ID
        address: row.colByName('address')!, // ParkingSpace address
        pricePerHour:
            double.parse(row.colByName('pricePerHour')!), // Price per hour
      ),
      startTime: DateTime.parse(row.colByName('startTime')!), // Start time
      endTime: row.colByName('endTime') != null
          ? DateTime.parse(row.colByName('endTime')!)
          : null, // End time (nullable)
      price: double.parse(row.colByName('price')!), // Parking price
    );
  }
}
