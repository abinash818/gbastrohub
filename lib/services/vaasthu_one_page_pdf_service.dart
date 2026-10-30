import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tamil_pdf_shaper/tamil_pdf_shaper.dart';
import 'gp_vaasthu_service.dart';
import 'settings_service.dart';

class VaasthuPoruthamPdfItem {
  final int sNo;
  final String name;
  final String value;
  final String status; // 'உ', 'ம', 'அ'
  final String statusText; // 'உத்தமம்', 'மத்திமம்', 'அதமம்'
  final bool isGood;
  final String symbol; // '✓', '=', '✗'

  const VaasthuPoruthamPdfItem({
    required this.sNo,
    required this.name,
    required this.value,
    required this.status,
    required this.statusText,
    required this.isGood,
    required this.symbol,
  });
}

class VaasthuOnePagePdfService {
  static pw.Font? _headingFont;
  static pw.Font? _bodyFont;

  static const List<String> tamilNakshatras = [
    "அசுவனி", "பரணி", "கிருத்திகை", "ரோகிணி", "மிருகசீர்ஷம்", "திருவாதிரை",
    "புனர்பூசம்", "பூசம்", "ஆயில்யம்", "மகம்", "பூரம்", "உத்திரம்",
    "அஸ்தம்", "சித்திரை", "சுவாதி", "விசாகம்", "அனுஷம்", "கேட்டை",
    "மூலம்", "பூராடம்", "உத்திராடம்", "திருவோணம்", "அவிட்டம்", "சதயம்",
    "பூரட்டாதி", "உத்திரட்டாதி", "ரேவதி"
  ];

  static const List<String> tamilRasis = [
    "மேஷம்", "ரிஷபம்", "மிதுனம்", "கடகம்", "சிம்மம்", "கன்னி",
    "துலாம்", "விருச்சிகம்", "தனுசு", "மகரம்", "கும்பம்", "மீனம்"
  ];

  static Future<void> _initFonts() async {
    if (_headingFont == null || _bodyFont == null) {
      try {
        _headingFont = await TamilPdfFont.loadCustomFont('assets/fonts/Uni_Ila.Sundaram-02_shaped.ttf');
        _bodyFont = await TamilPdfFont.loadCustomFont('assets/fonts/Uni_Ila.Sundaram-05_shaped.ttf');
      } catch (e) {
        debugPrint("Error loading shaped fonts, falling back: $e");
        _headingFont = await TamilPdfFont.load();
        _bodyFont = _headingFont;
      }
    }
  }

