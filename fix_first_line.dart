import 'dart:io';

void main() {
  File f = File('lib/services/jamakkol_one_page_pdf_service.dart');
  List<String> lines = f.readAsLinesSync();
  lines[0] = "import 'dart:io';";
  f.writeAsStringSync(lines.join('\n'));
  print('Fixed first line');
}
