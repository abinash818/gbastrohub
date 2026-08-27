// Auto-generated VSOP87 calculation function
#ifndef VSOP87_CALC_H
#define VSOP87_CALC_H
#include "nithya.h"
#include "vsop87_mercury.h"
#include "vsop87_venus.h"
#include "vsop87_earth.h"
#include "vsop87_mars.h"
#include "vsop87_jupiter.h"
#include "vsop87_saturn.h"

static void get_vsop87_heliocentric(int planet, double tau, double* L, double* B, double* R) {
    *L = 0; *B = 0; *R = 0;
    switch(planet) {
        case NITHYA_MERCURY:
            *L = 0.0 + sum_vsop_series(mercury_var1_t0, mercury_var1_t0_count, tau) + sum_vsop_series(mercury_var1_t1, mercury_var1_t1_count, tau)*tau + sum_vsop_series(mercury_var1_t2, mercury_var1_t2_count, tau)*pow(tau, 2) + sum_vsop_series(mercury_var1_t3, mercury_var1_t3_count, tau)*pow(tau, 3) + sum_vsop_series(mercury_var1_t4, mercury_var1_t4_count, tau)*pow(tau, 4) + sum_vsop_series(mercury_var1_t5, mercury_var1_t5_count, tau)*pow(tau, 5);
            *B = 0.0 + sum_vsop_series(mercury_var2_t0, mercury_var2_t0_count, tau) + sum_vsop_series(mercury_var2_t1, mercury_var2_t1_count, tau)*tau + sum_vsop_series(mercury_var2_t2, mercury_var2_t2_count, tau)*pow(tau, 2) + sum_vsop_series(mercury_var2_t3, mercury_var2_t3_count, tau)*pow(tau, 3) + sum_vsop_series(mercury_var2_t4, mercury_var2_t4_count, tau)*pow(tau, 4) + sum_vsop_series(mercury_var2_t5, mercury_var2_t5_count, tau)*pow(tau, 5);
            *R = 0.0 + sum_vsop_series(mercury_var3_t0, mercury_var3_t0_count, tau) + sum_vsop_series(mercury_var3_t1, mercury_var3_t1_count, tau)*tau + sum_vsop_series(mercury_var3_t2, mercury_var3_t2_count, tau)*pow(tau, 2) + sum_vsop_series(mercury_var3_t3, mercury_var3_t3_count, tau)*pow(tau, 3) + sum_vsop_series(mercury_var3_t4, mercury_var3_t4_count, tau)*pow(tau, 4) + sum_vsop_series(mercury_var3_t5, mercury_var3_t5_count, tau)*pow(tau, 5);
            break;
        case NITHYA_VENUS:
            *L = 0.0 + sum_vsop_series(venus_var1_t0, venus_var1_t0_count, tau) + sum_vsop_series(venus_var1_t1, venus_var1_t1_count, tau)*tau + sum_vsop_series(venus_var1_t2, venus_var1_t2_count, tau)*pow(tau, 2) + sum_vsop_series(venus_var1_t3, venus_var1_t3_count, tau)*pow(tau, 3) + sum_vsop_series(venus_var1_t4, venus_var1_t4_count, tau)*pow(tau, 4) + sum_vsop_series(venus_var1_t5, venus_var1_t5_count, tau)*pow(tau, 5);
            *B = 0.0 + sum_vsop_series(venus_var2_t0, venus_var2_t0_count, tau) + sum_vsop_series(venus_var2_t1, venus_var2_t1_count, tau)*tau + sum_vsop_series(venus_var2_t2, venus_var2_t2_count, tau)*pow(tau, 2) + sum_vsop_series(venus_var2_t3, venus_var2_t3_count, tau)*pow(tau, 3) + sum_vsop_series(venus_var2_t4, venus_var2_t4_count, tau)*pow(tau, 4) + sum_vsop_series(venus_var2_t5, venus_var2_t5_count, tau)*pow(tau, 5);
            *R = 0.0 + sum_vsop_series(venus_var3_t0, venus_var3_t0_count, tau) + sum_vsop_series(venus_var3_t1, venus_var3_t1_count, tau)*tau + sum_vsop_series(venus_var3_t2, venus_var3_t2_count, tau)*pow(tau, 2) + sum_vsop_series(venus_var3_t3, venus_var3_t3_count, tau)*pow(tau, 3) + sum_vsop_series(venus_var3_t4, venus_var3_t4_count, tau)*pow(tau, 4) + sum_vsop_series(venus_var3_t5, venus_var3_t5_count, tau)*pow(tau, 5);
            break;
        case NITHYA_SUN:
            *L = 0.0 + sum_vsop_series(earth_var1_t0, earth_var1_t0_count, tau) + sum_vsop_series(earth_var1_t1, earth_var1_t1_count, tau)*tau + sum_vsop_series(earth_var1_t2, earth_var1_t2_count, tau)*pow(tau, 2) + sum_vsop_series(earth_var1_t3, earth_var1_t3_count, tau)*pow(tau, 3) + sum_vsop_series(earth_var1_t4, earth_var1_t4_count, tau)*pow(tau, 4) + sum_vsop_series(earth_var1_t5, earth_var1_t5_count, tau)*pow(tau, 5);
            *B = 0.0 + sum_vsop_series(earth_var2_t0, earth_var2_t0_count, tau) + sum_vsop_series(earth_var2_t1, earth_var2_t1_count, tau)*tau + sum_vsop_series(earth_var2_t2, earth_var2_t2_count, tau)*pow(tau, 2) + sum_vsop_series(earth_var2_t3, earth_var2_t3_count, tau)*pow(tau, 3) + sum_vsop_series(earth_var2_t4, earth_var2_t4_count, tau)*pow(tau, 4);
            *R = 0.0 + sum_vsop_series(earth_var3_t0, earth_var3_t0_count, tau) + sum_vsop_series(earth_var3_t1, earth_var3_t1_count, tau)*tau + sum_vsop_series(earth_var3_t2, earth_var3_t2_count, tau)*pow(tau, 2) + sum_vsop_series(earth_var3_t3, earth_var3_t3_count, tau)*pow(tau, 3) + sum_vsop_series(earth_var3_t4, earth_var3_t4_count, tau)*pow(tau, 4) + sum_vsop_series(earth_var3_t5, earth_var3_t5_count, tau)*pow(tau, 5);
            break;
        case NITHYA_MARS:
            *L = 0.0 + sum_vsop_series(mars_var1_t0, mars_var1_t0_count, tau) + sum_vsop_series(mars_var1_t1, mars_var1_t1_count, tau)*tau + sum_vsop_series(mars_var1_t2, mars_var1_t2_count, tau)*pow(tau, 2) + sum_vsop_series(mars_var1_t3, mars_var1_t3_count, tau)*pow(tau, 3) + sum_vsop_series(mars_var1_t4, mars_var1_t4_count, tau)*pow(tau, 4) + sum_vsop_series(mars_var1_t5, mars_var1_t5_count, tau)*pow(tau, 5);
            *B = 0.0 + sum_vsop_series(mars_var2_t0, mars_var2_t0_count, tau) + sum_vsop_series(mars_var2_t1, mars_var2_t1_count, tau)*tau + sum_vsop_series(mars_var2_t2, mars_var2_t2_count, tau)*pow(tau, 2) + sum_vsop_series(mars_var2_t3, mars_var2_t3_count, tau)*pow(tau, 3) + sum_vsop_series(mars_var2_t4, mars_var2_t4_count, tau)*pow(tau, 4) + sum_vsop_series(mars_var2_t5, mars_var2_t5_count, tau)*pow(tau, 5);
            *R = 0.0 + sum_vsop_series(mars_var3_t0, mars_var3_t0_count, tau) + sum_vsop_series(mars_var3_t1, mars_var3_t1_count, tau)*tau + sum_vsop_series(mars_var3_t2, mars_var3_t2_count, tau)*pow(tau, 2) + sum_vsop_series(mars_var3_t3, mars_var3_t3_count, tau)*pow(tau, 3) + sum_vsop_series(mars_var3_t4, mars_var3_t4_count, tau)*pow(tau, 4) + sum_vsop_series(mars_var3_t5, mars_var3_t5_count, tau)*pow(tau, 5);
            break;
        case NITHYA_JUPITER:
            *L = 0.0 + sum_vsop_series(jupiter_var1_t0, jupiter_var1_t0_count, tau) + sum_vsop_series(jupiter_var1_t1, jupiter_var1_t1_count, tau)*tau + sum_vsop_series(jupiter_var1_t2, jupiter_var1_t2_count, tau)*pow(tau, 2) + sum_vsop_series(jupiter_var1_t3, jupiter_var1_t3_count, tau)*pow(tau, 3) + sum_vsop_series(jupiter_var1_t4, jupiter_var1_t4_count, tau)*pow(tau, 4) + sum_vsop_series(jupiter_var1_t5, jupiter_var1_t5_count, tau)*pow(tau, 5);
            *B = 0.0 + sum_vsop_series(jupiter_var2_t0, jupiter_var2_t0_count, tau) + sum_vsop_series(jupiter_var2_t1, jupiter_var2_t1_count, tau)*tau + sum_vsop_series(jupiter_var2_t2, jupiter_var2_t2_count, tau)*pow(tau, 2) + sum_vsop_series(jupiter_var2_t3, jupiter_var2_t3_count, tau)*pow(tau, 3) + sum_vsop_series(jupiter_var2_t4, jupiter_var2_t4_count, tau)*pow(tau, 4) + sum_vsop_series(jupiter_var2_t5, jupiter_var2_t5_count, tau)*pow(tau, 5);
            *R = 0.0 + sum_vsop_series(jupiter_var3_t0, jupiter_var3_t0_count, tau) + sum_vsop_series(jupiter_var3_t1, jupiter_var3_t1_count, tau)*tau + sum_vsop_series(jupiter_var3_t2, jupiter_var3_t2_count, tau)*pow(tau, 2) + sum_vsop_series(jupiter_var3_t3, jupiter_var3_t3_count, tau)*pow(tau, 3) + sum_vsop_series(jupiter_var3_t4, jupiter_var3_t4_count, tau)*pow(tau, 4) + sum_vsop_series(jupiter_var3_t5, jupiter_var3_t5_count, tau)*pow(tau, 5);
            break;
        case NITHYA_SATURN:
            *L = 0.0 + sum_vsop_series(saturn_var1_t0, saturn_var1_t0_count, tau) + sum_vsop_series(saturn_var1_t1, saturn_var1_t1_count, tau)*tau + sum_vsop_series(saturn_var1_t2, saturn_var1_t2_count, tau)*pow(tau, 2) + sum_vsop_series(saturn_var1_t3, saturn_var1_t3_count, tau)*pow(tau, 3) + sum_vsop_series(saturn_var1_t4, saturn_var1_t4_count, tau)*pow(tau, 4) + sum_vsop_series(saturn_var1_t5, saturn_var1_t5_count, tau)*pow(tau, 5);
            *B = 0.0 + sum_vsop_series(saturn_var2_t0, saturn_var2_t0_count, tau) + sum_vsop_series(saturn_var2_t1, saturn_var2_t1_count, tau)*tau + sum_vsop_series(saturn_var2_t2, saturn_var2_t2_count, tau)*pow(tau, 2) + sum_vsop_series(saturn_var2_t3, saturn_var2_t3_count, tau)*pow(tau, 3) + sum_vsop_series(saturn_var2_t4, saturn_var2_t4_count, tau)*pow(tau, 4) + sum_vsop_series(saturn_var2_t5, saturn_var2_t5_count, tau)*pow(tau, 5);
            *R = 0.0 + sum_vsop_series(saturn_var3_t0, saturn_var3_t0_count, tau) + sum_vsop_series(saturn_var3_t1, saturn_var3_t1_count, tau)*tau + sum_vsop_series(saturn_var3_t2, saturn_var3_t2_count, tau)*pow(tau, 2) + sum_vsop_series(saturn_var3_t3, saturn_var3_t3_count, tau)*pow(tau, 3) + sum_vsop_series(saturn_var3_t4, saturn_var3_t4_count, tau)*pow(tau, 4) + sum_vsop_series(saturn_var3_t5, saturn_var3_t5_count, tau)*pow(tau, 5);
            break;
    }
}
#endif // VSOP87_CALC_H
