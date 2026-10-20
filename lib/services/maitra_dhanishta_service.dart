import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../astro_engine/astro_engine.dart';

class DhanishtaPanchamiInfo {
  final int nakshatraIndex; // 0 to 26
  final String nakshatraName;
  final String nakshatraNameTamil;
  final bool isDhanishtaPanchami;
  final bool isAdaippu;
  final int adaippuMonths; // 6, 4, 3, 2, or 0
  final String adaippuTitle;
  final String statusText;
  final String description;
  final String remedies;

  DhanishtaPanchamiInfo({
    required this.nakshatraIndex,
    required this.nakshatraName,
    required this.nakshatraNameTamil,
    required this.isDhanishtaPanchami,
    required this.isAdaippu,
    required this.adaippuMonths,
    required this.adaippuTitle,
    required this.statusText,
    required this.description,
    required this.remedies,
  });
}

class DhanishtaDaySlot {
  final DateTime date;
  final String nakshatraNameTamil;
  final String nakshatraNameEn;
  final String weekday;
  final bool isDhanishtaPanchami;
  final bool isAdaippu;
  final int adaippuMonths;
  final String adaippuTitle;

  DhanishtaDaySlot({
    required this.date,
    required this.nakshatraNameTamil,
    required this.nakshatraNameEn,
    required this.weekday,
    required this.isDhanishtaPanchami,
    required this.isAdaippu,
    required this.adaippuMonths,
    required this.adaippuTitle,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'nakshatraNameTamil': nakshatraNameTamil,
    'nakshatraNameEn': nakshatraNameEn,
    'weekday': weekday,
    'isDhanishtaPanchami': isDhanishtaPanchami,
    'isAdaippu': isAdaippu,
    'adaippuMonths': adaippuMonths,
    'adaippuTitle': adaippuTitle,
  };

  factory DhanishtaDaySlot.fromJson(Map<String, dynamic> json) => DhanishtaDaySlot(
    date: DateTime.parse(json['date'] as String),
    nakshatraNameTamil: json['nakshatraNameTamil'] as String,
    nakshatraNameEn: json['nakshatraNameEn'] as String,
    weekday: json['weekday'] as String,
    isDhanishtaPanchami: json['isDhanishtaPanchami'] as bool,
    isAdaippu: json['isAdaippu'] as bool,
    adaippuMonths: json['adaippuMonths'] as int,
    adaippuTitle: json['adaippuTitle'] as String,
  );
}

class MaitraMuhurthamSlot {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String nakshatra;
  final String lagna;
  final String weekday;
  final bool isTuesday;
  final String ratingText;

  MaitraMuhurthamSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.nakshatra,
    required this.lagna,
    required this.weekday,
    required this.isTuesday,
    required this.ratingText,
  });

  String get formattedTime {
    String format(DateTime dt) {
      int h = dt.hour % 12;
      if (h == 0) h = 12;
      String m = dt.minute.toString().padLeft(2, '0');
      String ampm = dt.hour >= 12 ? "PM" : "AM";
      return "$h:$m $ampm";
    }
    return "${format(startTime)} - ${format(endTime)}";
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'nakshatra': nakshatra,
    'lagna': lagna,
    'weekday': weekday,
    'isTuesday': isTuesday,
    'ratingText': ratingText,
  };

  factory MaitraMuhurthamSlot.fromJson(Map<String, dynamic> json) => MaitraMuhurthamSlot(
    date: DateTime.parse(json['date'] as String),
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    nakshatra: json['nakshatra'] as String,
    lagna: json['lagna'] as String,
    weekday: json['weekday'] as String,
    isTuesday: json['isTuesday'] as bool,
    ratingText: json['ratingText'] as String,
  );
}

class AbhijitMuhurthamSlot {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String sunrise;
  final String sunset;
  final String weekday;
  final bool isWednesday;
  final String ratingText;
  final bool isAuspicious;

  AbhijitMuhurthamSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.sunrise,
    required this.sunset,
    required this.weekday,
    required this.isWednesday,
    required this.ratingText,
    required this.isAuspicious,
  });

  String get formattedTime {
    String format(DateTime dt) {
      int h = dt.hour % 12;
      if (h == 0) h = 12;
      String m = dt.minute.toString().padLeft(2, '0');
      String ampm = dt.hour >= 12 ? "PM" : "AM";
      return "$h:$m $ampm";
    }
    return "${format(startTime)} - ${format(endTime)}";
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'sunrise': sunrise,
    'sunset': sunset,
    'weekday': weekday,
    'isWednesday': isWednesday,
    'ratingText': ratingText,
    'isAuspicious': isAuspicious,
  };

  factory AbhijitMuhurthamSlot.fromJson(Map<String, dynamic> json) => AbhijitMuhurthamSlot(
    date: DateTime.parse(json['date'] as String),
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    sunrise: json['sunrise'] as String,
    sunset: json['sunset'] as String,
    weekday: json['weekday'] as String,
    isWednesday: json['isWednesday'] as bool,
    ratingText: json['ratingText'] as String,
    isAuspicious: json['isAuspicious'] as bool,
  );
}

class MaitraDhanishtaService {
  static const List<String> TAMIL_NAKSHATRAS = [
    "அஸ்வினி", "பரணி", "கார்த்திகை", "ரோகிணி", "மிருகசீரிஷம்", "திருவாதிரை",
    "புனர்பூசம்", "பூசம்", "ஆயில்யம்", "மகம்", "பூரம்", "உத்திரம்",
    "அஸ்தம்", "சித்திரை", "சுவாதி", "விசாகம்", "அனுஷம்", "கேட்டை",
    "மூலம்", "பூராடம்", "உத்திராடம்", "திருவோணம்", "அவிட்டம்", "சதயம்",
    "பூரட்டாதி", "உத்திரட்டாதி", "ரேவதி"
  ];

  static const List<String> ENGLISH_NAKSHATRAS = [
    "Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashirsha", "Arudra",
    "Punarvasu", "Pushya", "Aslesha", "Magha", "Purvaphalguni", "Uttaraphalguni",
    "Hastha", "Chitra", "Swati", "Vishakha", "Anuradha", "Jyeshta",
    "Mula", "Purvashada", "Uttarashada", "Shravana", "Dhanishta", "Shatabhisha",
    "Purvabhadrapada", "Uttarabhadrapada", "Revati"
  ];

  static const List<String> WEEKDAYS_TAMIL = [
    "ஞாயிறு", "திங்கள்", "செவ்வாய்", "புதன்", "வியாழன்", "வெள்ளி", "சனி"
  ];

