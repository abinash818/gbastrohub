import 'dart:math';

enum PoruthamStatusType {
  good,
  bad,
  none,
}

class PoruthamItem {
  final String nameEn;
  final String nameTa;
  final String value;
  final String statusText;
  final PoruthamStatusType statusType;
  final String? description;

  const PoruthamItem({
    required this.nameEn,
    required this.nameTa,
    required this.value,
    required this.statusText,
    required this.statusType,
    this.description,
  });

  bool get isGood => statusType == PoruthamStatusType.good;
}

class ManaiyadiResult {
  final double sqft;
  final double kuzhi;
  final int percentage;
  final int goodCount;
  final String manaiName;
  final String manaiNameTa;
  final bool manaiGood;
  final List<PoruthamItem> details;
  final double? widthFt;
  final double? widthIn;
  final double? lengthFt;
  final double? lengthIn;

  const ManaiyadiResult({
    required this.sqft,
    required this.kuzhi,
    required this.percentage,
    required this.goodCount,
    required this.manaiName,
    required this.manaiNameTa,
    required this.manaiGood,
    required this.details,
    this.widthFt,
    this.widthIn,
    this.lengthFt,
    this.lengthIn,
  });
}

class LengthSuggestion {
  final int lengthFt;
  final double lengthIn;
  final ManaiyadiResult result;

  const LengthSuggestion({
    required this.lengthFt,
    required this.lengthIn,
    required this.result,
  });
}

class VaasthuService {
  /// Auspicious feet values (நன்மையான உள்ப்பக்க அளவுகள்)
  static const List<int> goodFeet = [
    6, 8, 10, 11, 16, 17, 20, 21, 26, 27, 28, 29, 30, 31, 32, 33, 35, 36, 37, 39, 
    41, 42, 45, 52, 56, 60, 63, 64, 66, 68, 70, 71, 72, 73, 74, 77, 79, 80, 84, 85, 
    87, 88, 89, 91, 92, 95, 97, 99, 100, 101, 102, 106, 107, 108, 109, 110, 111, 112, 113, 
    115, 116, 117, 119
  ];

  static bool isGoodFoot(int feet) => goodFeet.contains(feet);

  /// Helper to check inclusion with tolerance for floating values
  static bool _includesNumber(List<num> list, num val) {
    for (final item in list) {
      if ((val - item).abs() < 0.0001) return true;
    }
    return false;
  }

