import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import '../bin/routes/PersonRoutes.dart';
import '../bin/routes/VehicleRoutes.dart';
import '../bin/routes/ParkingRoutes.dart';
import '../bin/routes/ParkingSpace.dart';

// Skapa en router och inkludera alla route-filer
final _router = Router()
  ..mount('/persons', PersonRoutes().router)
  ..mount('/vehicles', VehicleRoutes().router)
  ..mount('/parkings', ParkingRoutes().router)
  ..mount('/parkingspaces', ParkingSpaceRoutes().router);

// Middleware för att logga och hantera CORS
final handler = Pipeline()
    .addMiddleware(logRequests())
    .addMiddleware(corsHeaders()) // Tillåter API-anrop från frontend
    .addHandler(_router);

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final server = await serve(handler, ip, port);
  print('Servern körs på http://localhost:${server.port}');
}
