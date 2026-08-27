#include "../include/nithya.h"
#include <math.h>

// Julian Day calculation based on Jean Meeus Astronomical Algorithms
NITHYA_API double nithya_calc_julian_day(int year, int month, int day, int hour, int minute, double second) {
    if (month <= 2) {
        year -= 1;
        month += 12;
    }
    
    int A = year / 100;
    int B = 2 - A + (A / 4); // Gregorian calendar adjustment
    
    double JD = (int)(365.25 * (year + 4716)) + (int)(30.6001 * (month + 1)) + day + B - 1524.5;
    
    // Add time component
    double day_fraction = (hour + (minute / 60.0) + (second / 3600.0)) / 24.0;
    JD += day_fraction;
    
    return JD;
}

// Simplified Delta T calculation for the range 1900-2100
NITHYA_API double nithya_calc_delta_t(double jd) {
    double year = 2000.0 + (jd - 2451545.0) / 365.25;
    double t = year - 2000.0;
    
    if (year >= 2000.0) {
        return 62.92 + 0.32217 * t + 0.005589 * t * t;
    } else {
        double t1900 = year - 1900.0;
        return -2.79 + 1.494119 * t1900 - 0.0598939 * t1900 * t1900 + 0.00061966 * t1900 * t1900 * t1900;
    }
}

// Helper: Normalize degrees to 0-360
static double normalize_degrees(double deg) {
    deg = fmod(deg, 360.0);
    if (deg < 0) {
        deg += 360.0;
    }
    return deg;
}

static double deg(double rad) { return rad * 180.0 / M_PI; }
static double rad(double deg) { return deg * M_PI / 180.0; }

// Calculate Ascendant (Lagna)
NITHYA_API double nithya_calc_ascendant(double jd, double lat, double lon) {
    double T = (jd - 2451545.0) / 36525.0;
    
    // Greenwich Mean Sidereal Time (GMST) in degrees
    double gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * T * T - (T * T * T) / 38710000.0;
    
    // Local Sidereal Time (LST) in degrees
    double lst = normalize_degrees(gmst + lon);
    
    // Obliquity of Ecliptic (epsilon) in degrees
    double epsilon = 23.43929111 - 0.013004167 * T - 0.00000016389 * T * T + 0.0000005036 * T * T * T;
    
    // Convert to radians
    double lst_rad = rad(lst);
    double eps_rad = rad(epsilon);
    double lat_rad = rad(lat);
    
    // Ascendant formula (Meeus Chapter 14)
    double y = cos(lst_rad);
    double x = -sin(lst_rad) * cos(eps_rad) - tan(lat_rad) * sin(eps_rad);
    
    double asc_rad = atan2(y, x);
    return normalize_degrees(deg(asc_rad));
}

// Placidus House Cusp Iteration Helper
static double placidus_iterate(double ramc, double lat_rad, double eps_rad, double factor) {
    double ra = ramc;
    double d, a, ra_new, l_new;
    double l = ra; // initial guess
    
    for (int i = 0; i < 10; i++) {
        double l_rad = rad(l);
        d = asin(sin(eps_rad) * sin(l_rad));
        a = asin(tan(lat_rad) * tan(d));
        ra_new = ramc + factor * deg(a);
        
        double y = sin(rad(ra_new));
        double x = cos(rad(ra_new)) * cos(eps_rad);
        l_new = deg(atan2(y, x));
        
        if (fabs(l_new - l) < 0.0001) break;
        l = l_new;
    }
    return normalize_degrees(l);
}

// Calculate all 12 house cusps using Placidus
NITHYA_API void nithya_calc_houses_placidus(double jd, double lat, double lon, double* cusps) {
    double T = (jd - 2451545.0) / 36525.0;
    double gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * T * T;
    double lst = normalize_degrees(gmst + lon);
    double epsilon = 23.43929111 - 0.013004167 * T;
    
    double lst_rad = rad(lst);
    double eps_rad = rad(epsilon);
    double lat_rad = rad(lat);
    
    // House 1 (Ascendant)
    double y1 = cos(lst_rad);
    double x1 = -sin(lst_rad) * cos(eps_rad) - tan(lat_rad) * sin(eps_rad);
    cusps[1] = normalize_degrees(deg(atan2(y1, x1)));
    
    // House 10 (Midheaven)
    double y10 = sin(lst_rad);
    double x10 = cos(lst_rad) * cos(eps_rad);
    cusps[10] = normalize_degrees(deg(atan2(y10, x10)));
    
    // Iterative Houses
    cusps[11] = placidus_iterate(normalize_degrees(lst + 30.0), lat_rad, eps_rad, 1.0 / 3.0);
    cusps[12] = placidus_iterate(normalize_degrees(lst + 60.0), lat_rad, eps_rad, 2.0 / 3.0);
    cusps[2] = placidus_iterate(normalize_degrees(lst + 120.0), lat_rad, eps_rad, 2.0 / 3.0);
    cusps[3] = placidus_iterate(normalize_degrees(lst + 150.0), lat_rad, eps_rad, 1.0 / 3.0);
    
    // Opposite Houses
    cusps[4] = normalize_degrees(cusps[10] + 180.0);
    cusps[5] = normalize_degrees(cusps[11] + 180.0);
    cusps[6] = normalize_degrees(cusps[12] + 180.0);
    cusps[7] = normalize_degrees(cusps[1] + 180.0);
    cusps[8] = normalize_degrees(cusps[2] + 180.0);
    cusps[9] = normalize_degrees(cusps[3] + 180.0);
}
