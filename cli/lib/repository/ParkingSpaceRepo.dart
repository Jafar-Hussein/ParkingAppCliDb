import 'dart:convert';
import 'package:shared/src/model/ParkingSpace.dart';
import 'package:shared/src/repository/Repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ParkingSpaceRepo implements Repository<ParkingSpace> {
  static final ParkingSpaceRepo _instance = ParkingSpaceRepo._internal();
  ParkingSpaceRepo._internal();
  static ParkingSpaceRepo get instance => _instance;

  final String baseUrl = "http://localhost:8081/parkingspaces";

  /// **Create a new ParkingSpace**
  @override
  Future<ParkingSpace> create(ParkingSpace parkingSpace) async {
    final uri = Uri.parse(baseUrl);

    Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body:
          jsonEncode(parkingSpace.toDatabaseRow()), // Ensure correct structure
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create ParkingSpace: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return ParkingSpace.fromDatabaseRow(json);
  }

  /// **Get all ParkingSpaces**
  @override
  Future<List<ParkingSpace>> getAll() async {
    final uri = Uri.parse(baseUrl);
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch ParkingSpaces: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return (json as List)
        .map((item) => ParkingSpace.fromDatabaseRow(item))
        .toList();
  }

  /// **Get a ParkingSpace by ID**
  @override
  Future<ParkingSpace?> getById(int id) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null; // No ParkingSpace found
    } else if (response.statusCode != 200) {
      throw Exception("Failed to fetch ParkingSpace: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return ParkingSpace.fromDatabaseRow(json);
  }

  /// **Update a ParkingSpace**
  @override
  Future<ParkingSpace> update(int id, ParkingSpace parkingSpace) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parkingSpace.toDatabaseRow()), // Ensure correct format
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update ParkingSpace: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return ParkingSpace.fromDatabaseRow(json);
  }

  /// **Delete a ParkingSpace**
  @override
  Future<ParkingSpace> delete(int id) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete ParkingSpace: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return ParkingSpace.fromDatabaseRow(json);
  }
}
