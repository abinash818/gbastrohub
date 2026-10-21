import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/temple_worship_service.dart';

void main() {
  group('TempleWorshipService Tests', () {
    test('Verify Master Directory counts and data integrity', () {
      // 27 Yogas
      expect(TempleWorshipService.YOGA_TEMPLES.length, equals(27));
      expect(TempleWorshipService.YOGA_TEMPLES['விஷ்கம்பம்']?['yogi'], contains('தென்குடி திட்டை'));
      expect(TempleWorshipService.YOGA_TEMPLES['விஷ்கம்பம்']?['avayogi'], contains('சேரன்மாதேவி'));

      // 15 Shukla + 15 Krishna = 30 Thithis
      expect(TempleWorshipService.SHUKLA_THITHI_TEMPLES.length, equals(15));
      expect(TempleWorshipService.KRISHNA_THITHI_TEMPLES.length, equals(15));
      expect(TempleWorshipService.SHUKLA_THITHI_TEMPLES['பிரதமை']?['deity'], equals('துர்க்கை'));
      expect(TempleWorshipService.SHUKLA_THITHI_TEMPLES['பிரதமை']?['temple'], contains('பட்டீஸ்வரம்'));
      expect(TempleWorshipService.KRISHNA_THITHI_TEMPLES['அமாவாசை']?['deity'], equals('சதாசிவன்'));
      expect(TempleWorshipService.KRISHNA_THITHI_TEMPLES['அமாவாசை']?['temple'], contains('இராமேஸ்வரம்'));

      // 11 Karanas
      expect(TempleWorshipService.PRIMARY_KARANAS.length, equals(11));
      expect(TempleWorshipService.KARANA_TEMPLES['பவம்']?['lord'], equals('செவ்வாய்'));
      expect(TempleWorshipService.KARANA_TEMPLES['பவம்']?['animal'], equals('சிங்கம்'));
      expect(TempleWorshipService.KARANA_TEMPLES['பவம்']?['deity'], equals('நரசிம்மர்'));
      expect(TempleWorshipService.KARANA_TEMPLES['பவம்']?['temple'], contains('நாமக்கல்'));

      // 27 Vainasika Temples
      expect(TempleWorshipService.VAINASIKA_TEMPLES['அஸ்வினி'], contains('வெஞ்சமாங்கூடலூர்'));
      expect(TempleWorshipService.VAINASIKA_TEMPLES['ரேவதி'], contains('ஸ்ரீரங்கம்'));

      // Mudakku Bhava Temples
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('1-ஆம் பாவம் (லக்னமே முடக்கு)'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('2-ஆம் பாவம்'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('3-ஆம் பாவம்'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('4-ஆம் பாவம்'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('5-ஆம் பாவம்'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('6-ஆம் பாவம்'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('7-ஆம் பாவம்'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('8-ஆம் பாவம்'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('9-ஆம் பாவம்'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('10-ஆம் பாவம்'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('11-ஆம் பாவம்'), isTrue);
      expect(TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.containsKey('12-ஆம் பாவம்'), isTrue);
    });

    test('calculateNativeWorshipPlan correctly maps chart data', () {
      final mockResults = {
        'panchangam': {
          'star': 'ரோகிணி 2-ஆம் பாதம்',
          'thithi': 'சுக்ல பட்சம் பஞ்சமி',
          'karana': 'பாலவம்',
          'yoga': 'சோபனம்',
        },
        'yogi_avayogi': {
          'yoga_name_tamil': 'சோபனம்',
          'yogi_planet_tamil': 'சூரியன்',
          'avayogi_planet_tamil': 'சனி',
          'mudakku': {
            'rasi_tamil': 'கடகம்',
            'rasi_idx': 3,
            'lord_tamil': 'சந்திரன்',
          },
        },
        'vainasika_pada': {
          'vainasika_nakshatra': 'சுவாதி',
          'vainasika_pada': 3,
        },
        'planet_details': {
          'lagna': {
            'longitude': 15.0, // Mesham (rasi_idx = 0) -> Kadagam is 4th house
          },
        },
      };

      final plan = TempleWorshipService.calculateNativeWorshipPlan(mockResults);

      expect(plan['birth_star'], equals('ரோகிணி'));
      expect(plan['birth_star_temple'], contains('காஞ்சிபுரம் பாண்டவதூதப் பெருமாள்'));

      expect(plan['yoga_name'], equals('சோபனம்'));
      expect(plan['yogi_planet'], equals('சூரியன்'));
      expect(plan['yogi_temple'], contains('சூரியனார் கோவில்'));
      expect(plan['avayogi_planet'], equals('சனி'));
      expect(plan['avayogi_temple'], contains('குச்சனூர் சனி'));

      expect(plan['thithi_name'], equals('பஞ்சமி'));
      expect(plan['is_shukla'], isTrue);
      expect(plan['thithi_deity'], equals('தேவேந்திரன்'));
      expect(plan['thithi_temple'], contains('பெண்ணாடம் பிரளயகாளேஸ்வரர்'));

      expect(plan['karana_name'], equals('பாலவம்'));
      expect(plan['karana_lord'], equals('ராகு'));
      expect(plan['karana_animal'], equals('புலி'));
      expect(plan['karana_deity'], equals('ஐயப்பன்'));
      expect(plan['karana_temple'], contains('சபரிமலை'));

      expect(plan['vainasika_nak'], equals('சுவாதி'));
      expect(plan['vainasika_pada'], equals(3));
      expect(plan['vainasika_temple'], contains('மதுரை மேலூர் லக்ஷ்மி நரசிம்மர்'));

      expect(plan['mudakku_rasi'], equals('கடகம்'));
      expect(plan['mudakku_bhava'], equals(4)); // 3 - 0 + 1 = 4
      expect(plan['mudakku_temple'], contains('பவானி சங்கமேஸ்வரர்'));
    });

    test('Lagna mudakku assigns Madurai temple', () {
      final mockResults = {
        'panchangam': {
          'star': 'அஸ்வினி',
          'thithi': 'அமாவாசை',
          'karana': 'சகுனி',
        },
        'yogi_avayogi': {
          'yoga_name_tamil': 'விஷ்கம்பம்',
          'yogi_planet_tamil': 'குரு',
          'avayogi_planet_tamil': 'செவ்வாய்',
          'mudakku': {
            'rasi_tamil': 'மேஷம்',
            'rasi_idx': 0,
          },
        },
        'vainasika_pada': {
          'vainasika_nakshatra': 'அஸ்வினி',
          'vainasika_pada': 1,
        },
        'planet_details': {
          'lagna': {
            'longitude': 10.0, // Mesham (rasi_idx = 0) -> Bhava 1
          },
        },
      };

      final plan = TempleWorshipService.calculateNativeWorshipPlan(mockResults);
      expect(plan['mudakku_bhava'], equals(1));
      expect(plan['mudakku_temple'], contains('இன்மையில் நன்மை தருவார் கோவில், மதுரை'));
    });

    test('English input names (Atiganda, Rohini, etc.) are converted to Tamil and mapped to correct temples', () {
      final mockResults = {
        'panchangam': {
          'yoga': 'Atiganda',
          'tithi': 'Panchami',
          'karana': 'Bava',
        },
        'planet_details': {
          'moon': {
            'nakshatra': 'Rohini',
          },
          'lagna': {
            'longitude': 10.0,
          },
        },
        'yogi_avayogi': {
          'yogi': {
            'planet': 'Mercury',
            'planet_tamil': 'புதன்',
          },
          'avayogi': {
            'planet': 'Saturn',
            'planet_tamil': 'சனி',
          },
          'mudakku': {
            'rasi': 'Leo',
            'rasi_tamil': 'சிம்மம்',
            'rasi_idx': 4,
          },
        },
        'vainasika_pada': {
          'vainasika_nakshatra': 'Chitra',
          'vainasika_pada': 2,
        },
      };

      final plan = TempleWorshipService.calculateNativeWorshipPlan(mockResults);
      expect(plan['birth_star'], equals('ரோகிணி'));
      expect(plan['yoga_name'], equals('அதிகண்டம்'));
      expect(plan['yogi_planet'], equals('புதன்'));
      expect(plan['yogi_temple'], contains('கும்பகோணம் உப்பிலியப்பன்'));
      expect(plan['avayogi_planet'], equals('சனி'));
      expect(plan['avayogi_temple'], contains('அரியலூர் கலியபெருமாள்'));
      expect(plan['vainasika_nak'], equals('சித்திரை'));
      expect(plan['vainasika_temple'], contains('தெத்துப்பட்டி ராஜகாளியம்மன்'));
    });

    test('Verify all user specific corrections and mudakku bhavas 7 to 12', () {
      // 1. Preethi
      expect(TempleWorshipService.YOGA_TEMPLES['ப்ரீதி']?['avayogi'], equals('குணசீலம் பிரசன்ன வெங்கடாஜலபதி'));
      expect(TempleWorshipService.YOGA_TEMPLES['ப்ரீதி']?['avayogi'], isNot(contains('மனஉளைச்சல்')));

      // 2. Adhigandam
      expect(TempleWorshipService.YOGA_TEMPLES['அதிகண்டம்']?['yogi'], contains('கும்பகோணம் உப்பிலியப்பன்'));

      // 3. Dhriti
      expect(TempleWorshipService.YOGA_TEMPLES['திருதி']?['avayogi'], equals('கஞ்சனூர் சிவன், சுக்கிரன் ஆலயம்'));

      // 4. Harshanam
      expect(TempleWorshipService.YOGA_TEMPLES['ஹர்ஷணம்']?['yogi'], equals('சாயாவனம் சிவன் பூம்புகார்'));
      expect(TempleWorshipService.YOGA_TEMPLES['ஹர்ஷணம்']?['yogi'], isNot(contains('பக்கம்')));

      // 5. Vajram
      expect(TempleWorshipService.YOGA_TEMPLES['வஜ்ரம்']?['yogi'], equals('திருச்செந்தூர் அருகில் ஆத்தூர் சோம நாதேஸ்வர்'));
      expect(TempleWorshipService.YOGA_TEMPLES['வஜ்ரம்']?['avayogi'], equals('கபிஸ்தலம் வரதராஜ பெருமாள்'));

      // 6. Vyathipatham
      expect(TempleWorshipService.YOGA_TEMPLES['வியதிபாதம்']?['avayogi'], equals('கும்பகோணம் மணக்காடு அய்யம்பேட்டை பெருமாள்'));

      // 7. Variyan
      expect(TempleWorshipService.YOGA_TEMPLES['வரியான்']?['yogi'], equals('செங்கோட்டை புளியாரை தட்சிணாமூர்த்தி'));
      expect(TempleWorshipService.YOGA_TEMPLES['வரியான்']?['avayogi'], equals('சென்னை புழல் பகுதி தாமரை ஈஸ்வர்'));

      // 8. Bramiyam
      expect(TempleWorshipService.YOGA_TEMPLES['பிராமியம்']?['avayogi'], equals('திருவந்திபுரம் கடலூர் ஜகத்ராட்சகபெருமாள் (ஹயகிரிவர் கோவில்)'));

      // 9. Mahendram
      expect(TempleWorshipService.YOGA_TEMPLES['மஹேந்திரம்']?['avayogi'], equals('திருப்புவனை தோத்தாத்ரி நாதப்பெருமாள் விழுப்புரம்'));

      // 10. Mudakku Bhavas 7 to 12
      // Bhava 7
      expect(TempleWorshipService.getMudakkuTemple(7, 'மேஷம்'), contains('திருப்பரங்குன்றம் முருகன்'));
      expect(TempleWorshipService.getMudakkuTemple(7, 'ரிஷபம்'), contains('மணமுடித்தநல்லூர்'));
      expect(TempleWorshipService.getMudakkuTemple(7, 'மிதுனம்'), contains('திருநகரி கல்யாண ரங்கநாத பெருமாள்'));
      expect(TempleWorshipService.getMudakkuTemple(7, 'கடகம்'), contains('திருமணஞ்சேரி'));
      expect(TempleWorshipService.getMudakkuTemple(7, 'சிம்மம்'), contains('திருவேள்விக்குடி'));
      expect(TempleWorshipService.getMudakkuTemple(7, 'தனுசு'), contains('திருமுருகன்பூண்டி முருகநாதர் திருப்பூர்'));
      expect(TempleWorshipService.getMudakkuTemple(7, 'மகரம்'), contains('வேதாரண்யம் வேதாரண்யேஸ்வரன்'));

      // Bhava 8
      expect(TempleWorshipService.getMudakkuTemple(8, 'மேஷம்'), contains('திருக்கடையூர் அபிராமி'));
      expect(TempleWorshipService.getMudakkuTemple(8, 'ரிஷபம்'), contains('நல்லாத்தூர் சொர்ணபுரீஸ்வரர்'));
      expect(TempleWorshipService.getMudakkuTemple(8, 'மிதுனம்'), contains('மேலக்கடம்பூர் அமிர்தகடேஸ்வரர்'));
      expect(TempleWorshipService.getMudakkuTemple(8, 'கடகம்'), contains('திங்களூர் கைலாசநாதர்'));
      expect(TempleWorshipService.getMudakkuTemple(8, 'சிம்மம்'), contains('பருத்தியப்பர், மேலஉளூர்'));
      expect(TempleWorshipService.getMudakkuTemple(8, 'தனுசு'), contains('ஸ்ரீவாஞ்சியம் எமதர்மன்'));
      expect(TempleWorshipService.getMudakkuTemple(8, 'மகரம்'), contains('எமனேஸ்வரம், பரமக்குடி'));

      // Bhava 9
      expect(TempleWorshipService.getMudakkuTemple(9, 'மேஷம்'), contains('விராலிமலை முருகன்'));
      expect(TempleWorshipService.getMudakkuTemple(9, 'ரிஷபம்'), contains('திருமயம் கோட்டை உள்ள சிவன்'));
      expect(TempleWorshipService.getMudakkuTemple(9, 'மிதுனம்'), contains('அச்சரப்பாக்கம் ஆட்சீஸ்வரர்'));
      expect(TempleWorshipService.getMudakkuTemple(9, 'கடகம்'), contains('தரங்கம்பாடி மாசிலாமணீஸ்வரர், திருக்கடையூர்'));
      expect(TempleWorshipService.getMudakkuTemple(9, 'சிம்மம்'), contains('பெருநகர் பிரம்மபுரீஸ்வரர்'));
      expect(TempleWorshipService.getMudakkuTemple(9, 'தனுசு'), contains('தாயுமானவர் சுவாமி, திருச்சி'));
      expect(TempleWorshipService.getMudakkuTemple(9, 'மகரம்'), contains('தாண்டிக்குடி பாலமுருகன்'));
      expect(TempleWorshipService.getMudakkuTemple(9, 'மகரம்'), isNot(contains('பூண்டி')));

      // Bhava 10
      expect(TempleWorshipService.getMudakkuTemple(10, 'மேஷம்'), contains('பழனி முருகன் ராஜ அலங்காரம் வழிபாடு'));
      expect(TempleWorshipService.getMudakkuTemple(10, 'விருச்சிகம்'), contains('பழனி முருகன் ராஜ அலங்காரம் வழிபாடு'));
      expect(TempleWorshipService.getMudakkuTemple(10, 'ரிஷபம்'), contains('மதுரை மீனாட்சி'));
      expect(TempleWorshipService.getMudakkuTemple(10, 'மிதுனம்'), contains('ஸ்ரீரங்கம் கருடாழ்வார்'));
      expect(TempleWorshipService.getMudakkuTemple(10, 'கடகம்'), contains('திருச்சுழி சிவன் திருமேனிநாதர்'));
      expect(TempleWorshipService.getMudakkuTemple(10, 'சிம்மம்'), contains('விருத்தபுரீஸ்வரர் திருப்புனவாசல்'));
      expect(TempleWorshipService.getMudakkuTemple(10, 'தனுசு'), contains('அருப்புக்கோட்டை பழைய சிவன் கோவில்'));
      expect(TempleWorshipService.getMudakkuTemple(10, 'மகரம்'), contains('திருமால்பூர் மணிகண்டீஸ்வரர்'));

      // Bhava 11
      expect(TempleWorshipService.getMudakkuTemple(11, 'மேஷம்'), contains('வீரக்குடி கரைமேல் அழகர் முருகன்'));
      expect(TempleWorshipService.getMudakkuTemple(11, 'ரிஷபம்'), contains('காவளம்பாடி கோபாலகிருஷ்ணன்'));
      expect(TempleWorshipService.getMudakkuTemple(11, 'மிதுனம்'), contains('திருவெள்ளறை பெருமாள்'));
      expect(TempleWorshipService.getMudakkuTemple(11, 'கடகம்'), contains('திருநெடுங்களநாதர்'));
      expect(TempleWorshipService.getMudakkuTemple(11, 'சிம்மம்'), contains('பிரான்மலை முருகன்'));
      expect(TempleWorshipService.getMudakkuTemple(11, 'தனுசு'), contains('பட்டீஸ்வரர் (பேரூர், கோவை)'));
      expect(TempleWorshipService.getMudakkuTemple(11, 'மகரம்'), contains('ஆதிரத்தினேஸ்வரர்'));

      // Bhava 12
      expect(TempleWorshipService.getMudakkuTemple(12, 'மேஷம்'), contains('மயிலம் சுப்பிரமணியசுவாமி'));
      expect(TempleWorshipService.getMudakkuTemple(12, 'ரிஷபம்'), contains('திருவேற்காடு வேதபுரீஸ்வரர்'));
      expect(TempleWorshipService.getMudakkuTemple(12, 'மிதுனம்'), contains('புருஷோத்தமன் உத்தமர்கோவில் திருச்சி'));
      expect(TempleWorshipService.getMudakkuTemple(12, 'கடகம்'), contains('திருப்பட்டூர் பிரம்மாகோவில்'));
      expect(TempleWorshipService.getMudakkuTemple(12, 'சிம்மம்'), contains('நரசிம்மர் யானைமலை ஒத்தக்கடை மதுரை'));
      expect(TempleWorshipService.getMudakkuTemple(12, 'தனுசு'), contains('கோடியக்கரை அமுதகடேஸ்வரர்'));
      expect(TempleWorshipService.getMudakkuTemple(12, 'மகரம்'), contains('திருப்புல்லாணி பெருமாள்'));
    });
  });
}

