class AstroUtils {
  static double getCumulativeKaliDays(int gregorianYear) {
    // Exact Vakya Karana formula used in Python
    return ((210389 * gregorianYear) + 652415052) / 576.0;
  }

  static Map<String, double> getMeshaSankranti(int kaliYear) {
    // Standard Vakya expansion
    double days1 = kaliYear * 365.0;
    
    int q2 = kaliYear ~/ 4;
    int r2 = kaliYear % 4;
    double days2 = q2.toDouble();
    double naligai2 = r2 * 15.0;
    
    // Using -1237 as per user source
    double val3 = (kaliYear * 5.0 - 1237.0) / 576.0;
    int days3 = val3.floor();
    double naligai3 = (val3 - days3) * 60.0;
    
    double totalDays = days1 + days2 + days3;
    double totalNaligai = naligai2 + naligai3;
    
    // For foundation purposes, we need the rounded total days to determine the weekday start
    double cumulativeFloat = totalDays + (totalNaligai / 60.0);
    double roundedDays = cumulativeFloat.roundToDouble();
    
    return {'days': roundedDays, 'naligai': 0.0}; // Returning rounded days as foundation
  }

  static double getCumulativeKaliDaysFromSankranti(int gregorianYear) {
    // Traditional Kali Year: 1 AD is 3102 Kali. 2026 AD is 5127 Kali.
    int kaliYear = gregorianYear + 3101;
    var sankranti = getMeshaSankranti(kaliYear);
    return sankranti['days']! + (sankranti['naligai']! / 60.0);
  }

  static double pythonRound(double value) {
    double floorVal = value.floorToDouble();
    double frac = value - floorVal;
    
    // Near-integer check for precision
    if (frac.abs() < 1e-12) return floorVal;
    if ((1.0 - frac).abs() < 1e-12) return floorVal + 1;

    if (frac < 0.5) return floorVal;
    if (frac > 0.5) return floorVal + 1;
    // frac == 0.5: round to nearest even
    if (floorVal.toInt() % 2 == 0) return floorVal;
    return floorVal + 1;
  }

  static double pmod(double a, double n) {
    return ((a % n) + n) % n;
  }

  static double dmsToDecimalDegrees(double degrees, double minutes, double seconds) {
    return degrees + (minutes / 60.0) + (seconds / 3600.0);
  }

  static double arcSecondsToDecimalDegrees(double arcSeconds) {
    return arcSeconds / 3600.0;
  }

  static double arcMinutesToDecimalDegrees(double arcMinutes) {
    return arcMinutes / 60.0;
  }

  static double monthLengthToDays(Map<String, double> monthLength) {
    double day = monthLength['day']!;
    double naaligai = monthLength['naaligai']!;
    double vinaaligai = monthLength['vinaaligai'] ?? 0;
    return day + (naaligai / 60.0) + (vinaaligai / 3600.0);
  }

  static List<num> toDMS(double decimalDegrees) {
    int degrees = decimalDegrees.toInt();
    double reminder = (decimalDegrees - degrees) * 60;
    int arcMinutes = reminder.toInt();
    double arcSeconds = (reminder - arcMinutes) * 60;
    return [degrees, arcMinutes, arcSeconds];
  }

  static Map<String, dynamic> getCurrentDT() {
    final now = DateTime.now();
    return {
      'year': now.year,
      'month': now.month,
      'day': now.day,
      'hour': now.hour,
      'minute': now.minute
    };
  }

  static double getUjjainOffsetTime(int hour, int minute) {
    const double istToUjjainDiffTimeMinutes = 26.92;
    double istTimeMinutes = (hour * 60.0) + minute;
    double lmtUjjainConvertedMinutes = istTimeMinutes - istToUjjainDiffTimeMinutes;
    double lmtUjjainConvertedOffsetMinutes = lmtUjjainConvertedMinutes - 360; // 360 = 6 hours
    return lmtUjjainConvertedOffsetMinutes / 1440.0;
  }

  static int calculateKaliYear(int year, int month, int day) {
    return (month < 4 || (month == 4 && day <= 13)) ? year + 3100 : year + 3101;
  }