  // 13 நட்சத்திர அடைப்பு முழு அட்டவணை (Reference Table)
  static const List<Map<String, dynamic>> ADAIPPU_REFERENCE_TABLE = [
    {
      'months': 6,
      'duration_label': '6 மாதங்கள் அடைப்பு',
      'title': 'தனிஷ்டா பஞ்சமி (மகா அடைப்பு)',
      'color': '#C62828', // Dark Red
      'stars': ['அவிட்டம்', 'சதயம்', 'பூரட்டாதி', 'உத்திரட்டாதி', 'ரேவதி'],
      'stars_en': ['Dhanishta', 'Shatabhisha', 'Purvabhadrapada', 'Uttarabhadrapada', 'Revati'],
      'description': 'அவிட்டம் முதல் ரேவதி வரையிலான 5 நட்சத்திரங்கள் தனிஷ்டா பஞ்சமி எனப்படும். இந்நாளில் மரணம் சம்பவித்தால் 6 மாத காலம் வீட்டு அடைப்பு மற்றும் சாந்தி ஹோமங்கள் செய்வது மரபு.',
    },
    {
      'months': 4,
      'duration_label': '4 மாதங்கள் அடைப்பு',
      'title': 'ரோகிணி நட்சத்திர அடைப்பு',
      'color': '#D84315', // Deep Orange
      'stars': ['ரோகிணி'],
      'stars_en': ['Rohini'],
      'description': 'ரோகிணி நட்சத்திரத்தில் மரணம் நிகழ்ந்தால் 4 மாத காலம் அடைப்பு செய்ய வேண்டும்.',
    },
    {
      'months': 3,
      'duration_label': '3 மாதங்கள் அடைப்பு',
      'title': 'கார்த்திகை, உத்திரம் அடைப்பு',
      'color': '#E65100', // Amber-Orange
      'stars': ['கார்த்திகை', 'உத்திரம்'],
      'stars_en': ['Krittika', 'Uttaraphalguni'],
      'description': 'கார்த்திகை அல்லது உத்திரம் நட்சத்திரத்தில் மரணம் நிகழ்ந்தால் 3 மாதங்கள் அடைப்பு செய்ய வேண்டும்.',
    },
    {
      'months': 2,
      'duration_label': '2 மாதங்கள் அடைப்பு',
      'title': 'மிருகசீரிஷம், சித்திரை, புனர்பூசம், விசாகம், உத்திராடம்',
      'color': '#F57F17', // Gold-Amber
      'stars': ['மிருகசீரிஷம்', 'சித்திரை', 'புனர்பூசம்', 'விசாகம்', 'உத்திராடம்'],
      'stars_en': ['Mrigashirsha', 'Chitra', 'Punarvasu', 'Vishakha', 'Uttarashada'],
      'description': 'இந்த 5 நட்சத்திரங்களில் மரணம் சம்பவித்தால் 2 மாதங்கள் அடைப்பு செய்ய வேண்டும்.',
    },
    {
      'months': 0,
      'duration_label': 'அடைப்பில்லை',
      'title': 'சுப நட்சத்திரங்கள் (அடைப்பு இல்லாதவை)',
      'color': '#2E7D32', // Dark Green
      'stars': ['அஸ்வினி', 'பரணி', 'திருவாதிரை', 'பூசம்', 'ஆயில்யம்', 'மகம்', 'பூரம்', 'அஸ்தம்', 'சுவாதி', 'அனுஷம்', 'கேட்டை', 'மூலம்', 'பூராடம்', 'திருவோணம்'],
      'stars_en': ['Ashwini', 'Bharani', 'Arudra', 'Pushya', 'Aslesha', 'Magha', 'Purvaphalguni', 'Hastha', 'Swati', 'Anuradha', 'Jyeshta', 'Mula', 'Purvashada', 'Shravana'],
      'description': 'இந்த 14 நட்சத்திரங்களில் மரணம் சம்பவித்தால் எந்தவித அடைப்பும் இல்லை.',
    },
  ];

