#ifndef NITHYA_H
#define NITHYA_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
  #define NITHYA_API __declspec(dllexport)
#else
  #define NITHYA_API __attribute__((visibility("default")))
#endif

// Constants
#define NITHYA_VERSION "0.1.0"

// Struct to hold DateTime
typedef struct {
    int year;
    int month;
    int day;
    int hour;
    int minute;
    double second;
} NithyaDateTime;

// Calculate Julian Day for a given UTC DateTime
// Uses standard astronomical algorithms
NITHYA_API double nithya_calc_julian_day(int year, int month, int day, int hour, int minute, double second);

// Calculate Delta T (difference between TT and UT) for a given Julian Day
// This is essential for accurate ephemeris calculations.
NITHYA_API double nithya_calc_delta_t(double jd);

// --- Astrological Enums ---

#define NITHYA_SUN 0
#define NITHYA_MOON 1
#define NITHYA_MARS 2
#define NITHYA_MERCURY 3
#define NITHYA_JUPITER 4
#define NITHYA_VENUS 5
#define NITHYA_SATURN 6
#define NITHYA_RAHU 7
#define NITHYA_KETU 8
#define NITHYA_TRUE_RAHU 10
#define NITHYA_TRUE_KETU 11
#define NITHYA_EARTH 99



// --- Planetary Calculations ---

// Calculate the geocentric tropical longitude, latitude, and distance of a planet
NITHYA_API void nithya_calc_planet(double jd, int planet_id, double* longitude, double* latitude, double* distance);

// Calculate Ascendant (Lagna) - returns tropical longitude of Ascendant
// Provide geographical latitude and longitude (positive for East, negative for West)
NITHYA_API double nithya_calc_ascendant(double jd, double lat, double lon);

// Calculate all 12 house cusps using Placidus method.
// cusps must be a double array of size 13 (index 1 to 12).
NITHYA_API void nithya_calc_houses_placidus(double jd, double lat, double lon, double* cusps);

// Calculate Rise, Set, and Transit for a given planet (NITHYA_SUN or NITHYA_MOON)
// Output: rise_jd, set_jd, transit_jd
NITHYA_API void nithya_calc_phenomena(double jd, double lat, double lon, int planet_id, double* rise_jd, double* set_jd, double* transit_jd);

// Calculate Lahiri Ayanamsa (Chitra Paksha) for a given Julian Day
NITHYA_API double nithya_calc_lahiri_ayanamsa(double jd);

// --- Panchang Calculations ---

// Calculate current Tithi (0.0 to 30.0, where each integer represents one Tithi)
// Requires sidereal longitudes of Sun and Moon
NITHYA_API double nithya_calc_tithi(double sun_longitude, double moon_longitude);

// Calculate current Nakshatra (0.0 to 27.0)
// Requires sidereal longitude of Moon
NITHYA_API double nithya_calc_nakshatra(double moon_longitude);

#ifdef __cplusplus
}
#endif

#endif // NITHYA_H
