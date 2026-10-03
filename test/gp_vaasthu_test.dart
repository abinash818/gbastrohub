import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/gp_vaasthu_service.dart';

void main() {
  group('GP Vaasthu Calculations with Ayadi = 1763', () {
    const int ayadi = 1763;

    test('1. Garbham test', () {
      final g = GpVaasthuService.getGarbhamByAyadi(ayadi);
      expect(g.number, 3); // 1763 % 8 = 3 (சிம்மம்)
      expect(g.name.contains('சிம்மம்'), true);
    });

    test('2. Yoni test', () {
      final y = GpVaasthuService.getYoniByAyadi(ayadi);
      // 1763 * 3 = 5289; 5289 % 8 = 1 (கருட)
      expect(y.number, 1);
      expect(y.name.contains('கருட'), true);
    });

    test('3. Aadhayam test', () {
      final a = GpVaasthuService.getAadhayamByAyadi(ayadi);
      // 1763 * 8 = 14104; 14104 % 12 = 4 (கீர்த்தி உண்டு)
      expect(a.number, 4);
      expect(a.effect.contains('கீர்த்தி உண்டு'), true);
    });

    test('4. Virayam test', () {
      final v = GpVaasthuService.getVirayamByAyadi(ayadi);
      // 1763 * 9 = 15867; 15867 % 10 = 7 (உயர்வு உண்டு)
      expect(v.number, 7);
      expect(v.effect.contains('உயர்வு உண்டு'), true);
    });

    test('5. Vaaram test', () {
      final vaara = GpVaasthuService.getVaaraByAyadi(ayadi);
      // 1763 * 9 = 15867; 15867 - 15862 = 5 (வியாழன்)
      expect(vaara.number, 5);
      expect(vaara.dayName.contains('வியாழன்'), true);
      expect(vaara.effect.contains('தனம் / புத்திர விருத்தி'), true);
    });

    test('6. Amsam test', () {
      final amsa = GpVaasthuService.getAmsaByAyadi(ayadi);
      // 1763 * 4 = 7052; 7052 - 7047 = 5 (சேதம் உண்டாகும்)
      expect(amsa.number, 5);
      expect(amsa.effect.contains('சேதம் உண்டாகும்'), true);
    });

    test('7. Nakshatram test', () {
      final nak = GpVaasthuService.getNakshatraByAyadi(ayadi);
      // 1763 * 8 = 14104; 14104 - 14094 = 10 (மகம் - தீமை உண்டாகும்)
      expect(nak.number, 10);
      expect(nak.name.contains('மகம்'), true);
      expect(nak.gana.contains('ராட்சச'), true);
      expect(nak.effect.contains('தீமை உண்டாகும்'), true);
    });

    test('8. Vamsam test', () {
      final vamsam = GpVaasthuService.getVamsamByAyadi(ayadi);
      // 1763 * 9 = 15867; 15867 - 15864 = 3 (வைசிய வம்சம்)
      expect(vamsam.number, 3);
      expect(vamsam.name.contains('வைசிய'), true);
      expect(vamsam.effect.contains('தன செல்வம் பெருகும்'), true);
    });

    test('9. Thithi test (Method 1 & 2)', () {
      final t1 = GpVaasthuService.getThithi1ByAyadi(ayadi);
      // 1763 * 4 = 7052; 7052 - 7050 = 2 (வ. துவிதியை)
      expect(t1.number, 2);
      expect(t1.name.contains('துவிதியை'), true);
      expect(t1.paksha.contains('வளர்பிறை'), true);

      final t2 = GpVaasthuService.getThithi2ByAyadi(ayadi);
      // 1763 * 9 = 15867; 15867 - 15840 = 27 (தே. துவாதசி)
      expect(t2.number, 27);
      expect(t2.name.contains('துவாதசி'), true);
      expect(t2.paksha.contains('தேய்பிறை'), true);
    });

    test('10. Rasi test', () {
      final rasi = GpVaasthuService.getRasiByAyadi(ayadi);
      // 1763 * 4 = 7052; 7052 - 7044 = 8 (விருச்சிகம்)
      expect(rasi.number, 8);
      expect(rasi.name.contains('விருச்சிகம்'), true);
      expect(rasi.effect.contains('நடுநிலைமை'), true);
    });

    test('11. Age test', () {
      final age = GpVaasthuService.getAgeByAyadi(ayadi);
      // 1763 * 27 = 47601; 47601 % 100 = 1 வயது
      expect(age.age, 1);
      expect(age.category.contains('1 – 27'), true);
    });

    test('12. Gana compatibility evaluation', () {
      final res1 = GpVaasthuService.evaluateGanaMatch('தேவ கணம்', 'மனித கணம்');
      expect(res1['isGood'], true);
      expect(res1['status'], 'உத்தமம்');

      final res2 = GpVaasthuService.evaluateGanaMatch('ராட்சச கணம்', 'தேவ கணம்');
      expect(res2['isGood'], false);
      expect((res2['status'] as String).contains('அதர்மம்'), true);
    });

    test('13. Purusha Rasi test', () {
      final pr = GpVaasthuService.getPurushaRasiByAyadi(ayadi);
      // 1763 * 7 = 12341; 12341 - 12336 = 5 (ஸ்திர சிம்மம் - தீமை)
      expect(pr.number, 5);
      expect(pr.name.contains('சிம்மம்'), true);
      expect(pr.rasiType, 'ஸ்திர இராசி');
      expect(pr.isGood, false);
      expect(pr.status.contains('தீமை'), true);
    });

    test('14. Boothams test (Method 1 & 2)', () {
      final b1 = GpVaasthuService.getBootham1ByAyadi(ayadi);
      // 1763 * 3 = 5289; 5289 - 5285 = 4 (காற்று - நன்மை)
      expect(b1.number, 4);
      expect(b1.name.contains('காற்று'), true);
      expect(b1.effect.contains('நன்மை உண்டாகும்'), true);
      expect(b1.isGood, true);

      final b2 = GpVaasthuService.getBootham2ByAyadi(ayadi);
      // 1763 * 9 = 15867; 15867 - 15865 = 2 (நீர் - காரிய வெற்றி)
      expect(b2.number, 2);
      expect(b2.name.contains('நீர்'), true);
      expect(b2.effect.contains('காரிய வெற்றி உண்டாகும்'), true);
      expect(b2.isGood, true);
    });

    test('15. Soothiram test', () {
      final st = GpVaasthuService.getSoothiramByAyadi(ayadi);
      // 1763 * 7 = 12341; 12341 - 12340 = 1 (பால சூத்திரம் - உத்தமம்)
      expect(st.number, 1);
      expect(st.name.contains('பால சூத்திரம்'), true);
      expect(st.status, 'உத்தமம்');
      expect(st.isGood, true);
    });

    test('16. Nethiram test', () {
      // Vaaram = 5 (வியாழன்/குரு) -> Start star = 5 * 3 = 15 (விசாகம்)
      // Nakshatram = 10 (மகம்)
      // Range 1 (9 stars): 15-23 (விசாகம் to அவிட்டம்) -> No 10
      // Range 2 (12 stars): 24-8 (சதயம் to பூசம்) -> No 10
      // Range 3 (6 stars): 9-14 (ஆயில்யம் to சித்திரை) -> Contains 10 (மகம்)
      // Result: 0 - கண் (அதமம் / தீமை)
      final nethiram = GpVaasthuService.calculateNethiram(5, 10);
      expect(nethiram.eyes, 0);
      expect(nethiram.isGood, false);
      expect(nethiram.status.contains('அதமம்'), true);
      expect(nethiram.startStarNumber, 15);
      expect(nethiram.startStarName.contains('விசாகம்'), true);

      // Verify overall Kuzhi calculation has nethiram populated
      final res = GpVaasthuService.calculateKuzhi(
        region: GpVaasthuRegion.madurai,
        l1Ft: 30,
        w1Ft: 20,
      );
      expect(res.nethiram.eyes, isIn([0, 1, 2]));
      expect(res.nethiram.startStarNumber, greaterThanOrEqualTo(1));
    });

    test('17. Amirthathi Yoga test', () {
      // Ayadi = 1763 -> Vaaram = 5 (வியாழன்), Nakshatram = 10 (மகம்)
      // Row 10 (மகம்), Col 5 (வியாழன்) -> 'அ' = அமிர்த யோகம் (உத்தமம்)
      final yoga = GpVaasthuService.getAmirthathiYogaByAyadi(ayadi);
      expect(yoga.code, 'அ');
      expect(yoga.name, 'அமிர்த யோகம்');
      expect(yoga.isGood, true);
      expect(yoga.status.contains('உத்தமம்'), true);

      // Verify other specific matrix coordinates from the reference table:
      // 1. Sunday (1) + Bharani (2) -> 'பி' (பிரபலாரிஷ்ட யோகம்)
      final yogaBharaniSun = GpVaasthuService.calculateAmirthathiYoga(1, 2);
      expect(yogaBharaniSun.code, 'பி');
      expect(yogaBharaniSun.isGood, false);

      // 2. Wednesday (4) + Ashwini (1) -> 'ம' (மரண யோகம்)
      final yogaAshwiniWed = GpVaasthuService.calculateAmirthathiYoga(4, 1);
      expect(yogaAshwiniWed.code, 'ம');
      expect(yogaAshwiniWed.isGood, false);

      // 3. Sunday (1) + Ashwini (1) -> 'சி' (சித்த யோகம்)
      final yogaAshwiniSun = GpVaasthuService.calculateAmirthathiYoga(1, 1);
      expect(yogaAshwiniSun.code, 'சி');
      expect(yogaAshwiniSun.isGood, true);

      // Verify KuzhiResult integration
      final res = GpVaasthuService.calculateKuzhi(
        region: GpVaasthuRegion.madurai,
        l1Ft: 30,
        w1Ft: 20,
      );
      expect(res.amirthathiYoga.code, isIn(['அ', 'சி', 'ம', 'பி']));
    });

    test('18. Thara Phalan test', () {
      // House Nakshatra = 10 (மகம்), Owner Nakshatra = 11 (பூரம்)
      // Count = (11 - 10 + 27) % 27 + 1 = 2
      // Rem = 2 % 9 = 2 (2 சம்பத்து தாரை - உத்தமம் / நன்மை)
      final thara1 = GpVaasthuService.calculateTharaPhalan(
        ownerNakshatra: 11,
        houseNakshatra: 10,
      );
      expect(thara1.count, 2);
      expect(thara1.remainder, 2);
      expect(thara1.tharaName, 'சம்பத்து தாரை');
      expect(thara1.isGood, true);
      expect(thara1.status.contains('உத்தமம்'), true);

      // Owner = 10 (மகம்), House = 10 (மகம்) -> Count = 1, Rem = 1 (ஜென்ம தாரை - தீமை)
      final thara2 = GpVaasthuService.calculateTharaPhalan(
        ownerNakshatra: 10,
        houseNakshatra: 10,
      );
      expect(thara2.count, 1);
      expect(thara2.remainder, 1);
      expect(thara2.tharaName, 'ஜென்ம தாரை');
      expect(thara2.isGood, false);

      // House = 10 (மகம்), Owner = 1 (அசுவினி) -> Count = (1 - 10 + 27) % 27 + 1 = 19
      // Rem = 19 % 9 = 1 (ஜென்ம தாரை - தீமை)
      final thara3 = GpVaasthuService.calculateTharaPhalan(
        ownerNakshatra: 1,
        houseNakshatra: 10,
      );
      expect(thara3.count, 19);
      expect(thara3.remainder, 1);
      expect(thara3.tharaName, 'ஜென்ம தாரை');
      expect(thara3.isGood, false);
    });

    test('19. Karana Phalan test', () {
      // Ayadi = 1763
      // 1763 * 5 = 8815; 8815 % 11 = 4 (தைதுலை - நன்மை / உத்தமம்)
      final karana = GpVaasthuService.getKaranaByAyadi(ayadi);
      expect(karana.number, 4);
      expect(karana.name, 'தைதுலை');
      expect(karana.isGood, true);
      expect(karana.status.contains('உத்தமம்'), true);

      // Remainder 11 check (e.g. 11 * 11 = 121 -> 121 * 5 = 605 -> 605 % 11 = 0 -> 11 கிமஸ்துக்கினம்)
      final karana11 = GpVaasthuService.getKaranaByAyadi(121);
      expect(karana11.number, 11);
      expect(karana11.name, 'கிமஸ்துக்கினம்');
      expect(karana11.isGood, false);
    });

    test('20. Chandra Phalan test', () {
      // Ayadi = 1763 -> House Rasi = 8 (விருச்சிகம்)
      // Owner Rasi = 1 (மேஷம்)
      // Chandra Number = (8 - 1 + 12) % 12 + 1 = 8 (உத்தமம்)
      final cp = GpVaasthuService.calculateChandraPhalan(
        ownerRasi: 1,
        houseRasi: 8,
      );
      expect(cp.number, 8);
      expect(cp.name, 'உத்தமம்');
      expect(cp.isGood, true);

      // Owner Rasi = 8 (விருச்சிகம்), House Rasi = 8 (விருச்சிகம்) -> 1 தேக சௌக்கியம்
      final cpSame = GpVaasthuService.calculateChandraPhalan(
        ownerRasi: 8,
        houseRasi: 8,
      );
      expect(cpSame.number, 1);
      expect(cpSame.name, 'தேக சௌக்கியம்');
      expect(cpSame.isGood, true);

      // 4 ரோக பயம் (தீமை)
      final cp4 = GpVaasthuService.calculateChandraPhalan(
        ownerRasi: 1,
        houseRasi: 4,
      );
      expect(cp4.number, 4);
      expect(cp4.name, 'ரோக பயம்');
      expect(cp4.isGood, false);
    });

    test('21. Ashta Lakshmi Phalan test', () {
      // Ayadi = 1763
      // 1763 * 3 = 5289; 661 * 8 = 5288; 5289 - 5288 = 1 -> 1 இராஜலட்சுமி (இராஜயோகம் உண்டாகும்)
      final al = GpVaasthuService.getAshtaLakshmiByAyadi(ayadi);
      expect(al.number, 1);
      expect(al.name, 'இராஜலட்சுமி');
      expect(al.effect.contains('இராஜயோகம்'), true);
      expect(al.isGood, true);
    });

    test('22. Panchaka Phalan and Pariharam test', () {
      // Ayadi = 1763
      // Vaaram = 5 (குரு), Thithi1 = 2 (வ. துவிதியை), Nakshatra = 10 (மகம்), Rasi = 8 (விருச்சிகம்)
      // Sum = 5 + 2 + 10 + 8 = 25
      // 25 % 9 = 7 (7. நிஷ் பஞ்சகம் - உத்தமம் / நன்மை)
      final panchaka = GpVaasthuService.calculatePanchaka(
        vaaraNumber: 5,
        thithiNumber: 2,
        nakshatraNumber: 10,
        rasiNumber: 8,
      );
      expect(panchaka.totalSum, 25);
      expect(panchaka.number, 7);
      expect(panchaka.name, 'நிஷ் பஞ்சகம்');
      expect(panchaka.isGood, true);
      expect(panchaka.pariharam.contains('பரிகாரம் தேவையில்லை'), true);

      // Test Pariharam cases:
      // Case 1: Marana Panchakam (1) -> இரத்தின தானம்
      final p1 = GpVaasthuService.calculatePanchaka(
        vaaraNumber: 1,
        thithiNumber: 1,
        nakshatraNumber: 1,
        rasiNumber: 7,
      ); // 10 % 9 = 1
      expect(p1.number, 1);
      expect(p1.name, 'மரண பஞ்சகம்');
      expect(p1.isGood, false);
      expect(p1.pariharam, 'இரத்தின தானம்');

      // Case 2: Agni Panchakam (2) -> சந்தனம் தானம்
      final p2 = GpVaasthuService.calculatePanchaka(
        vaaraNumber: 1,
        thithiNumber: 1,
        nakshatraNumber: 1,
        rasiNumber: 8,
      ); // 11 % 9 = 2
      expect(p2.number, 2);
      expect(p2.name, 'அக்கினி பஞ்சகம்');
      expect(p2.isGood, false);
      expect(p2.pariharam, 'சந்தனம் தானம்');

      // Case 4: Raja Panchakam (4) -> எலுமிச்சம்பழம் தானம்
      final p4 = GpVaasthuService.calculatePanchaka(
        vaaraNumber: 1,
        thithiNumber: 1,
        nakshatraNumber: 1,
        rasiNumber: 1,
      ); // 4 % 9 = 4
      expect(p4.number, 4);
      expect(p4.name, 'இராஜ பஞ்சகம்');
      expect(p4.isGood, false);
      expect(p4.pariharam, 'எலுமிச்சம்பழம் தானம்');

      // Case 6: Chora Panchakam (6) -> தீபம் தானம்
      final p6 = GpVaasthuService.calculatePanchaka(
        vaaraNumber: 1,
        thithiNumber: 1,
        nakshatraNumber: 1,
        rasiNumber: 3,
      ); // 6 % 9 = 6
      expect(p6.number, 6);
      expect(p6.name, 'சோர பஞ்சகம்');
      expect(p6.isGood, false);
      expect(p6.pariharam, 'தீபம் தானம்');

      // Case 8: Roga Panchakam (8) -> உணவு / தானியம் தானம்
      final p8 = GpVaasthuService.calculatePanchaka(
        vaaraNumber: 1,
        thithiNumber: 1,
        nakshatraNumber: 1,
        rasiNumber: 5,
      ); // 8 % 9 = 8
      expect(p8.number, 8);
      expect(p8.name, 'ரோக பஞ்சகம்');
      expect(p8.isGood, false);
      expect(p8.pariharam, 'உணவு / தானியம் தானம்');
    });

    test('23. Guna Phalan test', () {
      // Ayadi = 1763
      // 1763 % 3: 1763 - 1761 = 2 (2 – செல்வம் விருத்தி - உத்தமம் / நன்மை)
      final guna2 = GpVaasthuService.getGunaByAyadi(ayadi);
      expect(guna2.number, 2);
      expect(guna2.name, 'செல்வம் விருத்தி');
      expect(guna2.effect.contains('செல்வம் விருத்தி உண்டாகும்'), true);
      expect(guna2.isGood, true);
      expect(guna2.status.contains('உத்தமம்'), true);

      // Ayadi = 1 -> 1 % 3 = 1 (1 – தீமை - அதமம்)
      final guna1 = GpVaasthuService.getGunaByAyadi(1);
      expect(guna1.number, 1);
      expect(guna1.name, 'தீமை');
      expect(guna1.effect.contains('தீமை உண்டாகும்'), true);
      expect(guna1.isGood, false);
      expect(guna1.status.contains('தீமை'), true);

      // Ayadi = 3 -> 3 % 3 = 0 -> 3 (3 – உடல் ஆரோக்கியம் - உத்தமம் / நன்மை)
      final guna3 = GpVaasthuService.getGunaByAyadi(3);
      expect(guna3.number, 3);
      expect(guna3.name, 'உடல் ஆரோக்கியம்');
      expect(guna3.effect.contains('உடல் ஆரோக்கியம் உண்டாகும்'), true);
      expect(guna3.isGood, true);
      expect(guna3.status.contains('உத்தமம்'), true);

      // Verify in full calculation (30x20 in Madurai -> perimeter 1200 / 1.333 = 900 -> 900 % 3 = 3)
      final res = GpVaasthuService.calculateKuzhi(
        region: GpVaasthuRegion.madurai,
        l1Ft: 30,
        w1Ft: 20,
      );
      expect(res.guna.number, 3);
      expect(res.gunaNumber, 3);
      expect(res.guna.name, 'உடல் ஆரோக்கியம்');
    });
  });
}


