import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/jamakkol_one_page_pdf_service.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('JamakkolOnePagePdfService generates full PDF bytes', () async {
    SharedPreferences.setMockInitialValues({
      'shop_name': 'ஜிபி அஸ்ட்ரோ ஜோதிட வித்யாலயம்',
      'astrologer_name': 'Dr. கருணாகரன்',
      'address': 'சென்னை',
      'phone': '9800666225',
    });

    DateTime dt = DateTime(2026, 6, 15, 12, 0, 0);
    DateTime sunrise = DateTime(2026, 6, 15, 5, 55, 0);
    DateTime sunset = DateTime(2026, 6, 15, 18, 42, 0);

    final subPlanets = calculateAllJamakkolSubPlanets(
      currentTime: dt,
      sunrise: sunrise,
      sunset: sunset,
      nextSunrise: sunrise.add(const Duration(days: 1)),
      prevSunset: sunset.subtract(const Duration(days: 1)),
      sunLon: 60.03,
    );

    final mockResults = {
      'inner': {
        'panchangam': {
          'sunrise': '05:55 AM',
          'sunset': '06:42 PM',
          'vara': 'திங்கட்கிழமை',
          'tamil_year': 'சுபகிருது',
          'tamil_month': 'ஆனி',
          'tamil_date': '01',
        },
        'planet_details': {
          'lagna': {'longitude': 145.2, 'rasi': 'Leo'},
          'sun': {'longitude': 60.03, 'rasi': 'Gemini'},
          'moon': {'longitude': 82.5, 'nakshatra': 'புனர்பூசம்', 'pada': 1, 'rasi': 'Gemini'},
          'mars': {'longitude': 210.0, 'rasi': 'Scorpio'},
          'mercury': {'longitude': 75.0, 'rasi': 'Gemini'},
          'jupiter': {'longitude': 40.0, 'rasi': 'Taurus'},
          'venus': {'longitude': 95.0, 'rasi': 'Cancer'},
          'saturn': {'longitude': 330.0, 'rasi': 'Pisces'},
          'rahu': {'longitude': 15.0, 'rasi': 'Aries'},
          'ketu': {'longitude': 195.0, 'rasi': 'Libra'},
          'maanthi': {'longitude': 120.0, 'rasi': 'Cancer'},
        },
      },
      'outer': {
        'udayam_abs_deg': 145.2,
        'arudam_abs_deg': 72.0,
        'current_jamam_planet': 'Mars',
        'planet_degrees': {
          'Sun': 60.0,
          'Mars': 105.0,
          'Jupiter': 150.0,
          'Mercury': 195.0,
          'Venus': 240.0,
          'Saturn': 285.0,
          'Moon': 330.0,
          'Rahu': 15.0,
        },
      },
      'udayam_idx': 4,
      'arudam_idx': 2,
      'kavi_idx': 8,
      'sub_planets': subPlanets,
      'strength': {
        'rasi_kathir_map': {
          'Aries': '7', 'Taurus': '8', 'Gemini': '14', 'Cancer': '19',
          'Leo': '7', 'Virgo': '11', 'Libra': '2', 'Scorpio': '11',
          'Sagittarius': '6', 'Capricorn': '8', 'Aquarius': '8', 'Pisces': '31'
        },
        'udayam': {'totalDisplay': '7', 'total': 7},
        'arudam': {'totalDisplay': '14', 'total': 14},
        'kavi': {'totalDisplay': '6', 'total': 6},
        'jamam': {'totalDisplay': '7', 'total': 7},
        'bhavas': [],
      },
      'notes': {
        'udayam_contact': [
          {'planet': 'Venus', 'deg': 28.13, 'house': '1', 'lordship': '1/6'}
        ],
        'udayam_star': {
          'deg': 13.51, 'nakshatra': 'Rohini', 'pada': 2, 'lord': 'Moon', 'lordship': '3'
        },
        'crossed_planet': {
          'planet': 'Saturn', 'lordship': '9/10', 'deg': 13.13
        },
        'udayam_lord_house': '1',
        'arudam_contact': {
          'planet': 'Venus', 'deg': 28.13, 'nakshatra': 'Mrigashirsha', 'pada': 2
        },
        'arudam_house_details': {
          'house': '12', 'lord': 'Mars', 'lordship': '7/12', 'deg': 22.3, 'nakshatra': 'Bharani', 'pada': 3
        },
        'arudam_lord_house': '6',
        'kavi_house_details': {
          'house': '2', 'deg': 7.68, 'nakshatra': 'Arudra', 'pada': 1
        },
        'kavi_planet_details': {
          'planet': 'Venus', 'lordship': '1/6', 'deg': 28.13, 'nakshatra': 'Mrigashirsha', 'pada': 2
        },
        'udayam_vs_arudam': '12',
        'udayam_vs_kavi': '2',
        'arudam_vs_udayam': '2',
        'arudam_vs_kavi': '3',
        'sootchuma_details': {'rasi': 'Taurus'},
        'ucham_planets': ['Saturn'],
        'neecham_planets': ['Jupiter'],
        'parivarthana_details': [
          {'sign1': 'Aries', 'sign2': 'Taurus', 'planet1': 'Mars', 'planet2': 'Venus'}
        ],
        'badhaka_lord_details': {'lord': 'Saturn', 'house': '12'},
        'eighth_lord_details': {'lord': 'Mars', 'house': '4'},
      },
    };

    final l10nTa = await AppLocalizations.delegate.load(const Locale('ta'));

    final Uint8List bytesTa = await JamakkolOnePagePdfService.generate(
      name: "ராஜேஷ்",
      gender: "ஆண்",
      results: mockResults,
      inputTime: dt,
      place: "சென்னை",
      lat: 13.0827,
      lon: 80.2707,
      l10n: l10nTa,
    );

    expect(bytesTa, isNotNull);
    expect(bytesTa.length, greaterThan(1000));

    // Test with English input (Wednesday, Krittika) under Tamil locale
    final innerMap = mockResults['inner'] as Map<String, dynamic>;
    (innerMap['panchangam'] as Map<String, dynamic>)['vara'] = 'Wednesday';
    (innerMap['planet_details'] as Map<String, dynamic>)['moon'] = {'longitude': 40.0, 'nakshatra': 'Krittika', 'pada': 4, 'rasi': 'Taurus'};
    mockResults['notes'] = {
      'udayam_lord_house': '1',
      'arudam_lord_house': '2',
      'badhaka_lord_details': {'lord': 'Saturn', 'house': '12'},
      'eighth_lord_details': {'lord': 'Mars', 'house': '4'},
    };

    final Uint8List bytesConvertedTa = await JamakkolOnePagePdfService.generate(
      name: "ராஜேஷ்",
      gender: "ஆண்",
      results: mockResults,
      inputTime: dt,
      place: "சென்னை",
      lat: 13.0827,
      lon: 80.2707,
      l10n: l10nTa,
    );
    expect(bytesConvertedTa, isNotNull);

    // Test with English locale
    final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
    final Uint8List bytesEn = await JamakkolOnePagePdfService.generate(
      name: "Rajesh",
      gender: "Male",
      results: mockResults,
      inputTime: dt,
      place: "Chennai",
      lat: 13.0827,
      lon: 80.2707,
      l10n: l10nEn,
    );
    expect(bytesEn, isNotNull);
  });
}
