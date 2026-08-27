#include "../include/nithya.h"
#include <math.h>

// Helper function to keep degrees between 0 and 360
static double normalize_degrees(double deg) {
    deg = fmod(deg, 360.0);
    if (deg < 0) {
        deg += 360.0;
    }
    return deg;
}

static double deg(double rad) { return rad * 180.0 / M_PI; }
static double rad(double deg) { return deg * M_PI / 180.0; }

// Helper for sum series needed by vsop87_calc.h
#ifndef VSOP_TERM_DEFINED
#define VSOP_TERM_DEFINED
typedef struct { double A; double B; double C; } VsopTerm;
#endif

static double sum_vsop_series(const VsopTerm* terms, int count, double tau) {
    double sum = 0.0;
    for (int i = 0; i < count; i++) {
        sum += terms[i].A * cos(terms[i].B + terms[i].C * tau);
    }
    return sum;
}

// Include the auto-generated switch statement function
#include "../include/vsop87_calc.h"

// Calculate Nutation in Longitude (dpsi) in degrees
static double calc_nutation(double T) {
    double omega = 125.04452 - 1934.136261 * T;
    double l_sun = 280.4665 + 36000.7698 * T;
    double l_moon = 218.3165 + 481267.8813 * T;
    
    double omega_rad = rad(omega);
    double l_sun_rad = rad(l_sun);
    double l_moon_rad = rad(l_moon);
    
    double dpsi_arcsec = -17.20 * sin(omega_rad) 
                         - 1.32 * sin(2.0 * l_sun_rad) 
                         - 0.23 * sin(2.0 * l_moon_rad) 
                         + 0.21 * sin(2.0 * omega_rad);
                         
    return dpsi_arcsec / 3600.0;
}

// Convert Heliocentric Spherical to Geocentric Spherical
static void helio_to_geo(double L0, double B0, double R0, double Lp, double Bp, double Rp, double* geo_lon, double* geo_lat, double* geo_dist) {
    // Earth rectangular (using L, B, R)
    double x0 = R0 * cos(B0) * cos(L0);
    double y0 = R0 * cos(B0) * sin(L0);
    double z0 = R0 * sin(B0);
    
    // Planet rectangular
    double xp = Rp * cos(Bp) * cos(Lp);
    double yp = Rp * cos(Bp) * sin(Lp);
    double zp = Rp * sin(Bp);
    
    // Geocentric rectangular
    double x = xp - x0;
    double y = yp - y0;
    double z = zp - z0;
    
    // Geocentric spherical
    *geo_dist = sqrt(x*x + y*y + z*z);
    *geo_lon = normalize_degrees(deg(atan2(y, x)));
    *geo_lat = deg(asin(z / *geo_dist));
}

