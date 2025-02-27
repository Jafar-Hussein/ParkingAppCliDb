import 'dart:convert';
import 'package:shared/src/model/Vehicle.dart';
import 'package:shared/src/model/Person.dart';
import 'package:shared/src/repository/Repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class VehicleRepo implements Repository<Vehicle> {
  static final VehicleRepo _instance = VehicleRepo._internal();
  VehicleRepo._internal();
  static VehicleRepo get instance => _instance;

  final String baseUrl = "http://localhost:8081/vehicles";

  /// **Create a new Vehicle**
  Future<Vehicle> create(Vehicle vehicle) async {
    final uri = Uri.parse(baseUrl);

    // Skicka endast nödvändig data (utan id, eftersom databasen genererar det)
    Map<String, dynamic> vehicleJson = {
      "registreringsnummer": vehicle.registreringsnummer,
      "typ": vehicle.typ,
      "ownerId": vehicle.owner.id, // ownerId måste vara en INT
    };

    print("Skickar fordon till API: ${jsonEncode(vehicleJson)}");

    Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vehicleJson),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create Vehicle: ${response.body}");
    }

    final json = jsonDecode(response.body);

    // Kontrollera att backend returnerar ett giltigt ID
    if (!json.containsKey('id') || json['id'] == null) {
      throw Exception(
          "Fel: Backend returnerade inget giltigt ID för fordonet.");
    }

    return Vehicle.fromJson(json);
  }

  /// **Get all Vehicles**
  @override
  Future<List<Vehicle>> getAll() async {
    final uri = Uri.parse(baseUrl);
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch Vehicles: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return (json as List).map((item) => Vehicle.fromDatabaseRow(item)).toList();
  }

  /// **Get a Vehicle by ID**
  @override
  Future<Vehicle?> getById(int id) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null; // No vehicle found
    } else if (response.statusCode != 200) {
      throw Exception("Failed to fetch Vehicle: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return Vehicle.fromDatabaseRow(json);
  }

  /// **Update a Vehicle**
  @override
  Future<Vehicle> update(int id, Vehicle vehicle) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "id": vehicle.id,
        "registreringsnummer": vehicle.registreringsnummer,
        "typ": vehicle.typ,
        "ownerId": vehicle.owner.id, // ✅ ownerId måste vara en INT
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update Vehicle: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return Vehicle.fromDatabaseRow(json);
  }

  /// **Delete a Vehicle**
  @override
  Future<Vehicle> delete(int id) async {
    final uri = Uri.parse("$baseUrl/$id");

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    // Om API:et svarar med status 200 (OK), tolka svaret korrekt
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      // 🛠 Om svaret har ett giltigt fordon, returnera det
      if (json.containsKey('id')) {
        return Vehicle.fromDatabaseRow(json);
      } else {
        // Om API:et svarar konstigt, returnera ett tomt fordon
        return Vehicle(
            id: id,
            registreringsnummer: '',
            typ: '',
            owner: Person(id: 0, namn: '', personnummer: ''));
      }
    }

    // Om API:et returnerar ett fel, kasta en Exception
    throw Exception("Failed to delete Vehicle: ${response.body}");
  }
}
