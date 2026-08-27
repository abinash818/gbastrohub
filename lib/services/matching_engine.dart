import 'package:flutter/foundation.dart';
import 'astro_data.dart';
import 'matching_result.dart';

class MatchingEngine {
  static List<MatchingResult> calculateAll(
      String girlNatch, int girlPaatham, String boyNatch, int boyPaatham) {
    List<MatchingResult> results = [];

    results.add(calculateDinam(girlNatch, boyNatch));
    results.add(calculateGanam(girlNatch, boyNatch));
    results.add(calculateMahendram(girlNatch, boyNatch));
    results.add(calculateIsthree(girlNatch, boyNatch));
    results.add(calculateYoni(girlNatch, boyNatch));
    results.add(calculateRaasi(girlNatch, girlPaatham, boyNatch, boyPaatham));
    results.add(calculateRaasiAdhi(girlNatch, girlPaatham, boyNatch, boyPaatham));
    results.add(calculateVasiyam(girlNatch, girlPaatham, boyNatch, boyPaatham));
    results.add(calculateRajju(girlNatch, boyNatch));
    results.add(calculateVedai(girlNatch, boyNatch));
    results.add(calculateNaadi(girlNatch, boyNatch));

    return results;
  }

  static int getNatchIndex(String natch) {
    int idx = AstroData.natchathiraList.indexOf(natch);
    if (idx == -1) {
      debugPrint("Warning: Natchathira '$natch' not found in AstroData. Using default index 0.");
      return 0;
    }
    return idx;
  }

  static MatchingResult calculateDinam(String girlNatch, String boyNatch) {
    int gIdx = getNatchIndex(girlNatch);
    int bIdx = getNatchIndex(boyNatch);
    int distance = (bIdx - gIdx + 27) % 27 + 1;
    int navatara = distance % 9;
    if (navatara == 0) navatara = 9;

    bool isGood = [2, 4, 6, 8, 9].contains(navatara) || distance == 27;
    return MatchingResult(
      name: "தினப் பொருத்தம்",
      result: isGood ? AstroData.matchUththamam : AstroData.matchAthamam,
      points: isGood ? 1.0 : 0.0,
      detail: "தொலைவு: $distance, நவதாரா: $navatara",
      girlValue: girlNatch,
      boyValue: boyNatch,
    );
  }

  static MatchingResult calculateGanam(String girlNatch, String boyNatch) {
    String gGanam = AstroData.natchGanamMap[girlNatch] ?? "";
    String bGanam = AstroData.natchGanamMap[boyNatch] ?? "";
    String res = AstroData.matchAthamam;
    double pts = 0.0;
    
    if (gGanam == bGanam) {
      res = AstroData.matchUththamam;
      pts = 1.0;
    } else if ((gGanam.contains("தேவ") && bGanam.contains("மனுஷ")) || (bGanam.contains("தேவ") && gGanam.contains("மனுஷ"))) {
      res = AstroData.matchUththamam;
      pts = 1.0;
    } else if ((gGanam.contains("ராட்சச") && !bGanam.contains("ராட்சச")) || (bGanam.contains("ராட்சச") && !gGanam.contains("ராட்சச"))) {
      res = AstroData.matchMadhythiyam;
      pts = 0.5;
    }
    return MatchingResult(
      name: "கணப் பொருத்தம்", 
      result: res, 
      points: pts, 
      detail: "$gGanam vs $bGanam",
      girlValue: gGanam.replaceAll(" கணம்", ""),
      boyValue: bGanam.replaceAll(" கணம்", ""),
    );
  }

  static MatchingResult calculateMahendram(String girlNatch, String boyNatch) {
    int gIdx = getNatchIndex(girlNatch);
    int bIdx = getNatchIndex(boyNatch);
    int distance = (bIdx - gIdx + 27) % 27 + 1;
    
    bool isGood = [1, 4, 7, 10, 13, 16, 19, 20, 22, 25].contains(distance);

    return MatchingResult(
      name: "மகேந்திரப் பொருத்தம்",
      result: isGood ? AstroData.matchUththamam : AstroData.matchAthamam,
      points: isGood ? 1.0 : 0.0,
      detail: "தொலைவு: $distance",
      girlValue: girlNatch,
      boyValue: boyNatch,
    );
  }

