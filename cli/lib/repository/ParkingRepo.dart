import 'dart:convert';
import 'package:shared/src/model/Parking.dart';
import 'package:shared/src/repository/Repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ParkingRepo implements Repository<Parking> {
  static final ParkingRepo _instance = ParkingRepo._internal();
  ParkingRepo._internal();
  static ParkingRepo get instance => _instance;

  final String baseUrl = "http://localhost:8081/parkings";

  /// **Create a new Parking entry**
  @override
  Future<Parking> create(Parking parking) async {
    final uri = Uri.parse(baseUrl);

    Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toDatabaseRow()), // Ensure correct structure
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create parking: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return Parking.fromDatabaseRow(json);
  }

  /// **Get all parkings**
  Future<List<Parking>> getAll() async {
    final uri = Uri.parse(baseUrl);
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch parkings: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return (json as List).map((item) => Parking.fromDatabaseRow(item)).toList();
  }

  /// **Get a parking by ID**
  @override
  Future<Parking?> getById(int id) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null; // No parking found
    } else if (response.statusCode != 200) {
      throw Exception("Failed to fetch parking: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return Parking.fromDatabaseRow(json);
  }

  /// **Update a parking**
  @override
  Future<Parking> update(int id, Parking parking) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toDatabaseRow()), // Ensure correct format
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update parking: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return Parking.fromDatabaseRow(json);
  }

  /// **Delete a parking**
  @override
  Future<Parking> delete(int id) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete parking: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return Parking.fromDatabaseRow(json);
  }
}