  /// Calculates Manaiyadi Shastram 11 Poruthams from Square Footage
  static ManaiyadiResult evaluateManaiyadiBySqft(double sqft) {
    final double kuzhi = ((sqft / 9.0) * 10).round() / 10.0;

    final double manaiVal = kuzhi % 8;
    final double vayadhuVal = (kuzhi * 27) % 100;
    final double adhayamVal = (kuzhi * 8) % 12;
    final double vyayamVal = (kuzhi * 9) % 10;
    final double yoniVal = (kuzhi * 3) % 8;
    final double natchathiramVal = (kuzhi * 8) % 27;
    final double vaaramVal = (kuzhi * 9) % 7;
    final double amsamVal = (kuzhi * 4) % 9;
    final double vamsamVal = (kuzhi * 9) % 4;
    final double thithiVal = (kuzhi * 9) % 15;
    final double rasiVal = (kuzhi * 4) % 12;

    String manaiName = "-";
    String manaiNameTa = "-";
    bool manaiGood = false;

    if ((manaiVal - 1).abs() < 0.0001) {
      manaiName = "Karuda";
      manaiNameTa = "கருட மனை";
      manaiGood = true;
    } else if ((manaiVal - 3).abs() < 0.0001) {
      manaiName = "Simma";
      manaiNameTa = "சிம்ம மனை";
      manaiGood = true;
    } else if ((manaiVal - 5).abs() < 0.0001) {
      manaiName = "Pasu";
      manaiNameTa = "பசு மனை";
      manaiGood = true;
    } else if ((manaiVal - 7).abs() < 0.0001) {
      manaiName = "Yanai";
      manaiNameTa = "யானை மனை";
      manaiGood = true;
    } else {
      if ((manaiVal - 2).abs() < 0.0001) {
        manaiName = "Poonai";
        manaiNameTa = "பூனை மனை";
      } else if ((manaiVal - 4).abs() < 0.0001) {
        manaiName = "Naai";
        manaiNameTa = "நாய் மனை";
      } else if ((manaiVal - 6).abs() < 0.0001) {
        manaiName = "Kazhudhai";
        manaiNameTa = "கழுதை மனை";
      } else if ((manaiVal - 0).abs() < 0.0001) {
        manaiName = "Kagam";
        manaiNameTa = "காக மனை";
      } else {
        final valStr = manaiVal.toStringAsFixed(1);
        manaiName = "Manai $valStr";
        manaiNameTa = "மனை $valStr";
      }
    }

    final bool vayadhuGood = vayadhuVal > 60;
    final bool adhayamGood = adhayamVal < 13;
    final bool vyayamGood = _includesNumber([3, 4, 6, 8, 10, 0], vyayamVal);
    final bool yoniGood = _includesNumber([1, 3, 5, 7], yoniVal);
    final bool natchathiramGood = _includesNumber(
      [1, 4, 5, 6, 7, 8, 10, 11, 12, 14, 15, 17, 21, 22, 24, 26],
      natchathiramVal,
    );
    final bool vaaramGood = _includesNumber([2, 4, 5, 6], vaaramVal);
    final bool amsamGood = _includesNumber([2, 4, 5, 6, 8, 9, 0], amsamVal);
    final bool vamsamGood = _includesNumber([1, 2, 3, 4, 0], vamsamVal);
    final bool thithiGood = _includesNumber([1, 2, 3, 5, 6, 10, 11, 12, 13, 15, 0], thithiVal);
    final bool rasiGood = _includesNumber([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 0], rasiVal);

    final List<bool> checks = [
      manaiGood,
      vayadhuGood,
      adhayamGood,
      vyayamGood,
      yoniGood,
      natchathiramGood,
      vaaramGood,
      amsamGood,
      vamsamGood,
      thithiGood,
      rasiGood,
    ];

    final int goodCount = checks.where((c) => c).length;
    int percentage = ((goodCount / 11.0) * 100).round();

    String vayadhuStatusText = vayadhuGood ? "நல்லது (Good)" : "-";
    PoruthamStatusType vayadhuStatusType = vayadhuGood ? PoruthamStatusType.good : PoruthamStatusType.none;

    if (vayadhuVal < 50) {
      vayadhuStatusText = "வயது குறைவு (Not Recommended)";
      vayadhuStatusType = PoruthamStatusType.bad;
      percentage = max(0, percentage - 20); // Subtract 20% penalty
    }

    PoruthamItem makeItem(String nameEn, String nameTa, num val, bool isGood) {
      return PoruthamItem(
        nameEn: nameEn,
        nameTa: nameTa,
        value: val is int ? val.toString() : val.toStringAsFixed(2),
        statusText: isGood ? "நல்லது (Good)" : "-",
        statusType: isGood ? PoruthamStatusType.good : PoruthamStatusType.none,
      );
    }

    final details = [
      PoruthamItem(
        nameEn: "Manai Type",
        nameTa: "மனை வகை",
        value: manaiGood ? "$manaiNameTa ($manaiName)" : "$manaiNameTa ($manaiName)",
        statusText: manaiGood ? "நல்லது (Good)" : "பொருந்தவில்லை",
        statusType: manaiGood ? PoruthamStatusType.good : PoruthamStatusType.bad,
      ),
      PoruthamItem(
        nameEn: "Vayadhu / Ayul",
        nameTa: "வயது / ஆயுள்",
        value: vayadhuVal.toStringAsFixed(2),
        statusText: vayadhuStatusText,
        statusType: vayadhuStatusType,
      ),
      makeItem("Adhayam / Varavu", "வரவு / ஆதாயம்", adhayamVal, adhayamGood),
      makeItem("Vyayam / Selavu", "செலவு / விரயம்", vyayamVal, vyayamGood),
      makeItem("Yoni", "யோனி", yoniVal, yoniGood),
      makeItem("Natchathiram", "நட்சத்திரம்", natchathiramVal, natchathiramGood),
      makeItem("Vaaram", "வாரம் (கிழமை)", vaaramVal, vaaramGood),
      makeItem("Amsam", "அம்சம்", amsamVal, amsamGood),
      makeItem("Vamsam", "வம்சம்", vamsamVal, vamsamGood),
      makeItem("Thithi", "திதி", thithiVal, thithiGood),
      makeItem("Rasi", "ராசி", rasiVal, rasiGood),
    ];

    return ManaiyadiResult(
      sqft: sqft,
      kuzhi: kuzhi,
      percentage: percentage,
      goodCount: goodCount,
      manaiName: manaiName,
      manaiNameTa: manaiNameTa,
      manaiGood: manaiGood,
      details: details,
    );
  }

