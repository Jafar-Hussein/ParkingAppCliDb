import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repository/VehicleRepo.dart';
import 'package:shared/src/model/Vehicle.dart';

class VehicleRoutes {
  final VehicleRepo vehicleRepo = VehicleRepo.instance;

  Router get router {
    final router = Router();

    // Hämta alla fordon
    router.get('/vehicles', (Request req) async {
      final vehicles = await vehicleRepo.getAll();
      final jsonResponse = jsonEncode(vehicles
          .map((v) => v.toJson())
          .toList()); // Konvertera lista till JSON
      return Response.ok(jsonResponse,
          headers: {'Content-Type': 'application/json'});
    });

    // Hämta ett fordon via ID
    router.get('/vehicles/<vehicleId>', (Request req, String vehicleId) async {
      try {
        final vehicle = await vehicleRepo.getById(int.parse(vehicleId));
        return vehicle != null
            ? Response.ok(jsonEncode(vehicle.toJson()),
                headers: {'Content-Type': 'application/json'})
            : Response.notFound(jsonEncode({'error': 'Fordon hittades inte'}),
                headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Ogiltigt ID-format'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // Skapa ett nytt fordon
    router.post('/vehicles', (Request req) async {
      try {
        final body = await req.readAsString();
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        final newVehicle = Vehicle.fromJson(jsonMap); // Använd fromJson-metoden

        final createdVehicle = await vehicleRepo.create(newVehicle);
        return Response.ok(jsonEncode(createdVehicle.toJson()),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Ogiltigt JSON-format'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // Uppdatera ett fordon via ID
    router.put('/vehicles/<vehicleId>', (Request req, String vehicleId) async {
      try {
        final body = await req.readAsString();
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        final updatedVehicle = Vehicle.fromJson(jsonMap);

        final result =
            await vehicleRepo.update(int.parse(vehicleId), updatedVehicle);
        return Response.ok(jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Kunde inte uppdatera fordon'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // Ta bort ett fordon via ID
    router.delete('/vehicles/<vehicleId>',
        (Request req, String vehicleId) async {
      try {
        final result = await vehicleRepo.delete(int.parse(vehicleId));
        return Response.ok(jsonEncode({'message': 'Fordon raderat'}),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Kunde inte radera fordon'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    return router;
  }
}
