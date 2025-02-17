import 'dart:convert';
import 'package:shared/src/model/Person.dart';
import 'package:shared/src/repository/Repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class PersonRepo implements Repository<Person> {
  static final PersonRepo _instance = PersonRepo._internal();
  PersonRepo._internal();
  static PersonRepo get instance => _instance;

  final String baseUrl = "http://localhost:8081/persons";

  /// **Create a new Person**
  @override
  Future<Person> create(Person person) async {
    final uri = Uri.parse(baseUrl);

    Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toDatabaseRow()), // Ensure correct structure
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create Person: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return Person.fromDatabaseRow(json);
  }

  /// **Get all Persons**
  @override
  Future<List<Person>> getAll() async {
    final uri = Uri.parse(baseUrl);
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch Persons: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return (json as List).map((item) => Person.fromDatabaseRow(item)).toList();
  }

  /// **Get a Person by ID**
  @override
  Future<Person?> getById(int id) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null; // No Person found
    } else if (response.statusCode != 200) {
      throw Exception("Failed to fetch Person: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return Person.fromDatabaseRow(json);
  }

  /// **Update a Person**
  @override
  Future<Person> update(int id, Person person) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toDatabaseRow()), // Ensure correct format
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update Person: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return Person.fromDatabaseRow(json);
  }

  /// **Delete a Person**

  @override
  Future<Person> delete(int id) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete Person: ${response.body}");
    }

    // Hämta endast "person"-objektet från svaret
    final json = jsonDecode(response.body);
    if (json.containsKey("person")) {
      return Person.fromDatabaseRow(json["person"]);
    } else {
      throw Exception("Invalid response: ${response.body}");
    }
  }
}
