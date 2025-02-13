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

// Funktion för att lägga till ett nytt fordon asynkront
  Future<void> addVehicle(
      VehicleRepo vehicleRepo, PersonRepo personRepo) async {
    try {
      // Fråga användaren att ange registreringsnummer och ta bort eventuella blanksteg
      stdout.write("\nAnge registreringsnummer: ");
      String regNumber = userInput.getUserInput().trim();
      if (regNumber.isEmpty) {
        throw FormatException("Registreringsnummer kan inte vara tomt.");
      }

      // Fråga användaren att ange typ av fordon
      stdout.write("Ange fordonstyp (Car, Motorcycle, Truck): \n");
      String type = userInput.getUserInput().trim();
      if (type.isEmpty) {
        throw FormatException("Fordonstyp kan inte vara tom.");
      }

      // Fråga användaren att ange ägarens ID och försök konvertera strängen till ett heltal
      stdout.write("Ange ägarens ID: ");
      String ownerInput = userInput.getUserInput().trim();
      int? ownerId = int.tryParse(ownerInput);
      if (ownerId == null) {
        throw FormatException("Ogiltigt ID-format.");
      }

      // Hämta ägaren från repository med angivet ID asynkront
      Person? owner = await personRepo.getById(ownerId);
      if (owner == null) {
        throw Exception("Ingen ägare hittades med ID $ownerId.");
      }

      // Hämta alla fordon asynkront för att generera ett unikt ID
      List<Vehicle> vehicles = await vehicleRepo.getAll();
      int newId = vehicles.isEmpty
          ? 1
          : vehicles.map((v) => v.id).reduce((a, b) => a > b ? a : b) + 1;

      // Skapa ett nytt fordon med det nya ID:t och de angivna attributen
      Vehicle newVehicle = Vehicle(
          id: newId, registreringsnummer: regNumber, typ: type, owner: owner);

      // Lägga till fordonet i databasen asynkront
      await vehicleRepo.create(newVehicle);

      // Informera användaren om att ett nytt fordon har lagts till
      print(
          "Nytt fordon tillagt: ID ${newVehicle.id}, Registreringsnummer: ${newVehicle.registreringsnummer}, Ägare: ${owner.namn}");
    } catch (e) {
      // Skriv ut felmeddelandet om något går fel under processen
      print("Fel: ${e.toString()}");
      return;
    }
  }

  // Visar alla fordon
  Future<void> viewAllVehicles(VehicleRepo vehicleRepo) async {
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
    stdout.write("Ange ID på fordonet du vill uppdatera: ");
    int? id = int.tryParse(userInput.getUserInput());
    if (id == null) {
      print("Ogiltigt ID.");
      return;
    }

    // Hämtar det befintliga fordonet baserat på ID
    Vehicle? existingVehicle = await vehicleRepo.getById(id);
    if (existingVehicle == null) {
      print("Inget fordon hittades med ID $id.");
      return;
    }

    // Ber användaren ange nytt registreringsnummer eller behålla det befintliga
    stdout.write(
        "Ange nytt registreringsnummer (${existingVehicle.registreringsnummer}): ");
    String newRegNumber = userInput.getUserInput();
    if (newRegNumber.isEmpty) {
      newRegNumber = existingVehicle.registreringsnummer;
    }

    // Ber användaren ange ny fordonstyp eller behålla den befintliga
    stdout.write("Ange ny typ (${existingVehicle.typ}): ");
    String newType = userInput.getUserInput();
    if (newType.isEmpty) {
      newType = existingVehicle.typ;
    }

    // Ber användaren ange ny ägare eller behålla den befintliga
    stdout.write("Ange ny ägarens ID (${existingVehicle.owner.id}): ");
    int? newOwnerId = int.tryParse(userInput.getUserInput());
    Person newOwner = existingVehicle.owner;

    if (newOwnerId != null) {
      Person? potentialNewOwner = await personRepo.getById(newOwnerId);
      if (potentialNewOwner != null) {
        newOwner = potentialNewOwner;
      }
    }

    // Skapar ett uppdaterat fordon och sparar det i databasen
    Vehicle updatedVehicle = Vehicle(
        id: existingVehicle.id,
        registreringsnummer: newRegNumber,
        typ: newType,
        owner: newOwner);
    vehicleRepo.update(id, updatedVehicle);
    print("Fordon uppdaterat.");
  }

  // Tar bort ett fordon
  Future<void> deleteVehicle(VehicleRepo vehicleRepo) async {
    stdout.write("Ange ID på fordonet du vill ta bort: ");
    int? id = int.tryParse(userInput.getUserInput());
    if (id == null) {
      print("Ogiltigt ID.");
      return;
    }

    // Kontrollera om fordonet existerar innan borttagning
    if (vehicleRepo.getById(id) == null) {
      print("Inget fordon hittades med ID $id.");
      return;
    }

    // Tar bort fordonet från databasen
    await vehicleRepo.delete(id);
    print("Fordon borttaget.");
  }
}
