import 'dart:io';
import 'package:firstapp/repository/PersonRepo.dart';
import 'package:firstapp/repository/VehicleRepo.dart';
import 'package:shared/src/model/Person.dart';
import 'package:shared/src/model/Vehicle.dart';
import 'package:firstapp/util/Input.dart';
import 'package:firstapp/util/MenuUtil.dart';

// Klass för att hantera fordon via kommandoradsgränssnitt
class VehicleCli {
  Input userInput = Input();
  MenuUtil menuUtil = MenuUtil();

  // Huvudmeny för att hantera fordon
  Future<void> manageVehicles(
      VehicleRepo vehicleRepo, PersonRepo personRepo) async {
    bool back = false;

    while (!back) {
      print("\nDu har valt att hantera fordon. Vad vill du göra?");
      menuUtil.printVehicleMenu(); // Skriver ut menyn
      var input = userInput.getUserInput();

      if (await userVehicleChoice(input, vehicleRepo, personRepo)) {
        break; // Avslutar loopen om "5" väljs
      }
    }
  }

  // Hanterar användarens val från menyn
  Future<bool> userVehicleChoice(
      String? userInput, VehicleRepo vehicleRepo, PersonRepo personRepo) async {
    switch (userInput) {
      case "1":
        await addVehicle(vehicleRepo, personRepo);
        return false;
      case "2":
        await viewAllVehicles(vehicleRepo);
        return false;
      case "3":
        await updateVehicle(vehicleRepo, personRepo);
        return false;
      case "4":
        await deleteVehicle(vehicleRepo);
        return false;
      case "5":
        return true; // Gå tillbaka till huvudmenyn
      default:
        print("Ogiltigt alternativ, försök igen.");
        return false;
    }
  }

  Future<void> addVehicle(
      VehicleRepo vehicleRepo, PersonRepo personRepo) async {
    try {
      stdout.write("\nAnge registreringsnummer: ");
      String regNumber = userInput.getUserInput().trim();
      if (regNumber.isEmpty)
        throw FormatException("Registreringsnummer kan inte vara tomt.");

      stdout.write("Ange fordonstyp (Car, Motorcycle, Truck): \n");
      String type = userInput.getUserInput().trim();
      if (type.isEmpty) throw FormatException("Fordonstyp kan inte vara tom.");

      stdout.write("Ange ägarens ID: ");
      int? ownerId = int.tryParse(userInput.getUserInput().trim());
      if (ownerId == null || ownerId <= 0)
        throw FormatException("Ogiltigt ID-format.");

      // 🛠 Debugga att ownerId hämtas korrekt
      print("DEBUG: ownerId som skickas: $ownerId");

      // Hämta ägaren från databasen
      Person? owner = await personRepo.getById(ownerId);
      if (owner == null) {
        throw Exception("Ingen ägare hittades med ID $ownerId.");
      }

      // 🛠 Debugga att personen hämtas korrekt
      print("DEBUG: Hämtad person - ID: ${owner.id}, Namn: ${owner.namn}");

      // Skapa nytt fordon
      Vehicle newVehicle = Vehicle(
        id: 1, // Tillfälligt ID, sätts av databasen
        registreringsnummer: regNumber,
        typ: type,
        owner: owner,
      );

      // Skicka till backend
      await vehicleRepo.create(newVehicle);

      print(
          "Nytt fordon tillagt: Registreringsnummer ${newVehicle.registreringsnummer}, Ägare ID: ${owner.id}");
    } catch (e) {
      print("Fel: ${e.toString()}");
    }
  }

