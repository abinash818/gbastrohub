enum GpVaasthuRegion {
  madurai(
    id: 'madurai',
    nameTa: 'மதுரை',
    nameEn: 'Madurai',
    constant: 1024,
    kolInches: 32,
    ayadiDivisor: 1.333,
    description: '32 அங்குல கோல் முறை (1024)',
  ),
  chidambaram(
    id: 'chidambaram',
    nameTa: 'சிதம்பரம்',
    nameEn: 'Chidambaram',
    constant: 1089,
    kolInches: 33,
    ayadiDivisor: 1.375,
    description: '33 அங்குல கோல் முறை (1089)',
  ),
  kanchipuram(
    id: 'kanchipuram',
    nameTa: 'காஞ்சிபுரம்',
    nameEn: 'Kanchipuram',
    constant: 1156,
    kolInches: 34,
    ayadiDivisor: 1.416,
    description: '34 அங்குல கோல் முறை (1156)',
  ),
  srirangam(
    id: 'srirangam',
    nameTa: 'ஸ்ரீரங்கம்',
    nameEn: 'Srirangam',
    constant: 1296,
    kolInches: 36,
    ayadiDivisor: 1.500,
    description: '36 அங்குல கோல் முறை (1296)',
  );

  final String id;
  final String nameTa;
  final String nameEn;
  final int constant;
  final int kolInches;
  final double ayadiDivisor;
  final String description;

  const GpVaasthuRegion({
    required this.id,
    required this.nameTa,
    required this.nameEn,
    required this.constant,
    required this.kolInches,
    required this.ayadiDivisor,
    required this.description,
  });
}

