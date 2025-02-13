import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:shared/src/model/Person.dart';
import 'package:shared/src/repository/Repository.dart';

class PersonRepo implements Repository<Person> {
  static final PersonRepo _instance = PersonRepo._internal();
  PersonRepo._internal();
  static PersonRepo get instance => _instance;

  // Lägg till en person asynkront
  @override
  Future<Person> create(Person person) async {
    final uri = Uri.parse("http://localhost:8080/person");

    Response response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(person.toJson()));

    final json = jsonDecode(response.body);

    return Person.fromJson(json);
  }

  // Hämta alla personer asynkront
  @override
  Future<List<Person>> getAll() async {
    final uri = Uri.parse("http://localhost:8080/parkingSpaces");
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte hämta parkerings platser');
    }
    final json = jsonDecode(response.body);

    return (json as List).map((bag) => Person.fromJson(bag)).toList();
  }

  // Hämta en person baserat på ID asynkront
  @override
  Future<Person?> getById(int id) async {
    final uri = Uri.parse("http://localhost:8080/person/${id}");

    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte hämta parkering plats');
    }
    final json = jsonDecode(response.body);

    return Person.fromJson(json);
  }

  // Uppdatera en person asynkront
  @override
  Future<Person> update(int id, Person person) async {
    // send bag serialized as json over http to server at localhost:8080
    final uri = Uri.parse("http://localhost:8080/person/${id}");

    Response response = await http.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(person.toJson()));

    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte uppdatera parkering plats');
    }
    final json = jsonDecode(response.body);

    return Person.fromJson(json);
  }

  // Ta bort en person asynkront
  @override
  Future<Person> delete(int id) async {
    final uri = Uri.parse("http://localhost:8080/person/${id}");

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte ta bort parkering plats');
    }
    final json = jsonDecode(response.body);

    return Person.fromJson(json);
  }
}
