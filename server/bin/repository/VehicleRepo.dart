import 'package:shared/src/model/Vehicle.dart';
import 'package:shared/src/model/Person.dart';
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
    // Infoga fordon i databasen
    await conn.execute(
      'INSERT INTO vehicle (registreringsnummer, typ, ownerId) VALUES (:registreringsnummer, :typ, :ownerId)',
      {
        'registreringsnummer': vehicle.registreringsnummer,
        'typ': vehicle.typ,
        'ownerId': vehicle.owner.id,
      },
    );

    // Hämta det nya fordonets ID
    var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
    int newId = int.parse(result.rows.first.colByName('id')!);

    // Hämta ägarens fullständiga information
    var ownerResult = await conn.execute(
      'SELECT id, namn, personnummer FROM person WHERE id = :ownerId',
      {'ownerId': vehicle.owner.id},
    );

    if (ownerResult.rows.isEmpty) {
      throw Exception('Ägare med ID ${vehicle.owner.id} hittades inte.');
    }

    var ownerRow = ownerResult.rows.first;
    Person owner = Person(
      id: int.parse(ownerRow.colByName('id')!),
      namn: ownerRow.colByName('namn') ?? 'Okänd',
      personnummer: ownerRow.colByName('personnummer')!,
    );

    // Skapa det nya fordonet med ägarens fullständiga info
    var newVehicle = Vehicle(
      id: newId,
      registreringsnummer: vehicle.registreringsnummer,
      typ: vehicle.typ,
      owner: owner,
    );

    print(
        'Fordon tillagt: ID ${newVehicle.id}, Registreringsnummer: ${newVehicle.registreringsnummer}, Typ: ${newVehicle.typ}, Ägare: ${newVehicle.owner.namn}');

    return newVehicle;
  } catch (e) {
    print('Fel: Kunde inte lägga till fordon. $e');
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
        'SELECT vehicle.id, vehicle.registreringsnummer, vehicle.typ, '
        'person.id AS ownerId, person.namn AS ownerNamn, person.personnummer '
        'FROM vehicle '
        'INNER JOIN person ON vehicle.ownerId = person.id',
      );

      for (final row in results.rows) {
        var vehicle = Vehicle(
          id: int.parse(row.colByName('id')!),
          registreringsnummer: row.colByName('registreringsnummer')!,
          typ: row.colByName('typ')!,
          owner: Person(
            id: int.parse(row.colByName('ownerId')!),
            namn: row.colByName('ownerNamn') ?? 'Okänd',
            personnummer: row.colByName('personnummer')!,
          ),
        );
        vehicles.add(vehicle);

        print(
            'Hämtat fordon: ID ${vehicle.id}, Registreringsnummer: ${vehicle.registreringsnummer}, Typ: ${vehicle.typ}, Ägare: ${vehicle.owner.namn}');
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
        'SELECT vehicle.id, vehicle.registreringsnummer, vehicle.typ, '
        'person.id AS ownerId, person.namn AS ownerNamn, person.personnummer '
        'FROM vehicle '
        'INNER JOIN person ON vehicle.ownerId = person.id '
        'WHERE vehicle.id = :id',
        {'id': id},
      );

      if (results.rows.isNotEmpty) {
        var row = results.rows.first;
        var vehicle = Vehicle(
          id: int.parse(row.colByName('id')!),
          registreringsnummer: row.colByName('registreringsnummer')!,
          typ: row.colByName('typ')!,
          owner: Person(
            id: int.parse(row.colByName('ownerId')!),
            namn: row.colByName('ownerNamn') ?? 'Okänd',
            personnummer: row.colByName('personnummer')!,
          ),
        );

        print(
            'Hämtat fordon: ID ${vehicle.id}, Registreringsnummer: ${vehicle.registreringsnummer}, Typ: ${vehicle.typ}, Ägare: ${vehicle.owner.namn}');

        return vehicle;
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
        'typ = :typ, ownerId = :ownerId WHERE id = :id', // Ändrad owner_id -> ownerId
        {
          'registreringsnummer': vehicle.registreringsnummer,
          'typ': vehicle.typ,
          'ownerId': vehicle.owner.id, // Ändrad owner_id -> ownerId
          'id': id,
        },
      );

      var result = await conn.execute(
        'SELECT vehicle.id, vehicle.registreringsnummer, vehicle.typ, '
        'person.id AS owner_id, person.namn, person.personnummer '
        'FROM vehicle '
        'INNER JOIN person ON vehicle.owner_id = person.id '
        'WHERE vehicle.id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception("Inget fordon hittades med ID $id.");
      }

      var row = result.rows.first;
      var updatedVehicle = Vehicle(
        id: int.parse(row.colByName('id')!),
        registreringsnummer: row.colByName('registreringsnummer')!,
        typ: row.colByName('typ')!,
        owner: Person(
          id: int.parse(row.colByName('owner_id')!),
          namn: row.colByName('namn')!,
          personnummer: row.colByName('personnummer')!,
        ),
      );

      print(
          'Uppdaterat fordon: ID ${updatedVehicle.id}, Registreringsnummer: ${updatedVehicle.registreringsnummer}, Typ: ${updatedVehicle.typ}, Ägare: ${updatedVehicle.owner.namn}');

      return updatedVehicle;
    } catch (e) {
      print('Fel: Kunde inte uppdatera fordon. $e');
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
      var result = await conn.execute(
        'SELECT vehicle.id, vehicle.registreringsnummer, vehicle.typ, '
        'person.id AS owner_id, person.namn, person.personnummer '
        'FROM vehicle '
        'INNER JOIN person ON vehicle.owner_id = person.id '
        'WHERE vehicle.id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception('Inget fordon hittades med ID: $id');
      }

      var row = result.rows.first;
      var deletedVehicle = Vehicle(
        id: int.parse(row.colByName('id')!),
        registreringsnummer: row.colByName('registreringsnummer')!,
        typ: row.colByName('typ')!,
        owner: Person(
          id: int.parse(row.colByName('owner_id')!),
          namn: row.colByName('namn')!,
          personnummer: row.colByName('personnummer')!,
        ),
      );

      await conn.execute(
        'DELETE FROM vehicle WHERE id = :id',
        {'id': id},
      );

      print(
          'Fordon raderat: ID ${deletedVehicle.id}, Registreringsnummer: ${deletedVehicle.registreringsnummer}, Typ: ${deletedVehicle.typ}, Ägare: ${deletedVehicle.owner.namn}');

      return deletedVehicle;
    } catch (e) {
      print('Fel: Kunde inte radera fordon. $e');
      throw Exception('Kunde inte radera fordon.');
    } finally {
      await conn.close();
    }
  }
}
