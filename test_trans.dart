import 'dart:io';

void main() {
  String val = "ஆண்";
  print("Val length: ${val.length}");
  print("Val characters: ${val.runes.toList()}");
  
  String mapVal = "ஆண்"; // what is in tMap
  print("MapVal length: ${mapVal.length}");
  print("MapVal characters: ${mapVal.runes.toList()}");
  print("Are they equal? ${val == mapVal}");
}
