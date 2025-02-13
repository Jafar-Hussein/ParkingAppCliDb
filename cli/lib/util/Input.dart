import 'dart:io';

class Input {
  
  String getUserInput() {
    var input = stdin.readLineSync();
    return input ?? "";
  }
}