  static int calculateSalivahanaYear(int year, int month, int day) {
    return (month < 3 || (month == 3 && day <= 21)) ? year - 79 : year - 80;
  }

  static int calculatePasaliYear(int year, int month, int day) {
    return (month < 7) ? year - 591 : year - 592;
  }

  static int calculateKollamYear(int year, int month, int day, {double? sunLongitude, int? tamilMonth}) {
    if (sunLongitude != null) {
      return (sunLongitude >= 120.0 && month > 4) ? year - 825 : year - 826;
    }
    if (tamilMonth != null) {
      return (tamilMonth >= 5 && month > 4) ? year - 825 : year - 826;
    }
    return (month < 7 || (month == 7 && day <= 16)) ? year - 826 : year - 825;
  }

  static int calculateHijriYear(int year, int month, int day, {int? tamilMonth, double? diff}) {
    if (tamilMonth != null && diff != null) {
      if (tamilMonth < 5) {
        return year - 579;
      } else if (tamilMonth > 5) {
        return year - 580;
      } else {
        if (diff < 36.0) {
          return year - 579;
        } else {
          return year - 580;
        }
      }
    }
    if (month < 8 || (month == 8 && day <= 30)) {
      return year - 579;
    } else {
      return year - 580;
    }
  }

  /// அயனம் (Ayanam): Sun Longitude (270°-90°: உத்தராயணம், 90°-270°: தட்சிணாயனம்)
  static String getAyanam(double sunLongitude) {
    double norm = (sunLongitude % 360.0 + 360.0) % 360.0;
    if (norm >= 270.0 || norm < 90.0) {
      return "உத்தராயணம்";
    } else {
      return "தட்சிணாயனம்";
    }
  }

  /// ருது / பருவம் (Vedic 6 Seasons based on Sun's Rasi)
  static String getSeason(double sunLongitude) {
    int sunRasi = ((sunLongitude % 360.0 + 360.0) % 360.0 / 30.0).floor() % 12;
    switch (sunRasi ~/ 2) {
      case 0:
        return "வசந்த ருது (இளவேனில்)"; // Mesha, Vrishabha
      case 1:
        return "கிரீஷ்ம ருது (முதுவேனில்)"; // Mithuna, Kataka
      case 2:
        return "வர்ஷ ருது (கார்காலம்)"; // Simha, Kanya
      case 3:
        return "சரத் ருது (கூதிர்காலம்)"; // Thula, Vrischika
      case 4:
        return "ஹேமந்த ருது (முன்பனி)"; // Dhanusu, Makara
      case 5:
      default:
        return "சிசிர ருது (பின்பனி)"; // Kumbha, Meena
    }
  }

  /// பஞ்சபட்சி (Pancha Patchi: 5 Birds based on Moon Star index 0..26 & Paksha)
  static String getPanchaPatchi(int moonNakIdx, bool isShukla) {
    int group = 0;
    if (moonNakIdx <= 4) {
      group = 0; // Ashwini - Mrigashirsha
    } else if (moonNakIdx <= 9) {
      group = 1; // Arudra - Magha
    } else if (moonNakIdx <= 14) {
      group = 2; // Purvaphalguni - Swati
    } else if (moonNakIdx <= 19) {
      group = 3; // Vishakha - Purvashada
    } else {
      group = 4; // Uttarashada - Revati
    }

    const shuklaBirds = ["வல்லூறு", "ஆந்தை", "காகம்", "கோழி", "மயில்"];
    const krishnaBirds = ["காகம்", "கோழி", "மயில்", "ஆந்தை", "வல்லூறு"];
    return isShukla ? shuklaBirds[group] : krishnaBirds[group];
  }

