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
      final persons = await personRepo.getAll();
      return Response.ok(jsonEncode(persons),
          headers: {'Content-Type': 'application/json'});
    });

    // Hämta en specifik person via ID
    router.get('/<id>', (Request req, String id) async {
      final person = await personRepo.getById(int.parse(id));
      return person != null
          ? Response.ok(jsonEncode(person.toJson()),
              headers: {'Content-Type': 'application/json'})
          : Response.notFound(jsonEncode({'error': 'Person not found'}));
    });

    // Skapa en ny person
    router.post('/', (Request req) async {
      try {
        final body = await req.readAsString();
        if (body.isEmpty) {
          return Response.badRequest(
              body: jsonEncode({'error': 'Request body is empty'}));
        }

        final Map<String, dynamic> jsonData = jsonDecode(body);
        if (!jsonData.containsKey('name') ||
            !jsonData.containsKey('personnummer')) {
          return Response.badRequest(
              body: jsonEncode({'error': 'Missing required fields'}));
        }

        final newPerson = Person.fromJson(jsonData);
        final createdPerson = await personRepo.create(newPerson);

        return Response.ok(jsonEncode(createdPerson.toJson()),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': 'Invalid input data: $e'}));
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
