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
    router.get('/', (Request req) async {
      try {
        final parkingSpaces = await parkingSpaceRepo.getAll();
        final jsonResponse =
            jsonEncode(parkingSpaces.map((p) => p.toJson()).toList());
        return Response.ok(jsonResponse,
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        // Logga felet för felsökning
        print('Fel vid hämtning av parkeringsplatser: $e');

        // Returnera ett 500-intern serverfel med ett användarvänligt meddelande
        return Response.internalServerError(
            body: jsonEncode({
              'error': 'Ett fel inträffade vid hämtning av parkeringsplatser.',
              'details': e
                  .toString(), // Detta kan vara användbart för utvecklare men bör tas bort i produktion
            }),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // Hämta en specifik parkeringsplats
    router.get('/<spaceId>', (Request req, String spaceId) async {
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

    // **Skapa en ny parkeringsplats (ID genereras automatiskt)**
    router.post('/', (Request req) async {
      try {
        final body = await req.readAsString();
        final jsonData = jsonDecode(body) as Map<String, dynamic>;

        // **Ta bort 'id' från JSON-data om den finns**
        jsonData.remove('id');

        final newParkingSpace = ParkingSpace.fromJson(jsonData);
        final createdParkingSpace =
            await parkingSpaceRepo.create(newParkingSpace);

        return Response.ok(jsonEncode(createdParkingSpace.toJson()));
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': '$e'}));
      }
    });

    // Uppdatera en parkeringsplats
    router.put('/<spaceId>', (Request req, String spaceId) async {
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
    router.delete('/<spaceId>', (Request req, String spaceId) async {
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
