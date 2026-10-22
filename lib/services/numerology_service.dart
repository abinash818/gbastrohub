class NumerologyService {
  // Chaldean Numerology Mapping
  static const Map<String, int> chaldeanMap = {
    'A': 1, 'I': 1, 'J': 1, 'Q': 1, 'Y': 1,
    'B': 2, 'K': 2, 'R': 2,
    'C': 3, 'G': 3, 'L': 3, 'S': 3,
    'D': 4, 'M': 4, 'T': 4,
    'E': 5, 'H': 5, 'N': 5, 'X': 5,
    'U': 6, 'V': 6, 'W': 6,
    'O': 7, 'Z': 7,
    'F': 8, 'P': 8,
  };

  /// Calculates the Psychic Number (Day of Birth)
  static int calculatePsychicNumber(DateTime dob) {
    return _reduceToSingleDigit(dob.day);
  }

  /// Calculates the Destiny Number (Full Date of Birth)
  static int calculateDestinyNumber(DateTime dob) {
    int sum = dob.day + dob.month + dob.year;
    return _reduceToSingleDigit(sum);
  }

  /// Calculates the Name Number using Chaldean method (Root number)
  static int calculateNameNumber(String name) {
    int total = calculateCompoundNameNumber(name);
    return _reduceToSingleDigit(total);
  }

  /// Calculates the Compound Name Number using Chaldean method (Total sum)
  static int calculateCompoundNameNumber(String name) {
    int total = 0;
    String cleanName = name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    
    for (int i = 0; i < cleanName.length; i++) {
      total += chaldeanMap[cleanName[i]] ?? 0;
    }
    
    return total;
  }

  /// Generates the full Pyramid Numerology data (Rows of inverted triangle)
  static List<List<int>> calculatePyramidData(String name) {
    String cleanName = name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (cleanName.isEmpty) return [];

    // Row 0: Initial values of letters
    List<int> firstRow = [];
    for (int i = 0; i < cleanName.length; i++) {
      firstRow.add(chaldeanMap[cleanName[i]] ?? 0);
    }

    List<List<int>> pyramid = [firstRow];

    // Iteratively build the pyramid rows
    while (pyramid.last.length > 1) {
      List<int> currentRow = pyramid.last;
      List<int> nextRow = [];
      for (int i = 0; i < currentRow.length - 1; i++) {
        int sum = currentRow[i] + currentRow[i + 1];
        nextRow.add(_reduceToSingleDigit(sum));
      }
      pyramid.add(nextRow);
    }

    return pyramid;
  }

  /// Generates the Pyramid Numerology data for Date of Birth (ddmmyyyy)
  static List<List<int>> calculateDobPyramidData(DateTime dob) {
    String dateStr = "${dob.day.toString().padLeft(2, '0')}${dob.month.toString().padLeft(2, '0')}${dob.year.toString().padLeft(4, '0')}";
    List<int> firstRow = dateStr.split('').map((e) => int.parse(e)).toList();
    List<List<int>> pyramid = [firstRow];

    while (pyramid.last.length > 1) {
      List<int> currentRow = pyramid.last;
      List<int> nextRow = [];
      for (int i = 0; i < currentRow.length - 1; i++) {
        int sum = currentRow[i] + currentRow[i + 1];
        nextRow.add(_reduceToSingleDigit(sum));
      }
      pyramid.add(nextRow);
    }

    return pyramid;
  }

  /// Formats the pyramid result as "[lastTwoDigits] = [peak]" (e.g. "34 = 7")
  /// or single digit if pyramid has fewer than 2 rows.
  static String formatPyramidResult(List<List<int>> pyramid) {
    if (pyramid.isEmpty || pyramid.last.isEmpty) return "";
    final int peak = pyramid.last.first;
    if (pyramid.length >= 2 && pyramid[pyramid.length - 2].length >= 2) {
      final rowBeforeLast = pyramid[pyramid.length - 2];
      final String lastTwo = "${rowBeforeLast[0]}${rowBeforeLast[1]}";
      return "$lastTwo = $peak";
    }
    return "$peak";
  }

  /// Returns digit breakdown for Date of Birth (DDMMYYYY)
  static List<int> getDobDigits(DateTime dob) {
    String dateStr = "${dob.day.toString().padLeft(2, '0')}${dob.month.toString().padLeft(2, '0')}${dob.year.toString().padLeft(4, '0')}";
    return dateStr.split('').map((e) => int.parse(e)).toList();
  }

  /// Returns Chaldean value for a letter (A-Z) or digit value for (0-9)
  static int getChaldeanValue(String char) {
    if (char.isEmpty) return 0;
    String upper = char[0].toUpperCase();
    if (chaldeanMap.containsKey(upper)) {
      return chaldeanMap[upper]!;
    }
    int? digit = int.tryParse(upper);
    if (digit != null) {
      return digit;
    }
    return 0;
  }

  /// Calculates the Compound Number for Alphanumeric / Numeric (Vehicle, Mobile, etc.)
  static int calculateAlphanumericCompoundNumber(String input) {
    int total = 0;
    String clean = input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    for (int i = 0; i < clean.length; i++) {
      total += getChaldeanValue(clean[i]);
    }
    return total;
  }

  /// Calculates the Root Number (1-9) for Alphanumeric / Numeric input
  static int calculateAlphanumericRootNumber(String input) {
    int compound = calculateAlphanumericCompoundNumber(input);
    return _reduceToSingleDigit(compound);
  }

  /// Returns character breakdown with mapped Chaldean / numeric value
  static List<Map<String, dynamic>> getCharacterBreakdown(String input) {
    String clean = input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    List<Map<String, dynamic>> list = [];
    for (int i = 0; i < clean.length; i++) {
      list.add({
        'char': clean[i],
        'value': getChaldeanValue(clean[i]),
      });
    }
    return list;
  }

  /// Generates the Pyramid Numerology data for Alphanumeric / Numeric (Vehicle, Mobile, etc.)
  static List<List<int>> calculateAlphanumericPyramidData(String input) {
    String clean = input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (clean.isEmpty) return [];

    List<int> firstRow = [];
    for (int i = 0; i < clean.length; i++) {
      firstRow.add(getChaldeanValue(clean[i]));
    }

    List<List<int>> pyramid = [firstRow];

    while (pyramid.last.length > 1) {
      List<int> currentRow = pyramid.last;
      List<int> nextRow = [];
      for (int i = 0; i < currentRow.length - 1; i++) {
        int sum = currentRow[i] + currentRow[i + 1];
        nextRow.add(_reduceToSingleDigit(sum));
      }
      pyramid.add(nextRow);
    }

    return pyramid;
  }

  /// Planet information for single digit root / pyramid peak numbers (1-9)
  static Map<String, String> getNumberAttributes(int number) {
    switch (number) {
      case 1:
        return {
          'planet': 'சூரியன் (Sun)',
          'color': 'மஞ்சள், தங்க நிறம்',
          'metal': 'தங்கம், செம்பு',
          'quality': 'தலைமைத்துவம், புகழ், நிர்வாகத்திறன், வெற்றி',
          'friendly': '1, 2, 3, 9',
        };
      case 2:
        return {
          'planet': 'சந்திரன் (Moon)',
          'color': 'வெள்ளை, வெளிர் நீலம்',
          'metal': 'வெள்ளி',
          'quality': 'அமைதி, கற்பனைத் திறன், சமநிலை, பாசம்',
          'friendly': '1, 5',
        };
      case 3:
        return {
          'planet': 'குரு (Jupiter)',
          'color': 'மஞ்சள், பொன் நிறம்',
          'metal': 'தங்கம்',
          'quality': 'ஞானம், கல்வி, ஆன்மீகம், வளர்ச்சி, அதிர்ஷ்டம்',
          'friendly': '1, 2, 3, 9',
        };
      case 4:
        return {
          'planet': 'ராகு (Rahu)',
          'color': 'நீலம், சாம்பல்',
          'metal': 'ஈயம், கலப்பு உலோகம்',
          'quality': 'திடீர் முன்னேற்றம், நவீன சிந்தனை, சுறுசுறுப்பு',
          'friendly': '1, 5, 6',
        };
      case 5:
        return {
          'planet': 'புதன் (Mercury)',
          'color': 'பச்சை',
          'metal': 'பித்தளை, தங்கம்',
          'quality': 'புத்தி கூர்மை, தகவல் தொடர்பு, வியாபார மேன்மை, வேகம்',
          'friendly': '1, 5, 6',
        };
      case 6:
        return {
          'planet': 'சுக்கிரன் (Venus)',
          'color': 'வெள்ளை, பளபளப்பான நிறங்கள்',
          'metal': 'வெள்ளி, பிளாட்டினம்',
          'quality': 'சொகுசு, கவர்ச்சி, கலை ஆர்வம், செல்வம், மகிழ்ச்சி',
          'friendly': '5, 6, 8',
        };
      case 7:
        return {
          'planet': 'கேது (Ketu)',
          'color': 'வெளிர் மஞ்சள், பலவண்ணம்',
          'metal': 'வெள்ளி',
          'quality': 'ஆராய்ச்சி, நுண்ணறிவு, ஆன்மீக பாதுகாப்பு, தூய்மை',
          'friendly': '1, 2, 4',
        };
      case 8:
        return {
          'planet': 'சனி (Saturn)',
          'color': 'கருப்பு, அடர் நீலம்',
          'metal': 'இரும்பு',
          'quality': 'நீதி, உழைப்பு, பொறுமை, நீண்ட கால நிலைத்தன்மை',
          'friendly': '3, 5, 6',
        };
      case 9:
        return {
          'planet': 'செவ்வாய் (Mars)',
          'color': 'சிவப்பு',
          'metal': 'செம்பு',
          'quality': 'வீரம், ஆற்றல், துணிவு, தலைமை, வெற்றி',
          'friendly': '1, 2, 3, 9',
        };
      default:
        return {
          'planet': '-',
          'color': '-',
          'metal': '-',
          'quality': '-',
          'friendly': '-',
        };
    }
  }

  /// Helper to reduce any number to a single digit (1-9)
  static int _reduceToSingleDigit(int n) {
    if (n == 0) return 0;
    int reduced = n % 9;
    return reduced == 0 ? 9 : reduced;
  }
}