  /// இன்றைய நட்சத்திரத்தின் அடிப்படையில் தனிஷ்டா பஞ்சமி & அடைப்பு தகவலைக் கணக்கிடுதல்
  static DhanishtaPanchamiInfo getDhanishtaInfo(int nakshatraIndex) {
    final idx = nakshatraIndex % 27;
    final nakTamil = TAMIL_NAKSHATRAS[idx];
    final nakEn = ENGLISH_NAKSHATRAS[idx];

    // 1. தனிஷ்டா பஞ்சமி (22: அவிட்டம், 23: சதயம், 24: பூரட்டாதி, 25: உத்திரட்டாதி, 26: ரேவதி)
    if (idx >= 22 && idx <= 26) {
      return DhanishtaPanchamiInfo(
        nakshatraIndex: idx,
        nakshatraName: nakEn,
        nakshatraNameTamil: nakTamil,
        isDhanishtaPanchami: true,
        isAdaippu: true,
        adaippuMonths: 6,
        adaippuTitle: "தனிஷ்டா பஞ்சமி (6 மாத அடைப்பு)",
        statusText: "இன்று தனிஷ்டா பஞ்சமி நட்சத்திரம் ($nakTamil) நிலவுகிறது.",
        description: "அவிட்டம் முதல் ரேவதி வரையிலான 5 நட்சத்திரங்கள் தனிஷ்டா பஞ்சமி என்று அழைக்கப்படுகின்றன. இந்த நட்சத்திரங்களில் புதுமனை கூரை வேய்தல், கட்டில் வாங்குதல், தெற்கு திசை பிரயாணம் ஆகியவற்றைத் தவிர்ப்பது மரபு. மரணம் சம்பவித்தால் 6 மாதங்கள் அடைப்பு காலம் ஆகும்.",
        remedies: "தனிஷ்டா பஞ்சக சாந்தி ஹோமம், தீப தானம், எள் தானம், சிவபெருமானுக்கு ருத்ராபிஷேகம் மற்றும் குலதெய்வ வழிபாடு செய்தல் நலம் பயக்கும்.",
      );
    }

    // 2. ரோகிணி (3) - 4 மாதங்கள்
    if (idx == 3) {
      return DhanishtaPanchamiInfo(
        nakshatraIndex: idx,
        nakshatraName: nakEn,
        nakshatraNameTamil: nakTamil,
        isDhanishtaPanchami: false,
        isAdaippu: true,
        adaippuMonths: 4,
        adaippuTitle: "ரோகிணி அடைப்பு (4 மாதங்கள்)",
        statusText: "இன்று ரோகிணி நட்சத்திரம் - 4 மாத அடைப்பு நட்சத்திரம்.",
        description: "ரோகிணி நட்சத்திரத்தில் மரணம் சம்பவித்தால் 4 மாத காலம் வீடு அடைப்பு சாஸ்திர விதியாகும்.",
        remedies: "நவக்கிரக சாந்தி, எள் மற்றும் தானிய தானம் செய்தல் உத்தமம்.",
      );
    }

    // 3. கார்த்திகை (2), உத்திரம் (11) - 3 மாதங்கள்
    if (idx == 2 || idx == 11) {
      return DhanishtaPanchamiInfo(
        nakshatraIndex: idx,
        nakshatraName: nakEn,
        nakshatraNameTamil: nakTamil,
        isDhanishtaPanchami: false,
        isAdaippu: true,
        adaippuMonths: 3,
        adaippuTitle: "3 மாத நட்சத்திர அடைப்பு",
        statusText: "இன்று $nakTamil நட்சத்திரம் - 3 மாத அடைப்பு காலம்.",
        description: "கார்த்திகை, உத்திரம் ஆகிய நட்சத்திரங்களில் மரணம் நிகழ்ந்தால் 3 மாத காலம் அடைப்பு அனுஷ்டிக்கப்படுகிறது.",
        remedies: "சூரிய நமஸ்காரம், நெய் தீப தானம் மற்றும் சாந்தி பரிகாரம் செய்தல் நன்று.",
      );
    }

    // 4. மிருகசீரிஷம் (4), புனர்பூசம் (6), சித்திரை (13), விசாகம் (15), உத்திராடம் (20) - 2 மாதங்கள்
    if (idx == 4 || idx == 6 || idx == 13 || idx == 15 || idx == 20) {
      return DhanishtaPanchamiInfo(
        nakshatraIndex: idx,
        nakshatraName: nakEn,
        nakshatraNameTamil: nakTamil,
        isDhanishtaPanchami: false,
        isAdaippu: true,
        adaippuMonths: 2,
        adaippuTitle: "2 மாத நட்சத்திர அடைப்பு",
        statusText: "இன்று $nakTamil நட்சத்திரம் - 2 மாத அடைப்பு காலம்.",
        description: "மிருகசீரிஷம், புனர்பூசம், சித்திரை, விசாகம், உத்திராடம் நட்சத்திரங்களில் மரணம் சம்பவித்தால் 2 மாத காலம் அடைப்பு விதியாகும்.",
        remedies: "சாந்தி ஹோமம் மற்றும் தான தர்மங்கள் செய்து சுபத்வம் பெறலாம்.",
      );
    }

    // 5. அடைப்பில்லாத சுப நட்சத்திரங்கள்
    return DhanishtaPanchamiInfo(
      nakshatraIndex: idx,
      nakshatraName: nakEn,
      nakshatraNameTamil: nakTamil,
      isDhanishtaPanchami: false,
      isAdaippu: false,
      adaippuMonths: 0,
      adaippuTitle: "நட்சத்திர அடைப்பு இல்லை",
      statusText: "இன்று சுப நட்சத்திரம் ($nakTamil) - எந்தவித அடைப்பும் இல்லை.",
      description: "இன்றைய நட்சத்திரத்திற்கு அடைப்பு தோஷம் ஏதுமில்லை. இது சுப காரியங்களுக்கும் நிம்மதியான நாளாகவும் திகழ்கிறது.",
      remedies: "வழக்கமான இஷ்ட தெய்வ வழிபாடு போதுமானது.",
    );
  }

  static AstroEngine? _cachedEngine;
  static AstroEngine get _engine => _cachedEngine ??= AstroEngine();

