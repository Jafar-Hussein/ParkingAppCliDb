import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repository/PersonRepo.dart';
import 'package:shared/src/model/Person.dart';

class PersonRoutes {
  final PersonRepo personRepo = PersonRepo.instance;

  Router get router {
    final router = Router();

    // Hämta alla personer
    router.get('/', (Request req) async {
      try {
        final persons = await personRepo.getAll();
        return Response.ok(jsonEncode(persons),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        // Logga felet för felsökning
        print('Fel vid hämtning av personer: $e');

        // Returnera ett 500-intern serverfel med ett användarvänligt meddelande
        return Response.internalServerError(
            body: jsonEncode({
              'error': 'Ett fel inträffade vid hämtning av personer.',
              'details': e
                  .toString(), // Detta kan vara användbart för utvecklare men bör tas bort i produktion
            }),
            headers: {'Content-Type': 'application/json'});
      }
    });
    // Hämta person baserat på namn
    router.get('/namn/<namn>', (Request req, String namn) async {
      try {
        final person = await personRepo.findByName(namn);
        if (person != null) {
          return Response.ok(jsonEncode(person.toJson()),
              headers: {'Content-Type': 'application/json'});
        } else {
          return Response.notFound(jsonEncode({'error': 'Person not found'}));
        }
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Ett fel inträffade: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // Hämta en specifik person via ID
    router.get('/<id>', (Request req, String id) async {
      try {
        final person = await personRepo.getById(int.parse(id));
        if (person != null) {
          return Response.ok(jsonEncode(person.toJson()),
              headers: {'Content-Type': 'application/json'});
        } else {
          return Response.notFound(jsonEncode({'error': 'Person not found'}));
        }
      } catch (e) {
        // Logga felet för felsökning
        print('Fel vid hämtning av person med ID $id: $e');

        // Returnera ett 500-intern serverfel med ett användarvänligt meddelande
        return Response.internalServerError(
            body: jsonEncode({
              'error': 'Ett fel inträffade vid hämtning av personen.',
              'details': e
                  .toString(), // Detta kan vara användbart för utvecklare men bör tas bort i produktion
            }),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // Skapa en ny person
    router.post('/', (Request req) async {
      try {
        final body = await req.readAsString();
        print("Received JSON: $body"); // Debugging incoming JSON

        if (body.isEmpty) {
          print("Request body is empty.");
          return Response.badRequest(
              body: jsonEncode({'error': 'Request body is empty'}),
              headers: {'Content-Type': 'application/json'});
        }

        final Map<String, dynamic> jsonData = jsonDecode(body);

        // Debugging input keys
        print("Parsed JSON keys: ${jsonData.keys}");

        if (!jsonData.containsKey('namn') ||
            !jsonData.containsKey('personnummer')) {
          print("Missing required fields: 'namn' or 'personnummer'.");
          return Response.badRequest(
              body: jsonEncode(
                  {'error': 'Missing required fields: namn, personnummer'}),
              headers: {'Content-Type': 'application/json'});
        }

        final newPerson = Person.fromJson(jsonData);
        print(
            "Creating Person: Namn=${newPerson.namn}, Personnummer=${newPerson.personnummer}");

        final createdPerson = await personRepo.create(newPerson);

        print(
            "Person created: ID=${createdPerson.id}, Namn=${createdPerson.namn}, Personnummer=${createdPerson.personnummer}");

        return Response.ok(jsonEncode(createdPerson.toJson()),
            headers: {'Content-Type': 'application/json'});
      } catch (e, stackTrace) {
        print('Exception occurred: $e\n$stackTrace');
        return Response.internalServerError(
            body: jsonEncode({'error': 'Invalid input data: $e'}),
            headers: {'Content-Type': 'application/json'});
      }
    });

    // Uppdatera en person via ID
    router.put('/<id>', (Request req, String id) async {
      try {
        final body = await req.readAsString();
        final Map<String, dynamic> jsonData = jsonDecode(body);
        final updatedPerson = Person.fromJson(jsonData);

        final result = await personRepo.update(int.parse(id), updatedPerson);
        return Response.ok(jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Could not update person: $e'}));
      }
    });

    // Ta bort en person via ID
    router.delete('/<id>', (Request req, String id) async {
      try {
        final deletedPerson = await personRepo.delete(int.parse(id));
        return Response.ok(jsonEncode(
            {'message': 'Person deleted', 'person': deletedPerson.toJson()}));
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Could not delete person: $e'}));
      }
    });

    return router;
  }
}