class GpGarbhamItem {
  final int number;
  final String name;
  final String direction;
  final String deity;
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpGarbhamItem({
    required this.number,
    required this.name,
    required this.direction,
    required this.deity,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpAadhayamItem {
  final int number;
  final String effect;
  final bool isGood;
  final String iconEmoji;

  const GpAadhayamItem({
    required this.number,
    required this.effect,
    this.isGood = true,
    required this.iconEmoji,
  });
}

class GpVirayamItem {
  final int number;
  final String effect;
  final bool isGood;
  final String iconEmoji;
  final String status;

  const GpVirayamItem({
    required this.number,
    required this.effect,
    required this.isGood,
    required this.iconEmoji,
    required this.status,
  });
}

class GpYoniItem {
  final int number;
  final String name;
  final String effect;
  final bool isGood;
  final String iconEmoji;
  final String status;
  final String enemyDirection;

  const GpYoniItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.iconEmoji,
    required this.status,
    required this.enemyDirection,
  });
}

class GpVaaraItem {
  final int number;
  final String dayName;
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpVaaraItem({
    required this.number,
    required this.dayName,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpAmsaItem {
  final int number;
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpAmsaItem({
    required this.number,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpVaasthuNakshatraItem {
  final int number;
  final String name;
  final String effect;
  final bool isGood;
  final String status;
  final String gana;
  final String iconEmoji;

  const GpVaasthuNakshatraItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.gana,
    required this.iconEmoji,
  });
}

class GpVamsamItem {
  final int number;
  final String name;
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpVamsamItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpThithiItem {
  final int number;
  final String paksha; // வளர்பிறை / தேய்பிறை
  final String name;
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpThithiItem({
    required this.number,
    required this.paksha,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpRasiItem {
  final int number;
  final String name;
  final String shortName;
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpRasiItem({
    required this.number,
    required this.name,
    required this.shortName,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpAgeItem {
  final int age;
  final String category; // '1 – 27', '28 – 50', '51 – 100'
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpAgeItem({
    required this.age,
    required this.category,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpPurushaRasiItem {
  final int number;
  final String name;
  final String shortName;
  final String rasiType; // 'சர இராசி', 'ஸ்திர இராசி', 'உபய இராசி'
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpPurushaRasiItem({
    required this.number,
    required this.name,
    required this.shortName,
    required this.rasiType,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpBoothamsItem {
  final int number;
  final String name;
  final String tamilElementName;
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpBoothamsItem({
    required this.number,
    required this.name,
    required this.tamilElementName,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpSoothiramItem {
  final int number;
  final String name;
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpSoothiramItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpNethiramItem {
  final int eyes; // 0, 1, 2
  final String title; // '2 – கண் (இரட்டைக் கண்)', '1 – கண் (ஒற்றைக் கண்)', '0 – கண் (கண் இல்லை)'
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;
  final int startStarNumber;
  final String startStarName;
  final String range1Description;
  final String range2Description;
  final String range3Description;
  final String matchedRange;

  const GpNethiramItem({
    required this.eyes,
    required this.title,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
    required this.startStarNumber,
    required this.startStarName,
    required this.range1Description,
    required this.range2Description,
    required this.range3Description,
    required this.matchedRange,
  });
}

class GpAmirthathiYogaItem {
  final String code; // 'அ', 'சி', 'ம', 'பி'
  final String name; // 'அமிர்த யோகம்', 'சித்த யோகம்', 'மரண யோகம்', 'பிரபலாரிஷ்ட யோகம்'
  final String effect;
  final bool isGood;
  final String status; // 'உத்தமம் (நன்மை)', 'அதமம் (தீமை)'
  final String iconEmoji;
  final int vaaraNumber;
  final String vaaraDayName;
  final int nakshatraNumber;
  final String nakshatraName;

  const GpAmirthathiYogaItem({
    required this.code,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
    required this.vaaraNumber,
    required this.vaaraDayName,
    required this.nakshatraNumber,
    required this.nakshatraName,
  });
}

class GpTharaPhalanItem {
  final int count; // 1 to 27
  final int remainder; // count % 9 (1 to 9, 0 is 9)
  final String tharaName; // ஜென்ம தாரை, சம்பத்து தாரை, etc.
  final String effect;
  final bool isGood;
  final String status; // 'உத்தமம் (நன்மை)' / 'தீமை (அதமம்)'
  final String iconEmoji;
  final int ownerNakshatraNumber;
  final String ownerNakshatraName;
  final int houseNakshatraNumber;
  final String houseNakshatraName;

  const GpTharaPhalanItem({
    required this.count,
    required this.remainder,
    required this.tharaName,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
    required this.ownerNakshatraNumber,
    required this.ownerNakshatraName,
    required this.houseNakshatraNumber,
    required this.houseNakshatraName,
  });
}

class GpKaranaItem {
  final int number; // 1 to 11
  final String name; // பாவம், பாலவம், etc.
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpKaranaItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpChandraPhalanItem {
  final int number; // 1 to 12
  final String name; // 'தேக சௌக்கியம்', 'உத்தமம்', etc.
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;
  final int ownerRasiNumber;
  final String ownerRasiName;
  final int houseRasiNumber;
  final String houseRasiName;

  const GpChandraPhalanItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
    required this.ownerRasiNumber,
    required this.ownerRasiName,
    required this.houseRasiNumber,
    required this.houseRasiName,
  });
}

class GpAshtaLakshmiItem {
  final int number; // 1 to 8
  final String name; // இராஜலட்சுமி, கீர்த்தி லட்சுமி, etc.
  final String effect; // இராஜயோகம் உண்டாகும், etc.
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpAshtaLakshmiItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpPanchakaItem {
  final int number; // 1 to 9
  final String name; // மரண பஞ்சகம், அக்கினி பஞ்சகம், நிஷ் பஞ்சகம், etc.
  final String effect;
  final String pariharam; // இரத்தின தானம், சந்தனம் தானம், etc.
  final bool isGood;
  final String status;
  final String iconEmoji;
  final int vaaraNumber;
  final int thithiNumber;
  final int nakshatraNumber;
  final int rasiNumber;
  final int totalSum;

  const GpPanchakaItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.pariharam,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
    required this.vaaraNumber,
    required this.thithiNumber,
    required this.nakshatraNumber,
    required this.rasiNumber,
    required this.totalSum,
  });
}

class GpGunaItem {
  final int number; // 1 to 3
  final String name; // தீமை, செல்வம் விருத்தி, உடல் ஆரோக்கியம்
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpGunaItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpNamaYogaItem {
  final int number; // 1 to 27
  final String name; // விஷ்கம்பம் .. வைதிருதி
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpNamaYogaItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpDikpalakarItem {
  final int number; // 1 to 8
  final String name; // இந்திரன் .. ஈசானியம்
  final String direction; // கிழக்கு .. வடகிழக்கு
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpDikpalakarItem({
    required this.number,
    required this.name,
    required this.direction,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpAthidevathaiItem {
  final int number; // 1 to 8
  final String name; // இந்திரன் .. ஈசானியம்
  final String effect;
  final bool isGood;
  final String status;
  final String iconEmoji;

  const GpAthidevathaiItem({
    required this.number,
    required this.name,
    required this.effect,
    required this.isGood,
    required this.status,
    required this.iconEmoji,
  });
}

class GpKuzhiResult {
  final GpVaasthuRegion region;
  final double length1Ft;
  final double length1In;
  final double length2Ft;
  final double length2In;
  final double width1Ft;
  final double width1In;
  final double width2Ft;
  final double width2In;
  final double avgLengthFt;
  final double avgWidthFt;
  final double sqft;
  final double sqInches;
  final int divisor;
  final double kuzhi;
  final double kuzhiExact;
  final int roundedKuzhi; // >= 0.5 rounds up, < 0.5 rounds down
  final int wholeKuzhi;
  final double fractionKuzhi;

  // Ayadi Number Fields
  final double perimeterFt;
  final double perimeterInches;
  final double ayadiDivisor;
  final double ayadiNumber;
  final double ayadiExact;
  final int roundedAyadi;

  // Garbham (கெர்ப்ப பலன்)
  final int garbhamNumber;
  final GpGarbhamItem garbham;

  // Aadhayam (ஆதாயம் பலன்)
  final int aadhayamNumber;
  final int aadhayamTotal;
  final GpAadhayamItem aadhayam;

  // Virayam (விரையம் பலன்)
  final int virayamNumber;
  final int virayamTotal;
  final GpVirayamItem virayam;
  final bool isAadhayamGreater; // ஆதாயத்தை விட விரையம் குறைவாக இருக்க வேண்டும்

  // Yoni (யோனி பலன்)
  final int yoniNumber;
  final int yoniTotal;
  final GpYoniItem yoni;

  // Vaaram (5. வாரப்பலன்)
  final int vaaraNumber;
  final int vaaraTotal;
  final GpVaaraItem vaara;

  // Amsam (6. அம்ச பலன்)
  final int amsaNumber;
  final int amsaTotal;
  final GpAmsaItem amsa;

  // Nakshatra (7. நட்சத்திர பலன் & 11. கணப் பலன்)
  final int nakshatraNumber;
  final int nakshatraTotal;
  final GpVaasthuNakshatraItem nakshatra;

  // Vamsam (8. வம்சம் பலன்)
  final int vamsamNumber;
  final int vamsamTotal;
  final GpVamsamItem vamsam;

  // Thithi (9. திதிப் பலன் - மரபு 1 & மரபு 2)
  final int thithi1Number;
  final int thithi1Total;
  final GpThithiItem thithi1;
  final int thithi2Number;
  final int thithi2Total;
  final GpThithiItem thithi2;

  // Rasi (10. இராசி பலன் / ஸ்திரீ இராசி)
  final int rasiNumber;
  final int rasiTotal;
  final GpRasiItem rasi;

  // Age (10 கூடுதல். வயது பலன்)
  final int ageNumber;
  final int ageTotal;
  final GpAgeItem age;

  // Purusha Rasi (12. புருஷ இராசி பலன்)
  final int purushaRasiNumber;
  final int purushaRasiTotal;
  final GpPurushaRasiItem purushaRasi;

  // Boothams (13. பூதம் பலன் - முறை 1 & 2)
  final int bootham1Number;
  final int bootham1Total;
  final GpBoothamsItem bootham1;
  final int bootham2Number;
  final int bootham2Total;
  final GpBoothamsItem bootham2;

  // Soothiram (14. சூத்திரம் பலன்)
  final int soothiramNumber;
  final int soothiramTotal;
  final GpSoothiramItem soothiram;

  // Nethiram (15. நேத்திர பலன்)
  final GpNethiramItem nethiram;

  // Amirthathi Yogam (16. அமிர்தாதி யோக பலன்கள்)
  final GpAmirthathiYogaItem amirthathiYoga;

  // Owner selections
  final int ownerNakshatra;
  final int ownerRasi;

  // 17. Thara Phalan (தாரா பலன்)
  final GpTharaPhalanItem tharaPhalan;

  // 18. Karana Phalan (கரணப் பலன்)
  final int karanaNumber;
  final int karanaTotal;
  final GpKaranaItem karana;

  // 19. Chandra Phalan (சந்திர பலன்)
  final GpChandraPhalanItem chandraPhalan;

  // 20. Ashta Lakshmi Phalan (அஷ்டலட்சுமி பலன்)
  final int ashtaLakshmiNumber;
  final int ashtaLakshmiTotal;
  final GpAshtaLakshmiItem ashtaLakshmi;

  // 21. Panchaka Phalan (பஞ்சகப் பலன்)
  final GpPanchakaItem panchaka;

  // 22. Guna Phalan (குணப் பலன்)
  final int gunaNumber;
  final GpGunaItem guna;

  // 23. Nama Yoga Phalan (நாம யோகப் பலன்)
  final int namaYogaNumber;
  final int namaYogaTotal;
  final GpNamaYogaItem namaYoga;

  // 24. Ashta Dikpalakar Phalan (அஷ்டதிக்கு பாலகர் பலன்)
  final int dikpalakarNumber;
  final int dikpalakarTotal;
  final GpDikpalakarItem dikpalakar;

  // 25. Athidevathai Phalan (அதிதேவதை பலன்)
  final int athidevathaiNumber;
  final int athidevathaiTotal;
  final GpAthidevathaiItem athidevathai;

  const GpKuzhiResult({
    required this.region,
    required this.length1Ft,
    required this.length1In,
    required this.length2Ft,
    required this.length2In,
    required this.width1Ft,
    required this.width1In,
    required this.width2Ft,
    required this.width2In,
    required this.avgLengthFt,
    required this.avgWidthFt,
    required this.sqft,
    required this.sqInches,
    required this.divisor,
    required this.kuzhi,
    required this.kuzhiExact,
    required this.roundedKuzhi,
    required this.wholeKuzhi,
    required this.fractionKuzhi,
    required this.perimeterFt,
    required this.perimeterInches,
    required this.ayadiDivisor,
    required this.ayadiNumber,
    required this.ayadiExact,
    required this.roundedAyadi,
    required this.garbhamNumber,
    required this.garbham,
    required this.aadhayamNumber,
    required this.aadhayamTotal,
    required this.aadhayam,
    required this.virayamNumber,
    required this.virayamTotal,
    required this.virayam,
    required this.isAadhayamGreater,
    required this.yoniNumber,
    required this.yoniTotal,
    required this.yoni,
    required this.vaaraNumber,
    required this.vaaraTotal,
    required this.vaara,
    required this.amsaNumber,
    required this.amsaTotal,
    required this.amsa,
    required this.nakshatraNumber,
    required this.nakshatraTotal,
    required this.nakshatra,
    required this.vamsamNumber,
    required this.vamsamTotal,
    required this.vamsam,
    required this.thithi1Number,
    required this.thithi1Total,
    required this.thithi1,
    required this.thithi2Number,
    required this.thithi2Total,
    required this.thithi2,
    required this.rasiNumber,
    required this.rasiTotal,
    required this.rasi,
    required this.ageNumber,
    required this.ageTotal,
    required this.age,
    required this.purushaRasiNumber,
    required this.purushaRasiTotal,
    required this.purushaRasi,
    required this.bootham1Number,
    required this.bootham1Total,
    required this.bootham1,
    required this.bootham2Number,
    required this.bootham2Total,
    required this.bootham2,
    required this.soothiramNumber,
    required this.soothiramTotal,
    required this.soothiram,
    required this.nethiram,
    required this.amirthathiYoga,
    required this.ownerNakshatra,
    required this.ownerRasi,
    required this.tharaPhalan,
    required this.karanaNumber,
    required this.karanaTotal,
    required this.karana,
    required this.chandraPhalan,
    required this.ashtaLakshmiNumber,
    required this.ashtaLakshmiTotal,
    required this.ashtaLakshmi,
    required this.panchaka,
    required this.gunaNumber,
    required this.guna,
    required this.namaYogaNumber,
    required this.namaYogaTotal,
    required this.namaYoga,
    required this.dikpalakarNumber,
    required this.dikpalakarTotal,
    required this.dikpalakar,
    required this.athidevathaiNumber,
    required this.athidevathaiTotal,
    required this.athidevathai,
  });
}

class GpVaasthuService {
  /// All 8 Garbham (கெர்ப்பங்கள்) definitions
  static const List<GpGarbhamItem> garbhamList = [
    GpGarbhamItem(
      number: 1,
      name: 'கருடன் / துஜம்',
      direction: 'கிழக்கு',
      deity: 'இந்திரன்',
      effect: 'மிகுந்த சுப நல பலன்களைத் தரும்',
      isGood: true,
      status: 'சுபம் (நன்மை)',
      iconEmoji: '🦅',
    ),
    GpGarbhamItem(
      number: 2,
      name: 'புறா / தூமம்',
      direction: 'தென்கிழக்கு',
      deity: 'அக்னி',
      effect: 'வறுமை / தன நஷ்டம் / அக்கினி பயம் மத்திமம்',
      isGood: false,
      status: 'மத்திமம்',
      iconEmoji: '🕊️',
    ),
    GpGarbhamItem(
      number: 3,
      name: 'சிம்மம்',
      direction: 'தெற்கு',
      deity: 'எமன்',
      effect: 'வெற்றி / சுப நல பலன்கள்',
      isGood: true,
      status: 'சுபம் (வெற்றி)',
      iconEmoji: '🦁',
    ),
    GpGarbhamItem(
      number: 4,
      name: 'ஸ்வானம் (நாய்)',
      direction: 'தென்மேற்கு',
      deity: 'நிருதி',
      effect: 'வறுமை — அதம தீய பலன்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '🐕',
    ),
    GpGarbhamItem(
      number: 5,
      name: 'பசு / ரிஷபம்',
      direction: 'மேற்கு',
      deity: 'வருணன்',
      effect: 'சகல காரியமும் வெற்றி',
      isGood: true,
      status: 'சுபம் (சகல வெற்றி)',
      iconEmoji: '🐄',
    ),
    GpGarbhamItem(
      number: 6,
      name: 'காக்கை',
      direction: 'வடமேற்கு',
      deity: 'வாயு',
      effect: 'தீய பலன்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '🪶',
    ),
    GpGarbhamItem(
      number: 7,
      name: 'யானை / கஜம்',
      direction: 'வடக்கு',
      deity: 'குபேரன்',
      effect: 'மிகுந்த நல பலன்',
      isGood: true,
      status: 'சுபம் (மிகுந்த நன்மை)',
      iconEmoji: '🐘',
    ),
    GpGarbhamItem(
      number: 8,
      name: 'கழுதை',
      direction: 'வடகிழக்கு',
      deity: 'ஈசான்யன்',
      effect: 'அதம பலன்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '🫏',
    ),
  ];

  /// All 12 Aadhayam (12 ஆதாயப் பலன்கள்) definitions
  static const List<GpAadhayamItem> aadhayamList = [
    GpAadhayamItem(
      number: 1,
      effect: 'சுபம் உண்டு',
      iconEmoji: '✨',
    ),
    GpAadhayamItem(
      number: 2,
      effect: 'போக உண்டு',
      iconEmoji: '🌟',
    ),
    GpAadhayamItem(
      number: 3,
      effect: 'பாக்கிய விருத்தி',
      iconEmoji: '🍀',
    ),
    GpAadhayamItem(
      number: 4,
      effect: 'கீர்த்தி உண்டு',
      iconEmoji: '👑',
    ),
    GpAadhayamItem(
      number: 5,
      effect: 'தானிய விருத்தி',
      iconEmoji: '🌾',
    ),
    GpAadhayamItem(
      number: 6,
      effect: 'தன உண்டு',
      iconEmoji: '💰',
    ),
    GpAadhayamItem(
      number: 7,
      effect: 'சுகம் / ஞானம் உண்டு',
      iconEmoji: '🧘',
    ),
    GpAadhayamItem(
      number: 8,
      effect: 'சந்தோஷம் உண்டு',
      iconEmoji: '😊',
    ),
    GpAadhayamItem(
      number: 9,
      effect: 'மிகுந்த யோகம் உண்டு',
      iconEmoji: '🔮',
    ),
    GpAadhayamItem(
      number: 10,
      effect: 'செல்வம் உண்டு',
      iconEmoji: '💎',
    ),
    GpAadhayamItem(
      number: 11,
      effect: 'தரும சிந்தனை உண்டு',
      iconEmoji: '🕊️',
    ),
    GpAadhayamItem(
      number: 12,
      effect: 'உத்தம பொருள் விருத்தி உண்டு',
      iconEmoji: '🏆',
    ),
  ];

  /// All 10 Virayam (10 விரையப் பலன்கள்) definitions
  static const List<GpVirayamItem> virayamList = [
    GpVirayamItem(
      number: 1,
      effect: 'வறுமை உண்டு',
      isGood: false,
      status: 'அதமம் (வறுமை)',
      iconEmoji: '📉',
    ),
    GpVirayamItem(
      number: 2,
      effect: 'அக்னி பயம் உண்டு',
      isGood: false,
      status: 'அதமம் (அக்னி பயம்)',
      iconEmoji: '🔥',
    ),
    GpVirayamItem(
      number: 3,
      effect: 'செல்வம் உண்டு',
      isGood: true,
      status: 'சுபம் (செல்வம்)',
      iconEmoji: '💰',
    ),
    GpVirayamItem(
      number: 4,
      effect: 'யோகம் உண்டு',
      isGood: true,
      status: 'சுபம் (யோகம்)',
      iconEmoji: '🔮',
    ),
    GpVirayamItem(
      number: 5,
      effect: 'பல வகை செல்வம் உண்டு / சுப செலவு',
      isGood: true,
      status: 'சுபம் (சுப செலவு)',
      iconEmoji: '✨',
    ),
    GpVirayamItem(
      number: 6,
      effect: 'செல்வம் உண்டு / செலவு வரும்',
      isGood: true,
      status: 'மத்திமம் (செலவு வரும்)',
      iconEmoji: '⚖️',
    ),
    GpVirayamItem(
      number: 7,
      effect: 'உயர்வு உண்டு',
      isGood: true,
      status: 'சுபம் (உயர்வு)',
      iconEmoji: '📈',
    ),
    GpVirayamItem(
      number: 8,
      effect: 'தன நாசம் உண்டு',
      isGood: false,
      status: 'அதமம் (தன நாசம்)',
      iconEmoji: '💸',
    ),
    GpVirayamItem(
      number: 9,
      effect: 'கலக உண்டு',
      isGood: false,
      status: 'அதமம் (கலகம்)',
      iconEmoji: '⚠️',
    ),
    GpVirayamItem(
      number: 10,
      effect: 'சம்பத்து / நட்பு உண்டு',
      isGood: true,
      status: 'சுபம் (நட்பு/சம்பத்து)',
      iconEmoji: '🤝',
    ),
  ];

  /// All 8 Yoni (8 யோனிப் பலன்கள்) definitions
  static const List<GpYoniItem> yoniList = [
    GpYoniItem(
      number: 1,
      name: 'கருட',
      effect: 'செல்வம் / குடும்பம் விருத்தி (மேற்கு திசை மனைக்கு பகை)',
      isGood: true,
      status: 'சுபம் (செல்வம் விருத்தி)',
      iconEmoji: '🦅',
      enemyDirection: 'மேற்கு திசை மனைக்கு பகை',
    ),
    GpYoniItem(
      number: 2,
      name: 'பூனை',
      effect: 'வறுமை / களவு உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '🐱',
      enemyDirection: '',
    ),
    GpYoniItem(
      number: 3,
      name: 'சிம்மம்',
      effect: 'தன / சுப விருத்தி (வடக்கு திசை மனைக்கு பகை)',
      isGood: true,
      status: 'சுபம் (தன விருத்தி)',
      iconEmoji: '🦁',
      enemyDirection: 'வடக்கு திசை மனைக்கு பகை',
    ),
    GpYoniItem(
      number: 4,
      name: 'சுவான (நாய்)',
      effect: 'கலகம் / நோய் உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '🐕',
      enemyDirection: '',
    ),
    GpYoniItem(
      number: 5,
      name: 'சர்ப்ப',
      effect: 'தனம் / பூமி இலாபம் விருத்தி (கிழக்கு திசை மனைக்கு பகை)',
      isGood: true,
      status: 'சுபம் (பூமி இலாபம்)',
      iconEmoji: '🐍',
      enemyDirection: 'கிழக்கு திசை மனைக்கு பகை',
    ),
    GpYoniItem(
      number: 6,
      name: 'காக்கை (எலி)',
      effect: 'பொருள் நஷ்டம் / குடும்ப பிரிவு',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '🪶',
      enemyDirection: '',
    ),
    GpYoniItem(
      number: 7,
      name: 'கஜ (யானை)',
      effect: 'செல்வம் விருத்தி (தெற்கு திசை மனைக்கு பகை)',
      isGood: true,
      status: 'சுபம் (செல்வ விருத்தி)',
      iconEmoji: '🐘',
      enemyDirection: 'தெற்கு திசை மனைக்கு பகை',
    ),
    GpYoniItem(
      number: 8,
      name: 'கழுதை',
      effect: 'தரித்திரம் / சண்டை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '🫏',
      enemyDirection: '',
    ),
  ];

  /// All 7 Vaaram (5. வாரப்பலன்கள்) definitions
  static const List<GpVaaraItem> vaaraList = [
    GpVaaraItem(
      number: 1,
      dayName: 'ஞாயிறு',
      effect: 'சாத்து உண்டு / பயம் தரும் மத்திமம்',
      isGood: false,
      status: 'மத்திமம்',
      iconEmoji: '☀️',
    ),
    GpVaaraItem(
      number: 2,
      dayName: 'திங்கள்',
      effect: 'தன விருத்தி',
      isGood: true,
      status: 'சுபம் (தன விருத்தி)',
      iconEmoji: '🌙',
    ),
    GpVaaraItem(
      number: 3,
      dayName: 'செவ்வாய்',
      effect: 'தன நஷ்டம்',
      isGood: false,
      status: 'அதமம் (தன நஷ்டம்)',
      iconEmoji: '🔴',
    ),
    GpVaaraItem(
      number: 4,
      dayName: 'புதன்',
      effect: 'மிகுந்த செல்வம் உண்டு',
      isGood: true,
      status: 'சுபம் (செல்வம்)',
      iconEmoji: '🟢',
    ),
    GpVaaraItem(
      number: 5,
      dayName: 'வியாழன்',
      effect: 'தனம் / புத்திர விருத்தி',
      isGood: true,
      status: 'சுபம் (புத்திர விருத்தி)',
      iconEmoji: '🟡',
    ),
    GpVaaraItem(
      number: 6,
      dayName: 'வெள்ளி',
      effect: 'சகல காரிய வெற்றி',
      isGood: true,
      status: 'சுபம் (சகல வெற்றி)',
      iconEmoji: '⚪',
    ),
    GpVaaraItem(
      number: 7,
      dayName: 'சனி',
      effect: 'துக்கம் / கவலை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (துக்கம்)',
      iconEmoji: '🪐',
    ),
  ];

  /// All 9 Amsam (6. அம்ச பலன்கள்) definitions
  static const List<GpAmsaItem> amsaList = [
    GpAmsaItem(
      number: 1,
      effect: 'மகிமை உண்டாகும்',
      isGood: true,
      status: 'சுபம் (மகிமை)',
      iconEmoji: '👑',
    ),
    GpAmsaItem(
      number: 2,
      effect: 'செல்வம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (செல்வம்)',
      iconEmoji: '💰',
    ),
    GpAmsaItem(
      number: 3,
      effect: 'பொருள் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (பொருள்)',
      iconEmoji: '💎',
    ),
    GpAmsaItem(
      number: 4,
      effect: 'தானிய விருத்தி உண்டாகும்',
      isGood: true,
      status: 'சுபம் (தானிய விருத்தி)',
      iconEmoji: '🌾',
    ),
    GpAmsaItem(
      number: 5,
      effect: 'சேதம் உண்டாகும்',
      isGood: false,
      status: 'அதமம் (சேதம்)',
      iconEmoji: '⚠️',
    ),
    GpAmsaItem(
      number: 6,
      effect: 'தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '❌',
    ),
    GpAmsaItem(
      number: 7,
      effect: 'தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '❌',
    ),
    GpAmsaItem(
      number: 8,
      effect: 'வறுமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (வறுமை)',
      iconEmoji: '📉',
    ),
    GpAmsaItem(
      number: 9,
      effect: 'தனவிருத்தி உண்டாகும்',
      isGood: true,
      status: 'சுபம் (தனவிருத்தி)',
      iconEmoji: '✨',
    ),
  ];

  /// All 27 Nakshatram (7. நட்சத்திர பலன்கள் & 11. கணப் பலன்) definitions
  static const List<GpVaasthuNakshatraItem> nakshatraList = [
    GpVaasthuNakshatraItem(
      number: 1,
      name: 'அசுவினி',
      effect: 'எல்லாம் வெற்றியுண்டு',
      isGood: true,
      status: 'சுபம் (வெற்றி)',
      gana: 'தேவ கணம்',
      iconEmoji: '🌟',
    ),
    GpVaasthuNakshatraItem(
      number: 2,
      name: 'பரணி',
      effect: 'மரண பயம் உண்டாகும்',
      isGood: false,
      status: 'அதமம் (பயம்)',
      gana: 'மனித கணம்',
      iconEmoji: '⚠️',
    ),
    GpVaasthuNakshatraItem(
      number: 3,
      name: 'கார்த்திகை',
      effect: 'வறுமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (வறுமை)',
      gana: 'ராட்சச கணம்',
      iconEmoji: '📉',
    ),
    GpVaasthuNakshatraItem(
      number: 4,
      name: 'ரோகிணி',
      effect: 'வெற்றியுண்டு உண்டாகும்',
      isGood: true,
      status: 'சுபம் (வெற்றி)',
      gana: 'மனித கணம்',
      iconEmoji: '🏆',
    ),
    GpVaasthuNakshatraItem(
      number: 5,
      name: 'மிருகசீரிஷம்',
      effect: 'ஜெயம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (ஜெயம்)',
      gana: 'தேவ கணம்',
      iconEmoji: '🎯',
    ),
    GpVaasthuNakshatraItem(
      number: 6,
      name: 'திருவாதிரை',
      effect: 'செல்வம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (செல்வம்)',
      gana: 'மனித கணம்',
      iconEmoji: '💎',
    ),
    GpVaasthuNakshatraItem(
      number: 7,
      name: 'புனர்பூசம்',
      effect: 'குழந்தை பேறு உண்டாகும்',
      isGood: true,
      status: 'சுபம் (புத்திர விருத்தி)',
      gana: 'தேவ கணம்',
      iconEmoji: '👶',
    ),
    GpVaasthuNakshatraItem(
      number: 8,
      name: 'பூசம்',
      effect: 'கீர்த்தி விருத்தி உண்டாகும்',
      isGood: true,
      status: 'சுபம் (கீர்த்தி)',
      gana: 'தேவ கணம்',
      iconEmoji: '👑',
    ),
    GpVaasthuNakshatraItem(
      number: 9,
      name: 'ஆயில்யம்',
      effect: 'தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      gana: 'ராட்சச கணம்',
      iconEmoji: '❌',
    ),
    GpVaasthuNakshatraItem(
      number: 10,
      name: 'மகம்',
      effect: 'தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      gana: 'ராட்சச கணம்',
      iconEmoji: '❌',
    ),
    GpVaasthuNakshatraItem(
      number: 11,
      name: 'பூரம்',
      effect: 'தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      gana: 'மனித கணம்',
      iconEmoji: '❌',
    ),
    GpVaasthuNakshatraItem(
      number: 12,
      name: 'உத்திரம்',
      effect: 'நன்மை உண்டாகும்',
      isGood: true,
      status: 'சுபம் (நன்மை)',
      gana: 'மனித கணம்',
      iconEmoji: '✨',
    ),
    GpVaasthuNakshatraItem(
      number: 13,
      name: 'அஸ்தம்',
      effect: 'நாளுக்கு நாள் நலம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (நாளுக்கு நாள் நலம்)',
      gana: 'தேவ கணம்',
      iconEmoji: '📈',
    ),
    GpVaasthuNakshatraItem(
      number: 14,
      name: 'சித்திரை',
      effect: 'நோய் உண்டாகும்',
      isGood: false,
      status: 'அதமம் (நோய்)',
      gana: 'ராட்சச கணம்',
      iconEmoji: '🤒',
    ),
    GpVaasthuNakshatraItem(
      number: 15,
      name: 'சுவாதி',
      effect: 'அதிக சிரமம் - மிகுந்த சுகம் / அதிக சிரமம்',
      isGood: true,
      status: 'மத்திமம் (சுகம்/சிரமம்)',
      gana: 'தேவ கணம்',
      iconEmoji: '⚖️',
    ),
    GpVaasthuNakshatraItem(
      number: 16,
      name: 'விசாகம்',
      effect: 'செல்வம் விரையம் உண்டாகும்',
      isGood: false,
      status: 'அதமம் (விரையம்)',
      gana: 'ராட்சச கணம்',
      iconEmoji: '💸',
    ),
    GpVaasthuNakshatraItem(
      number: 17,
      name: 'அனுஷம்',
      effect: 'சகல சௌபாக்கிய செல்வம் / கல்வி உண்டாகும்',
      isGood: true,
      status: 'சுபம் (சௌபாக்கியம்/கல்வி)',
      gana: 'தேவ கணம்',
      iconEmoji: '🎓',
    ),
    GpVaasthuNakshatraItem(
      number: 18,
      name: 'கேட்டை',
      effect: 'தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      gana: 'ராட்சச கணம்',
      iconEmoji: '❌',
    ),
    GpVaasthuNakshatraItem(
      number: 19,
      name: 'மூலம்',
      effect: 'தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      gana: 'ராட்சச கணம்',
      iconEmoji: '❌',
    ),
    GpVaasthuNakshatraItem(
      number: 20,
      name: 'பூராடம்',
      effect: 'தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      gana: 'மனித கணம்',
      iconEmoji: '❌',
    ),
    GpVaasthuNakshatraItem(
      number: 21,
      name: 'உத்திராடம்',
      effect: 'சுபம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (சுப நலம்)',
      gana: 'மனித கணம்',
      iconEmoji: '✨',
    ),
    GpVaasthuNakshatraItem(
      number: 22,
      name: 'திருவோணம்',
      effect: 'மிகுந்த நன்மை உண்டாகும்',
      isGood: true,
      status: 'சுபம் (மிகுந்த நன்மை)',
      gana: 'தேவ கணம்',
      iconEmoji: '🌸',
    ),
    GpVaasthuNakshatraItem(
      number: 23,
      name: 'அவிட்டம்',
      effect: 'அமைதி கிடைக்கும்',
      isGood: true,
      status: 'சுபம் (மன அமைதி)',
      gana: 'ராட்சச கணம்',
      iconEmoji: '🕊️',
    ),
    GpVaasthuNakshatraItem(
      number: 24,
      name: 'சதயம்',
      effect: 'இலட்சுமி வரவு உண்டாகும்',
      isGood: true,
      status: 'சுபம் (தன லக்ஷ்மி வரவு)',
      gana: 'ராட்சச கணம்',
      iconEmoji: '💰',
    ),
    GpVaasthuNakshatraItem(
      number: 25,
      name: 'பூரட்டாதி',
      effect: 'தீமை',
      isGood: false,
      status: 'அதமம் (தீமை)',
      gana: 'மனித கணம்',
      iconEmoji: '❌',
    ),
    GpVaasthuNakshatraItem(
      number: 26,
      name: 'உத்திரட்டாதி',
      effect: 'ஆயுள் விருத்தி உண்டாகும்',
      isGood: true,
      status: 'சுபம் (ஆயுள் விருத்தி)',
      gana: 'மனித கணம்',
      iconEmoji: '🛡️',
    ),
    GpVaasthuNakshatraItem(
      number: 27,
      name: 'ரேவதி',
      effect: 'நன்மை / தீமை இரண்டும் உண்டாகும்',
      isGood: true,
      status: 'மத்திமம் (இரண்டும் உண்டாகும்)',
      gana: 'தேவ கணம்',
      iconEmoji: '⚖️',
    ),
  ];

  /// All 4 Vamsam (8. வம்சம் பலன்கள்) definitions
  static const List<GpVamsamItem> vamsamList = [
    GpVamsamItem(
      number: 1,
      name: 'பிராமண வம்சம்',
      effect: 'தானிய வளம் பெருகும்',
      isGood: true,
      status: 'சுபம் (தானிய வளம்)',
      iconEmoji: '🪷',
    ),
    GpVamsamItem(
      number: 2,
      name: 'க்ஷத்திரிய வம்சம்',
      effect: 'தன செல்வம் பெருகும், ஜெயம்',
      isGood: true,
      status: 'சுபம் (ஜெயம் / செல்வம்)',
      iconEmoji: '⚔️',
    ),
    GpVamsamItem(
      number: 3,
      name: 'வைசிய வம்சம்',
      effect: 'தன செல்வம் பெருகும்',
      isGood: true,
      status: 'சுபம் (தன செல்வம்)',
      iconEmoji: '🌾',
    ),
    GpVamsamItem(
      number: 4,
      name: 'சூத்திர வம்சம்',
      effect: 'தொழில் பெருகும்',
      isGood: true,
      status: 'சுபம் (தொழில் வளர்ச்சி)',
      iconEmoji: '🛠️',
    ),
  ];

  /// All 30 Thithi (9. திதிப் பலன்கள்) definitions
  static const List<GpThithiItem> thithiList = [
    // வளர்பிறை (1 - 15)
    GpThithiItem(number: 1, paksha: 'வளர்பிறை', name: 'வ. பிரதமை', effect: 'உத்தமம் நலம்', isGood: true, status: 'உத்தமம்', iconEmoji: '🌕'),
    GpThithiItem(number: 2, paksha: 'வளர்பிறை', name: 'வ. துவிதியை', effect: 'சந்தோஷம்', isGood: true, status: 'சுபம்', iconEmoji: '🌕'),
    GpThithiItem(number: 3, paksha: 'வளர்பிறை', name: 'வ. திருதியை', effect: 'வெற்றி', isGood: true, status: 'சுபம்', iconEmoji: '🌕'),
    GpThithiItem(number: 4, paksha: 'வளர்பிறை', name: 'வ. சதுர்த்தி', effect: 'துன்பம்', isGood: false, status: 'அதமம்', iconEmoji: '🌑'),
    GpThithiItem(number: 5, paksha: 'வளர்பிறை', name: 'வ. பஞ்சமி', effect: 'புத்திரபாக்கியம்', isGood: true, status: 'சுபம்', iconEmoji: '🌕'),
    GpThithiItem(number: 6, paksha: 'வளர்பிறை', name: 'வ. சஷ்டி', effect: 'நலம்', isGood: true, status: 'சுபம்', iconEmoji: '🌕'),
    GpThithiItem(number: 7, paksha: 'வளர்பிறை', name: 'வ. சப்தமி', effect: 'யோகம்', isGood: true, status: 'சுபம்', iconEmoji: '🌕'),
    GpThithiItem(number: 8, paksha: 'வளர்பிறை', name: 'வ. அஷ்டமி', effect: 'துன்பம்', isGood: false, status: 'அதமம்', iconEmoji: '🌑'),
    GpThithiItem(number: 9, paksha: 'வளர்பிறை', name: 'வ. நவமி', effect: 'தீமை', isGood: false, status: 'அதமம்', iconEmoji: '❌'),
    GpThithiItem(number: 10, paksha: 'வளர்பிறை', name: 'வ. தசமி', effect: 'மாங்கல்யம்', isGood: true, status: 'சுபம்', iconEmoji: '💍'),
    GpThithiItem(number: 11, paksha: 'வளர்பிறை', name: 'வ. ஏகாதசி', effect: 'சுபம்', isGood: true, status: 'சுபம்', iconEmoji: '✨'),
    GpThithiItem(number: 12, paksha: 'வளர்பிறை', name: 'வ. துவாதசி', effect: 'செல்வம்', isGood: true, status: 'சுபம்', iconEmoji: '💰'),
    GpThithiItem(number: 13, paksha: 'வளர்பிறை', name: 'வ. திரியோதசி', effect: 'அதிர்ஷ்டம்', isGood: true, status: 'சுபம்', iconEmoji: '🍀'),
    GpThithiItem(number: 14, paksha: 'வளர்பிறை', name: 'வ. சதுர்த்தசி', effect: 'மத்திமம்', isGood: false, status: 'மத்திமம்', iconEmoji: '⚖️'),
    GpThithiItem(number: 15, paksha: 'வளர்பிறை', name: 'பௌர்ணமி', effect: 'நன்மை', isGood: true, status: 'உத்தமம்', iconEmoji: '🌕'),

    // தேய்பிறை (16 - 30)
    GpThithiItem(number: 16, paksha: 'தேய்பிறை', name: 'தே. பிரதமை', effect: 'மத்திமம் சுபம்', isGood: true, status: 'மத்திமம்', iconEmoji: '🌖'),
    GpThithiItem(number: 17, paksha: 'தேய்பிறை', name: 'தே. துவிதியை', effect: 'சந்தோஷம்', isGood: true, status: 'மத்திமம்', iconEmoji: '🌖'),
    GpThithiItem(number: 18, paksha: 'தேய்பிறை', name: 'தே. திருதியை', effect: 'வெற்றி', isGood: true, status: 'மத்திமம்', iconEmoji: '🌖'),
    GpThithiItem(number: 19, paksha: 'தேய்பிறை', name: 'தே. சதுர்த்தி', effect: 'துன்பம்', isGood: false, status: 'அதமம்', iconEmoji: '🌑'),
    GpThithiItem(number: 20, paksha: 'தேய்பிறை', name: 'தே. பஞ்சமி', effect: 'புத்திரபாக்கியம்', isGood: true, status: 'மத்திமம்', iconEmoji: '🌖'),
    GpThithiItem(number: 21, paksha: 'தேய்பிறை', name: 'தே. சஷ்டி', effect: 'நலம்', isGood: true, status: 'மத்திமம்', iconEmoji: '🌖'),
    GpThithiItem(number: 22, paksha: 'தேய்பிறை', name: 'தே. சப்தமி', effect: 'யோகம்', isGood: true, status: 'மத்திமம்', iconEmoji: '🌖'),
    GpThithiItem(number: 23, paksha: 'தேய்பிறை', name: 'தே. அஷ்டமி', effect: 'துன்பம்', isGood: false, status: 'அதமம்', iconEmoji: '🌑'),
    GpThithiItem(number: 24, paksha: 'தேய்பிறை', name: 'தே. நவமி', effect: 'தீமை', isGood: false, status: 'அதமம்', iconEmoji: '❌'),
    GpThithiItem(number: 25, paksha: 'தேய்பிறை', name: 'தே. தசமி', effect: 'மாங்கல்யம்', isGood: true, status: 'மத்திமம்', iconEmoji: '💍'),
    GpThithiItem(number: 26, paksha: 'தேய்பிறை', name: 'தே. ஏகாதசி', effect: 'சுபம்', isGood: true, status: 'மத்திமம்', iconEmoji: '✨'),
    GpThithiItem(number: 27, paksha: 'தேய்பிறை', name: 'தே. துவாதசி', effect: 'செல்வம்', isGood: true, status: 'மத்திமம்', iconEmoji: '💰'),
    GpThithiItem(number: 28, paksha: 'தேய்பிறை', name: 'தே. திரியோதசி', effect: 'அதிர்ஷ்டம்', isGood: true, status: 'மத்திமம்', iconEmoji: '🍀'),
    GpThithiItem(number: 29, paksha: 'தேய்பிறை', name: 'தே. சதுர்த்தசி', effect: 'மத்திமம்', isGood: false, status: 'மத்திமம்', iconEmoji: '⚖️'),
    GpThithiItem(number: 30, paksha: 'தேய்பிறை', name: 'அமாவாசை', effect: 'தீமை', isGood: false, status: 'அதமம்', iconEmoji: '🌑'),
  ];

  /// All 12 Rasi (10. இராசி பலன்கள்) definitions
  static const List<GpRasiItem> rasiList = [
    GpRasiItem(
      number: 1,
      name: 'மேஷம்',
      shortName: 'மே',
      effect: 'குடும்ப விருத்தி / நோய் உண்டாகும்',
      isGood: true,
      status: 'சுபம் / கவனம்',
      iconEmoji: '♈',
    ),
    GpRasiItem(
      number: 2,
      name: 'ரிஷபம்',
      shortName: 'ரி',
      effect: 'பெருமை / நன்மை உண்டாகும்',
      isGood: true,
      status: 'சுபம் (பெருமை)',
      iconEmoji: '♉',
    ),
    GpRasiItem(
      number: 3,
      name: 'மிதுனம்',
      shortName: 'மி',
      effect: 'தனம்; தானிய தானியம் மதியமாக உண்டாகும்',
      isGood: true,
      status: 'சுபம் (தன தானியம்)',
      iconEmoji: '♊',
    ),
    GpRasiItem(
      number: 4,
      name: 'கடகம்',
      shortName: 'க',
      effect: 'வெற்றி / சுபம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (வெற்றி)',
      iconEmoji: '♋',
    ),
    GpRasiItem(
      number: 5,
      name: 'சிம்மம்',
      shortName: 'சி',
      effect: 'செல்வம் / மதிப்பு உண்டாகும்',
      isGood: true,
      status: 'சுபம் (செல்வம்/மதிப்பு)',
      iconEmoji: '♌',
    ),
    GpRasiItem(
      number: 6,
      name: 'கன்னி',
      shortName: 'கன்',
      effect: 'யோகம் / ஞானம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (யோகம்/ஞானம்)',
      iconEmoji: '♍',
    ),
    GpRasiItem(
      number: 7,
      name: 'துலாம்',
      shortName: 'து',
      effect: 'செல்வம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (செல்வம்)',
      iconEmoji: '♎',
    ),
    GpRasiItem(
      number: 8,
      name: 'விருச்சிகம்',
      shortName: 'வி',
      effect: 'நன்மை தீமை பெருந்தாமல் நடுநிலைமை நடக்கும்',
      isGood: true,
      status: 'மத்திமம் (நடுநிலை)',
      iconEmoji: '♏',
    ),
    GpRasiItem(
      number: 9,
      name: 'தனுசு',
      shortName: 'த',
      effect: 'வரவு / செலவு சமமாய் இருக்கும்',
      isGood: true,
      status: 'மத்திமம் (சமநிலை)',
      iconEmoji: '♐',
    ),
    GpRasiItem(
      number: 10,
      name: 'மகரம்',
      shortName: 'ம',
      effect: 'பொருள் / மகிழ்ச்சி உண்டாகும்',
      isGood: true,
      status: 'சுபம் (மகிழ்ச்சி)',
      iconEmoji: '♑',
    ),
    GpRasiItem(
      number: 11,
      name: 'கும்பம்',
      shortName: 'கும்',
      effect: 'இன்பம் மற்றும் துன்பம் சமமாய் இருக்கும்',
      isGood: true,
      status: 'மத்திமம் (இன்ப துன்பம்)',
      iconEmoji: '♒',
    ),
    GpRasiItem(
      number: 12,
      name: 'மீனம்',
      shortName: 'மீ',
      effect: 'வெற்றி தாமதமாய் கிடைக்கும்',
      isGood: true,
      status: 'மத்திமம் (தாமத வெற்றி)',
      iconEmoji: '♓',
    ),
  ];

  /// All 12 Purusha Rasi (12. புருஷ இராசி பலன்கள்) definitions
  static const List<GpPurushaRasiItem> purushaRasiList = [
    GpPurushaRasiItem(
      number: 1,
      name: 'மேஷம்',
      shortName: 'மே',
      rasiType: 'சர இராசி',
      effect: 'சர இராசி — நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '♈',
    ),
    GpPurushaRasiItem(
      number: 2,
      name: 'ரிஷபம்',
      shortName: 'ரி',
      rasiType: 'ஸ்திர இராசி',
      effect: 'ஸ்திர இராசி — தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '♉',
    ),
    GpPurushaRasiItem(
      number: 3,
      name: 'மிதுனம்',
      shortName: 'மி',
      rasiType: 'உபய இராசி',
      effect: 'உபய இராசி — நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '♊',
    ),
    GpPurushaRasiItem(
      number: 4,
      name: 'கடகம்',
      shortName: 'கட',
      rasiType: 'சர இராசி',
      effect: 'சர இராசி — நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '♋',
    ),
    GpPurushaRasiItem(
      number: 5,
      name: 'சிம்மம்',
      shortName: 'சி',
      rasiType: 'ஸ்திர இராசி',
      effect: 'ஸ்திர இராசி — தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '♌',
    ),
    GpPurushaRasiItem(
      number: 6,
      name: 'கன்னி',
      shortName: 'கன்',
      rasiType: 'உபய இராசி',
      effect: 'உபய இராசி — நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '♍',
    ),
    GpPurushaRasiItem(
      number: 7,
      name: 'துலாம்',
      shortName: 'து',
      rasiType: 'சர இராசி',
      effect: 'சர இராசி — நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '♎',
    ),
    GpPurushaRasiItem(
      number: 8,
      name: 'விருச்சிகம்',
      shortName: 'வி',
      rasiType: 'ஸ்திர இராசி',
      effect: 'ஸ்திர இராசி — தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '♏',
    ),
    GpPurushaRasiItem(
      number: 9,
      name: 'தனுசு',
      shortName: 'த',
      rasiType: 'உபய இராசி',
      effect: 'உபய இராசி — நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '♐',
    ),
    GpPurushaRasiItem(
      number: 10,
      name: 'மகரம்',
      shortName: 'ம',
      rasiType: 'சர இராசி',
      effect: 'சர இராசி — நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '♑',
    ),
    GpPurushaRasiItem(
      number: 11,
      name: 'கும்பம்',
      shortName: 'கு',
      rasiType: 'ஸ்திர இராசி',
      effect: 'ஸ்திர இராசி — தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '♒',
    ),
    GpPurushaRasiItem(
      number: 12,
      name: 'மீனம்',
      shortName: 'மீ',
      rasiType: 'உபய இராசி',
      effect: 'உபய இராசி — நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '♓',
    ),
  ];

  /// All 5 Boothams (13. பூதம் பலன்கள்) definitions
  static const List<GpBoothamsItem> boothamsList = [
    GpBoothamsItem(
      number: 1,
      name: 'நிலம் (பூமி)',
      tamilElementName: 'பூமி தத்துவம்',
      effect: 'செல்வம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (செல்வம்)',
      iconEmoji: '🌍',
    ),
    GpBoothamsItem(
      number: 2,
      name: 'நீர் (அப்பு)',
      tamilElementName: 'ஜல தத்துவம்',
      effect: 'காரிய வெற்றி உண்டாகும்',
      isGood: true,
      status: 'சுபம் (காரிய வெற்றி)',
      iconEmoji: '💧',
    ),
    GpBoothamsItem(
      number: 3,
      name: 'நெருப்பு (தேயு)',
      tamilElementName: 'அக்னி தத்துவம்',
      effect: 'பயம் உண்டாகும்',
      isGood: false,
      status: 'தீமை (பயம்)',
      iconEmoji: '🔥',
    ),
    GpBoothamsItem(
      number: 4,
      name: 'காற்று (வாயு)',
      tamilElementName: 'வாயு தத்துவம்',
      effect: 'நன்மை உண்டாகும்',
      isGood: true,
      status: 'சுபம் (நன்மை)',
      iconEmoji: '💨',
    ),
    GpBoothamsItem(
      number: 5,
      name: 'ஆகாயம் (விண்)',
      tamilElementName: 'ஆகாச தத்துவம்',
      effect: 'விரையம் உண்டாகும்',
      isGood: false,
      status: 'தீமை (விரையம்)',
      iconEmoji: '🌌',
    ),
  ];

  /// All 5 Soothirams (14. சூத்திரம் பலன்கள்) definitions
  static const List<GpSoothiramItem> soothiramList = [
    GpSoothiramItem(
      number: 1,
      name: 'பால சூத்திரம்',
      effect: 'உத்தமம் (உத்தம சுப நலம் உண்டாகும்)',
      isGood: true,
      status: 'உத்தமம்',
      iconEmoji: '✨',
    ),
    GpSoothiramItem(
      number: 2,
      name: 'யௌவன சூத்திரம்',
      effect: 'சுபம் (சுப மங்கல விருத்தி உண்டாகும்)',
      isGood: true,
      status: 'சுபம்',
      iconEmoji: '🌟',
    ),
    GpSoothiramItem(
      number: 3,
      name: 'கௌமார சூத்திரம்',
      effect: 'நன்மை (சகல காரிய நன்மை உண்டாகும்)',
      isGood: true,
      status: 'நன்மை',
      iconEmoji: '🏹',
    ),
    GpSoothiramItem(
      number: 4,
      name: 'விருத்த சூத்திரம்',
      effect: 'துன்பம் (துன்பம் / மன சஞ்சலம் உண்டாகும்)',
      isGood: false,
      status: 'துன்பம் (மத்திமம்)',
      iconEmoji: '🍂',
    ),
    GpSoothiramItem(
      number: 5,
      name: 'மரண சூத்திரம்',
      effect: 'பயம் (அச்சம் / பயம் உண்டாகும்)',
      isGood: false,
      status: 'பயம் (தீமை)',
      iconEmoji: '⚡',
    ),
  ];

  /// Get Garbham from Ayadi Number (ஆயாதி எண் % 8; மீதம் 0 வந்தால் 8)
  static GpGarbhamItem getGarbhamByAyadi(int ayadiNumber) {
    int rem = ayadiNumber % 8;
    if (rem == 0) rem = 8;
    return garbhamList[rem - 1];
  }

  /// Get Aadhayam from Ayadi Number ((ஆயாதி எண் * 8) % 12; மீதம் 0 வந்தால் 12)
  static GpAadhayamItem getAadhayamByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 8;
    int rem = total % 12;
    if (rem == 0) rem = 12;
    return aadhayamList[rem - 1];
  }

  /// Get Virayam from Ayadi Number ((ஆயாதி எண் * 9) % 10; மீதம் 0 வந்தால் 10)
  static GpVirayamItem getVirayamByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 9;
    int rem = total % 10;
    if (rem == 0) rem = 10;
    return virayamList[rem - 1];
  }

  /// Get Yoni from Ayadi Number ((ஆயாதி எண் * 3) % 8; மீதம் 0 வந்தால் 8)
  static GpYoniItem getYoniByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 3;
    int rem = total % 8;
    if (rem == 0) rem = 8;
    return yoniList[rem - 1];
  }

  /// Get Vaaram from Ayadi Number ((ஆயாதி எண் * 9) % 7; மீதம் 0 வந்தால் 7)
  static GpVaaraItem getVaaraByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 9;
    int rem = total % 7;
    if (rem == 0) rem = 7;
    return vaaraList[rem - 1];
  }

  /// Get Amsam from Ayadi Number ((ஆயாதி எண் * 4) % 9; மீதம் 0 வந்தால் 9)
  static GpAmsaItem getAmsaByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 4;
    int rem = total % 9;
    if (rem == 0) rem = 9;
    return amsaList[rem - 1];
  }

  /// Get Nakshatram from Ayadi Number ((ஆயாதி எண் * 8) % 27; மீதம் 0 வந்தால் 27)
  static GpVaasthuNakshatraItem getNakshatraByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 8;
    int rem = total % 27;
    if (rem == 0) rem = 27;
    return nakshatraList[rem - 1];
  }

  /// Get Vamsam from Ayadi Number ((ஆயாதி எண் * 9) % 4; மீதம் 0 வந்தால் 4)
  static GpVamsamItem getVamsamByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 9;
    int rem = total % 4;
    if (rem == 0) rem = 4;
    return vamsamList[rem - 1];
  }

  /// Get Thithi Method 1 from Ayadi Number ((ஆயாதி எண் * 4) % 30; மீதம் 0 வந்தால் 30)
  static GpThithiItem getThithi1ByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 4;
    int rem = total % 30;
    if (rem == 0) rem = 30;
    return thithiList[rem - 1];
  }

  /// Get Thithi Method 2 from Ayadi Number ((ஆயாதி எண் * 9) % 30; மீதம் 0 வந்தால் 30)
  static GpThithiItem getThithi2ByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 9;
    int rem = total % 30;
    if (rem == 0) rem = 30;
    return thithiList[rem - 1];
  }

  /// Get Rasi from Ayadi Number ((ஆயாதி எண் * 4) % 12; மீதம் 0 வந்தால் 12)
  static GpRasiItem getRasiByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 4;
    int rem = total % 12;
    if (rem == 0) rem = 12;
    return rasiList[rem - 1];
  }

  /// Get Age from Ayadi Number ((ஆயாதி எண் * 27) % 100; மீதம் 0 வந்தால் 100)
  static GpAgeItem getAgeByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 27;
    int rem = total % 100;
    if (rem == 0) rem = 100;

    if (rem >= 51) {
      return GpAgeItem(
        age: rem,
        category: '51 – 100',
        effect: 'உத்தமம் (தீர்க்காயுள் உண்டாகும்)',
        isGood: true,
        status: 'உத்தமம்',
        iconEmoji: '🛡️',
      );
    } else if (rem >= 28) {
      return GpAgeItem(
        age: rem,
        category: '28 – 50',
        effect: 'மத்திமம் (மத்திம ஆயுள்)',
        isGood: true,
        status: 'மத்திமம்',
        iconEmoji: '⚖️',
      );
    } else {
      return GpAgeItem(
        age: rem,
        category: '1 – 27',
        effect: 'சகல பொருத்தங்கள் இருந்தால் நன்மை, இல்லை என்றால் அதர்மம்',
        isGood: false,
        status: 'மத்திமம் / அதர்மம்',
        iconEmoji: '⚠️',
      );
    }
  }

  /// Get Purusha Rasi from Ayadi Number ((ஆயாதி எண் * 7) % 12; மீதம் 0 வந்தால் 12)
  static GpPurushaRasiItem getPurushaRasiByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 7;
    int rem = total % 12;
    if (rem == 0) rem = 12;
    return purushaRasiList[rem - 1];
  }

  /// Get Boothams Method 1 from Ayadi Number ((ஆயாதி எண் * 3) % 5; மீதம் 0 வந்தால் 5)
  static GpBoothamsItem getBootham1ByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 3;
    int rem = total % 5;
    if (rem == 0) rem = 5;
    return boothamsList[rem - 1];
  }

  /// Get Boothams Method 2 from Ayadi Number ((ஆயாதி எண் * 9) % 5; மீதம் 0 வந்தால் 5)
  static GpBoothamsItem getBootham2ByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 9;
    int rem = total % 5;
    if (rem == 0) rem = 5;
    return boothamsList[rem - 1];
  }

  /// Get Soothiram from Ayadi Number ((ஆயாதி எண் * 7) % 5; மீதம் 0 வந்தால் 5)
  static GpSoothiramItem getSoothiramByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 7;
    int rem = total % 5;
    if (rem == 0) rem = 5;
    return soothiramList[rem - 1];
  }

  /// Compare House Gana with Owner Gana (11. கணப் பலன் ஒப்பீடு)
  static Map<String, dynamic> evaluateGanaMatch(String houseGana, String ownerGana) {
    if (houseGana == ownerGana) {
      return {
        'status': 'உத்தமம் (நலம்)',
        'isGood': true,
        'effect': 'தலைவன் (எஜமானன்) கணமும் மனையின் கணமும் ஒன்றாகில் நலம் உண்டாகும்.',
      };
    }
    if ((houseGana == 'தேவ கணம்' && ownerGana == 'மனித கணம்') ||
        (houseGana == 'மனித கணம்' && ownerGana == 'தேவ கணம்')) {
      return {
        'status': 'உத்தமம்',
        'isGood': true,
        'effect': 'தேவகணமும் மனிதகணமும் வந்தால் உத்தம பலன் உண்டாகும்.',
      };
    }
    if ((houseGana == 'ராட்சச கணம்' && ownerGana == 'மனித கணம்') ||
        (houseGana == 'மனித கணம்' && ownerGana == 'ராட்சச கணம்')) {
      return {
        'status': 'உத்தமம் (மகிமை)',
        'isGood': true,
        'effect': 'ராட்சஸகணமும் மனிதகணமும் வந்தால் மகிமையுண்டாகும்.',
      };
    }
    if ((houseGana == 'ராட்சச கணம்' && ownerGana == 'தேவ கணம்') ||
        (houseGana == 'தேவ கணம்' && ownerGana == 'ராட்சச கணம்')) {
      return {
        'status': 'அதமம் (பகை)',
        'isGood': false,
        'effect': 'ராட்சஸகணமும் தேவகணமும் வந்தால் பகையும் சத்துருக்களால் எக்காலத்திலும் கஷ்டமும் ஏற்படும்.',
      };
    }
    return {
      'status': 'மத்திமம்',
      'isGood': true,
      'effect': 'சாதாரண பலன் உண்டாகும்.',
    };
  }

  /// Calculate Nethiram (15. நேத்திர பலன்)
  /// வார எண் (1 ஞா .. 7 சனி) * 3 = வார நட்சத்திர எண் (1 அசுவினி .. 27 ரேவதி)
  /// அதற்கு அடுத்த நட்சத்திரத்திலிருந்து:
  /// - முதல் 9 நட்சத்திரங்கள்: 1 கண் (மத்திமம்)
  /// - அடுத்த 12 நட்சத்திரங்கள்: 2 கண் (உத்தமம்)
  /// - அடுத்த 6 நட்சத்திரங்கள்: 0 கண் (தீமை / அதமம்)
  static GpNethiramItem calculateNethiram(int vaaraNumber, int houseNakshatraNumber) {
    int baseStar = (vaaraNumber * 3) % 27;
    if (baseStar == 0) baseStar = 27;

    final String baseStarName = nakshatraList[baseStar - 1].name;

    // Range 1 (முதல் 9 நட்சத்): Starts from NEXT star after (vaaraNumber * 3)
    int start1 = (baseStar % 27) + 1;
    int end1 = (start1 + 8) % 27;
    if (end1 == 0) end1 = 27;

    // Range 2 (அடுத்த 12 நட்சத்): Starts from NEXT star after end1
    int start2 = (end1 % 27) + 1;
    int end2 = (start2 + 11) % 27;
    if (end2 == 0) end2 = 27;

    // Range 3 (கடைசி 6 நட்சத்): Starts from NEXT star after end2
    int start3 = (end2 % 27) + 1;
    int end3 = (start3 + 5) % 27;
    if (end3 == 0) end3 = 27;

    // Distance from start1 to houseNakshatraNumber (1-based index 1..27)
    int distance = (houseNakshatraNumber - start1) % 27;
    if (distance < 0) distance += 27;
    int starIndex = distance + 1;

    final String range1Desc = '$start1 ${nakshatraList[start1 - 1].name} முதல் $end1 ${nakshatraList[end1 - 1].name} வரை (9 நட்சத்)';
    final String range2Desc = '$start2 ${nakshatraList[start2 - 1].name} முதல் $end2 ${nakshatraList[end2 - 1].name} வரை (12 நட்சத்)';
    final String range3Desc = '$start3 ${nakshatraList[start3 - 1].name} முதல் $end3 ${nakshatraList[end3 - 1].name} வரை (6 நட்சத்)';

    if (starIndex <= 9) {
      return GpNethiramItem(
        eyes: 1,
        title: '1 – கண் (ஒற்றைக் கண்)',
        effect: 'மத்திம பலன் உண்டாகும் (சுபமும் அசுபமும் கலந்த பலன்)',
        isGood: true,
        status: 'மத்திமம் (1 கண்)',
        iconEmoji: '👁️',
        startStarNumber: baseStar,
        startStarName: baseStarName,
        range1Description: range1Desc,
        range2Description: range2Desc,
        range3Description: range3Desc,
        matchedRange: 'பிரிவு 1 ($range1Desc — 1 கண்)',
      );
    } else if (starIndex <= 21) {
      return GpNethiramItem(
        eyes: 2,
        title: '2 – கண் (இரட்டைக் கண்)',
        effect: 'உத்தம சுப நலம் உண்டாகும் (முழுமையான சுப பலன் மற்றும் சகல நன்மைகள்)',
        isGood: true,
        status: 'உத்தமம் (2 கண்)',
        iconEmoji: '👀',
        startStarNumber: baseStar,
        startStarName: baseStarName,
        range1Description: range1Desc,
        range2Description: range2Desc,
        range3Description: range3Desc,
        matchedRange: 'பிரிவு 2 ($range2Desc — 2 கண்)',
      );
    } else {
      return GpNethiramItem(
        eyes: 0,
        title: '0 – கண் (கண் இல்லை / குருடு)',
        effect: 'அதம தீய பலன் உண்டாகும் (பயம் மற்றும் தன நஷ்டம்)',
        isGood: false,
        status: 'தீமை / அதமம் (0 கண்)',
        iconEmoji: '🕶️',
        startStarNumber: baseStar,
        startStarName: baseStarName,
        range1Description: range1Desc,
        range2Description: range2Desc,
        range3Description: range3Desc,
        matchedRange: 'பிரிவு 3 ($range3Desc — 0 கண்)',
      );
    }
  }

  /// 22. அமிர்தாதி யோகங்கள் அறியும் அட்டவணை (27 Nakshatras x 7 Weekdays)
  /// Weekdays: [ஞாயிறு (0), திங்கள் (1), செவ்வாய் (2), புதன் (3), வியாழன் (4), வெள்ளி (5), சனி (6)]
  /// Codes: 'அ' = அமிர்த யோகம், 'சி' = சித்த யோகம், 'ம' = மரண யோகம், 'பி' = பிரபலாரிஷ்ட யோகம்
  static const List<List<String>> amirthathiYogaMatrix = [
    // 1. அசுவினி
    ['சி', 'சி', 'சி', 'ம', 'அ', 'அ', 'சி'],
    // 2. பரணி
    ['பி', 'சி', 'சி', 'சி', 'சி', 'சி', 'சி'],
    // 3. கார்த்திகை
    ['சி', 'ம', 'சி', 'அ', 'ம', 'சி', 'சி'],
    // 4. ரோகிணி
    ['சி', 'அ', 'அ', 'சி', 'ம', 'ம', 'அ'],
    // 5. மிருகசீரிடம்
    ['சி', 'சி', 'சி', 'சி', 'ம', 'சி', 'சி'],
    // 6. திருவாதிரை
    ['சி', 'சி', 'ம', 'சி', 'ம', 'சி', 'சி'],
    // 7. புனர்பூசம்
    ['சி', 'அ', 'சி', 'சி', 'அ', 'சி', 'சி'],
    // 8. பூசம்
    ['சி', 'சி', 'சி', 'சி', 'சி', 'ம', 'சி'],
    // 9. ஆயில்யம்
    ['சி', 'சி', 'சி', 'சி', 'சி', 'ம', 'ம'],
    // 10. மகம்
    ['ம', 'ம', 'சி', 'சி', 'அ', 'ம', 'அ'],
    // 11. பூரம்
    ['சி', 'சி', 'சி', 'அ', 'ம', 'அ', 'சி'],
    // 12. உத்திரம்
    ['அ', 'சி', 'அ', 'அ', 'சி', 'சி', 'ம'],
    // 13. அஸ்தம்
    ['சி', 'சி', 'சி', 'ம', 'சி', 'அ', 'ம'],
    // 14. சித்திரை
    ['சி', 'பி', 'சி', 'சி', 'சி', 'சி', 'ம'],
    // 15. சுவாதி
    ['சி', 'அ', 'சி', 'சி', 'அ', 'சி', 'சி'],
    // 16. விசாகம்
    ['ம', 'ம', 'ம', 'சி', 'சி', 'சி', 'சி'],
    // 17. அனுஷம்
    ['ம', 'சி', 'சி', 'சி', 'சி', 'சி', 'சி'],
    // 18. கேட்டை
    ['ம', 'சி', 'ம', 'சி', 'பி', 'ம', 'சி'],
    // 19. மூலம்
    ['அ', 'சி', 'அ', 'ம', 'சி', 'அ', 'சி'],
    // 20. பூராடம்
    ['சி', 'ம', 'சி', 'அ', 'சி', 'பி', 'சி'],
    // 21. உத்திராடம்
    ['அ', 'ம', 'பி', 'அ', 'சி', 'சி', 'சி'],
    // 22. திருவோணம்
    ['அ', 'அ', 'சி', 'சி', 'சி', 'ம', 'சி'],
    // 23. அவிட்டம்
    ['ம', 'சி', 'சி', 'பி', 'சி', 'சி', 'சி'],
    // 24. சதயம்
    ['சி', 'சி', 'ம', 'சி', 'ம', 'சி', 'அ'],
    // 25. பூரட்டாதி
    ['சி', 'ம', 'ம', 'அ', 'சி', 'சி', 'ம'],
    // 26. உத்திரட்டாதி
    ['அ', 'சி', 'அ', 'சி', 'சி', 'சி', 'சி'],
    // 27. ரேவதி
    ['அ', 'சி', 'சி', 'ம', 'சி', 'சி', 'பி'],
  ];

  /// Calculate Amirthathi Yogam (16. அமிர்தாதி யோக பலன்கள்)
  /// vaaraNumber: 1 (ஞாயிறு) .. 7 (சனி)
  /// nakshatraNumber: 1 (அசுவினி) .. 27 (ரேவதி)
  static GpAmirthathiYogaItem calculateAmirthathiYoga(int vaaraNumber, int nakshatraNumber) {
    final int safeVaara = vaaraNumber.clamp(1, 7);
    final int safeStar = nakshatraNumber.clamp(1, 27);
    final String code = amirthathiYogaMatrix[safeStar - 1][safeVaara - 1];
    final String dayName = vaaraList[safeVaara - 1].dayName;
    final String starName = nakshatraList[safeStar - 1].name;

    switch (code) {
      case 'அ':
        return GpAmirthathiYogaItem(
          code: 'அ',
          name: 'அமிர்த யோகம்',
          effect: 'மிகுந்த சுப நலன்கள், காரிய சித்தி மற்றும் சகல சௌபாக்கியங்கள் தரும்.',
          isGood: true,
          status: 'உத்தமம் (சுபம்)',
          iconEmoji: '✨',
          vaaraNumber: safeVaara,
          vaaraDayName: dayName,
          nakshatraNumber: safeStar,
          nakshatraName: starName,
        );
      case 'சி':
        return GpAmirthathiYogaItem(
          code: 'சி',
          name: 'சித்த யோகம்',
          effect: 'எண்ணிய காரியம் நிறைவேறும், சுப பலன்கள் மற்றும் தன லாபம் பெருகும்.',
          isGood: true,
          status: 'உத்தமம் (சுபம்)',
          iconEmoji: '🌟',
          vaaraNumber: safeVaara,
          vaaraDayName: dayName,
          nakshatraNumber: safeStar,
          nakshatraName: starName,
        );
      case 'ம':
        return GpAmirthathiYogaItem(
          code: 'ம',
          name: 'மரண யோகம்',
          effect: 'தீமை, காரியத் தடை, தன நஷ்டம் மற்றும் அசுப பலன்கள் தரும்.',
          isGood: false,
          status: 'தீமை / அதமம் (அசுபம்)',
          iconEmoji: '⚠️',
          vaaraNumber: safeVaara,
          vaaraDayName: dayName,
          nakshatraNumber: safeStar,
          nakshatraName: starName,
        );
      case 'பி':
      default:
        return GpAmirthathiYogaItem(
          code: 'பி',
          name: 'பிரபலாரிஷ்ட யோகம்',
          effect: 'கிழமை பிறந்த நட்சத்திர தோஷம், விரையம் மற்றும் அதர்ம தீய பலன்கள் தரும்.',
          isGood: false,
          status: 'தீமை / அதமம் (அசுபம்)',
          iconEmoji: '❌',
          vaaraNumber: safeVaara,
          vaaraDayName: dayName,
          nakshatraNumber: safeStar,
          nakshatraName: starName,
        );
    }
  }

  /// Get Amirthathi Yogam from Ayadi Number
  static GpAmirthathiYogaItem getAmirthathiYogaByAyadi(int ayadiNumber) {
    final vaara = getVaaraByAyadi(ayadiNumber);
    final nak = getNakshatraByAyadi(ayadiNumber);
    return calculateAmirthathiYoga(vaara.number, nak.number);
  }

  /// All 11 Karana (18. கரணப் பலன்) definitions
  static const List<GpKaranaItem> karanaList = [
    GpKaranaItem(
      number: 1,
      name: 'பாவம்',
      effect: 'சுப நலன்கள் மற்றும் தன விருத்தி உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🦁',
    ),
    GpKaranaItem(
      number: 2,
      name: 'பாலவம்',
      effect: 'காரிய சித்தி மற்றும் மகிழ்ச்சி உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🐯',
    ),
    GpKaranaItem(
      number: 3,
      name: 'கௌலவம்',
      effect: 'சுப காரிய வெற்றி மற்றும் செல்வம் பெருகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🐗',
    ),
    GpKaranaItem(
      number: 4,
      name: 'தைதுலை',
      effect: 'சகல நன்மைகள் மற்றும் சௌபாக்கியம் உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🫏',
    ),
    GpKaranaItem(
      number: 5,
      name: 'கரசை',
      effect: 'தன லாபம் மற்றும் தொழில் விருத்தி உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🐘',
    ),
    GpKaranaItem(
      number: 6,
      name: 'வனசை',
      effect: 'காரிய அனுகூலம் மற்றும் சுகம் உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🐂',
    ),
    GpKaranaItem(
      number: 7,
      name: 'பத்திரை / விஷ்டி',
      effect: 'தீமை, பயம் மற்றும் காரியத் தடை உண்டாகும்',
      isGood: false,
      status: 'தீமை (அதமம்)',
      iconEmoji: '🐕',
    ),
    GpKaranaItem(
      number: 8,
      name: 'சகுனி',
      effect: 'தன நஷ்டம் மற்றும் வறுமை உண்டாகும்',
      isGood: false,
      status: 'தீமை (அதமம்)',
      iconEmoji: '🦅',
    ),
    GpKaranaItem(
      number: 9,
      name: 'சதுஷ்பாதம்',
      effect: 'விரையம் மற்றும் மனக்கவலை உண்டாகும்',
      isGood: false,
      status: 'தீமை (அதமம்)',
      iconEmoji: '🐄',
    ),
    GpKaranaItem(
      number: 10,
      name: 'நாகவம்',
      effect: 'சத்துரு பயம் மற்றும் இடர் உண்டாகும்',
      isGood: false,
      status: 'தீமை (அதமம்)',
      iconEmoji: '🐍',
    ),
    GpKaranaItem(
      number: 11,
      name: 'கிமஸ்துக்கினம்',
      effect: 'அசுப பலன்கள் மற்றும் தீமை உண்டாகும்',
      isGood: false,
      status: 'தீமை (அதமம்)',
      iconEmoji: '🐛',
    ),
  ];

  /// All 8 Ashta Lakshmi (20. அஷ்டலட்சுமி பலன்) definitions
  static const List<GpAshtaLakshmiItem> ashtaLakshmiList = [
    GpAshtaLakshmiItem(
      number: 1,
      name: 'இராஜலட்சுமி',
      effect: 'இராஜயோகம் மற்றும் செல்வாக்கு உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '👑',
    ),
    GpAshtaLakshmiItem(
      number: 2,
      name: 'கீர்த்தி லட்சுமி',
      effect: 'புகழ், கீர்த்தி மற்றும் மதிப்பு உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🏆',
    ),
    GpAshtaLakshmiItem(
      number: 3,
      name: 'தன லட்சுமி',
      effect: 'அளவற்ற தனம் மற்றும் செல்வம் பெருகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '💰',
    ),
    GpAshtaLakshmiItem(
      number: 4,
      name: 'தானிய லட்சுமி',
      effect: 'தானிய விருத்தி மற்றும் உணவு வளம் பெருகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🌾',
    ),
    GpAshtaLakshmiItem(
      number: 5,
      name: 'தைரிய லட்சுமி',
      effect: 'அச்சமின்மை, தைரியம் மற்றும் மன உறுதி உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🛡️',
    ),
    GpAshtaLakshmiItem(
      number: 6,
      name: 'வீரிய லட்சுமி',
      effect: 'ஆற்றல், சுறுசுறுப்பு மற்றும் நன்மைகள் உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '⚡',
    ),
    GpAshtaLakshmiItem(
      number: 7,
      name: 'ஜெய லட்சுமி',
      effect: 'சகல காரியங்களிலும் வெற்றி ஜெயம் உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🎯',
    ),
    GpAshtaLakshmiItem(
      number: 8,
      name: 'வர லட்சுமி',
      effect: 'ஞானம், புண்ணியம் மற்றும் தெய்வீக அருள் உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🪷',
    ),
  ];

  /// 19. Chandra Phalan Definitions (12 Results)
  static const List<Map<String, dynamic>> chandraPhalanDefinitions = [
    {'name': 'தேக சௌக்கியம்', 'effect': 'உடல் ஆரோக்கியம், சௌக்கியம் மற்றும் சுப நலம் உண்டாகும்', 'isGood': true, 'status': 'உத்தமம் (சுபம்)', 'icon': '🧘'},
    {'name': 'உத்தமம்', 'effect': 'சகல செல்வ விருத்தி, நன்மைகள் மற்றும் மகிழ்ச்சி உண்டாகும்', 'isGood': true, 'status': 'உத்தமம் (சுபம்)', 'icon': '💎'},
    {'name': 'இலாபம்', 'effect': 'தன லாபம், பொருள் வரவு மற்றும் நன்மை உண்டாகும்', 'isGood': true, 'status': 'உத்தமம் (சுபம்)', 'icon': '💰'},
    {'name': 'ரோக பயம்', 'effect': 'நோய் அச்சம், உடல் நலிவு மற்றும் கவலை உண்டாகும்', 'isGood': false, 'status': 'தீமை (அதமம்)', 'icon': '🤒'},
    {'name': 'காரிய தடை', 'effect': 'செய்யும் செயல்களில் தடை, தாமதம் உண்டாகும்', 'isGood': false, 'status': 'தீமை (அதமம்)', 'icon': '⛔'},
    {'name': 'சத்துரு நாசம்', 'effect': 'எதிரிகள் அழிந்து வெற்றி மற்றும் நலம் உண்டாகும்', 'isGood': true, 'status': 'உத்தமம் (சுபம்)', 'icon': '⚔️'},
    {'name': 'விருத்தி', 'effect': 'குடும்ப விருத்தி, தன அபிவிருத்தி மற்றும் காரிய ஜெயம் உண்டாகும்', 'isGood': true, 'status': 'உத்தமம் (சுபம்)', 'icon': '📈'},
    {'name': 'உத்தமம்', 'effect': 'சுப யோகம், மங்கள நிகழ்வுகள் மற்றும் நன்மைகள் உண்டாகும்', 'isGood': true, 'status': 'உத்தமம் (சுபம்)', 'icon': '🌟'},
    {'name': 'காரிய தாமதம்', 'effect': 'காரியங்களில் கால தாமதம் மற்றும் மத்திம பலன் உண்டாகும்', 'isGood': false, 'status': 'மத்திமம் / தீமை', 'icon': '⏳'},
    {'name': 'தொழில் விருத்தி', 'effect': 'தொழில் வியாபாரம் மேன்மை அடைந்து லாபம் தரும்', 'isGood': true, 'status': 'உத்தமம் (சுபம்)', 'icon': '🏢'},
    {'name': 'சகலம் சித்தியாகும்', 'effect': 'எண்ணிய யாவும் தடையின்றி முழுமையாக சித்தியாகும்', 'isGood': true, 'status': 'உத்தமம் (சுபம்)', 'icon': '🎯'},
    {'name': 'விரையம்', 'effect': 'வீண் பண விரையம், தன நஷ்டம் மற்றும் இழப்பு உண்டாகும்', 'isGood': false, 'status': 'தீமை (அதமம்)', 'icon': '💸'},
  ];

  /// 21. Panchaka Phalan Definitions (9 Results & Pariharams)
  static const List<Map<String, dynamic>> panchakaDefinitions = [
    {
      'name': 'மரண பஞ்சகம்',
      'effect': 'ஆகாது — மரண பயம் மற்றும் கடும் தீமை தரும்',
      'pariharam': 'இரத்தின தானம்',
      'isGood': false,
      'status': 'தீமை (ஆகாதது)',
      'icon': '⚡',
    },
    {
      'name': 'அக்கினி பஞ்சகம்',
      'effect': 'ஆகாது — அக்கினி பயம் மற்றும் பொருள் நஷ்டம் தரும்',
      'pariharam': 'சந்தனம் தானம்',
      'isGood': false,
      'status': 'தீமை (ஆகாதது)',
      'icon': '🔥',
    },
    {
      'name': 'நிஷ் பஞ்சகம்',
      'effect': 'உத்தம சுப நலம் உண்டாகும் — சகல சுபகாரியங்களுக்கும் சிறந்தது',
      'pariharam': 'சுபம் (பரிகாரம் தேவையில்லை)',
      'isGood': true,
      'status': 'உத்தமம் (நன்மை)',
      'icon': '✨',
    },
    {
      'name': 'இராஜ பஞ்சகம்',
      'effect': 'ஆகாது — அரசு விரோதம் மற்றும் தண்டனை பயம் தரும்',
      'pariharam': 'எலுமிச்சம்பழம் தானம்',
      'isGood': false,
      'status': 'தீமை (ஆகாதது)',
      'icon': '👑',
    },
    {
      'name': 'நிஷ் பஞ்சகம்',
      'effect': 'உத்தம சுப நலம் உண்டாகும் — சகல சுபகாரியங்களுக்கும் சிறந்தது',
      'pariharam': 'சுபம் (பரிகாரம் தேவையில்லை)',
      'isGood': true,
      'status': 'உத்தமம் (நன்மை)',
      'icon': '✨',
    },
    {
      'name': 'சோர பஞ்சகம்',
      'effect': 'ஆகாது — களவு பயம், வஞ்சனை மற்றும் இழப்பு தரும்',
      'pariharam': 'தீபம் தானம்',
      'isGood': false,
      'status': 'தீமை (ஆகாதது)',
      'icon': '🪔',
    },
    {
      'name': 'நிஷ் பஞ்சகம்',
      'effect': 'உத்தம சுப நலம் உண்டாகும் — சகல சுபகாரியங்களுக்கும் சிறந்தது',
      'pariharam': 'சுபம் (பரிகாரம் தேவையில்லை)',
      'isGood': true,
      'status': 'உத்தமம் (நன்மை)',
      'icon': '✨',
    },
    {
      'name': 'ரோக பஞ்சகம்',
      'effect': 'ஆகாது — நோய் நொடிகள் மற்றும் உடல் உபாதைகள் தரும்',
      'pariharam': 'உணவு / தானியம் தானம்',
      'isGood': false,
      'status': 'தீமை (ஆகாதது)',
      'icon': '🍲',
    },
    {
      'name': 'நிஷ் பஞ்சகம்',
      'effect': 'உத்தம சுப நலம் உண்டாகும் — சகல சுபகாரியங்களுக்கும் சிறந்தது',
      'pariharam': 'சுபம் (பரிகாரம் தேவையில்லை)',
      'isGood': true,
      'status': 'உத்தமம் (நன்மை)',
      'icon': '✨',
    },
  ];

  /// 17. Calculate Thara Phalan
  static GpTharaPhalanItem calculateTharaPhalan({
    required int ownerNakshatra,
    required int houseNakshatra,
  }) {
    final int safeOwner = ownerNakshatra.clamp(1, 27);
    final int safeHouse = houseNakshatra.clamp(1, 27);
    final int count = ((safeOwner - safeHouse + 27) % 27) + 1;
    final int rem = count % 9;
    final int tharaIndex = rem == 0 ? 9 : rem;

    final String ownerStarName = nakshatraList[safeOwner - 1].name;
    final String houseStarName = nakshatraList[safeHouse - 1].name;

    switch (tharaIndex) {
      case 1:
        return GpTharaPhalanItem(
          count: count,
          remainder: rem,
          tharaName: 'ஜென்ம தாரை',
          effect: 'சரீர பீடை, அச்சம் மற்றும் தீய பலன் உண்டாகும்.',
          isGood: false,
          status: 'தீமை (அதமம்)',
          iconEmoji: '⚠️',
          ownerNakshatraNumber: safeOwner,
          ownerNakshatraName: ownerStarName,
          houseNakshatraNumber: safeHouse,
          houseNakshatraName: houseStarName,
        );
      case 2:
        return GpTharaPhalanItem(
          count: count,
          remainder: rem,
          tharaName: 'சம்பத்து தாரை',
          effect: 'தன லாபம், செல்வம் மற்றும் சகல சௌபாக்கியங்கள் பெருகும்.',
          isGood: true,
          status: 'உத்தமம் (நன்மை)',
          iconEmoji: '💰',
          ownerNakshatraNumber: safeOwner,
          ownerNakshatraName: ownerStarName,
          houseNakshatraNumber: safeHouse,
          houseNakshatraName: houseStarName,
        );
      case 3:
        return GpTharaPhalanItem(
          count: count,
          remainder: rem,
          tharaName: 'விபத்து தாரை',
          effect: 'காரிய நஷ்டம், விபத்து பயம் மற்றும் துன்பம் உண்டாகும்.',
          isGood: false,
          status: 'தீமை (அதமம்)',
          iconEmoji: '❌',
          ownerNakshatraNumber: safeOwner,
          ownerNakshatraName: ownerStarName,
          houseNakshatraNumber: safeHouse,
          houseNakshatraName: houseStarName,
        );
      case 4:
        return GpTharaPhalanItem(
          count: count,
          remainder: rem,
          tharaName: 'க்ஷேம தாரை',
          effect: 'க்ஷேமம், சுகம், மகிழ்ச்சி மற்றும் நன்மைகள் உண்டாகும்.',
          isGood: true,
          status: 'உத்தமம் (நன்மை)',
          iconEmoji: '🛡️',
          ownerNakshatraNumber: safeOwner,
          ownerNakshatraName: ownerStarName,
          houseNakshatraNumber: safeHouse,
          houseNakshatraName: houseStarName,
        );
      case 5:
        return GpTharaPhalanItem(
          count: count,
          remainder: rem,
          tharaName: 'பிரத்யக் தாரை',
          effect: 'காரியத் தடை, எதிர்ப்பு மற்றும் விரோதம் உண்டாகும்.',
          isGood: false,
          status: 'தீமை (அதமம்)',
          iconEmoji: '🚫',
          ownerNakshatraNumber: safeOwner,
          ownerNakshatraName: ownerStarName,
          houseNakshatraNumber: safeHouse,
          houseNakshatraName: houseStarName,
        );
      case 6:
        return GpTharaPhalanItem(
          count: count,
          remainder: rem,
          tharaName: 'சாதக தாரை',
          effect: 'எண்ணிய காரியம் சித்தியாகும், காரிய ஜெயம் உண்டாகும்.',
          isGood: true,
          status: 'உத்தமம் (நன்மை)',
          iconEmoji: '🎯',
          ownerNakshatraNumber: safeOwner,
          ownerNakshatraName: ownerStarName,
          houseNakshatraNumber: safeHouse,
          houseNakshatraName: houseStarName,
        );
      case 7:
        return GpTharaPhalanItem(
          count: count,
          remainder: rem,
          tharaName: 'வதை தாரை',
          effect: 'மரண பயம், கடும் துன்பம் மற்றும் இழப்பு உண்டாகும்.',
          isGood: false,
          status: 'தீமை (அதமம்)',
          iconEmoji: '⚡',
          ownerNakshatraNumber: safeOwner,
          ownerNakshatraName: ownerStarName,
          houseNakshatraNumber: safeHouse,
          houseNakshatraName: houseStarName,
        );
      case 8:
        return GpTharaPhalanItem(
          count: count,
          remainder: rem,
          tharaName: 'மைத்ர தாரை',
          effect: 'நட்பு, அமைதி, மகிழ்ச்சி மற்றும் சுப நலன்கள் உண்டாகும்.',
          isGood: true,
          status: 'உத்தமம் (நன்மை)',
          iconEmoji: '🤝',
          ownerNakshatraNumber: safeOwner,
          ownerNakshatraName: ownerStarName,
          houseNakshatraNumber: safeHouse,
          houseNakshatraName: houseStarName,
        );
      case 9:
      default:
        return GpTharaPhalanItem(
          count: count,
          remainder: rem,
          tharaName: 'பரம மைத்ர தாரை',
          effect: 'மிகுந்த நன்மைகள், பேரானந்தம் மற்றும் சகல காரிய வெற்றி தரும்.',
          isGood: true,
          status: 'உத்தமம் (நன்மை)',
          iconEmoji: '✨',
          ownerNakshatraNumber: safeOwner,
          ownerNakshatraName: ownerStarName,
          houseNakshatraNumber: safeHouse,
          houseNakshatraName: houseStarName,
        );
    }
  }

  /// 18. Get Karana from Ayadi Number ((ஆயாதி எண் * 5) % 11; மீதம் 0 என்றால் 11)
  static GpKaranaItem getKaranaByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 5;
    int rem = total % 11;
    if (rem == 0) rem = 11;
    return karanaList[rem - 1];
  }

  /// 19. Calculate Chandra Phalan
  static GpChandraPhalanItem calculateChandraPhalan({
    required int ownerRasi,
    required int houseRasi,
  }) {
    final int safeOwner = ownerRasi.clamp(1, 12);
    final int safeHouse = houseRasi.clamp(1, 12);
    final int num = ((safeHouse - safeOwner + 12) % 12) + 1;
    final def = chandraPhalanDefinitions[num - 1];

    final String ownerRasiName = rasiList[safeOwner - 1].name;
    final String houseRasiName = rasiList[safeHouse - 1].name;

    return GpChandraPhalanItem(
      number: num,
      name: def['name'] as String,
      effect: def['effect'] as String,
      isGood: def['isGood'] as bool,
      status: def['status'] as String,
      iconEmoji: def['icon'] as String,
      ownerRasiNumber: safeOwner,
      ownerRasiName: ownerRasiName,
      houseRasiNumber: safeHouse,
      houseRasiName: houseRasiName,
    );
  }

  /// 20. Get Ashta Lakshmi from Ayadi Number ((ஆயாதி எண் * 3) % 8; மீதம் 0 என்றால் 8)
  static GpAshtaLakshmiItem getAshtaLakshmiByAyadi(int ayadiNumber) {
    int total = ayadiNumber * 3;
    int rem = total % 8;
    if (rem == 0) rem = 8;
    return ashtaLakshmiList[rem - 1];
  }

  /// 21. Calculate Panchaka Phalan (வாரம் + திதி1 + நட்சத்திரம் + மனை ராசி)
  static GpPanchakaItem calculatePanchaka({
    required int vaaraNumber,
    required int thithiNumber,
    required int nakshatraNumber,
    required int rasiNumber,
  }) {
    final int sum = vaaraNumber + thithiNumber + nakshatraNumber + rasiNumber;
    int rem = sum % 9;
    if (rem == 0) rem = 9;
    final def = panchakaDefinitions[rem - 1];

    return GpPanchakaItem(
      number: rem,
      name: def['name'] as String,
      effect: def['effect'] as String,
      pariharam: def['pariharam'] as String,
      isGood: def['isGood'] as bool,
      status: def['status'] as String,
      iconEmoji: def['icon'] as String,
      vaaraNumber: vaaraNumber,
      thithiNumber: thithiNumber,
      nakshatraNumber: nakshatraNumber,
      rasiNumber: rasiNumber,
      totalSum: sum,
    );
  }

  /// All 3 Guna (22. குணப் பலன்) definitions
  static const List<GpGunaItem> gunaList = [
    GpGunaItem(
      number: 1,
      name: 'தீமை',
      effect: 'தீமை உண்டாகும்',
      isGood: false,
      status: 'தீமை (அதமம்)',
      iconEmoji: '❌',
    ),
    GpGunaItem(
      number: 2,
      name: 'செல்வம் விருத்தி',
      effect: 'செல்வம் விருத்தி உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '💰',
    ),
    GpGunaItem(
      number: 3,
      name: 'உடல் ஆரோக்கியம்',
      effect: 'உடல் ஆரோக்கியம் உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🧘',
    ),
  ];

  /// 22. Get Guna from Ayadi Number (ஆயாதி எண் % 3; மீதம் 0 என்றால் 3)
  static GpGunaItem getGunaByAyadi(int ayadiNumber) {
    int rem = ayadiNumber % 3;
    if (rem == 0) rem = 3;
    return gunaList[rem - 1];
  }

  /// All 27 Nama Yogas (23. நாம யோக பலன்கள்)
  static const List<GpNamaYogaItem> namaYogaList = [
    GpNamaYogaItem(
      number: 1,
      name: 'விஷ்கம்பம்',
      effect: 'அதர்மம் / தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '❌',
    ),
    GpNamaYogaItem(
      number: 2,
      name: 'பிரீதி',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '✨',
    ),
    GpNamaYogaItem(
      number: 3,
      name: 'ஆயுஷ்மான்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🌱',
    ),
    GpNamaYogaItem(
      number: 4,
      name: 'சௌபாக்கியம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '👑',
    ),
    GpNamaYogaItem(
      number: 5,
      name: 'சோபனம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🌟',
    ),
    GpNamaYogaItem(
      number: 6,
      name: 'அதிகண்டம்',
      effect: 'அதர்மம் / தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '⚠️',
    ),
    GpNamaYogaItem(
      number: 7,
      name: 'சுகர்மம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🎯',
    ),
    GpNamaYogaItem(
      number: 8,
      name: 'திருதி',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '💎',
    ),
    GpNamaYogaItem(
      number: 9,
      name: 'சூலம்',
      effect: 'அதர்மம் / தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '⚡',
    ),
    GpNamaYogaItem(
      number: 10,
      name: 'கண்டம்',
      effect: 'அதர்மம் / தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '⛔',
    ),
    GpNamaYogaItem(
      number: 11,
      name: 'விருத்தி',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '📈',
    ),
    GpNamaYogaItem(
      number: 12,
      name: 'துருவம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🏛️',
    ),
    GpNamaYogaItem(
      number: 13,
      name: 'வியாகாதம்',
      effect: 'அதர்மம் / தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '🌪️',
    ),
    GpNamaYogaItem(
      number: 14,
      name: 'ஹர்ஷணம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '😊',
    ),
    GpNamaYogaItem(
      number: 15,
      name: 'வஜ்ரம்',
      effect: 'அதர்மம் / தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '🔨',
    ),
    GpNamaYogaItem(
      number: 16,
      name: 'சித்தி',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🏆',
    ),
    GpNamaYogaItem(
      number: 17,
      name: 'வியதீபாதம்',
      effect: 'அதர்மம் / தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '🔥',
    ),
    GpNamaYogaItem(
      number: 18,
      name: 'வரியான்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🌈',
    ),
    GpNamaYogaItem(
      number: 19,
      name: 'பரிகம்',
      effect: 'மத்திமம் / சுபம் உண்டாகும்',
      isGood: true,
      status: 'மத்திமம் (சுபம்)',
      iconEmoji: '⚖️',
    ),
    GpNamaYogaItem(
      number: 20,
      name: 'சிவம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🕉️',
    ),
    GpNamaYogaItem(
      number: 21,
      name: 'சித்தம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '💡',
    ),
    GpNamaYogaItem(
      number: 22,
      name: 'சாத்தியம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🏅',
    ),
    GpNamaYogaItem(
      number: 23,
      name: 'சுபம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🪷',
    ),
    GpNamaYogaItem(
      number: 24,
      name: 'சுப்ரம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🕊️',
    ),
    GpNamaYogaItem(
      number: 25,
      name: 'பிராமியம்',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '🌸',
    ),
    GpNamaYogaItem(
      number: 26,
      name: 'மஹேந்திரம் (ஐந்திரம்)',
      effect: 'உத்தமம் / நன்மை உண்டாகும்',
      isGood: true,
      status: 'உத்தமம் (நன்மை)',
      iconEmoji: '👑',
    ),
    GpNamaYogaItem(
      number: 27,
      name: 'வைதிருதி',
      effect: 'அதர்மம் / தீமை உண்டாகும்',
      isGood: false,
      status: 'அதமம் (தீமை)',
      iconEmoji: '☠️',
    ),
  ];

  /// 23. Get Nama Yoga from Ayadi Number ((ஆயாதி எண் * 4) % 27; மீதம் 0 என்றால் 27)
  static GpNamaYogaItem getNamaYogaByAyadi(int ayadiNumber) {
    final int total = ayadiNumber * 4;
    int rem = total % 27;
    if (rem == 0) rem = 27;
    return namaYogaList[rem - 1];
  }

  /// All 8 Ashta Dikpalakas (24. அஷ்டதிக்கு பாலகர் பலன்கள்)
  static const List<GpDikpalakarItem> dikpalakarList = [
    GpDikpalakarItem(
      number: 1,
      name: 'இந்திரன்',
      direction: 'கிழக்கு',
      effect: 'யோகம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (யோகம்)',
      iconEmoji: '👑',
    ),
    GpDikpalakarItem(
      number: 2,
      name: 'அக்கினி',
      direction: 'தென்கிழக்கு',
      effect: 'வாதை உண்டாகும்',
      isGood: false,
      status: 'தீமை (வாதை)',
      iconEmoji: '🔥',
    ),
    GpDikpalakarItem(
      number: 3,
      name: 'எமன்',
      direction: 'தெற்கு',
      effect: 'மரணம் உண்டாகும்',
      isGood: false,
      status: 'தீமை (மரணம்)',
      iconEmoji: '⚠️',
    ),
    GpDikpalakarItem(
      number: 4,
      name: 'நிருதி',
      direction: 'தென்மேற்கு',
      effect: 'சுகம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (சுகம்)',
      iconEmoji: '✨',
    ),
    GpDikpalakarItem(
      number: 5,
      name: 'வருணன்',
      direction: 'மேற்கு',
      effect: 'இன்பம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (இன்பம்)',
      iconEmoji: '🌊',
    ),
    GpDikpalakarItem(
      number: 6,
      name: 'வாயு',
      direction: 'வடமேற்கு',
      effect: 'தனம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (தனம்)',
      iconEmoji: '💨',
    ),
    GpDikpalakarItem(
      number: 7,
      name: 'குபேரன்',
      direction: 'வடக்கு',
      effect: 'செல்வம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (செல்வம்)',
      iconEmoji: '💰',
    ),
    GpDikpalakarItem(
      number: 8,
      name: 'ஈசானியம்',
      direction: 'வடகிழக்கு',
      effect: 'சந்தோஷம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (சந்தோஷம்)',
      iconEmoji: '🕉️',
    ),
  ];

  /// 24. Get Ashta Dikpalakar from Ayadi Number ((ஆயாதி எண் * 9) % 8; மீதம் 0 என்றால் 8)
  static GpDikpalakarItem getDikpalakarByAyadi(int ayadiNumber) {
    final int total = ayadiNumber * 9;
    int rem = total % 8;
    if (rem == 0) rem = 8;
    return dikpalakarList[rem - 1];
  }

  /// All 8 Athidevathas (25. அதிதேவதை பலன்கள்)
  static const List<GpAthidevathaiItem> athidevathaiList = [
    GpAthidevathaiItem(
      number: 1,
      name: 'இந்திரன்',
      effect: 'யோகம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (யோகம்)',
      iconEmoji: '👑',
    ),
    GpAthidevathaiItem(
      number: 2,
      name: 'அக்கினி',
      effect: 'அவஸ்தை உண்டாகும்',
      isGood: false,
      status: 'தீமை (அவஸ்தை)',
      iconEmoji: '🔥',
    ),
    GpAthidevathaiItem(
      number: 3,
      name: 'எமன்',
      effect: 'மரணம் உண்டாகும்',
      isGood: false,
      status: 'தீமை (மரணம்)',
      iconEmoji: '⚠️',
    ),
    GpAthidevathaiItem(
      number: 4,
      name: 'நிருதி',
      effect: 'சந்தோசம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (சந்தோசம்)',
      iconEmoji: '✨',
    ),
    GpAthidevathaiItem(
      number: 5,
      name: 'வருணன்',
      effect: 'இன்பம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (இன்பம்)',
      iconEmoji: '🌊',
    ),
    GpAthidevathaiItem(
      number: 6,
      name: 'வாயு',
      effect: 'தனம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (தனம்)',
      iconEmoji: '💨',
    ),
    GpAthidevathaiItem(
      number: 7,
      name: 'குபேரன்',
      effect: 'இலாபம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (இலாபம்)',
      iconEmoji: '💰',
    ),
    GpAthidevathaiItem(
      number: 8,
      name: 'ஈசானியம்',
      effect: 'சகல சௌக்கியம் உண்டாகும்',
      isGood: true,
      status: 'சுபம் (சௌக்கியம்)',
      iconEmoji: '🕉️',
    ),
  ];

  /// 25. Get Athidevathai from Age Number ((வயது எண் * 5) % 8; மீதம் 0 என்றால் 8)
  static GpAthidevathaiItem getAthidevathaiByAge(int ageNumber) {
    final int total = ageNumber * 5;
    int rem = total % 8;
    if (rem == 0) rem = 8;
    return athidevathaiList[rem - 1];
  }

  /// Calculate GP Kuzhikanakku and all Vaasthu Poruthams
  static GpKuzhiResult calculateKuzhi({
    required GpVaasthuRegion region,
    required double l1Ft,
    double l1In = 0.0,
    double? l2Ft,
    double? l2In,
    required double w1Ft,
    double w1In = 0.0,
    double? w2Ft,
    double? w2In,
    int ownerNakshatra = 1,
    int ownerRasi = 1,
  }) {
    final double actualL2Ft = l2Ft ?? l1Ft;
    final double actualL2In = l2In ?? l1In;
    final double actualW2Ft = w2Ft ?? w1Ft;
    final double actualW2In = w2In ?? w1In;

    // Convert to decimal feet
    final double totalL1InFeet = l1Ft + (l1In / 12.0);
    final double totalL2InFeet = actualL2Ft + (actualL2In / 12.0);
    final double totalW1InFeet = w1Ft + (w1In / 12.0);
    final double totalW2InFeet = actualW2Ft + (actualW2In / 12.0);

    // Calculate averages & areas
    final double avgLengthFt = (totalL1InFeet + totalL2InFeet) / 2.0;
    final double avgWidthFt = (totalW1InFeet + totalW2InFeet) / 2.0;

    // Area in Sq.Ft and Sq.Inches
    final double sqft = avgLengthFt * avgWidthFt;
    final double sqInches = sqft * 144.0;

    // Kuzhi calculation using regional divisor
    final int divisor = region.constant;
    final double kuzhi = sqInches / divisor;
    final double kuzhiExact = double.parse(kuzhi.toStringAsFixed(3));
    final int roundedKuzhi = kuzhi.round(); // >= 0.5 rounds up, < 0.5 rounds down
    final int wholeKuzhi = kuzhi.floor();
    final double fractionKuzhi = double.parse((kuzhi - wholeKuzhi).toStringAsFixed(3));

    // Ayadi Number calculation:
    // (Sum of Lengths + Sum of Widths) * 12 / Regional Ayadi Divisor (1.333, 1.375, 1.416, 1.500)
    final double perimeterFt = totalL1InFeet + totalL2InFeet + totalW1InFeet + totalW2InFeet;
    final double perimeterInches = perimeterFt * 12.0;
    final double ayadiDivisor = region.ayadiDivisor;
    final double ayadiNumber = perimeterInches / ayadiDivisor;
    final double ayadiExact = double.parse(ayadiNumber.toStringAsFixed(3));
    final int roundedAyadi = ayadiNumber.round();

    // 1. Garbham (கெர்ப்ப எண் = ஆயாதி எண் % 8; மீதம் 0 என்றால் 8)
    int garbhamNum = roundedAyadi % 8;
    if (garbhamNum == 0) garbhamNum = 8;
    final GpGarbhamItem garbham = garbhamList[garbhamNum - 1];

    // 2. Aadhayam (ஆதாயம் எண் = (ஆயாதி எண் * 8) % 12; மீதம் 0 என்றால் 12)
    final int aadhayamTotal = roundedAyadi * 8;
    int aadhayamNum = aadhayamTotal % 12;
    if (aadhayamNum == 0) aadhayamNum = 12;
    final GpAadhayamItem aadhayam = aadhayamList[aadhayamNum - 1];

    // 3. Virayam (விரையம் எண் = (ஆயாதி எண் * 9) % 10; மீதம் 0 என்றால் 10)
    final int virayamTotal = roundedAyadi * 9;
    int virayamNum = virayamTotal % 10;
    if (virayamNum == 0) virayamNum = 10;
    final GpVirayamItem virayam = virayamList[virayamNum - 1];

    // ஆதாயத்தை விட விரையம் குறைவாக இருக்க வேண்டும் (Aadhayam > Virayam is Good)
    final bool isAadhayamGreater = aadhayamNum > virayamNum;

    // 4. Yoni (யோனி எண் = (ஆயாதி எண் * 3) % 8; மீதம் 0 என்றால் 8)
    final int yoniTotal = roundedAyadi * 3;
    int yoniNum = yoniTotal % 8;
    if (yoniNum == 0) yoniNum = 8;
    final GpYoniItem yoni = yoniList[yoniNum - 1];

    // 5. Vaaram (வாரப்பலன் எண் = (ஆயாதி எண் * 9) % 7; மீதம் 0 என்றால் 7)
    final int vaaraTotal = roundedAyadi * 9;
    int vaaraNum = vaaraTotal % 7;
    if (vaaraNum == 0) vaaraNum = 7;
    final GpVaaraItem vaara = vaaraList[vaaraNum - 1];

    // 6. Amsam (அம்ச எண் = (ஆயாதி எண் * 4) % 9; மீதம் 0 என்றால் 9)
    final int amsaTotal = roundedAyadi * 4;
    int amsaNum = amsaTotal % 9;
    if (amsaNum == 0) amsaNum = 9;
    final GpAmsaItem amsa = amsaList[amsaNum - 1];

    // 7. Nakshatram (நட்சத்திர பலன் எண் = (ஆயாதி எண் * 8) % 27; மீதம் 0 என்றால் 27)
    final int nakshatraTotal = roundedAyadi * 8;
    int nakshatraNum = nakshatraTotal % 27;
    if (nakshatraNum == 0) nakshatraNum = 27;
    final GpVaasthuNakshatraItem nakshatra = nakshatraList[nakshatraNum - 1];

    // 8. Vamsam (வம்சம் பலன் எண் = (ஆயாதி எண் * 9) % 4; மீதம் 0 என்றால் 4)
    final int vamsamTotal = roundedAyadi * 9;
    int vamsamNum = vamsamTotal % 4;
    if (vamsamNum == 0) vamsamNum = 4;
    final GpVamsamItem vamsam = vamsamList[vamsamNum - 1];

    // 9. Thithi Method 1 ((ஆயாதி எண் * 4) % 30; மீதம் 0 என்றால் 30)
    final int thithi1Total = roundedAyadi * 4;
    int thithi1Num = thithi1Total % 30;
    if (thithi1Num == 0) thithi1Num = 30;
    final GpThithiItem thithi1 = thithiList[thithi1Num - 1];

    // 9. Thithi Method 2 ((ஆயாதி எண் * 9) % 30; மீதம் 0 என்றால் 30)
    final int thithi2Total = roundedAyadi * 9;
    int thithi2Num = thithi2Total % 30;
    if (thithi2Num == 0) thithi2Num = 30;
    final GpThithiItem thithi2 = thithiList[thithi2Num - 1];

    // 10. Rasi ((ஆயாதி எண் * 4) % 12; மீதம் 0 என்றால் 12)
    final int rasiTotal = roundedAyadi * 4;
    int rasiNum = rasiTotal % 12;
    if (rasiNum == 0) rasiNum = 12;
    final GpRasiItem rasi = rasiList[rasiNum - 1];

    // 10 கூடுதல். Age ((ஆயாதி எண் * 27) % 100; மீதம் 0 என்றால் 100)
    final int ageTotal = roundedAyadi * 27;
    int ageNum = ageTotal % 100;
    if (ageNum == 0) ageNum = 100;
    final GpAgeItem age = getAgeByAyadi(roundedAyadi);

    // 12. Purusha Rasi ((ஆயாதி எண் * 7) % 12; மீதம் 0 என்றால் 12)
    final int purushaRasiTotal = roundedAyadi * 7;
    int purushaRasiNum = purushaRasiTotal % 12;
    if (purushaRasiNum == 0) purushaRasiNum = 12;
    final GpPurushaRasiItem purushaRasi = purushaRasiList[purushaRasiNum - 1];

    // 13. Boothams Method 1 ((ஆயாதி எண் * 3) % 5; மீதம் 0 என்றால் 5)
    final int bootham1Total = roundedAyadi * 3;
    int bootham1Num = bootham1Total % 5;
    if (bootham1Num == 0) bootham1Num = 5;
    final GpBoothamsItem bootham1 = boothamsList[bootham1Num - 1];

    // 13. Boothams Method 2 ((ஆயாதி எண் * 9) % 5; மீதம் 0 என்றால் 5)
    final int bootham2Total = roundedAyadi * 9;
    int bootham2Num = bootham2Total % 5;
    if (bootham2Num == 0) bootham2Num = 5;
    final GpBoothamsItem bootham2 = boothamsList[bootham2Num - 1];

    // 14. Soothiram ((ஆயாதி எண் * 7) % 5; மீதம் 0 என்றால் 5)
    final int soothiramTotal = roundedAyadi * 7;
    int soothiramNum = soothiramTotal % 5;
    if (soothiramNum == 0) soothiramNum = 5;
    final GpSoothiramItem soothiram = soothiramList[soothiramNum - 1];

    // 15. Nethiram (நேத்திர பலன்: வார எண் × 3 முதல் ஆயாதி நட்சத்திரம் வரை)
    final GpNethiramItem nethiram = calculateNethiram(vaaraNum, nakshatraNum);

    // 16. Amirthathi Yogam (அமிர்தாதி யோக பலன்கள்: வாரப்பலன் கிழமை + நட்சத்திர பலன் நட்சத்திரம்)
    final GpAmirthathiYogaItem amirthathiYoga = calculateAmirthathiYoga(vaaraNum, nakshatraNum);

    // 17. Thara Phalan (தாரா பலன்: உரிமையாளர் நட்சத்திரம் முதல் மனை நட்சத்திரம் வரை)
    final GpTharaPhalanItem tharaPhalan = calculateTharaPhalan(
      ownerNakshatra: ownerNakshatra,
      houseNakshatra: nakshatraNum,
    );

    // 18. Karana Phalan (கரணப் பலன்: (ஆயாதி எண் * 5) % 11)
    final int karanaTotal = roundedAyadi * 5;
    int karanaNum = karanaTotal % 11;
    if (karanaNum == 0) karanaNum = 11;
    final GpKaranaItem karana = karanaList[karanaNum - 1];

    // 19. Chandra Phalan (சந்திர பலன்: உரிமையாளர் ராசி முதல் மனை ராசி வரை)
    final GpChandraPhalanItem chandraPhalan = calculateChandraPhalan(
      ownerRasi: ownerRasi,
      houseRasi: rasiNum,
    );

    // 20. Ashta Lakshmi Phalan (அஷ்டலட்சுமி பலன்: (ஆயாதி எண் * 3) % 8)
    final int ashtaLakshmiTotal = roundedAyadi * 3;
    int ashtaLakshmiNum = ashtaLakshmiTotal % 8;
    if (ashtaLakshmiNum == 0) ashtaLakshmiNum = 8;
    final GpAshtaLakshmiItem ashtaLakshmi = ashtaLakshmiList[ashtaLakshmiNum - 1];

    // 21. Panchaka Phalan (பஞ்சகப் பலன்: வாரம் + திதி1 + நட்சத்திரம் + மனை ராசி)
    final GpPanchakaItem panchaka = calculatePanchaka(
      vaaraNumber: vaaraNum,
      thithiNumber: thithi1Num,
      nakshatraNumber: nakshatraNum,
      rasiNumber: rasiNum,
    );

    // 22. Guna Phalan (குணப் பலன்: ஆயாதி எண் % 3; மீதம் 0 என்றால் 3)
    int gunaNum = roundedAyadi % 3;
    if (gunaNum == 0) gunaNum = 3;
    final GpGunaItem guna = gunaList[gunaNum - 1];

    // 23. Nama Yoga Phalan (நாம யோகப் பலன்: (ஆயாதி எண் * 4) % 27; மீதம் 0 என்றால் 27)
    final int namaYogaTotal = roundedAyadi * 4;
    int namaYogaNum = namaYogaTotal % 27;
    if (namaYogaNum == 0) namaYogaNum = 27;
    final GpNamaYogaItem namaYoga = namaYogaList[namaYogaNum - 1];

    // 24. Ashta Dikpalakar Phalan (அஷ்டதிக்கு பாலகர் பலன்: (ஆயாதி எண் * 9) % 8; மீதம் 0 என்றால் 8)
    final int dikpalakarTotal = roundedAyadi * 9;
    int dikpalakarNum = dikpalakarTotal % 8;
    if (dikpalakarNum == 0) dikpalakarNum = 8;
    final GpDikpalakarItem dikpalakar = dikpalakarList[dikpalakarNum - 1];

    // 25. Athidevathai Phalan (அதிதேவதை பலன்: (வயது எண் * 5) % 8; மீதம் 0 என்றால் 8)
    final int athidevathaiTotal = ageNum * 5;
    int athidevathaiNum = athidevathaiTotal % 8;
    if (athidevathaiNum == 0) athidevathaiNum = 8;
    final GpAthidevathaiItem athidevathai = athidevathaiList[athidevathaiNum - 1];

    return GpKuzhiResult(
      region: region,
      length1Ft: l1Ft,
      length1In: l1In,
      length2Ft: actualL2Ft,
      length2In: actualL2In,
      width1Ft: w1Ft,
      width1In: w1In,
      width2Ft: actualW2Ft,
      width2In: actualW2In,
      avgLengthFt: avgLengthFt,
      avgWidthFt: avgWidthFt,
      sqft: sqft,
      sqInches: sqInches,
      divisor: divisor,
      kuzhi: kuzhi,
      kuzhiExact: kuzhiExact,
      roundedKuzhi: roundedKuzhi,
      wholeKuzhi: wholeKuzhi,
      fractionKuzhi: fractionKuzhi,
      perimeterFt: perimeterFt,
      perimeterInches: perimeterInches,
      ayadiDivisor: ayadiDivisor,
      ayadiNumber: ayadiNumber,
      ayadiExact: ayadiExact,
      roundedAyadi: roundedAyadi,
      garbhamNumber: garbhamNum,
      garbham: garbham,
      aadhayamNumber: aadhayamNum,
      aadhayamTotal: aadhayamTotal,
      aadhayam: aadhayam,
      virayamNumber: virayamNum,
      virayamTotal: virayamTotal,
      virayam: virayam,
      isAadhayamGreater: isAadhayamGreater,
      yoniNumber: yoniNum,
      yoniTotal: yoniTotal,
      yoni: yoni,
      vaaraNumber: vaaraNum,
      vaaraTotal: vaaraTotal,
      vaara: vaara,
      amsaNumber: amsaNum,
      amsaTotal: amsaTotal,
      amsa: amsa,
      nakshatraNumber: nakshatraNum,
      nakshatraTotal: nakshatraTotal,
      nakshatra: nakshatra,
      vamsamNumber: vamsamNum,
      vamsamTotal: vamsamTotal,
      vamsam: vamsam,
      thithi1Number: thithi1Num,
      thithi1Total: thithi1Total,
      thithi1: thithi1,
      thithi2Number: thithi2Num,
      thithi2Total: thithi2Total,
      thithi2: thithi2,
      rasiNumber: rasiNum,
      rasiTotal: rasiTotal,
      rasi: rasi,
      ageNumber: ageNum,
      ageTotal: ageTotal,
      age: age,
      purushaRasiNumber: purushaRasiNum,
      purushaRasiTotal: purushaRasiTotal,
      purushaRasi: purushaRasi,
      bootham1Number: bootham1Num,
      bootham1Total: bootham1Total,
      bootham1: bootham1,
      bootham2Number: bootham2Num,
      bootham2Total: bootham2Total,
      bootham2: bootham2,
      soothiramNumber: soothiramNum,
      soothiramTotal: soothiramTotal,
      soothiram: soothiram,
      nethiram: nethiram,
      amirthathiYoga: amirthathiYoga,
      ownerNakshatra: ownerNakshatra,
      ownerRasi: ownerRasi,
      tharaPhalan: tharaPhalan,
      karanaNumber: karanaNum,
      karanaTotal: karanaTotal,
      karana: karana,
      chandraPhalan: chandraPhalan,
      ashtaLakshmiNumber: ashtaLakshmiNum,
      ashtaLakshmiTotal: ashtaLakshmiTotal,
      ashtaLakshmi: ashtaLakshmi,
      panchaka: panchaka,
      gunaNumber: gunaNum,
      guna: guna,
      namaYogaNumber: namaYogaNum,
      namaYogaTotal: namaYogaTotal,
      namaYoga: namaYoga,
      dikpalakarNumber: dikpalakarNum,
      dikpalakarTotal: dikpalakarTotal,
      dikpalakar: dikpalakar,
      athidevathaiNumber: athidevathaiNum,
      athidevathaiTotal: athidevathaiTotal,
      athidevathai: athidevathai,
    );
  }
}
