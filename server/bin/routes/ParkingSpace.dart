import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repository/ParkingSpaceRepo.dart';
import 'package:shared/src/model/ParkingSpace.dart';

class ParkingSpaceRoutes {
  final ParkingSpaceRepo parkingSpaceRepo = ParkingSpaceRepo.instance;

  Router get router {
    final router = Router();

    // Hämta alla parkeringsplatser
    router.get('/parkingspaces', (Request req) async {
      final parkingSpaces = await parkingSpaceRepo.getAll();
      final jsonResponse =
          jsonEncode(parkingSpaces.map((p) => p.toJson()).toList());
      return Response.ok(jsonResponse,
          headers: {'Content-Type': 'application/json'});
    });

    // Hämta en specifik parkeringsplats
    router.get('/parkingspaces/<spaceId>', (Request req, String spaceId) async {
      try {
        final parkingSpace = await parkingSpaceRepo.getById(int.parse(spaceId));
        return parkingSpace != null
            ? Response.ok(jsonEncode(parkingSpace.toJson()),
                headers: {'Content-Type': 'application/json'})
            : Response.notFound(
                jsonEncode({'error': 'Parkeringsplats hittades inte'}),
                headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Ogiltigt ID-format'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // Skapa en ny parkeringsplats
    router.post('/parkingspaces', (Request req) async {
      try {
        final body = await req.readAsString();
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        final newParkingSpace = ParkingSpace.fromJson(jsonMap);

        final createdParkingSpace =
            await parkingSpaceRepo.create(newParkingSpace);
        return Response.ok(jsonEncode(createdParkingSpace.toJson()),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Ogiltigt JSON-format'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // Uppdatera en parkeringsplats
    router.put('/parkingspaces/<spaceId>', (Request req, String spaceId) async {
      try {
        final body = await req.readAsString();
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        final updatedParkingSpace = ParkingSpace.fromJson(jsonMap);

        final result = await parkingSpaceRepo.update(
            int.parse(spaceId), updatedParkingSpace);
        return Response.ok(jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Kunde inte uppdatera parkeringsplats'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // Ta bort en parkeringsplats
    router.delete('/parkingspaces/<spaceId>',
        (Request req, String spaceId) async {
      try {
        final result = await parkingSpaceRepo.delete(int.parse(spaceId));
        return Response.ok(jsonEncode({'message': 'Parkeringsplats raderad'}),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Kunde inte radera parkeringsplats'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    return router;
  }
}