  static MatchingResult calculateIsthree(String girlNatch, String boyNatch) {
    int gIdx = getNatchIndex(girlNatch);
    int bIdx = getNatchIndex(boyNatch);
    int distance = (bIdx - gIdx + 27) % 27 + 1;
    
    bool isGood = distance > 13;

    return MatchingResult(
      name: "ஸ்திரீ தீர்க்கப் பொருத்தம்",
      result: isGood ? AstroData.matchUththamam : AstroData.matchAthamam,
      points: isGood ? 1.0 : 0.0,
      detail: "தொலைவு: $distance",
      girlValue: girlNatch,
      boyValue: boyNatch,
    );
  }

  static MatchingResult calculateYoni(String girlNatch, String boyNatch) {
    String gYoniFull = AstroData.natchToYoniMap[girlNatch] ?? "";
    String bYoniFull = AstroData.natchToYoniMap[boyNatch] ?? "";
    
    String gAnimal = gYoniFull.replaceAll("ஆண் ", "").replaceAll("பெண் ", "");
    String bAnimal = bYoniFull.replaceAll("ஆண் ", "").replaceAll("பெண் ", "");
    
    String res = AstroData.matchMadhythiyam;
    double pts = 0.5;

    if (gAnimal == bAnimal) {
      res = AstroData.matchUththamam;
      pts = 1.0;
    } else if (AstroData.yoniVairamMap[gAnimal] == bAnimal || AstroData.yoniVairamMap[bAnimal] == gAnimal) {
      res = AstroData.matchAthamam;
      pts = 0.0;
    }
    return MatchingResult(
      name: "யோனிப் பொருத்தம்", 
      result: res, 
      points: pts, 
      detail: "$gYoniFull vs $bYoniFull",
      girlValue: gAnimal,
      boyValue: bAnimal,
    );
  }

  static MatchingResult calculateRaasi(String girlNatch, int girlPaatham, String boyNatch, int boyPaatham) {
    String gRaasi = AstroData.getRaasi(girlNatch, girlPaatham);
    String bRaasi = AstroData.getRaasi(boyNatch, boyPaatham);
    
    int gIdx = AstroData.raasiList.indexOf(gRaasi);
    int bIdx = AstroData.raasiList.indexOf(bRaasi);
    
    if (gIdx == -1 || bIdx == -1) {
      return MatchingResult(
        name: "ராசிப் பொருத்தம்",
        result: AstroData.matchAthamam,
        points: 0.0,
        detail: "தரவு இல்லை",
      );
    }
    
    int distance = (bIdx - gIdx + 12) % 12 + 1;

    String res = AstroData.matchAthamam;
    double pts = 0.0;

    if (distance == 1 || distance == 7 || distance == 10 || distance == 11) {
      res = AstroData.matchUththamam;
      pts = 1.0;
    } else if ([2, 3, 4, 5, 9].contains(distance)) {
      res = AstroData.matchMadhythiyam;
      pts = 0.5;
    }
    
    return MatchingResult(
      name: "ராசிப் பொருத்தம்",
      result: res,
      points: pts,
      detail: "$bRaasi vs $gRaasi",
      girlValue: gRaasi,
      boyValue: bRaasi,
    );
  }

