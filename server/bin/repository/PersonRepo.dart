import 'package:shared/src/model/Person.dart';
import 'package:shared/src/repository/Repository.dart';
import '../db/Database.dart';

class PersonRepo implements Repository<Person> {
  static final PersonRepo _instance = PersonRepo._internal();
  PersonRepo._internal();
  static PersonRepo get instance => _instance;

  /// **Lägger till en person i databasen och returnerar den skapade personen.**
  @override
  Future<Person> create(Person person) async {
    var conn = await Database.getConnection();
    try {
      // Kontrollera att namn och personnummer inte är tomma
      if (person.namn.trim().isEmpty || person.personnummer.trim().isEmpty) {
        throw Exception('Fel: Namn eller personnummer är tomt.');
      }

      // Lägg till personen i databasen
      await conn.execute(
        'INSERT INTO person (namn, personnummer) VALUES (:namn, :personnummer)',
        {
          'namn': person.namn,
          'personnummer': person.personnummer,
        },
      );

      // Hämta det nya ID:t
      var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(result.rows.first.colByName('id')!);

      print(
          'Person tillagd: ID $newId, Namn: ${person.namn}, Personnummer: ${person.personnummer}');

      // Returnera den skapade personen
      return Person(
          id: newId, namn: person.namn, personnummer: person.personnummer);
    } catch (e) {
      print('Fel: Kunde inte lägga till person → $e');
      throw Exception('Kunde inte skapa person.');
    } finally {
      await conn.close();
    }
  }

  /// **Hämtar alla personer från databasen och returnerar en lista av `Person`-objekt.**
  @override
  Future<List<Person>> getAll() async {
    var conn = await Database.getConnection();
    List<Person> persons = [];
    try {
      var results = await conn.execute('SELECT * FROM person');
      for (final row in results.rows) {
        String namn = row.colByName('namn') ?? '';
        String personnummer = row.colByName('personnummer') ?? '';
        int id = int.parse(row.colByName('id')!);

        print(
            'Hämtad person: ID $id, Namn: $namn, Personnummer: $personnummer');

        persons.add(Person(id: id, namn: namn, personnummer: personnummer));
      }
    } catch (e) {
      print('Fel: Kunde inte hämta personer → $e');
      return [];
    } finally {
      await conn.close();
    }
    return persons;
  }

  /// **Hämtar en person baserat på ID och returnerar ett `Person`-objekt.**
  @override
  Future<Person?> getById(int id) async {
    var conn = await Database.getConnection();
    try {
      var results = await conn.execute(
        'SELECT * FROM person WHERE id = :id',
        {'id': id},
      );

      if (results.rows.isNotEmpty) {
        var row = results.rows.first;
        String namn = row.colByName('namn') ?? '';
        String personnummer = row.colByName('personnummer') ?? '';

        print(
            'Hämtad person: ID $id, Namn: $namn, Personnummer: $personnummer');

        return Person(id: id, namn: namn, personnummer: personnummer);
      }
      return null;
    } catch (e) {
      print('Fel: Kunde inte hämta person med ID $id → $e');
      return Future.error('Misslyckades med att hämta person');
    } finally {
      await conn.close();
    }
  }

  /// **Uppdaterar en befintlig person i databasen och returnerar det uppdaterade objektet.**
  @override
  Future<Person> update(int id, Person person) async {
    var conn = await Database.getConnection();
    try {
      // Debug: Print received data
      print(
          "Received update request -> ID: $id, Namn: '${person.namn}', Personnummer: '${person.personnummer}'");

      // Perform update
      await conn.execute(
        'UPDATE person SET namn = :namn, personnummer = :personnummer WHERE id = :id',
        {
          'namn': person.namn,
          'personnummer': person.personnummer,
          'id': id,
        },
      );

      // Fetch the updated record
      var result = await conn.execute(
        'SELECT * FROM person WHERE id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception("Ingen person hittades med ID $id.");
      }

      var row = result.rows.first;
      String updatedNamn = row.colByName('namn') ?? '';
      String updatedPersonnummer = row.colByName('personnummer') ?? '';

      // Debug: Print database values after update
      print(
          "Updated in database -> ID: $id, Namn: '$updatedNamn', Personnummer: '$updatedPersonnummer'");

      return Person(
          id: id, namn: updatedNamn, personnummer: updatedPersonnummer);
    } catch (e) {
      print('Fel: Kunde inte uppdatera person → $e');
      throw Exception('Kunde inte uppdatera person.');
    } finally {
      await conn.close();
    }
  }

  /// **Tar bort en person från databasen baserat på ID och returnerar den raderade posten.**
  @override
  Future<Person> delete(int id) async {
    var conn = await Database.getConnection();
    try {
      // Hämta den existerande personen innan radering
      var result = await conn.execute(
        'SELECT * FROM person WHERE id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception('Ingen person hittades med ID: $id');
      }

      var row = result.rows.first;
      String deletedNamn = row.colByName('namn') ?? '';
      String deletedPersonnummer = row.colByName('personnummer') ?? '';

      // Radera personen
      await conn.execute(
        'DELETE FROM person WHERE id = :id',
        {'id': id},
      );

      print(
          'Person raderad: ID $id, Namn: $deletedNamn, Personnummer: $deletedPersonnummer');

      return Person(
          id: id, namn: deletedNamn, personnummer: deletedPersonnummer);
    } catch (e) {
      print('Fel: Kunde inte radera person → $e');
      throw Exception('Kunde inte radera person.');
    } finally {
      await conn.close();
    }
  }
}