  /// படுபட்சி (Padu Patchi: Inauspicious Dying Bird of the Day based on Weekday 0=Sun..6=Sat & Paksha)
  static String getPaduPatchi(int weekdayIdx, bool isShukla) {
    // வளர்பிறை (பூர்வபட்சம்):
    // வல்லூறு: வியாழன், சனி | ஆந்தை: ஞாயிறு, வெள்ளி | காகம்: திங்கள் | கோழி: செவ்வாய் | மயில்: புதன்
    const shuklaPadu = [
      "ஆந்தை",   // 0: ஞாயிறு (Sun)
      "காகம்",   // 1: திங்கள் (Mon)
      "கோழி",    // 2: செவ்வாய் (Tue)
      "மயில்",   // 3: புதன் (Wed)
      "வல்லூறு", // 4: வியாழன் (Thu)
      "ஆந்தை",   // 5: வெள்ளி (Fri)
      "வல்லூறு", // 6: சனி (Sat)
    ];

    // தேய்பிறை (அமரபட்சம்):
    // வல்லூறு: செவ்வாய் | ஆந்தை: திங்கள் | காகம்: ஞாயிறு | கோழி: வியாழன், சனி | மயில்: புதன், வெள்ளி
    const krishnaPadu = [
      "காகம்",   // 0: ஞாயிறு (Sun)
      "ஆந்தை",   // 1: திங்கள் (Mon)
      "வல்லூறு", // 2: செவ்வாய் (Tue)
      "மயில்",   // 3: புதன் (Wed)
      "கோழி",    // 4: வியாழன் (Thu)
      "மயில்",   // 5: வெள்ளி (Fri)
      "கோழி",    // 6: சனி (Sat)
    ];

    int w = weekdayIdx % 7;
    if (w < 0) w += 7;
    return isShukla ? shuklaPadu[w] : krishnaPadu[w];
  }

  /// அமிர்தாதி யோகம் தமிழ் பெயர்
  static String getAmirthathiYogamTamil(String raw) {
    switch (raw.toLowerCase().trim()) {
      case "amirtham":
      case "amirtha":
      case "amrutha":
        return "அமிர்த யோகம்";
      case "sitham":
      case "siddha":
      case "sidha":
        return "சித்த யோகம்";
      case "maranam":
      case "marana":
        return "மரண யோகம்";
      case "prabalarishtam":
      case "prabalarishta":
        return "பிரபலாரிஷ்ட யோகம்";
      default:
        return raw.isNotEmpty ? raw : "சித்த யோகம்";
    }
  }

  /// திசை (சூலம்) தமிழ் பெயர்
  static String getSoolamTamil(String raw) {
    switch (raw.toLowerCase().trim()) {
      case "east":
        return "கிழக்கு";
      case "west":
        return "மேற்கு";
      case "north":
        return "வடக்கு";
      case "south":
        return "தெற்கு";
      case "north-west":
      case "northwest":
        return "வடமேற்கு";
      case "north-east":
      case "northeast":
        return "வடகிழக்கு";
      case "south-west":
      case "southwest":
        return "தென்மேற்கு";
      case "south-east":
      case "southeast":
        return "தென்கிழக்கு";
      default:
        return raw.isNotEmpty ? raw : "வடக்கு";
    }
  }

  /// பரிகாரம் தமிழ் பெயர்
  static String getPariharamTamil(String raw) {
    switch (raw.toLowerCase().trim()) {
      case "milk":
        return "பால்";
      case "curd":
        return "தயிர்";
      case "jaggery":
        return "வெல்லம்";
      case "oil":
        return "நல்லெண்ணெய்";
      case "ghee":
        return "நெய்";
      default:
        return raw.isNotEmpty ? raw : "பால்";
    }
  }

  /// சுத்தமான தமிழ் நட்சத்திரப் பெயர்
  static String getTamilNakshatra(String raw) {
    const map = {
      "Ashwini": "அஸ்வினி", "Bharani": "பரணி", "Krittika": "கார்த்திகை", "Rohini": "ரோகிணி",
      "Mrigashirsha": "மிருகசீரிஷம்", "Arudra": "திருவாதிரை", "Punarvasu": "புனர்பூசம்",
      "Pushya": "பூசம்", "Aslesha": "ஆயில்யம்", "Magha": "மகம்", "Purvaphalguni": "பூரம்",
      "Uttaraphalguni": "உத்திரம்", "Hastha": "அஸ்தம்", "Chitra": "சித்திரை", "Swati": "சுவாதி",
      "Vishakha": "விசாகம்", "Anuradha": "அனுஷம்", "Jyeshta": "கேட்டை", "Jyeshtha": "கேட்டை",
      "Mula": "மூலம்", "Purvashada": "பூராடம்", "Uttarashada": "உத்திராடம்",
      "Shravana": "திருவோணம்", "Dhanishta": "அவிட்டம்", "Shatabhisha": "சதயம்",
      "Purvabhadrapada": "பூரட்டாதி", "Uttarabhadrapada": "உத்திரட்டாதி", "Revati": "ரேவதி"
    };
    for (var e in map.entries) {
      if (raw.toLowerCase().contains(e.key.toLowerCase())) {
        return raw.replaceAll(RegExp(e.key, caseSensitive: false), e.value);
      }
    }
    return raw;
  }

