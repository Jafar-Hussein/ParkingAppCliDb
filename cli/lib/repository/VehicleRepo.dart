import 'package:http/http.dart';
import 'dart:convert';
import 'package:shared/src/model/Vehicle.dart';
import 'package:shared/src/repository/Repository.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class VehicleRepo implements Repository<Vehicle> {
  static final VehicleRepo _instance = VehicleRepo._internal();
  VehicleRepo._internal();
  static VehicleRepo get instance => _instance;

  // Lägg till ett fordon asynkront
  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    // url
    final uri = Uri.parse("http://localhost:8080/vehicle");

    Response response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle.toJson()));

    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte skapa en fordon');
    }
    final json = jsonDecode(response.body);

    return Vehicle.fromJson(json);
  }

  // Hämta alla fordon asynkront
  @override
  Future<List<Vehicle>> getAll() async {
    final uri = Uri.parse("http://localhost:8080/vehicles");
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte hämta fordon');
    }
    final json = jsonDecode(response.body);

    return (json as List).map((bag) => Vehicle.fromJson(bag)).toList();
  }

  // Hämta ett fordon baserat på ID asynkront
  @override
  Future<Vehicle> getById(int id) async {
    final uri = Uri.parse("http://localhost:8080/vehicle/${id}");

    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte hämta fordon plats');
    }
    final json = jsonDecode(response.body);

    return Vehicle.fromJson(json);
  }

  // Uppdatera ett fordon asynkront
  @override
  Future<Vehicle> update(int id, Vehicle vehicle) async {
    // send bag serialized as json over http to server at localhost:8080
    final uri = Uri.parse("http://localhost:8080/vehicle/${id}");

    Response response = await http.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle.toJson()));

    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte uppdatera fordonet');
    }
    final json = jsonDecode(response.body);

    return Vehicle.fromJson(json);
  }

  // Ta bort ett fordon asynkront
  @override
  Future<Vehicle> delete(int id) async {
    final uri = Uri.parse("http://localhost:8080/vehicle/${id}");

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte ta bort Fordonet');
    }
    final json = jsonDecode(response.body);

    return Vehicle.fromJson(json);
  }
}