  // Visar alla fordon
  Future<void> viewAllVehicles(VehicleRepo vehicleRepo) async {
    // Vänta kort för att säkerställa att databasen har uppdaterats
    await Future.delayed(Duration(milliseconds: 200));

    // Hämta uppdaterad lista direkt från databasen
    List<Vehicle> vehicles = await vehicleRepo.getAll();

    if (vehicles.isEmpty) {
      print("Inga fordon hittades.");
    } else {
      print("\nLista över alla fordon:");
      for (var vehicle in vehicles) {
        print(
            'ID: ${vehicle.id}, Registreringsnummer: ${vehicle.registreringsnummer}, Typ: ${vehicle.typ}, Ägare: ${vehicle.owner.namn}');
      }
    }
  }

  // Uppdaterar ett befintligt fordon
  Future<void> updateVehicle(
      VehicleRepo vehicleRepo, PersonRepo personRepo) async {
    await viewAllVehicles(vehicleRepo); // Visa befintliga fordon

    stdout.write("\nAnge ID på fordonet du vill uppdatera: ");
    int? id = int.tryParse(userInput.getUserInput());
    if (id == null) {
      print("Ogiltigt ID, försök igen.");
      return;
    }

    try {
      Vehicle? existingVehicle = await vehicleRepo.getById(id);
      if (existingVehicle == null) {
        print("Inget fordon hittades med ID $id.");
        return;
      }

      print(
          "Nuvarande detaljer: Registreringsnummer: ${existingVehicle.registreringsnummer}, Typ: ${existingVehicle.typ}, Ägare: ${existingVehicle.owner.id}");

      stdout.write(
          "Ange nytt registreringsnummer (lämna tomt för att behålla): ");
      String newRegNumber = userInput.getUserInput();
      if (newRegNumber.isEmpty) {
        newRegNumber = existingVehicle.registreringsnummer;
      }

      stdout.write("Ange ny fordonstyp (lämna tomt för att behålla): ");
      String newType = userInput.getUserInput();
      if (newType.isEmpty) {
        newType = existingVehicle.typ;
      }

      stdout.write("Ange ny ägarens ID (lämna tomt för att behålla): ");
      String ownerInput = userInput.getUserInput();
      int? newOwnerId = ownerInput.isEmpty
          ? existingVehicle.owner.id
          : int.tryParse(ownerInput);

      if (newOwnerId == null) {
        print("Ogiltigt ägar-ID, försöker behålla befintlig ägare.");
        newOwnerId = existingVehicle.owner.id;
      }

      Person? newOwner = await personRepo.getById(newOwnerId);
      if (newOwner == null) {
        print(
            "Ingen ägare hittades med ID $newOwnerId. Behåller befintlig ägare.");
        newOwner = existingVehicle.owner;
      }

      Vehicle updatedVehicle = Vehicle(
        id: existingVehicle.id,
        registreringsnummer: newRegNumber,
        typ: newType,
        owner: newOwner,
      );

      await vehicleRepo.update(id, updatedVehicle);

      print("\nFordon uppdaterat!\n");

      await viewAllVehicles(vehicleRepo);
    } catch (e) {
      print("Fel vid uppdatering av fordon: $e");
    }
  }

  // Tar bort ett fordon
  Future<void> deleteVehicle(VehicleRepo vehicleRepo) async {
    await viewAllVehicles(vehicleRepo); // Visa befintliga fordon

    stdout.write("\nAnge ID på fordonet du vill ta bort: ");
    String input = userInput.getUserInput().trim();
    int? id = int.tryParse(input);

    if (id == null) {
      print("ERROR: Ogiltigt ID-format, måste vara ett heltal.");
      return;
    }
    try {
      Vehicle deletedVehicle = await vehicleRepo.delete(id);

      // Om raderingen lyckades och ID matchar, skriv ut framgångsmeddelande
      if (deletedVehicle.id == id) {
        print("\nFordon borttaget: ID ${deletedVehicle.id}\n");
      } else {
        print(
            "\ningen bekräftelse på radering mottogs, men begäran skickades.\n");
      }
    } catch (e) {
      // Endast fånga riktiga fel, inte normala API-responser
      print("Fel vid borttagning av fordon: $e");
    }
  }
}
