import 'package:http/http.dart';
import 'dart:convert';
import 'package:shared/src/model/ParkingSpace.dart';
import 'package:shared/src/repository/Repository.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ParkingSpaceRepo implements Repository<ParkingSpace> {
  static final ParkingSpaceRepo _instance = ParkingSpaceRepo._internal();

  ParkingSpaceRepo._internal();

  static ParkingSpaceRepo get instance => _instance;

  @override
  Future<ParkingSpace> create(ParkingSpace parkingSpace) async {
    // url
    final uri = Uri.parse("http://localhost:8080/parkingSpace");

    Response response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parkingSpace.toJson()));

    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte skapa parkering plats');
    }
    final json = jsonDecode(response.body);

    return ParkingSpace.fromJson(json);
  }

  // Hämtar alla parkeringar asynkront
  @override
  Future<List<ParkingSpace>> getAll() async {
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

    return (json as List).map((bag) => ParkingSpace.fromJson(bag)).toList();
  }

  // Hämtar en specifik parkering baserat på ID
  @override
  Future<ParkingSpace> getById(int id) async {
    final uri = Uri.parse("http://localhost:8080/parkingSpace/${id}");

    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte hämta parkering plats');
    }
    final json = jsonDecode(response.body);

    return ParkingSpace.fromJson(json);
  }

  // Uppdaterar en parkering asynkront
  @override
  Future<ParkingSpace> update(int id, ParkingSpace parkingSpace) async {
    // send bag serialized as json over http to server at localhost:8080
    final uri = Uri.parse("http://localhost:8080/parkingSpace/${id}");

    Response response = await http.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parkingSpace.toJson()));

    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte uppdatera parkering plats');
    }
    final json = jsonDecode(response.body);

    return ParkingSpace.fromJson(json);
  }

  // Tar bort en parkering asynkront
  @override
  Future<ParkingSpace> delete(int id) async {
    final uri = Uri.parse("http://localhost:8080/parkingSpace/${id}");

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      int statusCode = response.statusCode;
      print('Error $statusCode: kunde inte ta bort parkering plats');
    }
    final json = jsonDecode(response.body);

    return ParkingSpace.fromJson(json);
  }
}
