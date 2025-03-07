import 'Person.dart';

class Vehicle {
  int id;
  String registreringsnummer;
  String typ; 
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
    // Om ID saknas eller är null, sätt det till 0 (det genereras i databasen)
    int vehicleId = json.containsKey('id') && json['id'] != null
        ? int.tryParse(json['id'].toString()) ?? 0
        : 0;

    // Hantera om frontend skickar ownerId istället för owner-objekt
    Person owner;
    if (json.containsKey('ownerId') && json['ownerId'] != null) {
      owner = Person(
        id: int.tryParse(json['ownerId'].toString()) ?? 0,
        namn: 'Okänd',
        personnummer: '',
      );
    } else if (json.containsKey('owner') && json['owner'] != null) {
      owner = Person.fromJson(json['owner']);
    } else {
      owner = Person(id: 0, namn: "Okänd", personnummer: "");
    }

    return Vehicle(
      id: vehicleId, // Om det är 0, betyder det att det skapas och får ID av databasen
      registreringsnummer: json['registreringsnummer']?.toString() ?? 'Okänd',
      typ: json['typ']?.toString() ?? 'Okänd',
      owner: owner,
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
    return {
      'id': id,
      'registreringsnummer': registreringsnummer,
      'typ': typ,
      'ownerId': owner.id,
    };
  }
}
