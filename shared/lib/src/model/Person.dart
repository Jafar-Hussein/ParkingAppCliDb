import 'Vehicle.dart';

class Person {
  int id;
  String namn;
  String personnummer; // Assumed format: "19900101-1234"

  Person({
    required this.id,
    required this.namn,
    required this.personnummer,
  });

  // Getters
  int get getId => id;
  String get getNamn => namn;
  String get getPersonnummer => personnummer;

  // Setters
  set setId(int newId) => id = newId;
  set setNamn(String newNamn) => namn = newNamn;
  set setPersonnummer(String newPersonnummer) => personnummer = newPersonnummer;

  // **Convert from JSON**
  factory Person.fromJson(Map<String, dynamic> json) {
    print("Parsing Person from JSON: $json");

    return Person(
      id: json.containsKey('id') && json['id'] != null
          ? int.tryParse(json['id'].toString()) ?? 0
          : 0, // Default to 0 if id is null or missing
      namn: json['namn']?.toString() ?? '', // Ensure it’s a valid string
      personnummer: json['personnummer']?.toString() ?? '',
    );
  }

  // **Convert to JSON**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namn': namn,
      'personnummer': personnummer,
    };
  }

  // **Convert from Database Row**
  factory Person.fromDatabaseRow(Map<String, dynamic> row) {
    if (!row.containsKey('id') || row['id'] == null) {
      throw Exception("Person ID is missing in database row.");
    }

    return Person(
      id: int.tryParse(row['id'].toString()) ?? 0,
      namn: row['namn'] ?? '',
      personnummer: row['personnummer'] ?? '',
    );
  }

  // **Convert to Database Row**
  Map<String, dynamic> toDatabaseRow() {
    return {
      'id': id,
      'namn': namn,
      'personnummer': personnummer,
    };
  }
}
