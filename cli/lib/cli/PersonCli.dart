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
    //sparar alla personer i en lista
    List<Person> persons = await personRepo.getAll();
    //felhantering ifall det inte finns personer
    if (persons.isEmpty) {
      print("Inga personer hittades.");
    } else {
      // itererar igenom hela listan och skriver ut dem
      print("\nLista över alla personer:");
      for (var person in persons) {
        print(
            'ID: ${person.id}, Namn: ${person.namn}, Personnummer: ${person.personnummer}');
      }
    }
  }

  // updaterar personer
  // Uppdaterar en person i databasen
  Future<void> updatePerson(PersonRepo personRepo) async {
    // Visar alla befintliga personer så att användaren vet vilka som kan uppdateras
    await viewAllPersons(personRepo);

    // Frågar användaren vilken person som ska uppdateras
    stdout.write("\nAnge ID för personen du vill uppdatera: ");

    // Konverterar input från en sträng till en integer
    int? id = int.tryParse(userInput.getUserInput());

    // Felhantering om ID är ogiltigt
    if (id == null) {
      print("Ogiltigt ID, försök igen.");
      return;
    }

    // Hämtar personen med det angivna ID:t för att uppdatera den specifika personen
    Person? currentPerson = await personRepo.getById(id);

    // Felhantering om det inte finns någon person med det angivna ID:t
    if (currentPerson == null) {
      print("Ingen person hittades med ID $id.");
      return;
    }

    // Visar nuvarande information om personen för att undvika felaktiga uppdateringar
    print(
        "Nuvarande detaljer: Namn: ${currentPerson.namn},  Personnummer: ${currentPerson.personnummer}");

    // Ber användaren ange nytt namn, lämna tomt om det inte ska ändras
    stdout.write("Ange nytt namn (lämna tomt för att behålla): ");
    String? newName = userInput.getUserInput();

    // Ber användaren ange nytt personnummer, lämna tomt om det inte ska ändras
    stdout.write("Ange nytt personnummer (lämna tomt för att behålla): ");
    String? newPersonnummer = userInput.getUserInput();

    // Om fältet är tomt, behåll den gamla informationen
    newName = (newName?.isEmpty ?? true) ? currentPerson.namn : newName;
    newPersonnummer = (newPersonnummer?.isEmpty ?? true)
        ? currentPerson.personnummer
        : newPersonnummer;

    // Skapar ett uppdaterat person-objekt med det nya eller befintliga värdet
    Person updatedPerson = Person(
        id: currentPerson.id, namn: newName!, personnummer: newPersonnummer!);

    // Uppdaterar personen i databasen/repositoryt
    personRepo.update(id, updatedPerson);

    // Bekräftelsemeddelande till användaren
    print("Person uppdaterad.");
  }

  //tar bort person
  Future<void> deletePerson(PersonRepo personRepo) async {
    //samma här så visas alla i listan
    await viewAllPersons(personRepo);
    stdout.write("\nAnge ID på personen du vill ta bort: ");
    //konverterar id till int
    int? id = int.tryParse(userInput.getUserInput());
    //felhantering
    if (id == null) {
      print("Ogiltigt ID, försök igen.");
      return;
    }

    if (personRepo.getById(id) == null) {
      print("Ingen person hittades med ID $id.");
      return;
    }
    // ropar metoden för att ta bort personen
    personRepo.delete(id);
    //informerar användaren att personen har raderats
    print("Person borttagen.");
  }
}
