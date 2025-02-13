class MenuUtil {
  void printPersonMenu() {
    var options = [
      "1️ Skapa person",
      "2️ Visa alla personer",
      "3️ Uppdatera person",
      "4️ Ta bort person",
      "5️ Återgå till huvudmenyn\n"
    ];
    print("\n MENY:");
    options.forEach((option) => print(option));
  }

  void printParkingMenu() {
    var options = [
      "1️ Lägg till parkering",
      "2️ Visa alla parkeringar",
      "3️ Uppdatera parkering",
      "4️ Ta bort parkering",
      "5️ Återgå till huvudmenyn\n"
    ];
    print("\nMENY:");
    options.forEach((option) => print(option));
  }

  void printParkingSpaceMenu() {
    var options = [
      "1. Lägg till parkeringsplats",
      "2. Visa alla parkeringsplatser",
      "3. Uppdatera parkeringsplats",
      "4. Ta bort parkeringsplats",
      "5. Återgå till huvudmenyn\n"
    ];
    print("\nMENY:");
    options.forEach((option) => print(option));
  }

  void printVehicleMenu() {
    var options = [
      "1. Lägg till fordon",
      "2. Visa alla fordon",
      "3. Uppdatera fordon",
      "4. Ta bort fordon",
      "5️ Återgå till huvudmenyn\n"
    ];
    print("\nMENY:");
    options.forEach((option) => print(option));
  }

  void printMainMenu() {
    var options = [
      "1. Personer",
      "2. Fordon",
      "3. Parkeringsplatser",
      "4. Parkering",
      "5. avsluta\n"
    ];

    options.forEach((option) => print(option));
  }
}
