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
      print(
          "Inserting Person: Namn='${person.namn}', Personnummer='${person.personnummer}'");

      if (person.namn.trim().isEmpty || person.personnummer.trim().isEmpty) {
        throw Exception("Namn eller personnummer är tomt.");
      }

      await conn.execute(
        'INSERT INTO person (namn, personnummer) VALUES (:namn, :personnummer)',
        {
          'namn': person.namn,
          'personnummer': person.personnummer,
        },
      );

      var result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
      int newId = int.parse(result.rows.first.colByName('id')!);

      print(
          "Person skapad: ID=$newId, Namn=${person.namn}, Personnummer=${person.personnummer}");

      return Person(
          id: newId, namn: person.namn, personnummer: person.personnummer);
    } catch (e) {
      print('Fel: Kunde inte skapa person → $e');
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
        persons.add(Person.fromDatabaseRow({
          'id': row.colByName('id'),
          'namn': row.colByName('namn'),
          'personnummer': row.colByName('personnummer'),
        }));

        print(
            'Hämtad person: ID ${persons.last.id}, Namn: ${persons.last.namn}, Personnummer: ${persons.last.personnummer}');
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
        var person = Person.fromDatabaseRow({
          'id': results.rows.first.colByName('id'),
          'namn': results.rows.first.colByName('namn'),
          'personnummer': results.rows.first.colByName('personnummer'),
        });

        print(
            'Hämtad person: ID ${person.id}, Namn: ${person.namn}, Personnummer: ${person.personnummer}');
        return person;
      }
      return null;
    } catch (e) {
      print('Fel: Kunde inte hämta person med ID $id → $e');
      return Future.error('Misslyckades med att hämta person.');
    } finally {
      await conn.close();
    }
  }

  /// **Uppdaterar en befintlig person i databasen och returnerar det uppdaterade objektet.**
  @override
  Future<Person> update(int id, Person person) async {
    var conn = await Database.getConnection();
    try {
      print(
          "Updating person -> ID: $id, Namn: '${person.namn}', Personnummer: '${person.personnummer}'");

      await conn.execute(
        'UPDATE person SET namn = :namn, personnummer = :personnummer WHERE id = :id',
        person.toDatabaseRow()..['id'] = id, // Add ID to the update map
      );

      return await getById(id) ??
          (throw Exception("Person kunde inte uppdateras."));
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
      var personToDelete = await getById(id);
      if (personToDelete == null) {
        throw Exception('Ingen person hittades med ID: $id');
      }

      await conn.execute('DELETE FROM person WHERE id = :id', {'id': id});

      print(
          'Person raderad: ID $id, Namn: ${personToDelete.namn}, Personnummer: ${personToDelete.personnummer}');
      return personToDelete;
    } catch (e) {
      print('Fel: Kunde inte radera person → $e');
      throw Exception('Kunde inte radera person.');
    } finally {
      await conn.close();
    }
  }

  Future<Person> findByName(String name) async {
    var conn = await Database.getConnection();
    try {
      if (name == null) {
        // This check is redundant in null-safe Dart. You might want to remove it or handle it differently.
        throw Exception('Ingen person hittades med namnet: $name');
      }
      var results = await conn
          .execute('SELECT * FROM person WHERE namn = :namn', {'namn': name});

      if (results.rows.isNotEmpty) {
        var person = Person.fromDatabaseRow({
          'id': results.rows.first.colByName('id'),
          'namn': results.rows.first.colByName('namn'),
          'personnummer': results.rows.first.colByName('personnummer'),
        });

        print(
            'Hämtad person: ID ${person.id}, Namn: ${person.namn}, Personnummer: ${person.personnummer}');
        return person;
      }
      throw Exception('Ingen person hittades med namnet: $name');
    } catch (e) {
      print('Fel: Kunde inte hämta person med namnet $name → $e');
      return Future.error('Misslyckades med att hämta person.');
    } finally {
      await conn.close();
    }
  }
}
