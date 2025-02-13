import 'Person.dart';

class Vehicle {
  int id;
  String registreringsnummer;
  String typ; // Ändrat från "type" till "typ"
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
  String get getTyp => typ; // Ändrat från "getType" till "getTyp"
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

  set setTyp(String typ) =>
      this.typ = typ; // Ändrat från "setType" till "setTyp"
  set setOwner(Person owner) => this.owner = owner;

  // **Konverterar från JSON till ett `Vehicle`-objekt**
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json.containsKey('id') && json['id'] != null
          ? int.tryParse(json['id'].toString()) ?? 0
          : 0,
      registreringsnummer: json['registreringsnummer'] ?? '',
      typ: json['typ'] ?? '', // Ändrat från "type" till "typ"
      owner: json['owner'] is Map<String, dynamic>
          ? Person.fromJson(json['owner'])
          : Person(id: 0, namn: 'Unknown', personnummer: ''),
    );
  }

  // **Konvertera till JSON**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registreringsnummer': registreringsnummer,
      'typ': typ, // Ändrat från "type" till "typ"
      'owner': owner.toJson(),
    };
  }
}