  /// சுத்தமான தமிழ் நித்ய யோகப் பெயர்
  static String getTamilYoga(String raw) {
    const map = {
      "Vishkumbha": "விஷ்கம்பம்", "Priti": "பிரீதி", "Ayushman": "ஆயுஷ்மான்", "Saubhagya": "சௌபாக்கியம்",
      "Sobhana": "சோபனம்", "Atiganda": "அதிகண்டம்", "Sukarma": "சுகர்மம்", "Dhriti": "திருதி",
      "Shula": "சூலம்", "Ganda": "கண்டம்", "Vriddhi": "விருத்தி", "Dhruva": "துருவம்",
      "Vyaghata": "வியாகாதம்", "Harshana": "ஹர்ஷணம்", "Vajra": "வஜ்ரம்", "Siddhi": "சித்தி",
      "Vyatipata": "வியதீபாதம்", "Variyan": "வரியான்", "Parigha": "பரிகம்", "Shiva": "சிவம்",
      "Siddha": "சித்தம்", "Sadhya": "சாத்தியம்", "Shubha": "சுபம்", "Shukla": "சுக்கிலம்",
      "Brahma": "பிரம்மா", "Indra": "ஐந்திரம்", "Vaidhriti": "வைதிருதி"
    };
    for (var e in map.entries) {
      if (raw.toLowerCase().contains(e.key.toLowerCase())) {
        return raw.replaceAll(RegExp(e.key, caseSensitive: false), e.value);
      }
    }
    return raw;
  }

  /// சுத்தமான தமிழ் கரணப் பெயர்
  static String getTamilKarana(String raw) {
    const map = {
      "Bava": "பவம்", "Balava": "பாலவம்", "Kaulava": "கௌலவம்", "Taitila": "தைதுலை",
      "Garaja": "கரசை", "Vanija": "வணிசை", "Vishti": "பத்திரை (விஷ்டி)",
      "Shakuni": "சகுனி", "Chatushpada": "சதுஷ்பாதம்", "Nagawa": "நாகவம்",
      "Kimstughna": "கிம்துக்கினம்"
    };
    for (var e in map.entries) {
      if (raw.toLowerCase().contains(e.key.toLowerCase())) {
        return raw.replaceAll(RegExp(e.key, caseSensitive: false), e.value);
      }
    }
    return raw;
  }

  /// சுத்தமான தமிழ் திதிப் பெயர்
  static String getTamilTithi(String raw) {
    const map = {
      "Prathama": "பிரதமை", "Dwitiya": "துவிதியை", "Tritiya": "திரிதியை", "Chaturthi": "சதுர்த்தி",
      "Panchami": "பஞ்சமி", "Shasthi": "சஷ்டி", "Saptami": "சப்தமி", "Ashtami": "அஷ்டமி",
      "Navami": "நவமி", "Dashami": "தசமி", "Ekadashi": "ஏகாதசி", "Dwadashi": "துவாதசி",
      "Trayodashi": "திரயோதசி", "Chaturdashi": "சதுர்த்தசி", "Pournami": "பௌர்ணமி",
      "Purnima": "பௌர்ணமி", "Amavasya": "அமாவாசை"
    };
    for (var e in map.entries) {
      if (raw.toLowerCase().contains(e.key.toLowerCase())) {
        return raw.replaceAll(RegExp(e.key, caseSensitive: false), e.value);
      }
    }
    return raw;
  }
}

