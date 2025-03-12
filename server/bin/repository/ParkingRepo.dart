import 'dart:convert';

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
  Future<Parking> create(Parking parking) async {
    var conn = await Database.getConnection();
    try {
      // Utför INSERT utan RETURNING
      await conn.execute(
        'INSERT INTO parking (vehicleId, parkingspaceId, startTime, endTime, price) '
        'VALUES (:vehicleId, :parkingspaceId, :startTime, :endTime, :price)',
        {
          'vehicleId': parking.vehicle.id,
          'parkingspaceId': parking.parkingSpace.id,
          'startTime': _formatDateTime(parking.startTime),
          'endTime': parking.endTime != null
              ? _formatDateTime(parking.endTime!)
              : null,
          'price': parking.price,
        },
      );

      // Hämta det senast skapade ID:t med MySQLs LAST_INSERT_ID()
      var result = await conn.execute('SELECT LAST_INSERT_ID() as id');

      int newId = int.parse(result.rows.first.colByName('id')!);

      // Hämta det skapade objektet
      return await getById(newId) ??
          (throw Exception("Fel: Kunde inte hämta nyskapad parkering"));
    } catch (e) {
      throw Exception('Kunde inte skapa parkering: $e');
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
      var results = await conn.execute('''
      SELECT p.id, p.vehicleId, p.parkingspaceId, p.startTime, p.endTime, p.price, 
             v.registreringsnummer, v.typ, v.ownerId, 
             ps.address, ps.pricePerHour, pr.namn, pr.personnummer 
      FROM parking p
      INNER JOIN vehicle v ON p.vehicleId = v.id
      INNER JOIN parkingspace ps ON p.parkingspaceId = ps.id
      INNER JOIN person pr ON v.ownerId = pr.id
    ''');

      print('Hämtade rader: ${results.numOfRows}');

      for (final row in results.rows) {
        print("DEBUG: Rad från DB → ID: ${row.colByName('id')}, "
            "Fordon: ${row.colByName('registreringsnummer')}, "
            "Parkeringsplats: ${row.colByName('address')}, "
            "Kostnad: ${row.colByName('price')}");
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
      var results = await conn.execute('''
      SELECT p.id, p.vehicleId, p.parkingspaceId, p.startTime, p.endTime, p.price, 
             v.registreringsnummer, v.typ, v.ownerId, 
             ps.address, ps.pricePerHour, pr.namn, pr.personnummer 
      FROM parking p
      INNER JOIN vehicle v ON p.vehicleId = v.id
      INNER JOIN parkingspace ps ON p.parkingspaceId = ps.id
      INNER JOIN person pr ON v.ownerId = pr.id
      WHERE p.id = :id
    ''', {'id': id});

      if (results.rows.isNotEmpty) {
        var row = results.rows.first;
        return _parseParking(row);
      }

      print("DEBUG: Ingen parkering hittades med ID: $id");
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
      print("Uppdaterar parkering ID $id");
      print("DEBUG: Ny data → ${jsonEncode(parking.toJson())}");

      // Kontrollera om parkeringen existerar innan vi uppdaterar
      var checkExist = await conn.execute(
        'SELECT COUNT(*) as count FROM parking WHERE id = :id',
        {'id': id},
      );

      int count = checkExist.rows.first.colByName('count') != null
          ? int.parse(checkExist.rows.first.colByName('count')!)
          : 0;

      if (count == 0) {
        throw Exception("Parkering med ID $id hittades inte!");
      }

      // 🔍 Kontrollera om alla värden redan är identiska i databasen
      var existingRow = await getById(id);
      if (existingRow != null &&
          existingRow.toJson().toString() == parking.toJson().toString()) {
        print("Ingen uppdatering gjord eftersom värdena är identiska.");
        return existingRow; // Returnera befintlig data utan att kasta fel
      }

      // 🏷 Hämta pris per timme för parkering
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

      // 🏷 Beräkna uppdaterad kostnad
      double updatedPrice = parking.endTime != null
          ? (parking.endTime!.difference(parking.startTime).inMinutes / 60) *
              pricePerHour
          : 0.0;

      // 🏷 Format datum för MySQL
      String formattedStartTime = _formatDateTime(parking.startTime);
      String? formattedEndTime =
          parking.endTime != null ? _formatDateTime(parking.endTime!) : null;

      // Kör UPDATE-frågan
      var updateResult = await conn.execute(
        '''
      UPDATE parking 
      SET vehicleId = :vehicleId, 
          parkingspaceId = :parkingspaceId, 
          startTime = :startTime, 
          endTime = :endTime, 
          price = :price 
      WHERE id = :id
      ''',
        {
          'id': id,
          'vehicleId': parking.vehicle.id,
          'parkingspaceId': parking.parkingSpace.id,
          'startTime': formattedStartTime,
          'endTime': formattedEndTime,
          'price': updatedPrice,
        },
      );

      // Kolla om UPDATE påverkade någon rad
      if (updateResult.numOfRows == 0) {
        var existingRowAfter = await getById(id);
        if (existingRowAfter != null &&
            existingRowAfter.toJson().toString() ==
                parking.toJson().toString()) {
          print("Ingen ändring behövdes, värdena var redan samma.");
          return existingRowAfter;
        }
        throw Exception("Uppdatering misslyckades, ingen rad ändrades!");
      }

      print("Parkering uppdaterad! ID $id, Nytt pris: $updatedPrice kr");

      // Hämta parkeringen efter uppdatering och logga den
      var updatedParking = await getById(id);
      if (updatedParking == null) {
        throw Exception("Parkeringen kunde inte hittas efter uppdatering!");
      }

      print(
          "DEBUG: Hämtade parkering efter update: ${jsonEncode(updatedParking.toJson())}");
      return updatedParking;
    } catch (e, stacktrace) {
      print("Fel vid uppdatering i backend: $e");
      print(stacktrace);
      throw Exception("Kunde inte uppdatera parkering: $e");
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