  static MatchingResult calculateRaasiAdhi(String girlNatch, int girlPaatham, String boyNatch, int boyPaatham) {
    String gRaasi = AstroData.getRaasi(girlNatch, girlPaatham);
    String bRaasi = AstroData.getRaasi(boyNatch, boyPaatham);
    
    int gIdx = AstroData.raasiList.indexOf(gRaasi);
    int bIdx = AstroData.raasiList.indexOf(bRaasi);

    if (gIdx == -1 || bIdx == -1) {
      return MatchingResult(
        name: "ராசி அதிபதிப் பொருத்தம்",
        result: AstroData.matchAthamam,
        points: 0.0,
        detail: "தரவு இல்லை",
      );
    }

    String gLord = AstroData.raasiAdhipathiList[gIdx];
    String bLord = AstroData.raasiAdhipathiList[bIdx];

    bool isGood = gLord == bLord || 
                 (AstroData.friendshipMap[gLord]?.contains(bLord) ?? false) || 
                 (AstroData.samaMap[gLord]?.contains(bLord) ?? false);
                 
    return MatchingResult(
      name: "ராசி அதிபதிப் பொருத்தம்",
      result: isGood ? AstroData.matchUththamam : AstroData.matchAthamam,
      points: isGood ? 1.0 : 0.0,
      detail: "$bLord vs $gLord",
      girlValue: gLord,
      boyValue: bLord,
    );
  }

  static MatchingResult calculateVasiyam(String girlNatch, int girlPaatham, String boyNatch, int boyPaatham) {
    String gRaasi = AstroData.getRaasi(girlNatch, girlPaatham);
    String bRaasi = AstroData.getRaasi(boyNatch, boyPaatham);
    bool isGood = AstroData.raasiVasiyaMap[gRaasi]?.contains(bRaasi) ?? false;
                 
    return MatchingResult(
      name: "வசியப் பொருத்தம்",
      result: isGood ? AstroData.matchUththamam : AstroData.matchAthamam,
      points: isGood ? 1.0 : 0.0,
      detail: "$bRaasi vs $gRaasi",
      girlValue: gRaasi,
      boyValue: bRaasi,
    );
  }

  static MatchingResult calculateRajju(String girlNatch, String boyNatch) {
    String gRajju = AstroData.natchRajjuMap[girlNatch] ?? "";
    String bRajju = AstroData.natchRajjuMap[boyNatch] ?? "";
    bool isGood = gRajju != bRajju;
    return MatchingResult(
      name: "ரஜ்ஜுப் பொருத்தம்",
      result: isGood ? AstroData.matchUththamam : AstroData.matchAthamam,
      points: isGood ? 1.0 : 0.0,
      detail: "பெண்: $gRajju - ஆண்: $bRajju",
      girlValue: gRajju.split(' ')[0],
      boyValue: bRajju.split(' ')[0],
    );
  }

  static MatchingResult calculateVedai(String girlNatch, String boyNatch) {
    bool isGood = !(AstroData.vedaiMap[girlNatch]?.contains(boyNatch) ?? false);
    return MatchingResult(
      name: "வேதைப் பொருத்தம்",
      result: isGood ? AstroData.matchUththamam : AstroData.matchAthamam,
      points: isGood ? 1.0 : 0.0,
      detail: "",
      girlValue: girlNatch,
      boyValue: boyNatch,
    );
  }

  static MatchingResult calculateNaadi(String girlNatch, String boyNatch) {
    String gNaadi = AstroData.natchNaadiMap[girlNatch] ?? "";
    String bNaadi = AstroData.natchNaadiMap[boyNatch] ?? "";
    bool isGood = gNaadi != bNaadi;
    return MatchingResult(
      name: "நாடிப் பொருத்தம்",
      result: isGood ? AstroData.matchUththamam : AstroData.matchAthamam,
      points: isGood ? 1.0 : 0.0,
      detail: "$gNaadi vs $bNaadi",
      girlValue: gNaadi.replaceAll(" நாடி", ""),
      boyValue: bNaadi.replaceAll(" நாடி", ""),
    );
  }

  static double calculateTotalScore(List<MatchingResult> results) {
    return results.fold(0.0, (sum, res) => sum + res.points);
  }

  static String getFractionalScore(double score) {
    int whole = score.floor();
    double decimal = score - whole;
    if (decimal == 0) return whole.toString();
    if (decimal == 0.5) return "$whole ½";
    return score.toStringAsFixed(1);
  }

  // --- DOSHA ANALYSIS ---
  static Map<String, DoshaInfo> calculateDoshas(Map<String, dynamic> girlData, Map<String, dynamic> boyData) {
    return {
      'girl': _analyzeDosha(girlData),
      'boy': _analyzeDosha(boyData),
      'dasa_sandhi': _checkDasaSandhi(girlData['dasa'], boyData['dasa']),
    };
  }

