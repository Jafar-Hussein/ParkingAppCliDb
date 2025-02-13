import 'dart:convert';
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
      // Infoga ny parkeringsplats i databasen
      await conn.execute(
        'INSERT INTO parking_space (address, price_per_hour) VALUES (:address, :price_per_hour)',
        parkingSpace.toJson(), // ✅ Uses toJson() for inserting data
      );

      // Hämta ID för den senast tillagda posten
      var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(result.rows.first.colByName('id')!);

      // **Returnera ett nytt `ParkingSpace`-objekt från JSON**
      return ParkingSpace.fromJson({...parkingSpace.toJson(), 'id': newId});
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
      // Hämta den existerande parkeringsplatsen innan radering
      var result = await conn.execute(
        'SELECT * FROM parking_space WHERE id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception('Ingen parkeringsplats hittades med ID: $id');
      }

      // Konvertera resultatet till en ParkingSpace via fromJson()
      var deletedParkingSpace = ParkingSpace.fromJson({
        'id': int.parse(result.rows.first.colByName('id')!),
        'address': result.rows.first.colByName('address')!,
        'pricePerHour':
            double.parse(result.rows.first.colByName('price_per_hour')!),
      });

      // Radera posten
      await conn.execute(
        'DELETE FROM parking_space WHERE id = :id',
        {'id': id},
      );

      print('Parkeringsplats raderad: ID $id');

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
        parkingSpaces.add(ParkingSpace.fromJson({
          'id': int.parse(row.colByName('id')!),
          'address': row.colByName('address')!,
          'pricePerHour': double.parse(row.colByName('price_per_hour')!),
        }));
      }
    } catch (e) {
      print('Fel: Kunde inte hämta parkeringsplatser. $e');
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
      var results = await conn
          .execute('SELECT * FROM parking_space WHERE id = :id', {'id': id});
      if (results.rows.isNotEmpty) {
        return ParkingSpace.fromJson({
          'id': int.parse(results.rows.first.colByName('id')!),
          'address': results.rows.first.colByName('address')!,
          'pricePerHour':
              double.parse(results.rows.first.colByName('price_per_hour')!),
        });
      }
      return null;
    } catch (e) {
      print('Fel: Kunde inte hämta parkeringsplats. $e');
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
          item.toJson()
            ..addAll(
                {'id': id})); // ✅ Uses toJson() to structure query parameters

      // Hämta den uppdaterade posten
      var result = await conn
          .execute('SELECT * FROM parking_space WHERE id = :id', {'id': id});

      if (result.numOfRows == 0) {
        throw Exception("Fel: Ingen parkeringsplats hittades med ID $id.");
      }

      return ParkingSpace.fromJson({
        'id': int.parse(result.rows.first.colByName('id')!),
        'address': result.rows.first.colByName('address')!,
        'pricePerHour':
            double.parse(result.rows.first.colByName('price_per_hour')!)
      });
    } catch (e) {
      print('Fel: Kunde inte uppdatera parkeringsplats → $e');
      throw Exception('Kunde inte uppdatera parkeringsplats.');
    } finally {
      await conn.close();
    }
  }
}
