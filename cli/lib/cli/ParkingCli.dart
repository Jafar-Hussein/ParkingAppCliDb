import 'dart:io';
import 'package:firstapp/repository/ParkingRepo.dart';
import 'package:firstapp/repository/ParkingSpaceRepo.dart';
import 'package:firstapp/repository/VehicleRepo.dart';
import 'package:firstapp/util/Input.dart';
import 'package:firstapp/util/MenuUtil.dart';
import 'package:shared/src/model/Vehicle.dart';
import 'package:shared/src/model/ParkingSpace.dart';
import 'package:shared/src/model/Parking.dart';

import 'package:shared/shared.dart';

// Klass för att hantera parkeringar via kommandoradsgränssnitt
class ParkingCli {
  Input userInput = Input();
  MenuUtil menuUtil = MenuUtil();

  // Huvudmeny för att hantera parkeringar
  Future<void> manageParking(ParkingRepo parkingRepo, VehicleRepo vehicleRepo,
      ParkingSpaceRepo parkingSpaceRepo) async {
    bool back = false;

    while (!back) {
      print("\nDu har valt att hantera parkeringar. Vad vill du göra?");
      menuUtil.printParkingMenu(); // Skriver ut parkeringsmenyn
      var input = userInput.getUserInput();
      // Hanterar användarens val
      back = await userParkingChoice(
          input, parkingRepo, vehicleRepo, parkingSpaceRepo);
    }
  }

  // Hanterar användarens val från menyn
  Future<bool> userParkingChoice(String? userInput, ParkingRepo parkingRepo,
      VehicleRepo vehicleRepo, ParkingSpaceRepo parkingSpaceRepo) async {
    switch (userInput) {
      case "1":
        await addParking(parkingRepo, vehicleRepo, parkingSpaceRepo);
        return false;
      case "2":
        await viewAllParkings(parkingRepo);
        return false;
      case "3":
        await updateParking(parkingRepo, vehicleRepo, parkingSpaceRepo);
        return false;
      case "4":
        await deleteParking(parkingRepo);
        return false;
      case "5":
        return true; // Gå tillbaka till huvudmenyn
      default:
        print("Ogiltigt alternativ, försök igen.");
        return false;
    }
  }

  Future<void> addParking(ParkingRepo parkingRepo, VehicleRepo vehicleRepo,
      ParkingSpaceRepo parkingSpaceRepo) async {
    try {
      stdout.write("\nAnge fordonets ID: ");
      int? vehicleId = int.tryParse(userInput.getUserInput());
      if (vehicleId == null) throw FormatException("Ogiltigt fordon ID.");

      Vehicle? vehicle = await vehicleRepo.getById(vehicleId);
      if (vehicle == null)
        throw Exception("Inget fordon hittades med ID $vehicleId");

      stdout.write("Ange parkeringsplatsens ID: ");
      int? parkingSpaceId = int.tryParse(userInput.getUserInput());
      if (parkingSpaceId == null)
        throw FormatException("Ogiltigt parkeringsplats ID.");

      ParkingSpace? parkingSpace =
          await parkingSpaceRepo.getById(parkingSpaceId);
      if (parkingSpace == null)
        throw Exception(
            "Ingen parkeringsplats hittades med ID $parkingSpaceId");

      stdout.write("Ange starttid (yyyy-mm-dd hh:mm): ");
      DateTime startTime =
          DateTime.parse(userInput.getUserInput() ?? DateTime.now().toString());

      stdout.write(
          "Ange sluttid (yyyy-mm-dd hh:mm) eller lämna tom för pågående parkering: ");
      String? endTimeInput = userInput.getUserInput();
      DateTime? endTime = endTimeInput != null && endTimeInput.isNotEmpty
          ? DateTime.parse(endTimeInput)
          : null;

      Parking newParking = Parking(
        id: 0, // ID sätts av databasen
        vehicle: vehicle,
        parkingSpace: parkingSpace,
        startTime: startTime,
        endTime: endTime,
      );

      newParking.price =
          newParking.parkingCost(); // Calculate cost before sending

      Parking createdParking = await parkingRepo.create(newParking);
      print(
          "Ny parkering tillagd: ID ${createdParking.id}, Kostnad: ${createdParking.price} kr");
    } catch (e) {
      print("Fel: $e");
    }
  }

