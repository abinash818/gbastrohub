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

  /// Helper to reduce any number to a single digit (1-9)
  static int _reduceToSingleDigit(int n) {
    if (n == 0) return 0;
    int reduced = n % 9;
    return reduced == 0 ? 9 : reduced;
  }
}
