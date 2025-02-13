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
      if (person.namn.isEmpty || person.personnummer.isEmpty) {
        throw Exception('Fel: Namn eller personnummer är tomt.');
      }

      // Lägg till personen i databasen
      await conn.execute(
        'INSERT INTO person (namn, personnummer) VALUES (:namn, :personnummer)',
        person.toJson(),
      );

      // Hämta det nya ID:t
      var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(result.rows.first.colByName('id')!);

      print('Person tillagd med ID: $newId');

      // Returnera den skapade personen
      return Person.fromJson({...person.toJson(), 'id': newId});
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
        persons.add(Person.fromJson({
          'id': int.parse(row.colByName('id')!),
          'namn': row.colByName('namn')!,
          'personnummer': row.colByName('personnummer')!,
        }));
      }
    } catch (e) {
      print('Fel: Kunde inte hämta personer. $e');
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
        return Person.fromJson({
          'id': int.parse(row.colByName('id')!),
          'namn': row.colByName('namn')!,
          'personnummer': row.colByName('personnummer')!,
        });
      }
      return null;
    } catch (e) {
      print('Fel: Kunde inte hämta person med ID $id. $e');
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
      await conn.execute(
        'UPDATE person SET namn = :namn, personnummer = :personnummer WHERE id = :id',
        person.toJson()..addAll({'id': id}),
      );

      // Hämta den uppdaterade personen
      var result = await conn.execute(
        'SELECT * FROM person WHERE id = :id',
        {'id': id},
      );

      if (result.numOfRows == 0) {
        throw Exception("Ingen person hittades med ID $id.");
      }

      return Person.fromJson({
        'id': int.parse(result.rows.first.colByName('id')!),
        'namn': result.rows.first.colByName('namn')!,
        'personnummer': result.rows.first.colByName('personnummer')!,
      });
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

      // Konvertera resultatet till en Person
      var deletedPerson = Person.fromJson({
        'id': int.parse(result.rows.first.colByName('id')!),
        'namn': result.rows.first.colByName('namn')!,
        'personnummer': result.rows.first.colByName('personnummer')!,
      });

      // Radera personen
      await conn.execute(
        'DELETE FROM person WHERE id = :id',
        {'id': id},
      );

      print('Person raderad: ID $id');
      return deletedPerson;
    } catch (e) {
      print('Fel: Kunde inte radera person → $e');
      throw Exception('Kunde inte radera person.');
    } finally {
      await conn.close();
    }
  }
}