  /// Evaluates full Manaiyadi calculation given dimensions in Feet & Inches
  static ManaiyadiResult evaluateManaiyadi(
    double wFt, 
    double wIn, 
    double lFt, 
    double lIn
  ) {
    final double wTotalFt = wFt + (wIn / 12.0);
    final double lTotalFt = lFt + (lIn / 12.0);
    final double sqft = wTotalFt * lTotalFt;

    final res = evaluateManaiyadiBySqft(sqft);

    final List<PoruthamItem> extraDetails = [];
    if (wFt > 0) {
      final bool wGood = isGoodFoot(wFt.toInt());
      extraDetails.add(
        PoruthamItem(
          nameEn: "Width (Ulpakka Agalam)",
          nameTa: "உள்பக்க அகலம்",
          value: "${wFt.toInt()} அடி ${wIn > 0 ? '${wIn.toStringAsFixed(1)} அங்' : ''}",
          statusText: wGood ? "நல்லது (Good)" : "பொருந்தவில்லை (Not Recommended)",
          statusType: wGood ? PoruthamStatusType.good : PoruthamStatusType.bad,
        ),
      );
    }

    if (lFt > 0) {
      final bool lGood = isGoodFoot(lFt.toInt());
      extraDetails.add(
        PoruthamItem(
          nameEn: "Length (Ulpakka Neelam)",
          nameTa: "உள்பக்க நீளம்",
          value: "${lFt.toInt()} அடி ${lIn > 0 ? '${lIn.toStringAsFixed(1)} அங்' : ''}",
          statusText: lGood ? "நல்லது (Good)" : "பொருந்தவில்லை (Not Recommended)",
          statusType: lGood ? PoruthamStatusType.good : PoruthamStatusType.bad,
        ),
      );
    }

    final combinedDetails = [...extraDetails, ...res.details];

    return ManaiyadiResult(
      sqft: sqft,
      kuzhi: res.kuzhi,
      percentage: res.percentage,
      goodCount: res.goodCount,
      manaiName: res.manaiName,
      manaiNameTa: res.manaiNameTa,
      manaiGood: res.manaiGood,
      details: combinedDetails,
      widthFt: wFt,
      widthIn: wIn,
      lengthFt: lFt,
      lengthIn: lIn,
    );
  }

  /// Suggests auspicious lengths for a given width
  static List<LengthSuggestion> findGoodLengths(
    double wFt, 
    double wIn, 
    {double minLength = 10, double maxLength = 100}
  ) {
    final double wTotalFt = wFt + (wIn / 12.0);
    if (wTotalFt <= 0) return [];

    final double minArea = wTotalFt * minLength;
    final double maxArea = wTotalFt * maxLength;

    final int minKuzhi = max(1, (minArea / 9.0).floor());
    final int maxKuzhi = (maxArea / 9.0).ceil();

    final List<LengthSuggestion> suggestions = [];

    for (int k = minKuzhi; k <= maxKuzhi; k++) {
      final double sqft = k * 9.0;
      final res = evaluateManaiyadiBySqft(sqft);

      // Consider "Good" if it has a good Manai and overall match >= 7 (out of 11)
      if (res.manaiGood && res.goodCount >= 7) {
        final double lTotalFt = sqft / wTotalFt;
        final int lFt = lTotalFt.floor();
        final double lIn = ((lTotalFt - lFt) * 12.0 * 100).round() / 100.0;

        if (lTotalFt >= 5) {
          suggestions.add(
            LengthSuggestion(
              lengthFt: lFt,
              lengthIn: lIn,
              result: res,
            ),
          );
        }
      }
    }

    // Sort by highest percentage
    suggestions.sort((a, b) => b.result.percentage.compareTo(a.result.percentage));
    return suggestions;
  }

  /// Explores and filters best square footage sizes between 100 and 10,000 sqft
  static List<ManaiyadiResult> findBestAreas({
    String manaiFilter = 'All',
    String sortOrder = 'percent_desc',
  }) {
    final List<ManaiyadiResult> found = [];
    final Set<double> seenKuzhi = {};

    for (int s = 100; s <= 10000; s++) {
      final res = evaluateManaiyadiBySqft(s.toDouble());

      if (res.manaiGood && res.goodCount >= 8) {
        if (manaiFilter != 'All') {
          if (!res.manaiName.toLowerCase().contains(manaiFilter.toLowerCase()) &&
              !res.manaiNameTa.contains(manaiFilter)) {
            continue;
          }
        }

        if (!seenKuzhi.contains(res.kuzhi)) {
          seenKuzhi.add(res.kuzhi);
          found.push(res);
        }
      }
    }

    if (sortOrder == 'percent_desc') {
      found.sort((a, b) {
        if (b.percentage != a.percentage) {
          return b.percentage.compareTo(a.percentage);
        }
        return a.sqft.compareTo(b.sqft);
      });
    } else if (sortOrder == 'size_asc') {
      found.sort((a, b) {
        if (a.sqft != b.sqft) {
          return a.sqft.compareTo(b.sqft);
        }
        return b.percentage.compareTo(a.percentage);
      });
    } else if (sortOrder == 'size_desc') {
      found.sort((a, b) {
        if (b.sqft != a.sqft) {
          return b.sqft.compareTo(a.sqft);
        }
        return b.percentage.compareTo(a.percentage);
      });
    }

    return found;
  }
}

extension _ListExt<T> on List<T> {
  void push(T item) => add(item);
}
