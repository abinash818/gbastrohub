#include "../include/nithya.h"
#include <math.h>

// Helper to normalize degrees
static double normalize_degrees(double degrees) {
    double res = fmod(degrees, 360.0);
    if (res < 0.0) res += 360.0;
    return res;
}

// Calculate Tithi
// Difference between Moon and Sun longitudes divided by 12
// Returns 1 to 30 (fractional part indicates progress of Tithi)
NITHYA_API double nithya_calc_tithi(double sun_longitude, double moon_longitude) {
    double diff = normalize_degrees(moon_longitude - sun_longitude);
    double tithi = diff / 12.0;
    // Tithi usually represented as 1 to 30
    return tithi + 1.0; 
}

// Calculate Nakshatra
// Moon's longitude divided by 13 degrees 20 minutes (13.333333 degrees)
// Returns 1 to 27 (fractional part indicates progress of Nakshatra)
NITHYA_API double nithya_calc_nakshatra(double moon_longitude) {
    double nakshatra = normalize_degrees(moon_longitude) / (360.0 / 27.0);
    // Nakshatras usually represented as 1 to 27
    return nakshatra + 1.0; 
}
