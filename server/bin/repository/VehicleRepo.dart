import 'package:shared/src/model/Vehicle.dart';
import 'package:shared/src/repository/Repository.dart';
import '../db/Database.dart';

class VehicleRepo implements Repository<Vehicle> {
  static final VehicleRepo _instance = VehicleRepo._internal();
  VehicleRepo._internal();
  static VehicleRepo get instance => _instance;

  /// **Lägger till ett fordon i databasen och returnerar det skapade fordonet.**
  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    var conn = await Database.getConnection();
    try {
      await conn.execute(
        'INSERT INTO vehicle (registreringsnummer, type, owner_id) VALUES (:registreringsnummer, :type, :owner_id)',
        vehicle.toJson(),
      );

      // Hämta det nya ID:t
      var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(result.rows.first.colByName('id')!);

      print('Fordon tillagt med ID: $newId');

      return Vehicle.fromJson({...vehicle.toJson(), 'id': newId});
    } catch (e) {
      print('Fel: Kunde inte lägga till fordon → $e');
      throw Exception('Kunde inte skapa fordon.');
    } finally {
      await conn.close();
    }
  }

  /// **Hämtar alla fordon från databasen och returnerar en lista av `Vehicle`-objekt.**
  @override
  Future<List<Vehicle>> getAll() async {
    var conn = await Database.getConnection();
    List<Vehicle> vehicles = [];
    try {
      var results = await conn.execute(
        'SELECT vehicle.id, vehicle.registreringsnummer, vehicle.type, '
        'person.id AS owner_id, person.namn, person.personnummer '
        'FROM vehicle '
        'INNER JOIN person ON vehicle.owner_id = person.id',
      );

      for (final row in results.rows) {
        vehicles.add(
          Vehicle.fromJson({
            'id': int.parse(row.colByName('id')!),
            'registreringsnummer': row.colByName('registreringsnummer')!,
            'type': row.colByName('type')!,
            'owner': {
              'id': int.parse(row.colByName('owner_id')!),
              'namn': row.colByName('namn')!,
              'personnummer': row.colByName('personnummer')!,
            },
          }),
        );
      }
    } catch (e) {
      print('Fel: Kunde inte hämta fordon. $e');
      return [];
    } finally {
      await conn.close();
    }
    return vehicles;
  }

  /// **Hämtar ett fordon baserat på ID och returnerar ett `Vehicle`-objekt.**
  @override
  Future<Vehicle?> getById(int id) async {
    var conn = await Database.getConnection();
    try {
      var results = await conn.execute(
        'SELECT vehicle.id, vehicle.registreringsnummer, vehicle.type, '
        'person.id AS owner_id, person.namn, person.personnummer '
        'FROM vehicle '
        'INNER JOIN person ON vehicle.owner_id = person.id '
        'WHERE vehicle.id = :id',
        {'id': id},
      );

      if (results.rows.isNotEmpty) {
        var row = results.rows.first;
        return Vehicle.fromJson({
          'id': int.parse(row.colByName('id')!),
          'registreringsnummer': row.colByName('registreringsnummer')!,
          'type': row.colByName('type')!,
          'owner': {
            'id': int.parse(row.colByName('owner_id')!),
            'namn': row.colByName('namn')!,
            'personnummer': row.colByName('personnummer')!,
          },
        });
      }
      return null;
    } catch (e) {
      print('Fel: Kunde inte hämta fordon med ID $id. $e');
      return Future.error('Misslyckades med att hämta fordon.');
    } finally {
      await conn.close();
    }
  }

  /// **Uppdaterar ett fordon i databasen och returnerar det uppdaterade fordonet.**
  @override
  Future<Vehicle> update(int id, Vehicle vehicle) async {
    var conn = await Database.getConnection();
    try {
      await conn.execute(
        'UPDATE vehicle SET registreringsnummer = :registreringsnummer, '
        'type = :type, owner_id = :owner_id WHERE id = :id',
        vehicle.toJson()..addAll({'id': id}),
      );

      // Hämta det uppdaterade fordonet
      var result = await conn.execute(
        'SELECT vehicle.id, vehicle.registreringsnummer, vehicle.type, '
        'person.id AS owner_id, person.namn, person.personnummer '
        'FROM vehicle '
        'INNER JOIN person ON vehicle.owner_id = person.id '
        'WHERE vehicle.id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception("Ingen fordon hittades med ID $id.");
      }

      return Vehicle.fromJson({
        'id': int.parse(result.rows.first.colByName('id')!),
        'registreringsnummer':
            result.rows.first.colByName('registreringsnummer')!,
        'type': result.rows.first.colByName('type')!,
        'owner': {
          'id': int.parse(result.rows.first.colByName('owner_id')!),
          'namn': result.rows.first.colByName('namn')!,
          'personnummer': result.rows.first.colByName('personnummer')!,
        },
      });
    } catch (e) {
      print('Fel: Kunde inte uppdatera fordon → $e');
      throw Exception('Kunde inte uppdatera fordon.');
    } finally {
      await conn.close();
    }
  }

  /// **Tar bort ett fordon från databasen baserat på ID och returnerar det raderade fordonet.**
  @override
  Future<Vehicle> delete(int id) async {
    var conn = await Database.getConnection();
    try {
      // Hämta det existerande fordonet innan radering
      var result = await conn.execute(
        'SELECT vehicle.id, vehicle.registreringsnummer, vehicle.type, '
        'person.id AS owner_id, person.namn, person.personnummer '
        'FROM vehicle '
        'INNER JOIN person ON vehicle.owner_id = person.id '
        'WHERE vehicle.id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception('Ingen fordon hittades med ID: $id');
      }

      // Konvertera resultatet till ett Vehicle-objekt
      var deletedVehicle = Vehicle.fromJson({
        'id': int.parse(result.rows.first.colByName('id')!),
        'registreringsnummer':
            result.rows.first.colByName('registreringsnummer')!,
        'type': result.rows.first.colByName('type')!,
        'owner': {
          'id': int.parse(result.rows.first.colByName('owner_id')!),
          'namn': result.rows.first.colByName('namn')!,
          'personnummer': result.rows.first.colByName('personnummer')!,
        },
      });

      // Radera fordonet
      await conn.execute(
        'DELETE FROM vehicle WHERE id = :id',
        {'id': id},
      );

      print('Fordon raderat: ID $id');
      return deletedVehicle;
    } catch (e) {
      print('Fel: Kunde inte radera fordon → $e');
      throw Exception('Kunde inte radera fordon.');
    } finally {
      await conn.close();
    }
  }
}
