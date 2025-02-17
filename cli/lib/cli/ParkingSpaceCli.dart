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
    // Vänta en kort stund innan vi hämtar uppdaterad data
    await Future.delayed(Duration(milliseconds: 200));

    // Hämta uppdaterad lista direkt från databasen
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
    await viewAllParkingSpaces(parkingSpaceRepo); // Visa befintliga platser

    stdout.write("\nAnge ID på parkeringsplatsen du vill uppdatera: ");
    int? id = int.tryParse(userInput.getUserInput());
    if (id == null) {
      print("Ogiltigt ID, försök igen.");
      return;
    }

    // Hämta befintlig parkeringsplats
    ParkingSpace? existingSpace = await parkingSpaceRepo.getById(id);
    if (existingSpace == null) {
      print("Ingen parkeringsplats hittades med ID $id.");
      return;
    }

    print(
        "Nuvarande detaljer: Adress: ${existingSpace.address}, Pris per timme: ${existingSpace.pricePerHour}");

    stdout.write("Ange ny adress (lämna tomt för att behålla): ");
    String newAddress = userInput.getUserInput();
    if (newAddress.isEmpty) {
      newAddress = existingSpace.address;
    }

    stdout.write("Ange nytt pris per timme (lämna tomt för att behålla): ");
    double? newPricePerHour = double.tryParse(userInput.getUserInput());
    if (newPricePerHour == null || newPricePerHour <= 0) {
      newPricePerHour = existingSpace.pricePerHour;
    }

    // Uppdatera parkeringsplatsen i databasen
    ParkingSpace updatedSpace = ParkingSpace(
        id: existingSpace.id,
        address: newAddress,
        pricePerHour: newPricePerHour);

    await parkingSpaceRepo.update(id, updatedSpace);

    // **Lösning: Vänta en kort tid innan ny hämtning**
    await Future.delayed(Duration(milliseconds: 200));

    print("\nParkeringsplats uppdaterad!\n");

    // **Tvinga hämtning av den senaste listan från databasen**
    await viewAllParkingSpaces(parkingSpaceRepo);
  }

  // Tar bort en parkeringsplats
  Future<void> deleteParkingSpace(ParkingSpaceRepo parkingSpaceRepo) async {
    await viewAllParkingSpaces(parkingSpaceRepo); // Visa befintliga platser

    stdout.write("\nAnge ID på parkeringsplatsen du vill ta bort: ");
    int? id = int.tryParse(userInput.getUserInput());
    if (id == null) {
      print("Ogiltigt ID, försök igen.");
      return;
    }

    // Kontrollera om platsen existerar innan borttagning
    ParkingSpace? parkingSpaceToDelete = await parkingSpaceRepo.getById(id);
    if (parkingSpaceToDelete == null) {
      print("Ingen parkeringsplats hittades med ID $id.");
      return;
    }

    // Väntar på att platsen tas bort från databasen
    await parkingSpaceRepo.delete(id);

    // **Lösning: Vänta en kort tid innan ny hämtning**
    await Future.delayed(Duration(milliseconds: 200));

    print("\nParkeringsplats borttagen!\n");

    // **Tvinga hämtning av den senaste listan från databasen**
    await viewAllParkingSpaces(parkingSpaceRepo);
  }
}