  /// Builds the 26 poruthams list from GpKuzhiResult
  static List<VaasthuPoruthamPdfItem> buildPoruthamList(
    GpKuzhiResult res, {
    int thithiMethod = 1,
    int boothamMethod = 1,
  }) {
    final String ownerGana = (res.ownerNakshatra >= 1 && res.ownerNakshatra <= 27)
        ? tamilNakshatras[res.ownerNakshatra - 1]
        : 'அசுவனி';

    final Map<String, dynamic> ganaMatch = GpVaasthuService.evaluateGanaMatch(
      res.nakshatra.gana,
      // Pass owner gana
      _getStarGana(res.ownerNakshatra),
    );
    final bool isGanaGood = (ganaMatch['isGood'] as bool?) ?? false;

    VaasthuPoruthamPdfItem item({
      required int sNo,
      required String name,
      required String value,
      required String status,
      required String statusText,
      required bool isGood,
      String? customSymbol,
    }) {
      final String symbol = customSymbol ?? (status == 'உ' ? 'சுபம்' : (status == 'ம' ? 'மத்திமம்' : 'தீமை'));
      return VaasthuPoruthamPdfItem(
        sNo: sNo,
        name: name,
        value: value,
        status: status,
        statusText: statusText,
        isGood: isGood,
        symbol: symbol,
      );
    }


    // 9. Thithi Calculation based on thithiMethod
    final bool isThithiM1 = thithiMethod == 1;
    final activeThithi = isThithiM1 ? res.thithi1 : res.thithi2;
    final String activeThithiName = activeThithi.name.replaceAll('வ. ', 'வளர். ').replaceAll('தே. ', 'தேய். ');
    final String statusThithi = activeThithi.status.contains('மத்திமம்') ? 'ம' : (activeThithi.isGood ? 'உ' : 'அ');
    final String statusTextThithi = activeThithi.status.contains('மத்திமம்') ? 'மத்திமம்' : (activeThithi.isGood ? 'உத்தமம்' : 'அதமம்');

    // 11. Bootham Calculation based on boothamMethod
    final bool isBoothamM1 = boothamMethod == 1;
    final activeBootham = isBoothamM1 ? res.bootham1 : res.bootham2;
    final int activeBoothamNumber = isBoothamM1 ? res.bootham1Number : res.bootham2Number;
    final String activeBoothamName = '$activeBoothamNumber (${activeBootham.name.split(' ')[0]})';
    final String statusBootham = activeBootham.status.contains('மத்திமம்') ? 'ம' : (activeBootham.isGood ? 'உ' : 'அ');
    final String statusTextBootham = activeBootham.status.contains('மத்திமம்') ? 'மத்திமம்' : (activeBootham.isGood ? 'உத்தமம்' : 'அதமம்');

    return [
      item(
        sNo: 1,
        name: 'கற்பம்',
        value: '${res.garbhamNumber} (${res.garbham.name.split(' ')[0]})',
        status: res.garbham.status.contains('மத்திமம்') ? 'ம' : (res.garbham.isGood ? 'உ' : 'அ'),
        statusText: res.garbham.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.garbham.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.garbham.isGood,
      ),
      item(
        sNo: 2,
        name: 'இலாபம்',
        value: '${res.aadhayamNumber}',
        status: res.aadhayam.isGood ? 'உ' : 'அ',
        statusText: res.aadhayam.isGood ? 'உத்தமம்' : 'அதமம்',
        isGood: res.aadhayam.isGood,
      ),
      item(
        sNo: 3,
        name: 'செலவு',
        value: '${res.virayamNumber}',
        status: res.virayam.status.contains('மத்திமம்') ? 'ம' : (res.virayam.isGood ? 'உ' : 'அ'),
        statusText: res.virayam.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.virayam.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.virayam.isGood,
      ),
      item(
        sNo: 4,
        name: 'யோனி',
        value: '${res.yoniNumber} (${res.yoni.name.split(' ')[0]})',
        status: res.yoni.status.contains('மத்திமம்') ? 'ம' : (res.yoni.isGood ? 'உ' : 'அ'),
        statusText: res.yoni.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.yoni.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.yoni.isGood,
      ),
      item(
        sNo: 5,
        name: 'நட்சத்திரம்',
        value: '${res.nakshatraNumber} (${res.nakshatra.name})',
        status: res.nakshatra.status.contains('மத்திமம்') ? 'ம' : (res.nakshatra.isGood ? 'உ' : 'அ'),
        statusText: res.nakshatra.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.nakshatra.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.nakshatra.isGood,
      ),
      item(
        sNo: 6,
        name: 'கிழமை',
        value: '${res.vaara.dayName.split(' ')[0]} (${res.vaaraNumber})',
        status: res.vaara.status.contains('மத்திமம்') ? 'ம' : (res.vaara.isGood ? 'உ' : 'அ'),
        statusText: res.vaara.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.vaara.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.vaara.isGood,
      ),
      item(
        sNo: 7,
        name: 'அம்சம்',
        value: '${res.amsaNumber} (${res.amsa.effect.replaceAll(' உண்டாகும்', '')})',
        status: res.amsa.status.contains('மத்திமம்') ? 'ம' : (res.amsa.isGood ? 'உ' : 'அ'),
        statusText: res.amsa.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.amsa.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.amsa.isGood,
      ),
      item(
        sNo: 8,
        name: 'வம்சம்',
        value: '${res.vamsamNumber} (${res.vamsam.name})',
        status: res.vamsam.status.contains('மத்திமம்') ? 'ம' : (res.vamsam.isGood ? 'உ' : 'அ'),
        statusText: res.vamsam.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.vamsam.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.vamsam.isGood,
      ),
      item(
        sNo: 9,
        name: 'திதி',
        value: activeThithiName,
        status: statusThithi,
        statusText: statusTextThithi,
        isGood: activeThithi.isGood,
      ),
      item(
        sNo: 10,
        name: 'இராசி (மனைவி)',
        value: '${res.rasiNumber} (${res.rasi.name})',
        status: res.rasi.status.contains('மத்திமம்') ? 'ம' : (res.rasi.isGood ? 'உ' : 'அ'),
        statusText: res.rasi.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.rasi.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.rasi.isGood,
      ),
      item(
        sNo: 11,
        name: 'பூதம்',
        value: activeBoothamName,
        status: statusBootham,
        statusText: statusTextBootham,
        isGood: activeBootham.isGood,
      ),
      item(
        sNo: 12,
        name: 'கணம்',
        value: res.nakshatra.gana,
        status: isGanaGood ? 'உ' : 'அ',
        statusText: isGanaGood ? 'உத்தமம்' : 'அதமம்',
        isGood: isGanaGood,
      ),
      item(
        sNo: 13,
        name: 'நேத்திரம்',
        value: '${res.nethiram.eyes} கண் (${res.nethiram.title.split(' ')[0]})',
        status: res.nethiram.eyes == 2 ? 'உ' : (res.nethiram.eyes == 1 ? 'ம' : 'அ'),
        statusText: res.nethiram.eyes == 2 ? 'உத்தமம்' : (res.nethiram.eyes == 1 ? 'மத்திமம்' : 'அதமம்'),
        isGood: res.nethiram.eyes > 0,
      ),
      item(
        sNo: 14,
        name: 'வயது',
        value: '${res.age.age} (${res.age.status.split(' ')[0]})',
        status: res.age.age >= 51 ? 'உ' : (res.age.age >= 28 ? 'ம' : 'அ'),
        statusText: res.age.age >= 51 ? 'உத்தமம்' : (res.age.age >= 28 ? 'மத்திமம்' : 'அதமம்'),
        isGood: res.age.isGood,
      ),
      item(
        sNo: 15,
        name: 'தாராபலன்',
        value: '${res.tharaPhalan.remainder} (${res.tharaPhalan.tharaName})',
        status: res.tharaPhalan.status.contains('மத்திமம்') ? 'ம' : (res.tharaPhalan.isGood ? 'உ' : 'அ'),
        statusText: res.tharaPhalan.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.tharaPhalan.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.tharaPhalan.isGood,
      ),
      item(
        sNo: 16,
        name: 'சூத்திரம்',
        value: '${res.soothiramNumber} (${res.soothiram.name.split(' ')[0]})',
        status: res.soothiram.status.contains('மத்திமம்') || res.soothiram.number == 4 ? 'ம' : (res.soothiram.isGood ? 'உ' : 'அ'),
        statusText: res.soothiram.status.contains('மத்திமம்') || res.soothiram.number == 4 ? 'மத்திமம்' : (res.soothiram.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.soothiram.isGood,
      ),
      item(
        sNo: 17,
        name: 'நாமயோகம்',
        value: '${res.namaYogaNumber} (${res.namaYoga.name})',
        status: res.namaYoga.status.contains('மத்திமம்') ? 'ம' : (res.namaYoga.isGood ? 'உ' : 'அ'),
        statusText: res.namaYoga.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.namaYoga.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.namaYoga.isGood,
      ),
      item(
        sNo: 18,
        name: 'பஞ்சகம்',
        value: '${res.panchaka.number} (${res.panchaka.name})',
        status: res.panchaka.status.contains('மத்திமம்') ? 'ம' : (res.panchaka.isGood ? 'உ' : 'அ'),
        statusText: res.panchaka.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.panchaka.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.panchaka.isGood,
      ),
      item(
        sNo: 19,
        name: 'அமிர்தாதியோகம்',
        value: '(${res.amirthathiYoga.code}) ${res.amirthathiYoga.name.split(' ')[0]}',
        status: res.amirthathiYoga.status.contains('மத்திமம்') ? 'ம' : (res.amirthathiYoga.isGood ? 'உ' : 'அ'),
        statusText: res.amirthathiYoga.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.amirthathiYoga.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.amirthathiYoga.isGood,
      ),
      item(
        sNo: 20,
        name: 'கரணம்',
        value: '${res.karanaNumber} (${res.karana.name})',
        status: res.karana.status.contains('மத்திமம்') ? 'ம' : (res.karana.isGood ? 'உ' : 'அ'),
        statusText: res.karana.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.karana.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.karana.isGood,
      ),
      item(
        sNo: 21,
        name: 'சந்திரபலம்',
        value: '${res.chandraPhalan.number} (${res.chandraPhalan.name})',
        status: res.chandraPhalan.status.contains('மத்திமம்') ? 'ம' : (res.chandraPhalan.isGood ? 'உ' : 'அ'),
        statusText: res.chandraPhalan.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.chandraPhalan.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.chandraPhalan.isGood,
      ),
      item(
        sNo: 22,
        name: 'அ.இலட்சுமி',
        value: '${res.ashtaLakshmiNumber} (${res.ashtaLakshmi.name})',
        status: res.ashtaLakshmi.status.contains('மத்திமம்') ? 'ம' : (res.ashtaLakshmi.isGood ? 'உ' : 'அ'),
        statusText: res.ashtaLakshmi.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.ashtaLakshmi.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.ashtaLakshmi.isGood,
      ),
      item(
        sNo: 23,
        name: 'அ.திக்.பாலகர்',
        value: '${res.dikpalakarNumber} (${res.dikpalakar.name.split(' ')[0]})',
        status: res.dikpalakar.status.contains('மத்திமம்') ? 'ம' : (res.dikpalakar.isGood ? 'உ' : 'அ'),
        statusText: res.dikpalakar.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.dikpalakar.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.dikpalakar.isGood,
      ),
      item(
        sNo: 24,
        name: 'அ.திக்.தேவதை',
        value: '${res.athidevathaiNumber} (${res.athidevathai.name.split(' ')[0]})',
        status: res.athidevathai.status.contains('மத்திமம்') ? 'ம' : (res.athidevathai.isGood ? 'உ' : 'அ'),
        statusText: res.athidevathai.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.athidevathai.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.athidevathai.isGood,
      ),
      item(
        sNo: 25,
        name: 'புருஷ ராசி',
        value: '${res.purushaRasiNumber} (${res.purushaRasi.name})',
        status: res.purushaRasi.status.contains('மத்திமம்') ? 'ம' : (res.purushaRasi.isGood ? 'உ' : 'அ'),
        statusText: res.purushaRasi.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.purushaRasi.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.purushaRasi.isGood,
      ),
      item(
        sNo: 26,
        name: 'குண பலன்',
        value: '${res.gunaNumber} (${res.guna.name})',
        status: res.guna.status.contains('மத்திமம்') ? 'ம' : (res.guna.isGood ? 'உ' : 'அ'),
        statusText: res.guna.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.guna.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.guna.isGood,
      ),
    ];
  }

  static String _getStarGana(int starIndex) {
    if (starIndex >= 1 && starIndex <= 27) {
      return GpVaasthuService.nakshatraList[starIndex - 1].gana;
    }
    return 'தேவ கணம்';
  }

  /// Generates the pure Dart 1-Page A4 PDF binary for Vaasthu Poruthangal
  static Future<Uint8List> generate({
    required GpKuzhiResult result,
    required GpVaasthuRegion region,
    required int ownerNakshatraIndex,
    required int ownerRasiIndex,
    String? customLengthText,
    String? customWidthText,
    int thithiMethod = 1,
    int boothamMethod = 1,
    String? clientName,
  }) async {
    await _initFonts();
    final astro = await SettingsService.getAstrologerDetails();
    final customLogoBase64 = await SettingsService.getCustomLogo();

    Uint8List? ganapathyImg;
    Uint8List? appLogoImg;
    Uint8List? customLogoImg;

    try {
      ganapathyImg = (await rootBundle.load('assets/images/ganapathy.png')).buffer.asUint8List();
    } catch (_) {}

    try {
      appLogoImg = (await rootBundle.load('assets/images/APPLOGO.png')).buffer.asUint8List();
    } catch (_) {
      try {
        appLogoImg = (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List();
      } catch (_) {}
    }

    if (customLogoBase64 != null && customLogoBase64.isNotEmpty) {
      try {
        customLogoImg = base64Decode(customLogoBase64);
      } catch (_) {}
    }

    final pdf = pw.Document();

    // Theme Palette
    final primaryColor = PdfColor.fromHex('#5D1204');     // Deep Maroon
    final goldAccent = PdfColor.fromHex('#B58D3D');       // Temple Gold
    final borderCol = PdfColor.fromHex('#C9B087');        // Border Gold
    final bgIvory = PdfColor.fromHex('#FFFDF9');          // Ivory background
    final textDark = PdfColor.fromHex('#212121');         // Text
    final textMuted = PdfColor.fromHex('#666666');        // Muted Text
    final greenGood = PdfColor.fromHex('#1B5E20');        // Green for Uthumam
    final orangeMid = PdfColor.fromHex('#E65100');        // Orange for Mathimam
    final redBad = PdfColor.fromHex('#B71C1C');           // Red for Athamam

    final String shopName = astro['astrologer_company'] ?? "GB ASTRO வாஸ்து மையம்";
    final String astroName = astro['astrologer_name'] ?? "";
    final String phone = astro['astrologer_phone'] ?? "";
    final String address = astro['astrologer_address'] ?? "";

    // Dimensions String
    String lengthWidthStr;
    if (customLengthText != null && customWidthText != null) {
      lengthWidthStr = "$customLengthText × $customWidthText";
    } else if (result.length1Ft > 0) {
      final lFt = result.length1Ft.toInt();
      final lIn = result.length1In.toInt();
      final wFt = result.width1Ft.toInt();
      final wIn = result.width1In.toInt();
      lengthWidthStr = "${lFt}அடி ${lIn}அங்  ×  ${wFt}அடி ${wIn}அங்";
    } else {
      lengthWidthStr = "சுற்றளவு: ${result.perimeterFt.toStringAsFixed(1)} அடி";
    }

    final String kolStr = "${region.nameTa} (${region.kolInches}\")";
    final String kuzhiStr = "${result.kuzhi.toStringAsFixed(2)} குழி\n(${result.sqft.toStringAsFixed(1)} ச.அடி)";
    final String ayadiStr = "${result.roundedAyadi}";

    final String ownerStarName = (ownerNakshatraIndex >= 1 && ownerNakshatraIndex <= 27)
        ? tamilNakshatras[ownerNakshatraIndex - 1]
        : "அசுவனி";
    final String ownerRasiName = (ownerRasiIndex >= 1 && ownerRasiIndex <= 12)
        ? tamilRasis[ownerRasiIndex - 1]
        : "மேஷம்";
    final String ownerDetailsStr = "$ownerStarName / $ownerRasiName";

    // 26 Items calculation
    final items = buildPoruthamList(result, thithiMethod: thithiMethod, boothamMethod: boothamMethod);
    final int uCount = items.where((i) => i.status == 'உ').length;
    final int mCount = items.where((i) => i.status == 'ம').length;
    final int aCount = items.where((i) => i.status == 'அ').length;

    final int uPercent = uCount * 4;
    final int mPercent = mCount * 2;
    final int aPercent = aCount * 0;
    final int totalPercent = uPercent + mPercent + aPercent;

    final String verdictText = totalPercent >= 60
        ? 'உத்தம சுப மனை (நன்று)'
        : (totalPercent >= 40 ? 'மத்திம மனை (சுமார்)' : 'அதம மனை (தவிர்)');

    final PdfColor verdictColor = totalPercent >= 60
        ? greenGood
        : (totalPercent >= 40 ? orangeMid : redBad);

    // Split 26 items into 2 columns: Left (1-13) and Right (14-26)
    final leftItems = items.sublist(0, 13);
    final rightItems = items.sublist(13, 26);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: primaryColor, width: 1.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // -------------------------------------------------------------
                // 1. TOP HEADER: Pillaiyar Suzhi & Astrologer Banner
                // -------------------------------------------------------------
                pw.Center(
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text("உ".toTamilPdf, style: pw.TextStyle(font: _headingFont, fontSize: 13, color: primaryColor)),
                      pw.Container(width: 16, height: 0.8, color: primaryColor, margin: const pw.EdgeInsets.only(top: 0.5)),
                      pw.Container(width: 16, height: 0.8, color: primaryColor, margin: const pw.EdgeInsets.only(top: 0.5)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 2),

                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderCol, width: 0.8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    color: bgIvory,
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Left: God image (Ganapathy)
                      if (ganapathyImg != null)
                        pw.Container(
                          width: 40,
                          height: 40,
                          child: pw.Image(pw.MemoryImage(ganapathyImg), fit: pw.BoxFit.contain),
                        )
                      else if (customLogoImg != null)
                        pw.Container(
                          width: 40,
                          height: 40,
                          child: pw.ClipOval(
                            child: pw.Image(pw.MemoryImage(customLogoImg), fit: pw.BoxFit.cover),
                          ),
                        )
                      else
                        pw.SizedBox(width: 40),

                      // Center: Astrologer Details
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              shopName.toTamilPdf,
                              style: pw.TextStyle(font: _headingFont, fontSize: 12.5, color: primaryColor),
                            ),
                            if (astroName.isNotEmpty)
                              pw.Text(
                                astroName.toTamilPdf,
                                style: pw.TextStyle(font: _headingFont, fontSize: 9.0, color: textDark),
                              ),
                            pw.Text(
                              "$address ${phone.isNotEmpty ? '| செல்: $phone' : ''}".toTamilPdf,
                              style: pw.TextStyle(font: _bodyFont, fontSize: 7.5, color: textMuted),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Right: Astrologer Image (customLogo) or App Logo
                      if (customLogoImg != null)
                        pw.Container(
                          width: 40,
                          height: 40,
                          child: pw.ClipOval(
                            child: pw.Image(pw.MemoryImage(customLogoImg), fit: pw.BoxFit.cover),
                          ),
                        )
                      else if (appLogoImg != null)
                        pw.Container(
                          width: 40,
                          height: 40,
                          child: pw.Image(pw.MemoryImage(appLogoImg), fit: pw.BoxFit.contain),
                        )
                      else
                        pw.SizedBox(width: 40),
                    ],
                  ),
                ),
                pw.SizedBox(height: 3),

                // -------------------------------------------------------------
                // 2. TITLE BAR with SOFTWARE CREDIT
                // -------------------------------------------------------------
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 8),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        "மனைபொருத்தப் பலன்கள்".toTamilPdf,
                        style: pw.TextStyle(font: _headingFont, fontSize: 12.0, color: PdfColors.white),
                      ),
                      pw.Container(
                        margin: const pw.EdgeInsets.only(top: 2),
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 1.8),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#2D0802'),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                          border: pw.Border.all(color: PdfColor.fromHex('#FFE082'), width: 0.6),
                        ),
                        child: pw.Text(
                          "SOFTWARE DEVELOPED BY GBASTRO SUITE / MO. NO - 9787067910 / 7373411173",
                          style: pw.TextStyle(
                            font: _headingFont,
                            fontSize: 7.0,
                            color: PdfColor.fromHex('#FFE082'), // Bright Radiant Temple Gold
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),

                ),
                pw.SizedBox(height: 3),

                // -------------------------------------------------------------
                // 3. PARAMETERS BOX (ம.கோல், நீளம்-அகலம், குழி, ஆயாதி, உ.நட்சத்திரம்/ராசி)
                // -------------------------------------------------------------
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderCol, width: 0.8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    color: bgIvory,
                  ),
                  child: pw.Table(
                    border: pw.TableBorder(
                      verticalInside: pw.BorderSide(color: borderCol, width: 0.8),
                    ),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2.0),
                      1: const pw.FlexColumnWidth(2.6),
                      2: const pw.FlexColumnWidth(1.8),
                      3: const pw.FlexColumnWidth(1.4),
                      4: const pw.FlexColumnWidth(2.4),
                    },
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          border: pw.Border(bottom: pw.BorderSide(color: borderCol, width: 0.8)),
                        ),
                        children: [
                          _paramHeaderCell("ம.கோல்"),
                          _paramHeaderCell("நீளம் - அகலம்"),
                          _paramHeaderCell("குழி எண்"),
                          _paramHeaderCell("ஆயாதி எண்"),
                          _paramHeaderCell("உ.நட்சத்திரம் / ராசி"),
                        ],
                      ),

                      // Value Row
                      pw.TableRow(
                        children: [
                          _paramValueCell(kolStr),
                          _paramValueCell(lengthWidthStr),
                          _paramValueCell(kuzhiStr),
                          _paramValueCell(ayadiStr, isBoldLarge: true),
                          _paramValueCell(ownerDetailsStr),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 4),

                // -------------------------------------------------------------
                // 4. 26 பொருத்த அட்டவணை HEADER
                // -------------------------------------------------------------
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "26 பொருத்த அட்டவணை".toTamilPdf,
                        style: pw.TextStyle(font: _headingFont, fontSize: 9.5, color: PdfColors.white),
                      ),
                      pw.Text(
                        "மனை வகை: ${result.garbham.name} | ${result.garbham.direction}".toTamilPdf,
                        style: pw.TextStyle(font: _bodyFont, fontSize: 8.0, color: goldAccent),
                      ),

                    ],
                  ),
                ),
                pw.SizedBox(height: 2),

                // -------------------------------------------------------------
                // 5. 26 PORUTHAMS TABLE (Left: 1-13, Right: 14-26)
                // -------------------------------------------------------------
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Column (1 to 13)
                    pw.Expanded(
                      child: _buildSubPoruthamTable(
                        items: leftItems,
                        primaryColor: primaryColor,
                        borderCol: borderCol,
                        bgIvory: bgIvory,
                        greenGood: greenGood,
                        orangeMid: orangeMid,
                        redBad: redBad,
                      ),
                    ),
                    pw.SizedBox(width: 4),
                    // Right Column (14 to 26)
                    pw.Expanded(
                      child: _buildSubPoruthamTable(
                        items: rightItems,
                        primaryColor: primaryColor,
                        borderCol: borderCol,
                        bgIvory: bgIvory,
                        greenGood: greenGood,
                        orangeMid: orangeMid,
                        redBad: redBad,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),

                // -------------------------------------------------------------
                // 6. மொத்த பொருத்த சுருக்கம் (SUMMARY SCORECARD)
                // -------------------------------------------------------------
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderCol, width: 0.8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    color: bgIvory,
                  ),
                  child: pw.Column(
                    children: [
                      // Section Header
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 8),
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          borderRadius: const pw.BorderRadius.only(
                            topLeft: pw.Radius.circular(3),
                            topRight: pw.Radius.circular(3),
                          ),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "மொத்த பொருத்த சுருக்கம்".toTamilPdf,
                              style: pw.TextStyle(font: _headingFont, fontSize: 9.5, color: PdfColors.white),
                            ),
                            pw.Text(
                              "மொத்த பலன்கள்: 26".toTamilPdf,
                              style: pw.TextStyle(font: _headingFont, fontSize: 8.5, color: goldAccent),
                            ),
                          ],
                        ),
                      ),

                      // Result Bar: High Contrast, Crystal Clear, No Calculations
                      pw.Container(
                        width: double.infinity,
                        margin: const pw.EdgeInsets.all(5),
                        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          border: pw.Border.all(color: goldAccent, width: 0.8),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            // Left: Total Percentage Badge + Verdict Text
                            pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: pw.BoxDecoration(
                                    color: verdictColor,
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                                    border: pw.Border.all(color: goldAccent, width: 0.6),
                                  ),
                                  child: pw.Row(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    children: [
                                      pw.Text(
                                        "பொருத்தம்: ".toTamilPdf,
                                        style: pw.TextStyle(font: _headingFont, fontSize: 8.5, color: PdfColors.white),
                                      ),
                                      pw.Text(
                                        "$totalPercent%",
                                        style: pw.TextStyle(font: _headingFont, fontSize: 11.5, color: goldAccent),
                                      ),
                                    ],
                                  ),
                                ),
                                pw.SizedBox(width: 8),
                                pw.Text(
                                  "இறுதி முடிவு: $verdictText".toTamilPdf,
                                  style: pw.TextStyle(font: _headingFont, fontSize: 9.5, color: goldAccent),
                                ),
                              ],
                            ),

                            // Right: Manai Vagai (Crisp White Text on Dark Red Background)
                            pw.Text(
                              "மனை வகை: ${result.garbham.name} (${result.garbham.direction})".toTamilPdf,
                              style: pw.TextStyle(font: _headingFont, fontSize: 8.5, color: PdfColors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),


                // -------------------------------------------------------------
                // 7. FOOTER NOTE
                // -------------------------------------------------------------
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: borderCol, width: 0.6)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "வாஸ்து சாஸ்திர விதிகளின்படி மனை அமைத்து சகல ஐஸ்வர்யங்களும் பெற்று வாழ வாழ்த்துகிறோம்.".toTamilPdf,
                        style: pw.TextStyle(font: _bodyFont, fontSize: 6.5, color: textMuted),
                      ),
                      pw.Text(
                        "GB ASTRO SUITE".toTamilPdf,
                        style: pw.TextStyle(font: _headingFont, fontSize: 7.0, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------

  static pw.Widget _paramHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 3),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text.toTamilPdf,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _headingFont, fontSize: 8.0, color: PdfColors.white),
      ),
    );
  }

  static pw.Widget _paramValueCell(String text, {bool isBoldLarge = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 3.5, horizontal: 3),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text.toTamilPdf,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: isBoldLarge ? _headingFont : _bodyFont,
          fontSize: isBoldLarge ? 9.5 : 7.2,
          color: isBoldLarge ? PdfColor.fromHex('#5D1204') : PdfColor.fromHex('#212121'),
        ),
      ),
    );
  }

  static pw.Widget _buildSubPoruthamTable({
    required List<VaasthuPoruthamPdfItem> items,
    required PdfColor primaryColor,
    required PdfColor borderCol,
    required PdfColor bgIvory,
    required PdfColor greenGood,
    required PdfColor orangeMid,
    required PdfColor redBad,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderCol, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Table(
        border: pw.TableBorder(
          horizontalInside: pw.BorderSide(color: borderCol.shade(0.3), width: 0.5),
          verticalInside: pw.BorderSide(color: borderCol.shade(0.3), width: 0.5),
        ),
        columnWidths: {
          0: const pw.FixedColumnWidth(18), // #
          1: const pw.FlexColumnWidth(2.6), // பொருத்தம்
          2: const pw.FlexColumnWidth(3.8), // மதிப்பு
          3: const pw.FixedColumnWidth(20), // நிலை
          4: const pw.FlexColumnWidth(2.2), // பலன்
        },
        children: [
          // Table Header
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: primaryColor,
              border: pw.Border(bottom: pw.BorderSide(color: borderCol, width: 0.8)),
            ),
            children: [
              _subTableHeader("#"),
              _subTableHeader("பொருத்தம்"),
              _subTableHeader("மதிப்பு / விவரம்"),
              _subTableHeader("நிலை"),
              _subTableHeader("முடிவு"),
            ],
          ),
          // Table Rows
          ...items.asMap().entries.map((entry) {
            final int idx = entry.key;
            final item = entry.value;
            final bool isEven = idx.isEven;
            final PdfColor rowBg = isEven ? bgIvory : PdfColors.white;

            final PdfColor statusColor = item.status == 'உ'
                ? greenGood
                : (item.status == 'ம' ? orangeMid : redBad);

            return pw.TableRow(
              decoration: pw.BoxDecoration(color: rowBg),
              children: [
                // 1. S.No
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.2, horizontal: 2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    "${item.sNo}",
                    style: pw.TextStyle(font: _bodyFont, fontSize: 6.8, color: PdfColors.black),
                  ),
                ),
                // 2. Name
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.2, horizontal: 3),
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    item.name.toTamilPdf,
                    style: pw.TextStyle(font: _headingFont, fontSize: 7.0, color: primaryColor),
                  ),
                ),
                // 3. Value
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.2, horizontal: 3),
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    item.value.toTamilPdf,
                    style: pw.TextStyle(font: _bodyFont, fontSize: 6.8, color: PdfColor.fromHex('#212121')),
                    maxLines: 1,
                  ),
                ),
                // 4. Status (உ / ம / அ)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.2, horizontal: 2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    item.status.toTamilPdf,
                    style: pw.TextStyle(font: _headingFont, fontSize: 7.0, color: statusColor),
                  ),
                ),
                // 5. Result (உத்தமம் / மத்திமம் / அதமம்)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.2, horizontal: 2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    item.statusText.toTamilPdf,
                    style: pw.TextStyle(font: _headingFont, fontSize: 6.5, color: statusColor),
                  ),
                ),

              ],
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _subTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 2),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text.toTamilPdf,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _headingFont, fontSize: 7.2, color: PdfColors.white),
      ),
    );
  }
}
