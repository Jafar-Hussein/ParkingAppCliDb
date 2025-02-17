import 'Person.dart';

class Vehicle {
  int id;
  String registreringsnummer;
  String typ; // Changed from "type" to "typ"
  Person owner;

  Vehicle({
    required this.id,
    required this.registreringsnummer,
    required this.typ,
    required this.owner,
  });

  // Getters
  int get getId => id;
  String get getRegistreringsnummer => registreringsnummer;
  String get getTyp => typ;
  Person get getOwner => owner;

  // Setters
  set setId(int id) {
    if (id <= 0) {
      throw Exception("ID must be greater than zero.");
    }
    this.id = id;
  }

  set setRegistreringsnummer(String regNummer) {
    if (regNummer.isEmpty) {
      throw Exception("Registreringsnummer cannot be empty.");
    }
    this.registreringsnummer = regNummer;
  }

  set setTyp(String typ) => this.typ = typ;
  set setOwner(Person owner) => this.owner = owner;

  // **Convert from JSON to `Vehicle` object**
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    print("DEBUG: Skapar Vehicle från JSON: $json");

    // 🛠 Hantera om frontend skickar ownerId istället för owner-objekt
    if (json.containsKey('ownerId')) {
      return Vehicle(
        id: json.containsKey('id') && json['id'] != null
            ? int.tryParse(json['id'].toString()) ?? 0
            : 0,
        registreringsnummer: json['registreringsnummer'] ?? '',
        typ: json['typ'] ?? '',
        owner: Person(
          // Vi skapar en dummy-Person med ownerId
          id: json['ownerId'],
          namn: '',
          personnummer: '',
        ),
      );
    }

    // 🛠 Hantera om frontend skickar owner som ett objekt
    if (json['owner'] == null || !json['owner'].containsKey('id')) {
      throw Exception("ERROR: JSON innehåller ingen giltig ownerId!");
    }

    return Vehicle(
      id: json.containsKey('id') && json['id'] != null
          ? int.tryParse(json['id'].toString()) ?? 0
          : 0,
      registreringsnummer: json['registreringsnummer'] ?? '',
      typ: json['typ'] ?? '',
      owner: Person.fromJson(json['owner']),
    );
  }

  // **Convert to JSON**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registreringsnummer': registreringsnummer,
      'typ': typ,
      'owner': owner.toJson(),
    };
  }

  // **Convert from Database Row**
  factory Vehicle.fromDatabaseRow(Map<String, dynamic> json) {
    if (json['owner'] == null || json['owner']['id'] == null) {
      throw Exception("Owner ID is missing in database row.");
    }

    return Vehicle(
      id: json['id'] as int,
      registreringsnummer: json['registreringsnummer'] as String,
      typ: json['typ'] as String,
      owner: Person.fromDatabaseRow(json['owner']),
    );
  }

  // **Convert to Database Row**
  Map<String, dynamic> toDatabaseRow() {
    print("⚠️ DEBUG: toDatabaseRow() - skickar ownerId: ${owner.id}");
    return {
      'id': id,
      'registreringsnummer': registreringsnummer,
      'typ': typ,
      'ownerId': owner.id,
    };
  }
}
