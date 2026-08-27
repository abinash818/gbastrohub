const Map<String, Map<String, String>> PLANET_NAMES = {
  "English": {
    "sun": "Su", "moon": "Mo", "mars": "Ma", "mercury": "Me",
    "jupiter": "J", "venus": "V", "saturn": "Sa",
    "rahu": "R", "ketu": "K", "lagna": "L"
  },
  "Tamil": {
    "sun": "சூரி", "moon": "சந்", "mars": "செவ்", "mercury": "புத",
    "jupiter": "குரு", "venus": "சுக்", "saturn": "சனி",
    "rahu": "ராகு", "ketu": "கேது", "lagna": "லக்"
  }
};

const Map<String, int> RASI_GRID = {
  "0,0": 12, "0,1": 1, "0,2": 2, "0,3": 3,
  "1,0": 11, "1,3": 4,
  "2,0": 10, "2,3": 5,
  "3,0": 9, "3,1": 8, "3,2": 7, "3,3": 6
};

const Map<String, Map<int, String>> FULL_RASI_NAMES = {
  "English": {
    1: 'Aries', 2: 'Taurus', 3: 'Gemini', 4: 'Cancer', 5: 'Leo', 6: 'Virgo',
    7: 'Libra', 8: 'Scorpio', 9: 'Sagittarius', 10: 'Capricorn', 11: 'Aquarius', 12: 'Pisces'
  },
  "Tamil": {
    1: 'மேஷம்', 2: 'ரிஷபம்', 3: 'மிதுனம்', 4: 'கடகம்', 5: 'சிம்மம்', 6: 'கன்னி',
    7: 'துலாம்', 8: 'விருச்சிகம்', 9: 'தனுசு', 10: 'மகரம்', 11: 'கும்பம்', 12: 'மீனம்'
  }
};

const Map<String, Map<String, String>> FULL_PLANET_NAMES = {
  "English": {
    "sun": "Sun", "moon": "Moon", "mars": "Mars", "mercury": "Mercury",
    "jupiter": "Jupiter", "venus": "Venus", "saturn": "Saturn",
    "rahu": "Rahu", "ketu": "Ketu", "lagna": "Lagna"
  },
  "Tamil": {
    "sun": "சூரியன்", "moon": "சந்திரன்", "mars": "செவ்வாய்", "mercury": "புதன்",
    "jupiter": "குரு", "venus": "சுக்கிரன்", "saturn": "சனி",
    "rahu": "ராகு", "ketu": "கேது", "lagna": "லக்னம்"
  }
};
