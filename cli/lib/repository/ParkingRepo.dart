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

    // ✅ Rätt JSON-struktur – skickar hela vehicle- och parkingSpace-objekten
    Map<String, dynamic> parkingJson = {
      "vehicle": parking.vehicle.toJson(), // 🔥 Skicka hela objektet!
      "parkingSpace": parking.parkingSpace.toJson(),
      "startTime": parking.startTime.toIso8601String(),
      "endTime": parking.endTime?.toIso8601String(),
      "price": parking.price,
    };

    print(parkingJson);

    Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parkingJson),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create parking: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return Parking.fromJson(json);
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

    // Kontrollera att API-svaret är en lista
    if (json is! List) {
      throw Exception("API-svar är inte en lista: $json");
    }

    return json.map((item) => Parking.fromJson(item)).toList();
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

    // 🔍 Debug: Skriver ut JSON som skickas till backend
    Map<String, dynamic> jsonBody = parking.toJson();

    try {
      Response response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonBody), // 🔥 Använd `toJson()` istället!
      );

      // 🔍 Debug: Logga svaret från backend
      print("DEBUG: Response Status Code → ${response.statusCode}");
      print("DEBUG: Response Body → ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Parking.fromJson(
            json); //Ändrat från `fromDatabaseRow()` till `fromJson()`
      } else {
        print("Fel vid uppdatering! Status Code: ${response.statusCode}");
        throw Exception("Failed to update parking: ${response.body}");
      }
    } catch (e, stacktrace) {
      print("Exception vid PUT-uppdatering: $e");
      print(stacktrace);
      throw Exception("Kunde inte uppdatera parkering: $e");
    }
  }

  /// **Delete a parking**
  @override
  Future<Parking> delete(int id) async {
    final uri = Uri.parse("$baseUrl/$id");

    // ✅ Först hämta parkeringen innan vi tar bort den
    Parking? parkingToDelete = await getById(id);
    if (parkingToDelete == null) {
      throw Exception("Parkering med ID $id hittades inte.");
    }

    Response response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("Parkering med ID $id raderades framgångsrikt!");
      return parkingToDelete; // 🔥 Returnera den raderade parkeringen!
    } else {
      throw Exception("Misslyckades att ta bort parkering: ${response.body}");
    }
  }
}
