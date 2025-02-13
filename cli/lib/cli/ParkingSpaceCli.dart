import 'dart:io';
import 'package:firstapp/repository/ParkingSpaceRepo.dart';
import 'package:shared/src/model/ParkingSpace.dart';
import 'package:firstapp/util/Input.dart';
import 'package:firstapp/util/MenuUtil.dart';

// Klass för att hantera parkeringsplatser via kommandoradsgränssnitt
class ParkingSpaceCli {
  Input userInput = Input();
  MenuUtil menuUtil = MenuUtil();

  // Huvudmeny för att hantera parkeringsplatser
  Future<void> manageParkingSpaces(ParkingSpaceRepo parkingSpaceRepo) async {
    bool back = false;

    while (!back) {
      print("\nDu har valt att hantera parkeringsplatser. Vad vill du göra?");
      menuUtil.printParkingSpaceMenu(); // Skriver ut menyn
      var input = userInput.getUserInput();
      // Hanterar användarens val
      back = await userParkingSpaceChoice(input, parkingSpaceRepo);
    }
  }

  // Hanterar användarens val från menyn
  Future<bool> userParkingSpaceChoice(
      String? userInput, ParkingSpaceRepo parkingSpaceRepo) async {
    switch (userInput) {
      case "1":
        await addParkingSpace(parkingSpaceRepo);
        return false;
      case "2":
        await viewAllParkingSpaces(parkingSpaceRepo);
        return false;
      case "3":
        await updateParkingSpace(parkingSpaceRepo);
        return false;
      case "4":
        await deleteParkingSpace(parkingSpaceRepo);
        return false;
      case "5":
        return true; // Gå tillbaka till huvudmenyn
      default:
        print("Ogiltigt alternativ, försök igen.");
        return false;
    }
  }

// Lägger till en ny parkeringsplats asynkront
  Future<void> addParkingSpace(ParkingSpaceRepo parkingSpaceRepo) async {
    stdout.write("\nAnge adress för parkeringsplatsen: ");
    String address = userInput.getUserInput();
    if (address.isEmpty) {
      print("Ogiltig adress. Försök igen.");
      return;
    }

    stdout.write("Ange pris per timme: ");
    double? pricePerHour = double.tryParse(userInput.getUserInput());
    if (pricePerHour == null || pricePerHour <= 0) {
      print("Ogiltigt pris. Försök igen.");
      return;
    }

    // Väntar på att hämta alla parkeringsplatser asynkront
    List<ParkingSpace> parkingSpaces = await parkingSpaceRepo.getAll();

    // Genererar ett nytt unikt ID asynkront
    int newId = parkingSpaces.isEmpty
        ? 1
        : parkingSpaces.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

    // Skapar en ny parkeringsplats
    ParkingSpace newParkingSpace =
        ParkingSpace(id: newId, address: address, pricePerHour: pricePerHour);

    // Lägger till parkeringsplatsen asynkront
    await parkingSpaceRepo.create(newParkingSpace);

    print(
        "Ny parkeringsplats tillagd: ID ${newParkingSpace.id}, Adress: $address, Pris per timme: ${pricePerHour.toStringAsFixed(2)} kr");
  }

  // Visar alla parkeringsplatser
  Future<void> viewAllParkingSpaces(ParkingSpaceRepo parkingSpaceRepo) async {
    List<ParkingSpace> parkingSpaces = await parkingSpaceRepo.getAll();
    if (parkingSpaces.isEmpty) {
      print("Inga parkeringsplatser hittades.");
    } else {
      print("\nLista över alla parkeringsplatser:");
      for (var space in parkingSpaces) {
        print(
            'ID: ${space.id}, Adress: ${space.address}, Pris per timme: ${space.pricePerHour}');
      }
    }
  }

  // Uppdaterar en befintlig parkeringsplats
  Future<void> updateParkingSpace(ParkingSpaceRepo parkingSpaceRepo) async {
    stdout.write("Ange ID på parkeringsplatsen du vill uppdatera: ");
    int? id = int.tryParse(userInput.getUserInput());
    if (id == null) {
      print("Ogiltigt ID.");
      return;
    }

    // Hämtar befintlig parkeringsplats baserat på ID
    ParkingSpace? existingSpace = await parkingSpaceRepo.getById(id);
    if (existingSpace == null) {
      print("Ingen parkeringsplats hittades med ID $id.");
      return;
    }

    // Ber användaren ange ny adress, eller behålla den gamla om fältet är tomt
    stdout.write("Ange ny adress (${existingSpace.address}): ");
    String newAddress = userInput.getUserInput();
    if (newAddress.isEmpty) {
      newAddress = existingSpace.address;
    }

    // Ber användaren ange nytt pris per timme, eller behålla det gamla om fältet är tomt
    stdout.write("Ange nytt pris per timme (${existingSpace.pricePerHour}): ");
    double? newPricePerHour = double.tryParse(userInput.getUserInput());
    if (newPricePerHour == null || newPricePerHour <= 0) {
      newPricePerHour = existingSpace.pricePerHour;
    }

    // Skapar en uppdaterad parkeringsplats och sparar den i databasen
    ParkingSpace updatedSpace = ParkingSpace(
        id: existingSpace.id,
        address: newAddress,
        pricePerHour: newPricePerHour);
    parkingSpaceRepo.update(id, updatedSpace);
    print("Parkeringsplats uppdaterad.");
  }

  // Tar bort en parkeringsplats
  Future<void> deleteParkingSpace(ParkingSpaceRepo parkingSpaceRepo) async {
    stdout.write("Ange ID på parkeringsplatsen du vill ta bort: ");
    int? id = int.tryParse(userInput.getUserInput());
    if (id == null) {
      print("Ogiltigt ID.");
      return;
    }

    // Kontrollera om parkeringsplatsen existerar innan borttagning
    if (parkingSpaceRepo.getById(id) == null) {
      print("Ingen parkeringsplats hittades med ID $id.");
      return;
    }

    // Tar bort parkeringsplatsen från databasen
    parkingSpaceRepo.delete(id);
    print("Parkeringsplats borttagen.");
  }
}
