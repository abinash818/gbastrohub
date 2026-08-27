import 'dart:io';

void main() {
  File f = File('lib/services/jamakkol_one_page_pdf_service.dart');
  String text = f.readAsStringSync();
  
  // 1. Remove jothidar kurippu
  int start = text.indexOf('<div style=\x22flex: 1; min-height: 15mm; border: 0.3mm solid var(--border-orange); border-radius: 1mm; padding: 1.5mm; margin-top: 1.5mm; display: flex; flex-direction: column; background: #fff;\x22>');
  if (start != -1) {
    int end = text.indexOf('</div>\n          <div class=\x22footer\x22>', start);
    if (end != -1) {
      text = text.substring(0, start) + text.substring(end + 7);
    }
  }

  // 2. Increase font sizes by 10%
  text = text.replaceAllMapped(RegExp(r'font-size:\s*([0-9.]+)mm'), (match) {
    double size = double.parse(match.group(1)!);
    double newSize = size * 1.1;
    return 'font-size: \mm';
  });

  // 3. Fix inner planets (Arudam % 30, Kavippu degree) in PDF
  String oldArudamCode = \x22\x22\x22    double aDeg = (outer['arudam_abs_deg'] ?? 0.0).toDouble();
    int aD = aDeg.floor();
    int aM = ((aDeg - aD) * 60).floor();
    if (rasiMap.containsKey(KPService.SIGNS[arudamIdx % 12])) {
        rasiMap[KPService.SIGNS[arudamIdx % 12]]?.add(\x22<span style='color:red; font-weight:bold'>??? \° \'</span>\x22);
    }
    if (rasiMap.containsKey(KPService.SIGNS[kaviIdx % 12])) {
        rasiMap[KPService.SIGNS[kaviIdx % 12]]?.add(\x22<span style='color:purple; font-weight:bold'>???</span>\x22);
    }\x22\x22\x22;
  
  String newArudamCode = \x22\x22\x22    double aDeg = (outer['arudam_abs_deg'] ?? 0.0).toDouble();
    double aDegInSign = aDeg % 30.0;
    int aD = aDegInSign.floor();
    int aM = ((aDegInSign - aD) * 60).floor();
    if (rasiMap.containsKey(KPService.SIGNS[arudamIdx % 12])) {
        rasiMap[KPService.SIGNS[arudamIdx % 12]]?.add(\x22<span style='color:red; font-weight:bold'>???&nbsp;\:\</span>\x22);
    }
    
    double kDegInSign = 30.0 - aDegInSign;
    if (kDegInSign == 30.0) kDegInSign = 0.0;
    int kD = kDegInSign.floor();
    int kM = ((kDegInSign - kD) * 60).floor();
    if (rasiMap.containsKey(KPService.SIGNS[kaviIdx % 12])) {
        rasiMap[KPService.SIGNS[kaviIdx % 12]]?.add(\x22<span style='color:purple; font-weight:bold'>???&nbsp;\:\</span>\x22);
    }\x22\x22\x22;
    
  text = text.replaceAll(oldArudamCode, newArudamCode);

  // 4. Fix outer planets DD:MM
  text = text.replaceAll(
    \x22items.add(\\\x22\ \&deg; \'\\\x22);\x22,
    \x22items.add(\\\x22\&nbsp;\:\\\\x22);\x22
  );
  
  // 5. Fix inner planets DD:MM in PDF
  String oldInnerCode = \x22\x22\x22      if (pKey == 'lagna') {
        String jUdayamSign = KPService.SIGNS[udayamIdx % 12];
        double jUdayamDeg = (outer['udayam_abs_deg'] ?? 0.0) % 30;
        int jd = jUdayamDeg.floor();
        int jm = ((jUdayamDeg - jd) * 60).floor();
        if (rasiMap.containsKey(jUdayamSign)) rasiMap[jUdayamSign]?.add(\x22<span style='color:green; font-weight:bold'>?? \° \'</span>\x22);
      } else {
        String k = pKey.toString();
        String pName = KPService.TAMIL_PLANET_SHORT[k[0].toUpperCase() + k.substring(1)] ?? k;
        if (k == 'sun') pName = '??';
        if (k == 'moon') pName = '???';
        if (rasiMap.containsKey(sign)) rasiMap[sign]!.add(\x22\ \° \'\x22);
      }\x22\x22\x22;
      
  String newInnerCode = \x22\x22\x22      if (pKey == 'lagna') {
        String jUdayamSign = KPService.SIGNS[udayamIdx % 12];
        double jUdayamDeg = (outer['udayam_abs_deg'] ?? 0.0) % 30;
        int jd = jUdayamDeg.floor();
        int jm = ((jUdayamDeg - jd) * 60).floor();
        if (rasiMap.containsKey(jUdayamSign)) rasiMap[jUdayamSign]?.add(\x22<span style='color:green; font-weight:bold'>??&nbsp;\:\</span>\x22);
      } else {
        String k = pKey.toString();
        String pName = KPService.TAMIL_PLANET_SHORT[k[0].toUpperCase() + k.substring(1)] ?? k;
        if (k == 'sun') pName = '??';
        if (k == 'moon') pName = '???';
        if (rasiMap.containsKey(sign)) rasiMap[sign]!.add(\x22\&nbsp;\:\\x22);
      }\x22\x22\x22;
      
  text = text.replaceAll(oldInnerCode, newInnerCode);

  f.writeAsStringSync(text);
  print('Done!');
}