  /// இன்றைய நாளுக்குரிய மைத்ர முகூர்த்தத்தைக் கண்டறிதல் (துல்லியமானது மற்றும் அதிவேகமானது)
  static List<MaitraMuhurthamSlot> getTodayMaitraMuhurthams(DateTime date, double lat, double lon) {
    try {
      final engine = _engine;
      final midnight = DateTime(date.year, date.month, date.day, 0, 0);
      final night = DateTime(date.year, date.month, date.day, 23, 59);

      final moon0 = engine.calculatePlanetLongitude(midnight, 1);
      final moon24 = engine.calculatePlanetLongitude(night, 1);
      final nak0 = (moon0 / (360.0 / 27.0)).floor() % 27;
      final nak24 = (moon24 / (360.0 / 27.0)).floor() % 27;

      bool mightHaveAshwini = (nak0 == 0 || nak24 == 0 || (nak0 == 26 && (nak24 == 0 || nak24 == 1)));
      bool mightHaveAnuradha = (nak0 == 16 || nak24 == 16 || (nak0 == 15 && nak24 >= 16));

      if (!mightHaveAshwini && !mightHaveAnuradha) {
        return const [];
      }

      final lagna0 = engine.calculateLagna(midnight, lat, lon);
      final List<int> targetMinutes = [];

      if (mightHaveAshwini) {
        double diff = (15.0 - lagna0 + 360) % 360;
        int estMin = (diff * 4).round();
        for (int m = estMin - 80; m <= estMin + 80; m += 5) {
          int norm = (m + 1440) % 1440;
          if (!targetMinutes.contains(norm)) targetMinutes.add(norm);
        }
      }

      if (mightHaveAnuradha) {
        double diff = (225.0 - lagna0 + 360) % 360;
        int estMin = (diff * 4).round();
        for (int m = estMin - 80; m <= estMin + 80; m += 5) {
          int norm = (m + 1440) % 1440;
          if (!targetMinutes.contains(norm)) targetMinutes.add(norm);
        }
      }

      targetMinutes.sort();

      final List<MaitraMuhurthamSlot> slots = [];
      DateTime? slotStart;
      DateTime? slotEnd;
      String activeNak = "";
      String activeLagna = "";

      for (int min in targetMinutes) {
        final t = midnight.add(Duration(minutes: min));
        final lagnaDeg = engine.calculateLagna(t, lat, lon);
        final lagnaRasi = (lagnaDeg / 30.0).floor() % 12;
        final moonDeg = engine.calculatePlanetLongitude(t, 1);
        final moonNak = (moonDeg / (360.0 / 27.0)).floor() % 27;

        bool isMatch = false;
        String currentNakName = "";
        String currentLagnaName = "";

        if (lagnaRasi == 0 && moonNak == 0) {
          isMatch = true;
          currentNakName = "அஸ்வினி";
          currentLagnaName = "மேஷ லக்னம்";
        } else if (lagnaRasi == 7 && moonNak == 16) {
          isMatch = true;
          currentNakName = "அனுஷம்";
          currentLagnaName = "விருச்சிக லக்னம்";
        }

        if (isMatch) {
          if (slotStart == null) {
            slotStart = t;
            activeNak = currentNakName;
            activeLagna = currentLagnaName;
          }
          slotEnd = t.add(const Duration(minutes: 5));
        } else {
          if (slotStart != null && slotEnd != null) {
            int wkIdx = date.weekday == 7 ? 0 : date.weekday;
            bool isTue = wkIdx == 2;
            slots.add(MaitraMuhurthamSlot(
              date: date,
              startTime: slotStart,
              endTime: slotEnd,
              nakshatra: activeNak,
              lagna: activeLagna,
              weekday: WEEKDAYS_TAMIL[wkIdx],
              isTuesday: isTue,
              ratingText: isTue ? "100% மகா உத்தம மைத்ர முகூர்த்தம்" : "75% உத்தம மைத்ர முகூர்த்தம்",
            ));
            slotStart = null;
            slotEnd = null;
          }
        }
      }

      if (slotStart != null && slotEnd != null) {
        int wkIdx = date.weekday == 7 ? 0 : date.weekday;
        bool isTue = wkIdx == 2;
        slots.add(MaitraMuhurthamSlot(
          date: date,
          startTime: slotStart,
          endTime: slotEnd,
          nakshatra: activeNak,
          lagna: activeLagna,
          weekday: WEEKDAYS_TAMIL[wkIdx],
          isTuesday: isTue,
          ratingText: isTue ? "100% மகா உத்தம மைத்ர முகூர்த்தம்" : "75% உத்தம மைத்ர முகூர்த்தம்",
        ));
      }

      return slots;
    } catch (e) {
      return const [];
    }
  }

