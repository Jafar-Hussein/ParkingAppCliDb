import 'dart:io';
import 'package:firstapp/repository/PersonRepo.dart';
import 'package:firstapp/util/Input.dart';
import 'package:firstapp/util/MenuUtil.dart';
import 'package:shared/src/model/Person.dart';

class PersonCli {
  Input userInput = Input();
  MenuUtil menuUtil = MenuUtil();

  Future<void> managePersons(PersonRepo personRepo) async {
    while (true) {
      //  Loop avslutas när "5" matas in
      print("\nDu har valt att hantera personer. Vad vill du göra?");
      menuUtil.printPersonMenu();
      var input = userInput.getUserInput();

      if (await userChoice(input, personRepo)) {
        break;
      }
    }
  }

  Future<bool> userChoice(String? userInput, PersonRepo personRepo) async {
    switch (userInput) {
      case "1":
        await addPerson(personRepo);
        return false;
      case "2":
        await viewAllPersons(personRepo);
        return false;
      case "3":
        await updatePerson(personRepo);
        return false;
      case "4":
        await deletePerson(personRepo);
        return false;
      case "5":
        print("\nÅtergår till huvudmenyn...");
        return true;
      default:
        print("Ogiltigt alternativ, försök igen.");
        return false;
    }
  }

  Future<void> addPerson(PersonRepo personRepo) async {
    // Ber användaren mata in namn
    stdout.write("\nAnge namn: ");
    String? name = userInput.getUserInput();

    // Ber användaren mata in personnummer
    stdout.write("Ange personnummer: ");
    String? personnummer = userInput.getUserInput();

    // Kontrollera om namnet och personnumret är giltiga
    if (name == null ||
        name.isEmpty ||
        personnummer == null ||
        personnummer.isEmpty) {
      print("Ogiltig information, försök igen.");
      return;
    }

    // Väntar på att hämta alla personer asynkront
    List<Person> persons = await personRepo.getAll();

    // Genererar ett nytt unikt ID asynkront
    int newId = persons.isEmpty
        ? 1
        : persons.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

    // Skapar en ny person
    Person newPerson =
        Person(id: newId, namn: name, personnummer: personnummer);

    // Lägger till personen asynkront i repositoryt
    await personRepo.create(newPerson);

    // Bekräftelsemeddelande till användaren
    print("Ny person tillagd: ID ${newPerson.id}, Namn: ${newPerson.namn}");
  }

  //skriver ut alla persone
  Future<void> viewAllPersons(PersonRepo personRepo) async {
    // Vänta kort för att säkerställa att databasen har uppdaterats
    await Future.delayed(Duration(milliseconds: 200));

    // Hämta uppdaterad lista direkt från databasen
    List<Person> persons = await personRepo.getAll();

    if (persons.isEmpty) {
      print("Inga personer hittades.");
    } else {
      print("\nLista över alla personer:");
      for (var person in persons) {
        print(
            'ID: ${person.id}, Namn: ${person.namn}, Personnummer: ${person.personnummer}');
      }
    }
  }

  // updaterar personer
  Future<void> updatePerson(PersonRepo personRepo) async {
    await viewAllPersons(personRepo); // Visa befintliga personer

    stdout.write("\nAnge ID för personen du vill uppdatera: ");
    int? id = int.tryParse(userInput.getUserInput());
    if (id == null) {
      print("Ogiltigt ID, försök igen.");
      return;
    }

    Person? currentPerson = await personRepo.getById(id);
    if (currentPerson == null) {
      print("Ingen person hittades med ID $id.");
      return;
    }

    print(
        "Nuvarande detaljer: Namn: ${currentPerson.namn},  Personnummer: ${currentPerson.personnummer}");

    stdout.write("Ange nytt namn (lämna tomt för att behålla): ");
    String? newName = userInput.getUserInput();

    stdout.write("Ange nytt personnummer (lämna tomt för att behålla): ");
    String? newPersonnummer = userInput.getUserInput();

    newName = (newName?.isEmpty ?? true) ? currentPerson.namn : newName;
    newPersonnummer = (newPersonnummer?.isEmpty ?? true)
        ? currentPerson.personnummer
        : newPersonnummer;

    Person updatedPerson = Person(
        id: currentPerson.id, namn: newName!, personnummer: newPersonnummer!);

    await personRepo.update(id, updatedPerson);

    // **Lösning: Vänta en kort tid innan ny hämtning**
    await Future.delayed(Duration(milliseconds: 200));

    print("\nPerson uppdaterad!\n");

    // **Tvinga hämtning av den senaste listan från databasen**
    await viewAllPersons(personRepo);
  }

  // Tar bort en person

  Future<void> deletePerson(PersonRepo personRepo) async {
    await viewAllPersons(
        personRepo); // Visa befintliga personer innan borttagning

    stdout.write("\nAnge ID på personen du vill ta bort: ");
    int? id = int.tryParse(userInput.getUserInput());

    if (id == null) {
      print("Ogiltigt ID, försök igen.");
      return;
    }

    try {
      await personRepo.delete(id);
      print("\nPerson med ID $id har raderats!\n");
    } catch (e) {
      print("Fel vid borttagning: $e");
    }

    // Visa uppdaterad lista efter borttagning
    await viewAllPersons(personRepo);
  }
}