// Planetary Calculations (Full VSOP87 for 6 Planets, basic for others)
NITHYA_API void nithya_calc_planet(double jd, int planet_id, double* longitude, double* latitude, double* distance) {
    // Add Delta T to get Terrestrial Time (TT)
    double jd_tt = jd + (nithya_calc_delta_t(jd) / 86400.0);
    // tau is Julian millennia since J2000.0 for VSOP87
    double tau = (jd_tt - 2451545.0) / 365250.0; 
    
    // Calculate Earth's heliocentric position (used for geocentric conversion)
    double earth_L, earth_B, earth_R;
    get_vsop87_heliocentric(NITHYA_SUN, tau, &earth_L, &earth_B, &earth_R);
    
    double dpsi = calc_nutation((jd_tt - 2451545.0) / 36525.0);

    if (planet_id == NITHYA_SUN) {
        // Light time for Sun
        double tau_light = 0.0057755183 * earth_R;
        double tau_sun = (jd_tt - tau_light - 2451545.0) / 365250.0;
        double e_L, e_B, e_R;
        get_vsop87_heliocentric(NITHYA_SUN, tau_sun, &e_L, &e_B, &e_R);
        
        // Sun from Earth is exactly Earth from Sun + 180 deg, opposite latitude
        *longitude = normalize_degrees(deg(e_L) + 180.0 + dpsi);
        *latitude = -deg(e_B);
        *distance = e_R; 
        return;
    }
    
    if (planet_id == NITHYA_MOON) {
        // High-precision Moon calculation (Meeus Chapter 47 - Top terms)
        double T = (jd_tt - 2451545.0) / 36525.0; 
        
        double L_prime = 218.3164477 + 481267.88123421 * T;
        double D = 297.8501921 + 445267.1114034 * T;
        double M = 357.5291092 + 35999.0502909 * T;
        double M_prime = 134.9633964 + 477198.8675055 * T;
        double F = 93.2720950 + 483202.0175233 * T;
        
        // 60 periodic terms for Moon's longitude (Meeus Chapter 47)
        double sum_L = 0.0;
        sum_L += 6288774.0 * sin(rad(M_prime));
        sum_L += 1274027.0 * sin(rad(2*D - M_prime));
        sum_L += 658314.0 * sin(rad(2*D));
        sum_L += 213618.0 * sin(rad(2*M_prime));
        sum_L += -185116.0 * sin(rad(M));
        sum_L += -114332.0 * sin(rad(2*F));
        sum_L += 58793.0 * sin(rad(2*D - 2*M_prime));
        sum_L += 57066.0 * sin(rad(2*D - M - M_prime));
        sum_L += 53322.0 * sin(rad(2*D + M_prime));
        sum_L += 45758.0 * sin(rad(2*D - M));
        sum_L += -40923.0 * sin(rad(M - M_prime));
        sum_L += -34720.0 * sin(rad(D));
        sum_L += -30383.0 * sin(rad(M + M_prime));
        sum_L += 15327.0 * sin(rad(2*D - 2*F));
        sum_L += -12528.0 * sin(rad(M_prime + 2*F));
        sum_L += 10980.0 * sin(rad(M_prime - 2*F));
        sum_L += 10675.0 * sin(rad(4*D - M_prime));
        sum_L += 10034.0 * sin(rad(3*M_prime));
        sum_L += 8548.0 * sin(rad(4*D - 2*M_prime));
        sum_L += -7888.0 * sin(rad(2*D + M - M_prime));
        sum_L += -6766.0 * sin(rad(2*D + M));
        sum_L += -5163.0 * sin(rad(D - M_prime));
        sum_L += 4987.0 * sin(rad(D + M));
        sum_L += 4036.0 * sin(rad(2*D - M + M_prime));
        sum_L += 3994.0 * sin(rad(2*D + 2*M_prime));
        sum_L += 3861.0 * sin(rad(4*D));
        sum_L += 3665.0 * sin(rad(2*D - 3*M_prime));
        sum_L += -2689.0 * sin(rad(M - 2*M_prime));
        sum_L += -2602.0 * sin(rad(2*D - M_prime + 2*F));
        sum_L += 2390.0 * sin(rad(2*D - M - 2*M_prime));
        sum_L += -2348.0 * sin(rad(D + M_prime));
        sum_L += 2236.0 * sin(rad(2*D - 2*M));
        sum_L += -2120.0 * sin(rad(M + 2*M_prime));
        sum_L += -2069.0 * sin(rad(2*M));
        sum_L += 2048.0 * sin(rad(2*D - 2*M - M_prime));
        sum_L += -1773.0 * sin(rad(2*D + M_prime - 2*F));
        sum_L += -1595.0 * sin(rad(2*D + 2*F));
        sum_L += 1215.0 * sin(rad(4*D - M - M_prime));
        sum_L += -1110.0 * sin(rad(2*M_prime + 2*F));
        sum_L += -892.0 * sin(rad(3*D - M_prime));
        sum_L += -810.0 * sin(rad(2*D + M + M_prime));
        sum_L += 759.0 * sin(rad(4*D - M - 2*M_prime));
        sum_L += -713.0 * sin(rad(2*M - M_prime));
        sum_L += -700.0 * sin(rad(2*D + 2*M - M_prime));
        sum_L += 691.0 * sin(rad(2*D + M - 2*M_prime));
        sum_L += 596.0 * sin(rad(2*D - M - 2*F));
        sum_L += 549.0 * sin(rad(4*D + M_prime));
        sum_L += 537.0 * sin(rad(4*M_prime));
        sum_L += 520.0 * sin(rad(4*D - M));
        sum_L += -487.0 * sin(rad(D - 2*M_prime));
        sum_L += -399.0 * sin(rad(2*D + M - 2*F));
        sum_L += -381.0 * sin(rad(2*M_prime - 2*F));
        sum_L += 351.0 * sin(rad(D + M + M_prime));
        sum_L += -340.0 * sin(rad(3*D - 2*M_prime));
        sum_L += 330.0 * sin(rad(4*D - 3*M_prime));
        sum_L += 327.0 * sin(rad(2*D - M + 2*M_prime));
        sum_L += -323.0 * sin(rad(2*M + M_prime));
        sum_L += 299.0 * sin(rad(D + M - M_prime));
        sum_L += 294.0 * sin(rad(2*D + 3*M_prime));
          
        // Apply light time delay for Moon
        double tau_light = 0.0057755183 * 0.00257; // ~0.00257 AU
        double T_delayed = (jd_tt - tau_light - 2451545.0) / 36525.0;
        
        double L_prime_delayed = 218.3164477 + 481267.88123421 * T_delayed;
        double moon_lon = L_prime_delayed + (sum_L / 1000000.0);
        
        *longitude = normalize_degrees(moon_lon + dpsi);
        *latitude = 0.0; // To do: add B terms
        *distance = 0.00257; // roughly 384,400 km in AU
        return;
    }
    
    if (planet_id == NITHYA_MERCURY || planet_id == NITHYA_VENUS || planet_id == NITHYA_MARS || 
        planet_id == NITHYA_JUPITER || planet_id == NITHYA_SATURN) {
        // Calculate requested planet heliocentric coordinates (geometric)
        double p_L, p_B, p_R;
        get_vsop87_heliocentric(planet_id, tau, &p_L, &p_B, &p_R);
        
        // Convert to Geocentric to get geometric distance
        helio_to_geo(earth_L, earth_B, earth_R, p_L, p_B, p_R, longitude, latitude, distance);
        
        // Apply Light Time
        double tau_light = 0.0057755183 * (*distance);
        double tau_planet = (jd_tt - tau_light - 2451545.0) / 365250.0;
        
        // Re-calculate planet heliocentric at t - tau_light
        get_vsop87_heliocentric(planet_id, tau_planet, &p_L, &p_B, &p_R);
        
        // Re-convert to Geocentric
        helio_to_geo(earth_L, earth_B, earth_R, p_L, p_B, p_R, longitude, latitude, distance);
        
        // Apply Nutation
        *longitude = normalize_degrees(*longitude + dpsi);
        return;
    }
    
    // For Rahu and Ketu
    if (planet_id == NITHYA_RAHU || planet_id == NITHYA_KETU || 
        planet_id == NITHYA_TRUE_RAHU || planet_id == NITHYA_TRUE_KETU) {
        double T = (jd_tt - 2451545.0) / 36525.0;
        // Mean Node of the Moon (Meeus)
        double omega = 125.04452 - 1934.136261 * T + 0.0020708 * T * T + (T * T * T / 450000.0);
        
        double node_lon = omega;
        
        if (planet_id == NITHYA_TRUE_RAHU || planet_id == NITHYA_TRUE_KETU) {
            double D = 297.8501921 + 445267.1114034 * T;
            double M = 357.5291092 + 35999.0502909 * T;
            double F = 93.2720950 + 483202.0175233 * T;
            
            // Approximation of True Node using primary periodic terms
            node_lon += -1.4979 * sin(rad(2.0*D - 2.0*F))
                        -0.1500 * sin(rad(M))
                        -0.1226 * sin(rad(2.0*D))
                        +0.1176 * sin(rad(2.0*D - M - 2.0*F))
                        -0.0801 * sin(rad(2.0*F));
        }
        
        if (planet_id == NITHYA_RAHU || planet_id == NITHYA_TRUE_RAHU) {
            *longitude = normalize_degrees(node_lon + dpsi);
        } else {
            *longitude = normalize_degrees(node_lon + 180.0 + dpsi);
        }
        *latitude = 0.0;
        *distance = 0.00257;
        return;
    }
}

