import 'dart:io';

void main() {
  File f = File('lib/services/jamakkol_one_page_pdf_service.dart');
  String text = f.readAsStringSync();
  
  int start = text.indexOf('<div style=\x22flex: 1; min-height: 15mm; border: 0.3mm solid var(--border-orange); border-radius: 1mm; padding: 1.5mm; margin-top: 1.5mm; display: flex; flex-direction: column; background: #fff;\x22>');
  
  if (start != -1) {
    int end = text.indexOf('</div>\n          <div class=\x22footer\x22>', start);
    if (end != -1) {
      text = text.substring(0, start) + text.substring(end);
    }
  }

  text = text.replaceAllMapped(RegExp(r'font-size:\s*([0-9.]+)mm'), (match) {
    double size = double.parse(match.group(1)!);
    double newSize = size * 1.1;
    return 'font-size: \mm';
  });

  f.writeAsStringSync(text);
  print('Done!');
}
