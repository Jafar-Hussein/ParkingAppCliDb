import 'package:mysql_client/mysql_client.dart';

class Database {
  static Future<MySQLConnection> getConnection() async {
    // Skapa en anslutning till databasen
    var conn = await MySQLConnection.createConnection(
      host: "localhost", // Byt till din databasadress om den är extern
      port: 3306, // Standardport för MySQL
      userName: "root", // Ditt MySQL-användarnamn
      password: "Jafar_Hussein332", // Ditt MySQL-lösenord
      databaseName: "parkingapp", // Ditt databasnamn
    );

    // Anslut till databasen
    await conn.connect();
    return conn;
  }
}
