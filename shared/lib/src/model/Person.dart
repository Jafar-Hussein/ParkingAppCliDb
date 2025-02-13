import 'Vehicle.dart';

class Person {
  int id;
  String namn;
  String
      personnummer; // personnummer är string för att jag gissar på att den ska stå såhär 19900101-1234

  Person({required this.id, required this.namn, required this.personnummer});

  // Getters
  int get getId => id;
  String get getNamn => namn;
  String get getPersonnummer => personnummer;

  // Setters
  set setId(int newId) => id = newId;
  set setNamn(String newNamn) => namn = newNamn;
  set setPersonnummer(String newPersonnummer) => personnummer = newPersonnummer;

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      namn: json['namn'],
      personnummer: json['personnummer'],
    );
  }

  // **Konvertera till JSON**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namn': namn,
      'personnummer': personnummer,
    };
  }
}
