import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repository/ParkingRepo.dart';
import 'package:shared/src/model/Parking.dart';

class ParkingRoutes {
  final ParkingRepo parkingRepo = ParkingRepo.instance;

  Router get router {
    final router = Router();

    // Hämta alla parkeringar
router.get('/', (Request req) async {
  try {
    final parkings = await parkingRepo.getAll();
    final jsonResponse = jsonEncode(parkings.map((p) => p.toJson()).toList());
    return Response.ok(jsonResponse, headers: {'Content-Type': 'application/json'});
  } catch (e) {
    // Logga felet för felsökning
    print('Fel vid hämtning av parkeringar: $e');

    // Returnera ett 500-intern serverfel med ett användarvänligt meddelande
    return Response.internalServerError(
      body: jsonEncode({
        'error': 'Ett fel inträffade vid hämtning av parkeringar.',
        'details': e.toString(), // Detta kan vara användbart för utvecklare men bör tas bort i produktion
      }),
      headers: {'Content-Type': 'application/json'}
    );
  }
});


    // Hämta en specifik parkering
    router.get('/<parkingId>', (Request req, String parkingId) async {
      try {
        final parking = await parkingRepo.getById(int.parse(parkingId));
        return parking != null
            ? Response.ok(jsonEncode(parking.toJson()),
                headers: {'Content-Type': 'application/json'})
            : Response.notFound(
                jsonEncode({'error': 'Parkering hittades inte'}),
                headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Ogiltigt ID-format'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // **Skapa en ny parkering (ID genereras automatiskt)**
    router.post('/', (Request req) async {
      try {
        final body = await req.readAsString();
        final jsonData = jsonDecode(body) as Map<String, dynamic>;

        // **Ta bort 'id' från JSON-data om den finns**
        jsonData.remove('id');

        final newParking = Parking.fromJson(jsonData);
        final createdParking = await parkingRepo.create(newParking);

        return Response.ok(jsonEncode(createdParking.toJson()));
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': '$e'}));
      }
    });

    // Uppdatera en parkering
    router.put('/<parkingId>', (Request req, String parkingId) async {
      try {
        final body = await req.readAsString();
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        final updatedParking = Parking.fromJson(jsonMap);

        final result =
            await parkingRepo.update(int.parse(parkingId), updatedParking);
        return Response.ok(jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Kunde inte uppdatera parkering'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // Ta bort en parkering
    router.delete('/<parkingId>', (Request req, String parkingId) async {
      try {
        final result = await parkingRepo.delete(int.parse(parkingId));
        return Response.ok(jsonEncode({'message': 'Parkering raderad'}),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Kunde inte radera parkering'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    return router;
  }
}
