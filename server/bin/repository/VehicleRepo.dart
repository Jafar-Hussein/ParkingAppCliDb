import 'package:shared/src/model/Vehicle.dart';
import 'package:shared/src/model/Person.dart';
import 'package:shared/src/repository/Repository.dart';
import '../db/Database.dart';

class VehicleRepo implements Repository<Vehicle> {
  static final VehicleRepo _instance = VehicleRepo._internal();
  VehicleRepo._internal();
  static VehicleRepo get instance => _instance;

  /// **Lägger till ett fordon i databasen**
  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    var conn = await Database.getConnection();
    try {
      await conn.execute(
        'INSERT INTO vehicle (registreringsnummer, typ, ownerId) VALUES (:registreringsnummer, :typ, :ownerId)',
        vehicle.toDatabaseRow(),
      );

      var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(result.rows.first.colByName('id')!);

      var newVehicle = Vehicle(
        id: newId,
        registreringsnummer: vehicle.registreringsnummer,
        typ: vehicle.typ,
        owner: vehicle.owner,
      );

      print(
          'Fordon tillagt: ID ${newVehicle.id}, Registreringsnummer: ${newVehicle.registreringsnummer}, Typ: ${newVehicle.typ}, Ägare: ${newVehicle.owner.namn}');

      return newVehicle;
    } catch (e) {
      print('Fel: Kunde inte skapa fordon → $e');
      throw Exception('Kunde inte skapa fordon.');
    } finally {
      await conn.close();
    }
  }

  /// **Hämtar alla fordon från databasen**
  @override
  Future<List<Vehicle>> getAll() async {
    var conn = await Database.getConnection();
    List<Vehicle> vehicles = [];
    try {
      var results = await conn.execute(
        'SELECT vehicle.id, vehicle.registreringsnummer, vehicle.typ, '
        'person.id AS ownerId, person.namn AS ownerNamn, person.personnummer '
        'FROM vehicle '
        'INNER JOIN person ON vehicle.ownerId = person.id',
      );

      for (final row in results.rows) {
        // 🛠 Konvertera id och ownerId till INT
        int vehicleId = int.tryParse(row.colByName('id').toString()) ?? 0;
        int ownerId = int.tryParse(row.colByName('ownerId').toString()) ?? 0;

        Map<String, dynamic> rowMap = {
          'id': vehicleId,
          'registreringsnummer': row.colByName('registreringsnummer'),
          'typ': row.colByName('typ'),
          'ownerId': ownerId, // 🔥 Se till att ownerId är int
          'owner': {
            'id': ownerId,
            'namn': row.colByName('ownerNamn'),
            'personnummer': row.colByName('personnummer'),
          }
        };

        // 🛠 Debug: Skriver ut exakt hur varje rad ser ut innan konvertering
        print("DEBUG: Skapar Vehicle från DatabaseRow: $rowMap");

        vehicles.add(Vehicle.fromDatabaseRow(rowMap));
      }
    } catch (e) {
      print('Fel: Kunde inte hämta fordon → $e');
      return [];
    } finally {
      await conn.close();
    }
    return vehicles;
  }

  /// **Hämtar ett fordon baserat på ID**
  @override
  Future<Vehicle?> getById(int id) async {
    var conn = await Database.getConnection();
    try {
      var results = await conn.execute(
        'SELECT vehicle.id, vehicle.registreringsnummer, vehicle.typ, '
        'person.id AS ownerId, person.namn AS ownerNamn, person.personnummer '
        'FROM vehicle '
        'INNER JOIN person ON vehicle.ownerId = person.id '
        'WHERE vehicle.id = :id',
        {'id': id},
      );

      if (results.rows.isNotEmpty) {
        var row = results.rows.first;
        return Vehicle.fromDatabaseRow({
          'id': row.colByName('id'),
          'registreringsnummer': row.colByName('registreringsnummer'),
          'typ': row.colByName('typ'),
          'ownerId': row.colByName('ownerId'),
          'ownerNamn': row.colByName('ownerNamn'),
          'personnummer': row.colByName('personnummer'),
        });
      }
      return null;
    } catch (e) {
      print('Fel: Kunde inte hämta fordon med ID $id → $e');
      return Future.error('Misslyckades med att hämta fordon.');
    } finally {
      await conn.close();
    }
  }

  /// **Uppdaterar ett fordon i databasen**
  @override
  Future<Vehicle> update(int id, Vehicle vehicle) async {
    var conn = await Database.getConnection();
    try {
      await conn.execute(
        'UPDATE vehicle SET registreringsnummer = :registreringsnummer, '
        'typ = :typ, ownerId = :ownerId WHERE id = :id',
        vehicle.toDatabaseRow()..addAll({'id': id}),
      );

      return await getById(id) ??
          (throw Exception("Fordon ej hittat efter uppdatering"));
    } catch (e) {
      print('Fel: Kunde inte uppdatera fordon → $e');
      throw Exception('Kunde inte uppdatera fordon.');
    } finally {
      await conn.close();
    }
  }

  /// **Tar bort ett fordon från databasen**

  @override
  Future<Vehicle> delete(int id) async {
    var conn = await Database.getConnection();
    try {
      print("DEBUG: Försöker radera fordon med ID: $id...");

      // Kontrollera om fordonet finns innan radering
      var result = await conn.execute(
        'SELECT id FROM vehicle WHERE id = :id',
        {'id': id},
      );

      if (result.rows.isEmpty) {
        print("ERROR: Fordonet med ID $id hittades inte.");
        throw Exception('Inget fordon hittades med ID: $id');
      }

      // Radera fordonet
      await conn.execute(
        'DELETE FROM vehicle WHERE id = :id',
        {'id': id},
      );

      print("Fordon med ID: $id har raderats.");

      // Returnera ett tomt Vehicle-objekt med endast ID
      return Vehicle(
        id: id,
        registreringsnummer: '',
        typ: '',
        owner: Person(id: 0, namn: '', personnummer: ''),
      );
    } catch (e) {
      print('Fel: Kunde inte radera fordon → $e');
      throw Exception('Kunde inte radera fordon.');
    } finally {
      await conn.close();
    }
  }
}
