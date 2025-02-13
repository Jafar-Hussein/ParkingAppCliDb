import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import './routes/PersonRoutes.dart';
import './routes/VehicleRoutes.dart';
import './routes/ParkingRoutes.dart';
import './routes/ParkingSpace.dart';

// Skapa en router och lägg till alla routes
final Router appRouter = Router()
  ..mount('/persons', PersonRoutes().router)
  ..mount('/vehicles', VehicleRoutes().router)
  ..mount('/parkings', ParkingRoutes().router)
  ..mount('/parkingspaces', ParkingSpaceRoutes().router);

// Middleware för loggning och felhantering
Handler createHandler() {
  return Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware((Handler innerHandler) {
    return (Request request) async {
      try {
        final response = await innerHandler(request);
        return response;
      } catch (e, stackTrace) {
        print('Server error: $e\n$stackTrace');
        return Response.internalServerError(
          body: 'Internt serverfel: $e',
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  }).addHandler(appRouter);
}

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8081');

  final handler = createHandler();

  final server = await serve(handler, ip, port);
  print('Servern körs på http://${server.address.host}:${server.port}');
}