  Future<void> viewAllParkings(ParkingRepo parkingRepo) async {
    // Vänta en kort stund innan vi hämtar uppdaterad data
    await Future.delayed(Duration(milliseconds: 200));

    DateTime now = DateTime.now();
    List<Parking> parkings = await parkingRepo.getAll();

    // Filtrera parkeringar i två listor: Aktiva och Avslutade
    List<Parking> activeParkings =
        parkings.where((p) => p.endTime == null).toList();
    List<Parking> expiredParkings =
        parkings.where((p) => p.endTime != null).toList();

    if (parkings.isEmpty) {
      print("\nInga parkeringar hittades.");
      return;
    }

    // Visa avslutade parkeringar separat
    if (expiredParkings.isNotEmpty) {
      print("\nAvslutade parkeringar:");
      for (var parking in expiredParkings) {
        double cost = parking.parkingCost();
        print('Parking ID: ${parking.id}, '
            'Registreringsnummer: ${parking.vehicle.registreringsnummer}, '
            'Parkeringsplats: ${parking.parkingSpace.address}, '
            'Start: ${parking.startTime}, '
            'Slut: ${parking.endTime}, '
            'Kostnad: ${cost.toStringAsFixed(2)} kr');
      }
    }

    // Visa aktiva parkeringar separat
    if (activeParkings.isNotEmpty) {
      print("\nPågående parkeringar:");
      for (var parking in activeParkings) {
        double cost = parking.parkingCost();
        print('Parking ID: ${parking.id}, '
            'Registreringsnummer: ${parking.vehicle.registreringsnummer}, '
            'Parkeringsplats: ${parking.parkingSpace.address}, '
            'Start: ${parking.startTime}, '
            'Slut: Pågående, '
            'Kostnad: ${cost.toStringAsFixed(2)} kr');
      }
    }
  }

  // Uppdaterar en befintlig parkering
  Future<void> updateParking(ParkingRepo parkingRepo, VehicleRepo vehicleRepo,
      ParkingSpaceRepo parkingSpaceRepo) async {
    await viewAllParkings(parkingRepo); // Visa befintliga parkeringar

    stdout.write("\nAnge ID på parkeringen du vill uppdatera: ");
    int? id = int.tryParse(userInput.getUserInput());
    if (id == null) {
      print("Ogiltigt ID, försök igen.");
      return;
    }

    // Hämta befintlig parkering
    Parking? existingParking = await parkingRepo.getById(id);
    if (existingParking == null) {
      print("Ingen parkering hittades med ID $id.");
      return;
    }

    print(
        "Nuvarande detaljer: Fordon: ${existingParking.vehicle.registreringsnummer}, Parkeringsplats: ${existingParking.parkingSpace.address}");

    stdout.write("Ange nytt fordonets ID (lämna tomt för att behålla): ");
    int? newVehicleId = int.tryParse(userInput.getUserInput());
    if (newVehicleId != null) {
      Vehicle? newVehicle = await vehicleRepo.getById(newVehicleId);
      if (newVehicle != null) {
        existingParking.vehicle = newVehicle;
      }
    }

    stdout
        .write("Ange ny parkeringsplatsens ID (lämna tomt för att behålla): ");
    int? newParkingSpaceId = int.tryParse(userInput.getUserInput());
    if (newParkingSpaceId != null) {
      ParkingSpace? newParkingSpace =
          await parkingSpaceRepo.getById(newParkingSpaceId);
      if (newParkingSpace != null) {
        existingParking.parkingSpace = newParkingSpace;
      }
    }

    stdout.write(
        "Ange ny sluttid (yyyy-mm-dd hh:mm) eller lämna tom för pågående parkering: ");
    String? newEndTimeInput = userInput.getUserInput();
    if (newEndTimeInput != null && newEndTimeInput.isNotEmpty) {
      existingParking.endTime = DateTime.parse(newEndTimeInput);
    }

    // Beräkna ny kostnad om endTime har ändrats
    existingParking.price = existingParking.parkingCost();

    await parkingRepo.update(id, existingParking);

    // **Lösning: Vänta en kort tid innan ny hämtning**
    await Future.delayed(Duration(milliseconds: 200));

    print("\nParkering uppdaterad!\n");

    // **Tvinga hämtning av den senaste listan från databasen**
    await viewAllParkings(parkingRepo);
  }

  // Tar bort en parkering
  Future<void> deleteParking(ParkingRepo parkingRepo) async {
    await viewAllParkings(parkingRepo); // Visa befintliga parkeringar

    stdout.write("\nAnge ID på parkeringen du vill ta bort: ");
    int? id = int.tryParse(userInput.getUserInput());
    if (id == null) {
      print("Ogiltigt ID, försök igen.");
      return;
    }

    // Kontrollera om parkeringen existerar innan borttagning
    Parking? parkingToDelete = await parkingRepo.getById(id);
    if (parkingToDelete == null) {
      print("Ingen parkering hittades med ID $id.");
      return;
    }

    // Väntar på att parkeringen tas bort från databasen
    await parkingRepo.delete(id);

    // **Lösning: Vänta en kort tid innan ny hämtning**
    await Future.delayed(Duration(milliseconds: 200));

    print("\nParkering borttagen!\n");

    // **Tvinga hämtning av den senaste listan från databasen**
    await viewAllParkings(parkingRepo);
  }
}
