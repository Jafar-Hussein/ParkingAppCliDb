import 'dart:convert';

import 'package:shared/src/model/Parking.dart';
import 'package:shared/src/repository/Repository.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ParkingRepo implements Repository<Parking> {
  static final ParkingRepo _instance = ParkingRepo._internal();
  ParkingRepo._internal();
  static ParkingRepo get instance => _instance;

  // Asynkron metod för att lägga till parkering
  @override
  Future<Parking> create(Parking parking) async {
    // send bag serialized as json over http to server at localhost:8080
    final uri = Uri.parse("http://localhost:8080/parking");

    Response response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parking.toJson()));

    final json = jsonDecode(response.body);

    return Parking.fromJson(json);
  }

  // Hämtar alla parkeringar asynkront
  Future<List<Parking>> getAll() async {
    final uri = Uri.parse("http://localhost:8080/parkings");
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);

    return (json as List).map((bag) => Parking.fromJson(bag)).toList();
  }

  // Hämtar en specifik parkering baserat på ID
  @override
  Future<Parking?> getById(int id) async {
    final uri = Uri.parse("http://localhost:8080/parkings/${id}");

    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);

    return Parking.fromJson(json);
  }

  // Uppdaterar en parkering asynkront
  @override
  Future<Parking> update(int id, Parking parking) async {
    // send bag serialized as json over http to server at localhost:8080
    final uri = Uri.parse("http://localhost:8080/Parkings/${id}");

    Response response = await http.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parking.toJson()));

    final json = jsonDecode(response.body);

    return Parking.fromJson(json);
  }

  // Tar bort en parkering asynkront
  @override
  Future<Parking> delete(int id) async {
   final uri = Uri.parse("http://localhost:8080/parkings/${id}");

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);

    return Parking.fromJson(json);
  }
}
