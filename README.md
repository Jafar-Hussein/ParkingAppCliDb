# Parking app

En applikation för att hantera parkeringar, fordon och parkeringsplatser.

## Databasstruktur

För att använda denna applikation, skapa följande tabeller i din MySQL-databas. Nedan finns SQL-frågorna för att skapa tabellerna.

### SQL-frågor för att skapa tabeller

```sql
CREATE TABLE `person` (
   `id` INT NOT NULL AUTO_INCREMENT,
   `namn` VARCHAR(255) NOT NULL,
   `personnummer` VARCHAR(20) NOT NULL,
   PRIMARY KEY (`id`),
   UNIQUE KEY `personnummer` (`personnummer`)
);

CREATE TABLE `parkingspace` (
   `id` INT NOT NULL AUTO_INCREMENT,
   `address` VARCHAR(255) NOT NULL,
   `pricePerHour` DOUBLE NOT NULL
);

CREATE TABLE `vehicle` (
   `id` INT NOT NULL AUTO_INCREMENT,
   `registreringsnummer` VARCHAR(20) NOT NULL,
   `typ` VARCHAR(50) NOT NULL,
   `ownerId` INT NOT NULL,
   PRIMARY KEY (`id`),
   UNIQUE KEY `registreringsnummer` (`registreringsnummer`),
   KEY `ownerId` (`ownerId`),
   CONSTRAINT `vehicle_ibfk_1` FOREIGN KEY (`ownerId`) REFERENCES `person` (`id`)
);

CREATE TABLE `parking` (
   `id` INT NOT NULL AUTO_INCREMENT,
   `vehicleId` INT DEFAULT NULL,
   `parkingSpaceId` INT DEFAULT NULL,
   `startTime` DATETIME DEFAULT NULL,
   `endTime` DATETIME DEFAULT NULL,
   `price` DOUBLE DEFAULT '0',
   PRIMARY KEY (`id`),
   KEY `vehicleId` (`vehicleId`),
   KEY `parkingSpaceId` (`parkingSpaceId`),
   CONSTRAINT `parking_ibfk_1` FOREIGN KEY (`vehicleId`) REFERENCES `vehicle` (`id`),
   CONSTRAINT `parking_ibfk_2` FOREIGN KEY (`parkingSpaceId`) REFERENCES `parkingspace` (`id`)
);
```

## Installation

- steg 1: klona repo
git clone https://github.com/Jafar-Hussein/ParkingAppCliDb.git
cd ParkingAppCliDb

- steg 2: Intsallera beroenden
dart pub get

- steg 3: Konfigurera databasen
Följ instruktionerna ovan för att skapa tabellerna i din MySQL-databas.

- steg 4: Starta app
cd till server dart run server.dart, sedan ändra till cli mapp och dart run FirstApp.dart

# API Endpoints

## Parkeringar (Parkings)

### GET /parkings
Hämtar alla parkeringar.

### GET /parkings/<id>
Hämtar en specifik parkering baserat på ID.

### POST /parkings
Skapar en ny parkering.

**Request body example:**
```json
{
  "vehicleId": 1,
  "parkingSpaceId": 2,
  "startTime": "2025-02-25T10:00:00",
  "endTime": "2025-02-25T12:00:00",
  "price": 20.5
}
```
### PUT /parkings/<id>

**Request body example:**
```json
{
  "vehicleId": 1,
  "parkingSpaceId": 2,
  "startTime": "2025-02-25T10:00:00",
  "endTime": "2025-02-25T12:00:00",
  "price": 20.5
}
```
### DELETE /parkings/<id>
Tar bort en specifik parkering baserat på ID.

##Fordon (Vehicles)

### GET /vehicles
Hämtar alla fordon.

### GET /vehicles/<id>
Hämtar ett specifikt fordon baserat på ID.

### POST /vehicles

**Request body example:**

```json
{
  "registreringsnummer": "ABC123",
  "typ": "Bil",
  "ownerId": 1
}

```

### PUT /vehicles/<id>
Uppdaterar ett specifikt fordon baserat på ID.

**Request body example:**

```json
{
  "registreringsnummer": "ABC123",
  "typ": "Bil",
  "ownerId": 1
}

```

### DELETE /vehicles/<id>
Tar bort ett specifikt fordon baserat på ID.

##Personer (Persons)

### GET /persons
Hämtar alla personer.

### GET /persons/<id>
Hämtar en specifik person baserat på ID.

### POST /persons
Skapar en ny person.

**Request body example:**

```json
{
  "namn": "John Doe",
  "personnummer": "1234567890"
}


```

### PUT /persons/<id>
Uppdaterar en specifik person baserat på ID.

**Request body example:**
```json
{
  "namn": "John Doe",
  "personnummer": "1234567890"
}
```

### DELETE /persons/<id>
Tar bort en specifik person baserat på ID.

## Parkeringsplatser (Parking Spaces)

### GET /parkingspaces
Hämtar alla parkeringsplatser.

### GET /parkingspaces/<id>
Hämtar en specifik parkeringsplats baserat på ID.

### POST /parkingspaces
Skapar en ny parkeringsplats.
**Request body example:**
```json
{
  "address": "Storgatan 1",
  "pricePerHour": 15.0
}

```

### PUT /parkingspaces/<id>
Uppdaterar en specifik parkeringsplats baserat på ID.
**Request body example:**
```json
{
  "address": "Storgatan 1",
  "pricePerHour": 15.0
}
```

### DELETE /parkingspaces/<id>
Tar bort en specifik parkeringsplats baserat på ID.