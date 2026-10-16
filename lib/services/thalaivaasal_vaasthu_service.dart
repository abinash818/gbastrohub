enum VaasthuDirection {
  east,
  south,
  west,
  north,
}

class ThalaivaasalResult {
  final VaasthuDirection direction;
  final double totalFeet;
  final double ucchaFeet; // Total / 2
  final double onePartFeet; // ucchaFeet / 4.5
  final double uttamaStartFeet; // onePartFeet * 3
  final double uttamaEndFeet; // uttamaStartFeet + onePartFeet
  final double neesaStartFeet; // ucchaFeet
  final double neesaEndFeet; // totalFeet

  final String startCornerName; // e.g., 'ஈசானியம் (வடகிழக்கு)'
  final String endCornerName; // e.g., 'அக்னி (தென்கிழக்கு)'
  final String startCornerShort; // e.g., 'ஈசானியம்'
  final String endCornerShort; // e.g., 'அக்னி'

  const ThalaivaasalResult({
    required this.direction,
    required this.totalFeet,
    required this.ucchaFeet,
    required this.onePartFeet,
    required this.uttamaStartFeet,
    required this.uttamaEndFeet,
    required this.neesaStartFeet,
    required this.neesaEndFeet,
    required this.startCornerName,
    required this.endCornerName,
    required this.startCornerShort,
    required this.endCornerShort,
  });

  static String toFeetAndInches(double feet) {
    if (feet <= 0) return "0 அடி 0 அங்";
    int ft = feet.floor();
    double remaining = (feet - ft) * 12.0;
    int inches = remaining.round();
    if (inches == 12) {
      ft += 1;
      inches = 0;
    }
    return "$ft அடி $inches அங்";
  }

  static String toFeetAndInchesDetailed(double feet) {
    if (feet <= 0) return "0 அடி 0 அங்குலம் (0.00 அடி)";
    int ft = feet.floor();
    double remaining = (feet - ft) * 12.0;
    int inches = remaining.round();
    if (inches == 12) {
      ft += 1;
      inches = 0;
    }
    return "$ft அடி $inches அங்குலம் (${feet.toStringAsFixed(2)} அடி)";
  }
}

class ThalaivaasalVaasthuService {
  /// Direction Display Name in Tamil
  static String getDirectionName(VaasthuDirection dir) {
    switch (dir) {
      case VaasthuDirection.east:
        return 'கிழக்கு (East)';
      case VaasthuDirection.south:
        return 'தெற்கு (South)';
      case VaasthuDirection.west:
        return 'மேற்கு (West)';
      case VaasthuDirection.north:
        return 'வடக்கு (North)';
    }
  }

  static String getDirectionOnlyTamil(VaasthuDirection dir) {
    switch (dir) {
      case VaasthuDirection.east:
        return 'கிழக்கு';
      case VaasthuDirection.south:
        return 'தெற்கு';
      case VaasthuDirection.west:
        return 'மேற்கு';
      case VaasthuDirection.north:
        return 'வடக்கு';
    }
  }

  /// Calculates Thalaivaasal position according to GB Vaasthu rules
  static ThalaivaasalResult calculate({
    required VaasthuDirection direction,
    required double feet,
    required double inches,
  }) {
    final double totalFeet = feet + (inches / 12.0);
    final double safeTotal = totalFeet > 0 ? totalFeet : 17.0;

    // 1. உச்சப்பகுதி (மத்திமம் பலன்) = கொடுக்கப்பட்ட அளவு ÷ 2
    final double ucchaFeet = safeTotal / 2.0;

    // 2. உத்தம பலன் கணிதம்:
    //    உச்சப்பகுதி வந்த அளவை ÷ 4.5 வகுக்க வேண்டும் = ஒரு பகுதி
    final double onePartFeet = ucchaFeet / 4.5;

    //    ஒரு பகுதி அளவு × 3 = உத்தம பகுதி ஆரம்ப அளவு
    final double uttamaStartFeet = onePartFeet * 3.0;

    //    ஆரம்ப அளவுடன் ஒரு பகுதி அளவு கூட்ட வேண்டும் = உத்தம பகுதி முடிவு அளவு
    final double uttamaEndFeet = uttamaStartFeet + onePartFeet;

    final double neesaStartFeet = ucchaFeet;
    final double neesaEndFeet = safeTotal;

    // Corner determinations based on direction
    String startCornerName = '';
    String endCornerName = '';
    String startCornerShort = '';
    String endCornerShort = '';

    switch (direction) {
      case VaasthuDirection.east:
        // கிழக்கு பார்த்த கட்டிடம்: ஈசானியத்தில் (வடகிழக்கு) இருந்து உச்சப்பகுதி ஆரம்பம் -> அக்னி (தென்கிழக்கு)
        startCornerName = 'ஈசானியம் (வடகிழக்கு)';
        endCornerName = 'அக்னி (தென்கிழக்கு)';
        startCornerShort = 'ஈசானியம்';
        endCornerShort = 'அக்னி';
        break;

      case VaasthuDirection.south:
        // தெற்கு பார்த்த கட்டிடம்: அக்னி (தென்கிழக்கு) மூலையிலிருந்து உச்சப்பகுதி ஆரம்பம் -> கன்னி (தென்மேற்கு)
        startCornerName = 'அக்னி (தென்கிழக்கு)';
        endCornerName = 'கன்னி / நிருதி (தென்மேற்கு)';
        startCornerShort = 'அக்னி';
        endCornerShort = 'கன்னி';
        break;

      case VaasthuDirection.west:
        // மேற்கு பார்த்த கட்டிடம்: வாயு (வடமேற்கு) மூலையிலிருந்து உச்சப்பகுதி ஆரம்பம் -> கன்னி (தென்மேற்கு)
        startCornerName = 'வாயு (வடமேற்கு)';
        endCornerName = 'கன்னி / நிருதி (தென்மேற்கு)';
        startCornerShort = 'வாயு';
        endCornerShort = 'கன்னி';
        break;

      case VaasthuDirection.north:
        // வடக்கு பார்த்த கட்டிடம்: ஈசானிய (வடகிழக்கு) மூலையிலிருந்து உச்சப்பகுதி ஆரம்பம் -> வாயு (வடமேற்கு)
        startCornerName = 'ஈசானியம் (வடகிழக்கு)';
        endCornerName = 'வாயு (வடமேற்கு)';
        startCornerShort = 'ஈசானியம்';
        endCornerShort = 'வாயு';
        break;
    }

    return ThalaivaasalResult(
      direction: direction,
      totalFeet: safeTotal,
      ucchaFeet: ucchaFeet,
      onePartFeet: onePartFeet,
      uttamaStartFeet: uttamaStartFeet,
      uttamaEndFeet: uttamaEndFeet,
      neesaStartFeet: neesaStartFeet,
      neesaEndFeet: neesaEndFeet,
      startCornerName: startCornerName,
      endCornerName: endCornerName,
      startCornerShort: startCornerShort,
      endCornerShort: endCornerShort,
    );
  }
}
