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