  static final Map<String, List<MaitraMuhurthamSlot>> _memoryMaitraCache = {};
  static final Map<String, List<DhanishtaDaySlot>> _memoryDhanishtaCache = {};

  /// குறிப்பிட்ட மாதத்திற்கான மைத்ர முகூர்த்த நாட்களைக் கண்டறிதல் (லோக்கல் கேச் மூலம்)
  static Future<List<MaitraMuhurthamSlot>> getMonthMaitraMuhurthams(
    int year,
    int month,
    double lat,
    double lon,
  ) async {
    final cacheKey = "cache_maitra_${year}_${month}_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}";

    if (_memoryMaitraCache.containsKey(cacheKey)) {
      return _memoryMaitraCache[cacheKey]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(cacheKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedJson);
        final slots = decoded.map((item) => MaitraMuhurthamSlot.fromJson(item as Map<String, dynamic>)).toList();
        _memoryMaitraCache[cacheKey] = slots;
        return slots;
      }
    } catch (_) {}

    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final List<MaitraMuhurthamSlot> results = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final curDate = DateTime(year, month, day);
      final daySlots = getTodayMaitraMuhurthams(curDate, lat, lon);
      if (daySlots.isNotEmpty) {
        results.addAll(daySlots);
      }
    }

    _memoryMaitraCache[cacheKey] = results;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(results.map((e) => e.toJson()).toList());
      await prefs.setString(cacheKey, jsonString);
    } catch (_) {}

    return results;
  }

  /// குறிப்பிட்ட மாதத்திற்கான தனிஷ்டா பஞ்சமி / அடைப்பு நாட்களைக் கண்டறிதல் (லோக்கல் கேச் மூலம்)
  static Future<List<DhanishtaDaySlot>> getMonthDhanishtaDays(
    int year,
    int month,
    double lat,
    double lon,
  ) async {
    final cacheKey = "cache_dhanishta_${year}_${month}_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}";

    if (_memoryDhanishtaCache.containsKey(cacheKey)) {
      return _memoryDhanishtaCache[cacheKey]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(cacheKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedJson);
        final slots = decoded.map((item) => DhanishtaDaySlot.fromJson(item as Map<String, dynamic>)).toList();
        _memoryDhanishtaCache[cacheKey] = slots;
        return slots;
      }
    } catch (_) {}

    final engine = _engine;
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final List<DhanishtaDaySlot> results = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final curDate = DateTime(year, month, day);
      final noon = DateTime(year, month, day, 12, 0);
      final moonDeg = engine.calculatePlanetLongitude(noon, 1);
      final nakIdx = (moonDeg / (360.0 / 27.0)).floor() % 27;

      final info = getDhanishtaInfo(nakIdx);
      if (info.isAdaippu) {
        final wkIdx = curDate.weekday == 7 ? 0 : curDate.weekday;
        results.add(DhanishtaDaySlot(
          date: curDate,
          nakshatraNameTamil: info.nakshatraNameTamil,
          nakshatraNameEn: info.nakshatraName,
          weekday: WEEKDAYS_TAMIL[wkIdx],
          isDhanishtaPanchami: info.isDhanishtaPanchami,
          isAdaippu: info.isAdaippu,
          adaippuMonths: info.adaippuMonths,
          adaippuTitle: info.adaippuTitle,
        ));
      }
    }

    _memoryDhanishtaCache[cacheKey] = results;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(results.map((e) => e.toJson()).toList());
      await prefs.setString(cacheKey, jsonString);
    } catch (_) {}

    return results;
  }

  static final Map<String, List<AbhijitMuhurthamSlot>> _memoryAbhijitCache = {};

  /// நாளுக்குரிய அபிஜித் முகூர்த்தத்தைக் கணக்கிடுதல் (சூரிய உதயத்திலிருந்து 15-ல் 8-வது பாகம்)
  static AbhijitMuhurthamSlot calculateAbhijitMuhurthamForDate(
    DateTime date,
    DateTime sunriseDt,
    DateTime sunsetDt,
  ) {
    double durationSeconds = sunsetDt.difference(sunriseDt).inSeconds.toDouble();
    if (durationSeconds <= 0) durationSeconds = 12 * 3600;

    int startSeconds = (7 * durationSeconds / 15.0).round();
    int endSeconds = (8 * durationSeconds / 15.0).round();
    DateTime start = sunriseDt.add(Duration(seconds: startSeconds));
    DateTime end = sunriseDt.add(Duration(seconds: endSeconds));

    int wkIdx = date.weekday == 7 ? 0 : date.weekday;
    bool isWed = date.weekday == DateTime.wednesday;

    String ratingText = isWed
        ? "புதன்கிழமை தோஷம் (தவிர்ப்பது நன்று)"
        : "100% மகா உத்தம சுப முகூர்த்தம்";

    String formatTime(DateTime dt) {
      int h = dt.hour % 12;
      if (h == 0) h = 12;
      String m = dt.minute.toString().padLeft(2, '0');
      String ampm = dt.hour >= 12 ? "PM" : "AM";
      return "$h:$m $ampm";
    }

    return AbhijitMuhurthamSlot(
      date: date,
      startTime: start,
      endTime: end,
      sunrise: formatTime(sunriseDt),
      sunset: formatTime(sunsetDt),
      weekday: WEEKDAYS_TAMIL[wkIdx],
      isWednesday: isWed,
      ratingText: ratingText,
      isAuspicious: !isWed,
    );
  }

  /// குறிப்பிட்ட மாதத்திற்கான அனைத்து நாட்களின் அபிஜித் முகூர்த்தப் பட்டியல் (லோக்கல் கேச் மூலம்)
  static Future<List<AbhijitMuhurthamSlot>> getMonthAbhijitMuhurthams(
    int year,
    int month,
    double lat,
    double lon,
  ) async {
    final cacheKey = "cache_abhijit_${year}_${month}_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}";

    if (_memoryAbhijitCache.containsKey(cacheKey)) {
      return _memoryAbhijitCache[cacheKey]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(cacheKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedJson);
        final slots = decoded.map((item) => AbhijitMuhurthamSlot.fromJson(item as Map<String, dynamic>)).toList();
        _memoryAbhijitCache[cacheKey] = slots;
        return slots;
      }
    } catch (_) {}

    final engine = _engine;
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final List<AbhijitMuhurthamSlot> results = [];
    const double timezone = 5.5;

    for (int day = 1; day <= daysInMonth; day++) {
      final curDate = DateTime(year, month, day);
      DateTime riseDt = DateTime(year, month, day, 6, 0);
      DateTime setDt = DateTime(year, month, day, 18, 0);

      try {
        double jd = (curDate.millisecondsSinceEpoch / 86400000.0) + 2440587.5;
        double jdNoonUt = jd.floor() + 0.5;
        double jdLocalMidnightUt = jdNoonUt - 0.5 - (timezone / 24.0);

        var phenomena = await engine.calcPhenomena(jdLocalMidnightUt, lat, lon, 0);
        double riseJD = phenomena['rise'] ?? 0;
        double setJD = phenomena['set'] ?? 0;

        if (riseJD > 0 && setJD > 0) {
          int riseMs = ((riseJD - 2440587.5) * 86400 * 1000).round();
          int setMs = ((setJD - 2440587.5) * 86400 * 1000).round();
          riseDt = DateTime.fromMillisecondsSinceEpoch(riseMs, isUtc: true).add(const Duration(minutes: 330));
          setDt = DateTime.fromMillisecondsSinceEpoch(setMs, isUtc: true).add(const Duration(minutes: 330));
        }
      } catch (_) {}

      final slot = calculateAbhijitMuhurthamForDate(curDate, riseDt, setDt);
      results.add(slot);
    }

    _memoryAbhijitCache[cacheKey] = results;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(results.map((e) => e.toJson()).toList());
      await prefs.setString(cacheKey, jsonString);
    } catch (_) {}

    return results;
  }
}
