import 'dart:convert';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../bin/routes/ParkingRoutes.dart';
import '../bin/routes/ParkingSpace.dart';
import '../bin/routes/PersonRoutes.dart';

void main() {
  // group('ParkingRoutes Tests', () {
  //   final router = ParkingRoutes().router;

  //   test('POST / should create a parking', () async {
  //     final request = Request('POST', Uri.parse('http://localhost/'),
  //         body: jsonEncode({'name': 'Test Parking'}),
  //         headers: {'Content-Type': 'application/json'});
  //     final response = await router(request);
  //     expect(response.statusCode, 201);
  //   });
  // });

  // group('ParkingSpaceRoutes Tests', () {
  //   final router = ParkingSpaceRoutes().router;

  //   test('GET / should return all parking spaces', () async {
  //     final request = Request('GET', Uri.parse('http://localhost/'));
  //     final response = await router(request);
  //     expect(response.statusCode, 200);
  //   });
  // });

  // group('PersonRoutes Tests', () {
  //   final router = PersonRoutes().router;

  //   test('GET / should return all persons', () async {
  //     final request = Request('GET', Uri.parse('http://localhost/'));
  //     final response = await router(request);
  //     expect(response.statusCode, 200);
  //   });
  // });
}