  static DoshaInfo _analyzeDosha(Map<String, dynamic> data) {
    var details = data['planet_details'];
    if (details == null) return DoshaInfo(hasChevvai: false, hasRahuKethu: false, details: "No data");

    int lagnaIdx = AstroData.raasiList.indexOf(details['lagna']['rasi']);
    
    // 1. Chevvai Dosham (Mars in 2, 4, 7, 8, 12 from Lagna)
    int marsIdx = AstroData.raasiList.indexOf(details['mars']['rasi']);
    int marsPos = (marsIdx - lagnaIdx + 12) % 12 + 1;
    bool chDosha = [2, 4, 7, 8, 12].contains(marsPos);
    
    // Basic Tamil Astrology Exceptions (Simplified)
    if (chDosha) {
       String marsRasi = details['mars']['rasi'];
       if (marsPos == 2 && (marsRasi == 'Aries' || marsRasi == 'Scorpio' || marsRasi == 'Capricorn')) chDosha = false;
       if (marsPos == 4 && (marsRasi == 'Cancer' || marsRasi == 'Scorpio')) chDosha = false;
       if (marsPos == 7 && (marsRasi == 'Capricorn' || marsRasi == 'Aries')) chDosha = false;
       if (marsPos == 8 && (marsRasi == 'Sagittarius' || marsRasi == 'Pisces')) chDosha = false;
       if (marsPos == 12 && (marsRasi == 'Sagittarius' || marsRasi == 'Pisces' || marsRasi == 'Taurus')) chDosha = false;
    }

    // 2. Rahu-Kethu Dosham (Rahu or Kethu in 1, 2, 7, 8, 12)
    int rahuIdx = AstroData.raasiList.indexOf(details['rahu']['rasi']);
    int kethuIdx = AstroData.raasiList.indexOf(details['ketu']['rasi']);
    int rahuPos = (rahuIdx - lagnaIdx + 12) % 12 + 1;
    int kethuPos = (kethuIdx - lagnaIdx + 12) % 12 + 1;
    
    bool rkDosha = [1, 2, 7, 8, 12].contains(rahuPos) || [1, 2, 7, 8, 12].contains(kethuPos);

    return DoshaInfo(
      hasChevvai: chDosha,
      hasRahuKethu: rkDosha,
      details: "செவ்வாய்: ${marsPos}ம் இடம், ராகு: ${rahuPos}ம் இடம்",
    );
  }

  static DoshaInfo _checkDasaSandhi(List<dynamic>? girlDasa, List<dynamic>? boyDasa) {
    if (girlDasa == null || boyDasa == null) return DoshaInfo(hasDasaSandhi: false, details: "");
    
    // Find current Dasa end date for both
    DateTime? girlEnd = _getCurrentDasaEnd(girlDasa);
    DateTime? boyEnd = _getCurrentDasaEnd(boyDasa);
    
    if (girlEnd == null || boyEnd == null) return DoshaInfo(hasDasaSandhi: false, details: "");
    
    int diffDays = (girlEnd.difference(boyEnd)).inDays.abs();
    bool isUnfavorable = diffDays < 365; // Within 1 year is considered Dasa Sandhi

    return DoshaInfo(
      hasDasaSandhi: isUnfavorable,
      details: "வித்தியாசம்: ${ (diffDays/30).toStringAsFixed(1) } மாதம்",
    );
  }

  static DateTime? _getCurrentDasaEnd(List<dynamic> dasaList) {
    DateTime now = DateTime.now();
    for (var d in dasaList) {
        if (now.isAfter(d['start']) && now.isBefore(d['end'])) return d['end'];
    }
    return null;
  }
}

class DoshaInfo {
  final bool hasChevvai;
  final bool hasRahuKethu;
  final bool hasDasaSandhi;
  final String details;

  DoshaInfo({
    this.hasChevvai = false,
    this.hasRahuKethu = false,
    this.hasDasaSandhi = false,
    required this.details,
  });
}