// Chitra Paksha (Lahiri) Ayanamsa Calculation
NITHYA_API double nithya_calc_lahiri_ayanamsa(double jd) {
    double t = (jd - 2451545.0) / 36525.0; // Centuries from J2000
    // Simplified Chitra Paksha Ayanamsa formula
    double ayanamsa = 23.856472222222 + (1.396041666666 * t) + (0.000308333333 * t * t);
    return ayanamsa;
}

// Calculate Rise, Set, Transit
NITHYA_API void nithya_calc_phenomena(double jd, double lat, double lon, int planet_id, double* rise_jd, double* set_jd, double* transit_jd) {
    double h0 = -0.8333; // Default for Sun
    if (planet_id == NITHYA_MOON) {
        h0 = +0.125; // Default for Moon
    }
    
    // We calculate coordinates at 0 UT for the given day
    int year, month, day;
    // Just a basic approximation without iterative refinement for speed
    // Calculate RA and Dec at jd_mid (JD at noon UTC)
    double jd_mid = floor(jd - 0.5) + 0.5;
    
    double p_lon, p_lat, p_dist;
    nithya_calc_planet(jd_mid, planet_id, &p_lon, &p_lat, &p_dist);
    
    double T = (jd_mid - 2451545.0) / 36525.0;
    double epsilon = 23.43929111 - 0.013004167 * T;
    
    double eps_rad = rad(epsilon);
    double lon_rad = rad(p_lon);
    double lat_rad = rad(p_lat);
    
    // Ecliptic to Equatorial
    double y = sin(lon_rad) * cos(eps_rad) - tan(lat_rad) * sin(eps_rad);
    double x = cos(lon_rad);
    double ra = normalize_degrees(deg(atan2(y, x)));
    
    double sin_dec = sin(lat_rad) * cos(eps_rad) + cos(lat_rad) * sin(eps_rad) * sin(lon_rad);
    double dec = deg(asin(sin_dec));
    
    // Calculate Hour Angle H
    double dec_rad = rad(dec);
    double geo_lat_rad = rad(lat);
    double h0_rad = rad(h0);
    
    double cos_H = (sin(h0_rad) - sin(geo_lat_rad)*sin(dec_rad)) / (cos(geo_lat_rad)*cos(dec_rad));
    
    if (cos_H < -1.0) {
        // Circumpolar (Always above horizon)
        *rise_jd = 0.0; *set_jd = 0.0; *transit_jd = 0.0; return;
    } else if (cos_H > 1.0) {
        // Never rises
        *rise_jd = 0.0; *set_jd = 0.0; *transit_jd = 0.0; return;
    }
    
    double H = deg(acos(cos_H));
    
    // GMST at 0 UT
    double jd0 = floor(jd - 0.5) + 0.5;
    double T0 = (jd0 - 2451545.0) / 36525.0;
    double gmst0 = 280.46061837 + 360.98564736629 * (jd0 - 2451545.0) + 0.000387933 * T0 * T0;
    gmst0 = normalize_degrees(gmst0);
    
    double m_transit = (ra - lon - gmst0) / 360.0;
    m_transit = m_transit - floor(m_transit);
    
    double m_rise = m_transit - (H / 360.0);
    if (m_rise < 0) m_rise += 1.0;
    
    double m_set = m_transit + (H / 360.0);
    if (m_set > 1.0) m_set -= 1.0;
    
    *transit_jd = jd0 + m_transit;
    *rise_jd = jd0 + m_rise;
    *set_jd = jd0 + m_set;
}
