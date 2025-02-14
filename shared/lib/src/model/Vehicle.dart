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
    return Vehicle(
      id: json.containsKey('id') && json['id'] != null
          ? int.tryParse(json['id'].toString()) ?? 0
          : 0,
      registreringsnummer: json['registreringsnummer'] ?? '',
      typ: json['typ'] ?? '',
      owner: json['owner'] is Map<String, dynamic>
          ? Person.fromJson(json['owner'])
          : Person(id: 0, namn: 'Unknown', personnummer: ''),
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
  factory Vehicle.fromDatabaseRow(Map<String, dynamic> row) {
    return Vehicle(
      id: int.tryParse(row['id'].toString()) ?? 0,
      registreringsnummer: row['registreringsnummer'] ?? '',
      typ: row['typ'] ?? '',
      owner: Person.fromDatabaseRow({
        'id': row['ownerId'],
        'namn': row['ownerNamn'],
        'personnummer': row['personnummer'],
      }),
    );
  }

  // **Convert to Database Row**
  Map<String, dynamic> toDatabaseRow() {
    return {
      'id': id,
      'registreringsnummer': registreringsnummer,
      'typ': typ,
      'ownerId': owner.id,
    };
  }
}
