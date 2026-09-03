import 'package:flutter/material.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class AstroTranslationService {
  static String translate(BuildContext context, String tamilWord, {bool isPlanet = false}) {
    if (tamilWord.isEmpty) return tamilWord;
    
    // Normalization Map: Convert English and full Tamil terms to short Tamil base keys
    final Map<String, String> englishToTamil = {
      "Sun": "சூரி", "Moon": "சந்", "Mars": "செவ்", "Mercury": "புத",
      "Jupiter": "குரு", "Venus": "சுக்", "Saturn": "சனி", "Rahu": "ராகு", "Ketu": "கேது",
      "Maanthi": "மா", "Lagna": "லக்",
      "சூரியன்": "சூரி", "சந்திரன்": "சந்", "செவ்வாய்": "செவ்", "புதன்": "புத",
      "வியாழன்": "குரு", "சுக்கிரன்": "சுக்", "மாந்தி": "மா", "லக்னம்": "லக்",
      "Su": "சூரி", "Mo": "சந்", "Ma": "செவ்", "Me": "புத", "Ju": "குரு", "Ve": "சுக்", "Sa": "சனி", "Ra": "ராகு", "Ke": "கேது",
      "Aries": "மேஷம்", "Taurus": "ரிஷபம்", "Gemini": "மிதுனம்", "Cancer": "கடகம்",
      "Leo": "சிம்மம்", "Virgo": "கன்னி", "Libra": "துலாம்", "Scorpio": "விருச்சிகம்",
      "Sagittarius": "தனுசு", "Capricorn": "மகரம்", "Aquarius": "கும்பம்", "Pisces": "மீனம்",
      "Ashwini": "அசுவனி", "Bharani": "பரணி", "Krittika": "கிருத்திகை", "Rohini": "ரோகிணி",
      "Mrigashirsha": "மிருகசீர்ஷம்", "Arudra": "திருவாதிரை", "Punarvasu": "புனர்பூசம்",
      "Pushya": "பூசம்", "Aslesha": "ஆயில்யம்", "Magha": "மகம்", "Purvaphalguni": "பூரம்",
      "Uttaraphalguni": "உத்திரம்", "Hastha": "அஸ்தம்", "Chitra": "சித்திரை", "Swati": "சுவாதி",
      "Vishakha": "விசாகம்", "Anuradha": "அனுஷம்", "Jyeshta": "கேட்டை", "Jyeshtha": "கேட்டை", "Mula": "மூலம்",
      "Purvashada": "பூராடம்", "PurvaAshadha": "பூராடம்", "Uttarashada": "உத்திராடம்", "UttaraAshadha": "உத்திராடம்",
      "Shravana": "திருவோணம்", "Dhanishta": "அவிட்டம்", "Shatabhisha": "சதயம்",
      "Purvabhadrapada": "பூரட்டாதி", "Uttarabhadrapada": "உத்திரட்டாதி", "Revati": "ரேவதி",
      "Sunday": "ஞாயிறு", "Monday": "திங்கள்", "Tuesday": "செவ்வாய்", "Wednesday": "புதன்",
      "Thursday": "குரு", "Friday": "வெள்ளி", "Saturday": "சனி",
      "Prathama": "பிரதமை", "Dwitiya": "துவிதியை", "Tritiya": "திரிதியை", "Chaturthi": "சதுர்த்தி",
      "Panchami": "பஞ்சமி", "Shasthi": "சஷ்டி", "Saptami": "சப்தமி", "Ashtami": "அஷ்டமி",
      "Navami": "நவமி", "Dashami": "தசமி", "Ekadashi": "ஏகாதசி", "Dwadashi": "துவாதசி",
      "Trayodashi": "திரயோதசி", "Chaturdashi": "சதுர்த்தசி", "Pournami": "பௌர்ணமி", "Purnima": "பௌர்ணமி", "Amavasya": "அமாவாசை",
      "Sukla Paksha (Waxing)": "சுக்ல பட்சம் (வளர்பிறை)",
      "Krishna Paksha (Waning)": "கிருஷ்ண பட்சம் (தேய்பிறை)",
      "Bava": "பவம்", "Balava": "பாலவம்", "Kaulava": "கௌலவம்", "Taitila": "தைதுலை", "Garaja": "கரசை",
      "Vanija": "வணிசை", "Vishti": "பத்திரை (விஷ்டி)", "Shakuni": "சகுனி", "Chatushpada": "சதுஷ்பாதம்", "Nagawa": "நாகவம்",
      "Kimstughna": "கிம்துக்கினம்",
      "Vishkumbha": "விஷ்கம்பம்", "Priti": "பிரீதி", "Ayushman": "ஆயுஷ்மான்", "Saubhagya": "சௌபாக்கியம்",
      "Sobhana": "சோபனம்", "Atiganda": "அதிகண்டம்", "Sukarma": "சுகர்மம்", "Dhriti": "திருதி",
      "Shula": "சூலம்", "Ganda": "கண்டம்", "Vriddhi": "விருத்தி", "Dhruva": "துருவம்",
      "Vyaghata": "வியாகாதம்", "Harshana": "ஹர்ஷணம்", "Vajra": "வஜ்ரம்", "Siddhi": "சித்தி",
      "Vyatipata": "வியதீபாதம்", "Variyan": "வரியான்", "Parigha": "பரிகம்", "Shiva": "சிவம்",
      "Siddha": "சித்தம்", "Sadhya": "சாத்தியம்", "Shubha": "சுபம்", "Shukla": "சுக்கிலம்",
      "Brahma": "பிரம்மா", "Indra": "ஐந்திரம்", "Vaidhriti": "வைதிருதி",
      "Amirtha Yoga": "அமிர்த யோகம்", "Marana Yoga": "மரண யோகம்", "Siddha Yoga": "சித்த யோகம்",
      "Amirtha": "அமிர்த யோகம்", "Marana": "மரண யோகம்"
    };

    String normalizedWord = tamilWord;
    final sortedEnglishKeys = englishToTamil.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    for (var eng in sortedEnglishKeys) {
      if (RegExp(r'^[A-Za-z]+$').hasMatch(eng)) {
        normalizedWord = normalizedWord.replaceAllMapped(RegExp(r'\b' + eng + r'\b'), (match) => englishToTamil[eng]!);
      } else {
        normalizedWord = normalizedWord.replaceAll(eng, englishToTamil[eng]!);
      }
    }

    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    
    // Master mapping for exact words and substrings
    Map<String, String> tMap = {
      "சூரியன்": l10n.sun,
      "சந்திரன்": l10n.moon,
      "மேஷம்": l10n.aries,
      "ரிஷபம்": l10n.taurus,
      "மிதுனம்": l10n.gemini,
      "கடகம்": l10n.cancer,
      "சிம்மம்": l10n.leo,
      "கன்னி": l10n.virgo,
      "துலாம்": l10n.libra,
      "விருச்சிகம்": l10n.scorpio,
      "தனுசு": l10n.sagittarius,
      "மகரம்": l10n.capricorn,
      "கும்பம்": l10n.aquarius,
      "மீனம்": l10n.pisces,
      "அசுவனி": l10n.ashwini,
      "பரணி": l10n.bharani,
      "கிருத்திகை": l10n.krittika,
      "ரோகிணி": l10n.rohini,
      "மிருகசீர்ஷம்": l10n.mrigashirsha,
      "திருவாதிரை": l10n.ardra,
      "புனர்பூசம்": l10n.punarvasu,
      "பூசம்": l10n.pushya,
      "ஆயில்யம்": l10n.ashlesha,
      "மகம்": l10n.magha,
      "பூரம்": l10n.purvaPhalguni,
      "உத்திரம்": l10n.uttaraPhalguni,
      "அஸ்தம்": l10n.hasta,
      "சித்திரை": l10n.chithirai,
      "சுவாதி": l10n.swati,
      "விசாகம்": l10n.vishakha,
      "அனுஷம்": l10n.anuradha,
      "கேட்டை": l10n.jyeshtha,
      "மூலம்": l10n.mula,
      "பூராடம்": l10n.purvaAshadha,
      "உத்திராடம்": l10n.uttaraAshadha,
      "திருவோணம்": l10n.shravana,
      "அவிட்டம்": l10n.dhanishta,
      "சதயம்": l10n.shatabhisha,
      "பூரட்டாதி": l10n.purvaBhadrapada,
      "உத்திரட்டாதி": l10n.uttaraBhadrapada,
      "ரேவதி": l10n.revati,
      "வைகாசி": l10n.vaikasi,
      "ஆனி": l10n.aani,
      "ஆடி": l10n.aadi,
      "ஆவணி": l10n.aavani,
      "புரட்டாசி": l10n.purattasi,
      "ஐப்பசி": l10n.aippasi,
      "கார்த்திகை": l10n.karthikai,
      "மார்கழி": l10n.margazhi,
      "தை": l10n.thai,
      "மாசி": l10n.masi,
      "பங்குனி": l10n.panguni,
      "ஞாயிறு": l10n.sunday,
      "திங்கள்": l10n.monday,
    };

    if (isPlanet && languageCode == 'en') {
      tMap["செவ்வாய்"] = "Mars";
      tMap["புதன்"] = "Mercury";
      tMap["குரு"] = "Jupiter";
      tMap["சுக்கிரன்"] = "Venus";
      tMap["சனி"] = "Saturn";
    } else if (isPlanet && languageCode == 'hi') {
      tMap["செவ்வாய்"] = "मंगल";
      tMap["புதன்"] = "बुध";
      tMap["குரு"] = "गुरु";
      tMap["சுக்கிரன்"] = "शुक्र";
      tMap["சனி"] = "शनि";
    } else {
      tMap["செவ்வாய்"] = l10n.tuesday;
      tMap["புதன்"] = l10n.wednesday;
      if (!isPlanet) {
        tMap["குரு"] = l10n.thursday;
        tMap["சுக்கிரன்"] = l10n.friday;
      }
      tMap["சனி"] = l10n.saturday;
    }

    if (languageCode == 'en') {
      tMap["சூரி"] = "Sun";
      tMap["சூ"] = "Sun";
      tMap["சந்"] = "Mon";
      tMap["செவ்"] = "Mar";
      tMap["செ"] = "Mar";
      tMap["புத"] = "Mer";
      tMap["சுக்"] = "Ven";
      tMap["குரு"] = "Jup";
      tMap["சனி"] = "Sat";
      tMap["பாம்பு"] = "Snake";
      tMap["லக்"] = "Asc";
      tMap["உத"] = "Uda";
      tMap["உதயம்"] = "Udayam";
      tMap["ஆரூ"] = "Aru";
      tMap["ஆரூடம்"] = "Arudam";
      tMap["கவி"] = "Kav";
      tMap["கவிப்பு"] = "Kavippu";
      tMap["ராகு"] = "Rahu";
      tMap["கேது"] = "Ketu";
      tMap["மாந்தி"] = "Maanthi";
      tMap["மாந்"] = "Maanthi";
      
      tMap["கிரகம்"] = "Planet";
      tMap["நட்சத்திரம் பாதம்"] = "Star Pada";
      tMap["நட்சத்திர அதிபதி"] = "Star Lord";
      tMap["பாவ தொடர்பு"] = "House Connection";
      tMap["பாவ ஆரம்ப முனை"] = "House Cusp";
      tMap["நின்ற நட்சத்திர அதிபதி"] = "Lord's Star Lord";
      tMap[" ல்"] = " in ";
      tMap["தற்போதைய கிரக நிலை"] = "Current planetary position";
      tMap["நாள்"] = "days";
      tMap["கோயம்புத்தூர்"] = "Coimbatore";
      tMap["பராபவ"] = "Parabhava";
      tMap["சப்தமி"] = "Saptami";
      tMap["சூலம்"] = "Soolam";
      tMap["பவம்"] = "Bavam";
      tMap["கண்டம்"] = "Kandam";
      tMap["நாளை"] = "Tomorrow";
      tMap["சுக்ல பட்சம் (வளர்பிறை)"] = "Shukla Paksha (Waxing)";
      tMap["கிருஷ்ண பட்சம் (தேய்பிறை)"] = "Krishna Paksha (Waning)";
      tMap["Pada"] = "Pada";
      tMap["தேவ"] = "Deva";
      tMap["ஆண்குதிரை"] = "Male Horse";
      tMap["ராசாளி"] = "Eagle";
      tMap["எட்டி"] = "Etti";
      tMap["விநாழிகை"] = "Vinazhigai";
      tMap["நாழிகை"] = "Nazhigai";
      tMap["மரண யோகம்"] = "Marana Yoga";
      tMap["அமிர்த யோகம்"] = "Amirtha Yoga";
      tMap["சித்த யோகம்"] = "Siddha Yoga";
      tMap["பாதம்"] = "Pada";
      tMap["சுப/அசுப கிரகங்கள்"] = "Benefic/Malefic Planets";
      tMap["லக்ன சுபர்கள்"] = "Lagna Benefics";
      tMap["லக்ன பாபர்கள்"] = "Lagna Malefics";
      tMap["லக்ன மாரகர்"] = "Lagna Marakas";
      tMap["ஆதியந்த பரம "] = "Aadhiyantha Parama ";
      tMap["பிறக்கும் போது தசா இருப்பு"] = "Birth Dasa Balance";
      tMap["நேரம் & யோகங்கள்"] = "Time & Yogas";
      tMap["யோனி"] = "Yoni";
      tMap["ரஜ்ஜு"] = "Rajju";
      tMap["நாடி"] = "Naadi";
      tMap[" வ,"] = " y,";
      tMap[" மா,"] = " m,";
      tMap[" நா"] = " d";
      
      // Rajju & Naadi
      tMap["சிரசு"] = "Sirsu";
      tMap["கண்ட"] = "Kanda";
      tMap["உதர"] = "Udara";
      tMap["தொடை"] = "Thodai";
      tMap["துடை"] = "Thudai";
      tMap["பாத"] = "Pada";
      tMap["தக்ஷிண பார்சுவ"] = "Dakshina Parsva";
      tMap["தஷிண பார்சுவ"] = "Dakshina Parsva";
      tMap["மத்திய பார்சுவ"] = "Madhya Parsva";
      tMap["வாம பார்சுவ"] = "Vama Parsva";
      
      tMap["கௌரி"] = "Gowri";

      tMap["பாகை"] = "Degree";
      tMap["நட்சத்திரம்-பாதம்"] = "Star-Pada";
      tMap["ந.நா"] = "N.Lord";
      tMap["நிலை"] = "Status";
      tMap["உ.நா"] = "S.Lord";
      tMap["ராசிபா"] = "SignL";
      tMap["நட்சபா"] = "StarL";
      tMap["சு.நா"] = "SS.Lord";
      tMap["சமம்"] = "Neutral";
      tMap["ஆட்சி"] = "Own House";
      tMap["உச்சம்"] = "Exalted";
      tMap["நீசம்"] = "Debilitated";
      tMap["நட்பு"] = "Friend";
      tMap["பகை"] = "Enemy";
      tMap["மூலத்திரிகோணம்"] = "Moolatrikona";

      tMap["மேஷ"] = "Ari";
      tMap["ரிஷ"] = "Tau";
      tMap["மிது"] = "Gem";
      tMap["கட"] = "Can";
      tMap["சிம்"] = "Leo";
      tMap["கன்"] = "Vir";
      tMap["துலா"] = "Lib";
      tMap["விரு"] = "Sco";
      tMap["தனு"] = "Sag";
      tMap["மக"] = "Cap";
      tMap["கும்"] = "Aqu";
      tMap["மீன"] = "Pis";

      tMap["ராசி"] = "Rasi";
      tMap["ஹோரை"] = "Hora";
      tMap["திரேக்காணம்"] = "Drekkan";
      tMap["சதுர்த்தாம்சம்"] = "Chaturthamsha";
      tMap["பஞ்சாம்சம்"] = "Panchamsha";
      tMap["ஷஷ்டாம்சம்"] = "Shashtamsha";
      tMap["சஷ்டாம்சம்"] = "Shashtamsha";
      tMap["சப்தாம்சம்"] = "Saptamsha";
      tMap["அஷ்டமாம்சம்"] = "Ashtamsha";
      tMap["அஷ்டாம்சம்"] = "Ashtamsha";
      tMap["நவாம்சம்"] = "Navamsha";
      tMap["தசாம்சம்"] = "Dashamsha";
      tMap["துவாதசாம்சம்"] = "Dwadashamsha";
      tMap["ஷோடசாம்சம்"] = "Shodashamsha";
      tMap["சோடசாம்சம்"] = "Shodashamsha";
      tMap["விம்சாம்சம்"] = "Vimshamsha";
      tMap["சதுர்விம்சாம்சம்"] = "Chaturvimshamsha";
      tMap["சித்தாம்சம்"] = "Chaturvimshamsha";
      tMap["சப்தவிம்சாம்சம்"] = "Saptavimshamsha";
      tMap["நட்சத்திராம்சம்"] = "Saptavimshamsha";
      tMap["த்ரிம்சாம்சம்"] = "Trimshamsha";
      tMap["திரிம்சாம்சம்"] = "Trimshamsha";
      tMap["கவேதாம்சம்"] = "Khavedamsha";
      tMap["அக்ஷவேதாம்சம்"] = "Akshavedamsha";
      tMap["அட்சவேதாம்சம்"] = "Akshavedamsha";
      tMap["ஷஷ்டியாம்சம்"] = "Shashtiamsha";
      tMap["அனைத்தும் (Show All)"] = "All";


      tMap["அமைப்புகள் சேமிக்கப்பட்டன! (Settings Saved)"] = "Settings Saved!";
      tMap["அமைப்புகள்"] = "Settings";
      tMap["ஜாமக்கோள் உதயம் கணக்கிடும் முறை"] = "Jamakkol Udayam Calculation Method";
      tMap["12 மணிநேர முறை"] = "12 HR Method";
      tMap["சூரிய உதய முறை"] = "Sunrise Method";
      tMap["மாந்தி உதயம் கணக்கிடும் முறை"] = "Maandi Rising Calculation Method";
      tMap["நாள்/இரவு நாழிகை மற்றும் நிலையான நாழிகை விகிதாச்சாரம்"] = "Ghatikas of day/night x constant rising ghatika / 30";
      tMap["8 சம பாகங்கள் மற்றும் சனியின் பாகத் தொடக்கம் (Start)"] = "Divided into 8 equal parts & at start of Saturn's part";
      tMap["8 சம பாகங்கள் மற்றும் சனியின் பாக நடுப்பகுதி (Middle)"] = "Divided into 8 equal parts & at middle of Saturn's part";
      tMap["8 சம பாகங்கள் மற்றும் சனியின் பாக முடிவு (End)"] = "Divided into 8 equal parts & at end of Saturn's part";
      tMap["சூரியன் பாகை + நிலையான பாகை கூட்டும் முறை"] = "Sun degree + constant rising degree of day/night";
      tMap["நிலையான இடம் (Default Location)"] = "Default Location";
      tMap["மாற்று"] = "Change";
      tMap["ஜோதிடர் விவரங்கள் (Astrologer Details)"] = "Astrologer Details";
      tMap["ஜோதிடர் பெயர் (Name)"] = "Astrologer Name";
      tMap["ஜோதிடர் எண் (Phone)"] = "Astrologer Phone";
      tMap["முகவரி (Address)"] = "Address";
      tMap["அமைப்புகள் (App Settings)"] = "App Settings";
      tMap["மொழி (Language)"] = "Language";
      tMap["எழுத்துரு அளவு (Font Size)"] = "Font Size";
      tMap["அயனாம்சம் (Ayanamsa Mode)"] = "Ayanamsa Mode";
      tMap["Lahiri (Chitra Paksha)"] = "Lahiri (Chitra Paksha)";
      tMap["Raman"] = "Raman";
      tMap["KP Old (Original)"] = "KP Old (Original)";
      tMap["KP New (Modern)"] = "KP New (Modern)";
      tMap["KP Straight Line (Khullar)"] = "KP Straight Line (Khullar)";
      tMap["KP-Newcomb (Auto)"] = "KP-Newcomb (Auto)";
      tMap["கணித அமைப்புகள் (Calculation Settings)"] = "Calculation Settings";
      tMap["ராகு/கேது (Node Calculation)"] = "Node Calculation";
      tMap["சராசரி (Mean Node)"] = "Mean Node";
      tMap["உண்மை (True Node)"] = "True Node";
      tMap["தசா வருட அளவு (Dasa Year Length)"] = "Dasa Year Length";
      tMap["360 நாட்கள்"] = "360 Days";
      tMap["365.25 நாட்கள்"] = "365.25 Days";
      tMap["சிறிய (Small)"] = "Small";
      tMap["இயல்பு (Normal)"] = "Normal";
      tMap["பெரிய (Large)"] = "Large";
      tMap["தமிழ்"] = "Tamil";
      tMap["ஹிந்தி"] = "Hindi";
      tMap["சந்தா (Subscription)"] = "Subscription";
      tMap["சந்தா திட்டங்கள்"] = "Subscription Plans";
      tMap["Subscription Plans"] = "Subscription Plans";
      tMap["சந்தா விவரங்கள்"] = "Subscription Details";
      tMap["சேமி (SAVE)"] = "SAVE";
      tMap["உங்கள் பெயர் (Name)"] = "Your Name";
      tMap["மொபைல் எண் (Phone)"] = "Mobile Number";
      tMap["நடுத்தர (Normal)"] = "Normal";
      tMap["* பாரம்பரிய பஞ்சாங்கங்கள் 'சராசரி' (Mean Node) முறையை பயன்படுத்துகின்றன."] = "* Traditional panchangams use 'Mean Node' calculation.";
      tMap["* 365.25 என்பது நவீன முறை (Default). 360 என்பது பாரம்பரிய முறை."] = "* 365.25 is Modern method (Default). 360 is Traditional.";
      tMap["நட்சத்திர நாம எழுத்து"] = "Nakshatra Name Letters";

      // Missing basic translations
      tMap["ஆண்"] = "Male";
      tMap["பெண்"] = "Female";
      tMap["சுப/அசுப கிரகங்கள்"] = "Benefic/Malefic Planets";
      tMap["நேரம் & யோகங்கள்"] = "Time & Yogas";
      tMap["ஜனன கால தசை இருப்பு"] = "Birth Dasa Balance";
      tMap["நடப்பு தசா இருப்பு"] = "Current Dasa Balance";
      tMap["நடப்பு புத்தி இருப்பு"] = "Current Bukthi Balance";
      tMap["திதி சூன்ய ராசிகள்"] = "Tithi Sunya Rasis";
      tMap["ராசி கட்டம்"] = "Rasi Chart";
      tMap["பாவகம்"] = "Bhavagam";
      tMap["லக்ன சுபர்கள்"] = "Lagna Benefics";
      tMap["லக்ன பாபர்கள்"] = "Lagna Malefics";
      tMap["லக்ன மாரகர்"] = "Lagna Marakas";
      tMap["ரஜ்ஜு"] = "Rajju";
      tMap["நாடி"] = "Naadi";
      tMap["யோனி"] = "Yoni";
      tMap["ஆதியந்த பரம நாழிகை"] = "Aadhiyantha Parama Nazhigai";
      tMap["பிறக்கும் போது தசா இருப்பு"] = "Dasa Balance at Birth";
      // Tithis, Yogas, Karanas in English
      tMap["பிரதமை"] = "Prathama";
      tMap["துவிதியை"] = "Dwitiya";
      tMap["திரிதியை"] = "Tritiya";
      tMap["சதுர்த்தி"] = "Chaturthi";
      tMap["பஞ்சமி"] = "Panchami";
      tMap["சஷ்டி"] = "Shasthi";
      tMap["சப்த்தமி"] = "Saptami";
      tMap["சப்தமி"] = "Saptami";
      tMap["அஷ்டமி"] = "Ashtami";
      tMap["நவமி"] = "Navami";
      tMap["தசமி"] = "Dashami";
      tMap["ஏகாதசி"] = "Ekadashi";
      tMap["துவாதசி"] = "Dwadashi";
      tMap["திரயோதசி"] = "Trayodashi";
      tMap["சதுர்த்தசி"] = "Chaturdashi";
      tMap["பௌர்ணமி"] = "Pournami";
      tMap["அமாவாசை"] = "Amavasya";

      tMap["விஷ்கம்பம்"] = "Vishkumbha";
      tMap["பிரீதி"] = "Priti";
      tMap["ஆயுஷ்மான்"] = "Ayushman";
      tMap["சௌபாக்கியம்"] = "Saubhagya";
      tMap["சோபனம்"] = "Sobhana";
      tMap["அதிகண்டம்"] = "Atiganda";
      tMap["சுகர்மம்"] = "Sukarma";
      tMap["திருதி"] = "Dhriti";
      tMap["சூலம்"] = "Shula";
      tMap["கண்டம்"] = "Ganda";
      tMap["விருத்தி"] = "Vriddhi";
      tMap["துருவம்"] = "Dhruva";
      tMap["வியாகாதம்"] = "Vyaghata";
      tMap["ஹர்ஷணம்"] = "Harshana";
      tMap["வஜ்ரம்"] = "Vajra";
      tMap["சித்தி"] = "Siddhi";
      tMap["வியதீபாதம்"] = "Vyatipata";
      tMap["வரியான்"] = "Variyan";
      tMap["பரிகம்"] = "Parigha";
      tMap["சிவம்"] = "Shiva";
      tMap["சித்தம்"] = "Siddha";
      tMap["சாத்தியம்"] = "Sadhya";
      tMap["சுபம்"] = "Shubha";
      tMap["சுக்கிலம்"] = "Shukla";
      tMap["பிரம்மா"] = "Brahma";
      tMap["ஐந்திரம்"] = "Indra";
      tMap["வைதிருதி"] = "Vaidhriti";

      tMap["பவம்"] = "Bava";
      tMap["பாலவம்"] = "Balava";
      tMap["கௌலவம்"] = "Kaulava";
      tMap["தைதிலை"] = "Taitila";
      tMap["கரசை"] = "Garaja";
      tMap["பத்திரா"] = "Vishti";
      tMap["சகுனி"] = "Shakuni";
      tMap["சதுஷ்பாதம்"] = "Chatushpada";
      tMap["நாகவம்"] = "Nagawa";
      tMap["கிம்ஸ்துக்கினம்"] = "Kimstughna";

      // Nakshatra Name Letters (English)
      tMap["சு, சே, சோ, ல"] = "Chu, Che, Cho, La";
      tMap["லி, லு, லே, வோ"] = "Li, Lu, Le, Lo";
      tMap["அ, இ, உ, எ"] = "A, I, U, E";
      tMap["ஓ, வா, வீ, வு"] = "O, Va, Vi, Vu";
      tMap["வே, வோ, கா, கி"] = "Ve, Vo, Ka, Ki";
      tMap["கு, க, ரு, ச"] = "Ku, Gha, Ng, Chha";
      tMap["கே, கோ, ஹ, ஹி"] = "Ke, Ko, Ha, Hi";
      tMap["ஹு, ஹே, ஹோ, ட"] = "Hu, He, Ho, Da";
      tMap["டி, டு, டே, டோ"] = "Di, Du, De, Do";
      tMap["ம, மி, மு, மெ"] = "Ma, Mi, Mu, Me";
      tMap["மோ, ட, டி, டு"] = "Mo, Ta, Ti, Tu";
      tMap["டே, டோ, ப, பி"] = "Te, To, Pa, Pi";
      tMap["பு, ஷ, ண, ட"] = "Pu, Sha, Na, Tha";
      tMap["பே, போ, ரா, ரி"] = "Pe, Po, Ra, Ri";
      tMap["ரு, ரே, ரோ, த"] = "Ru, Re, Ro, Ta";
      tMap["தி, து, தே, தோ"] = "Ti, Tu, Te, To";
      tMap["நா, நி, நு, நே"] = "Na, Ni, Nu, Ne";
      tMap["நோ, ய, இ, ய"] = "No, Ya, Yi, Yu";
      tMap["யே, யோ, ப, பி"] = "Ye, Yo, Bha, Bhi";
      tMap["பு, த, ப, டா"] = "Bhu, Dha, Bha, Dha";
      tMap["பே, போ, ஜ, ஜி"] = "Bhe, Bho, Ja, Ji";
      tMap["கூ, கா, கே, கோ"] = "Ju, Je, Jo, Gha";
      tMap["க, கீ, கு, கூ"] = "Ga, Gi, Gu, Ge";
      tMap["கோ, ஸ, ஸீ, ஸு"] = "Go, Sa, Si, Su";
      tMap["ஸே, ஸோ, தா, தி"] = "Se, So, Da, Di";
      tMap["து, ஞ், ச, ஸ்ரீ"] = "Du, Tha, Jha, Jna";
      tMap["தே, தோ, ச, சி"] = "De, Do, Cha, Chi";


    } else if (languageCode == 'hi') {
      tMap["சூரி"] = "सूर्य";
      tMap["சூ"] = "सू";
      tMap["சந்"] = "चंद्र";
      tMap["செவ்"] = "मंगल";
      tMap["செ"] = "मंगल";
      tMap["புத"] = "बुध";
      tMap["சுக்"] = "शुक्र";
      tMap["குரு"] = "गुरु";
      tMap["சனி"] = "शनि";
      tMap["பாம்பு"] = "सांप";
      tMap["லக்"] = "लग्न";
      tMap["உத"] = "उदय";
      tMap["உதயம்"] = "उदयम";
      tMap["ஆரூ"] = "आरूढ़";
      tMap["ஆரூடம்"] = "आरूढ़म";
      tMap["கவி"] = "कविप्पु";
      tMap["கவிப்பு"] = "कविप्पु";
      tMap["ராகு"] = "राहु";
      tMap["கேது"] = "केतु";
      tMap["மாந்தி"] = "मान्दि";
      tMap["மாந்"] = "मान्दि";

      tMap["தற்போதைய கிரக நிலை"] = "वर्तमान ग्रह स्थिति";
      tMap["நாள்"] = "दिन";
      tMap["பராபவ"] = "पराभव";
      tMap["சப்தமி"] = "सप्तमी";
      tMap["சூலம்"] = "शूल";
      tMap["பவம்"] = "बव";
      tMap["கண்டம்"] = "कंडम (Kandam)";
      tMap["நாளை"] = "कल (Tomorrow)";
      tMap["சுக்ல பட்சம் (வளர்பிறை)"] = "शुक्ल पक्ष (Shukla Paksha)";
      tMap["கிருஷ்ண பட்சம் (தேய்பிறை)"] = "कृष्ण पक्ष (Krishna Paksha)";
      tMap["Pada"] = "पद";
      tMap["தேவ"] = "देव";
      tMap["ஆண்குதிரை"] = "अश्व";
      tMap["ராசாளி"] = "गरुड़";
      tMap["எட்டி"] = "एट्टी";
      tMap["விநாழிகை"] = "विनाड़ी";
      tMap["நாழிகை"] = "नाड़ी";
      tMap["மரண யோகம்"] = "मरण योग";
      tMap["அமிர்த யோகம்"] = "अमृत योग";
      tMap["சித்த யோகம்"] = "सिद्ध योग";
      tMap["பாதம்"] = "पद";
      tMap["சுப/அசுப கிரகங்கள்"] = "शुभ/अशुभ ग्रह";
      tMap["லக்ன சுபர்கள்"] = "लग्न शुभ";
      tMap["லக்ன பாபர்கள்"] = "लग्न पापी";
      tMap["லக்ன மாரகர்"] = "लग्न मारक";
      tMap["ஆதியந்த பரம "] = "आद्यंत परम ";
      tMap["பிறக்கும் போது தசா இருப்பு"] = "जन्म दशा शेष";
      tMap["நேரம் & யோகங்கள்"] = "समय और योग";
      tMap["யோனி"] = "योनि";
      tMap["ரஜ்ஜு"] = "रज्जु";
      tMap["நாடி"] = "नाड़ी";
      tMap[" வ,"] = " व,";
      tMap[" மா,"] = " म,";
      tMap[" நா"] = " दिन";
      tMap["கௌரி"] = "गौरी";

      tMap["பாகை"] = "अंश";
      tMap["நட்சத்திரம்-பாதம்"] = "नक्षत्र-पद";
      tMap["ந.நா"] = "न.स्वामी";
      tMap["நிலை"] = "स्थिति";
      tMap["உ.நா"] = "उ.स्वामी";
      tMap["ராசிபா"] = "राशि स्वामी";
      tMap["நட்சபா"] = "नक्षत्र स्वामी";
      tMap["சு.நா"] = "सू.स्वामी";
      tMap["சமம்"] = "सम";
      tMap["ஆட்சி"] = "स्वराशि";
      tMap["உச்சம்"] = "उच्च";
      tMap["நீசம்"] = "नीच";
      tMap["நட்பு"] = "मित्र";
      tMap["பகை"] = "शत्रु";
      tMap["மூலத்திரிகோணம்"] = "मूलत्रिकोण";

      tMap["மேஷ"] = "मेष";
      tMap["ரிஷ"] = "वृष";
      tMap["மிது"] = "मिथु";
      tMap["கட"] = "कर्क";
      tMap["சிம்"] = "सिंह";
      tMap["கன்"] = "कन्या";
      tMap["துலா"] = "तुला";
      tMap["விரு"] = "वृश्";
      tMap["தனு"] = "धनु";
      tMap["மக"] = "मकर";
      tMap["கும்"] = "कुंभ";
      tMap["மீன"] = "मीन";

      tMap["ராசி"] = "राशि";
      tMap["ஹோரை"] = "होरा";
      tMap["திரேக்காணம்"] = "द्रेष्काण";
      tMap["சதுர்த்தாம்சம்"] = "चतुर्थांश";
      tMap["பஞ்சாம்சம்"] = "पंचांश";
      tMap["ஷஷ்டாம்சம்"] = "षष्ठांश";
      tMap["சஷ்டாம்சம்"] = "षष्ठांश";
      tMap["சப்தாம்சம்"] = "सप्तांश";
      tMap["அஷ்டமாம்சம்"] = "अष्टमांश";
      tMap["அஷ்டாம்சம்"] = "अष्टमांश";
      tMap["நவாம்சம்"] = "नवांश";
      tMap["தசாம்சம்"] = "दशांश";
      tMap["துவாதசாம்சம்"] = "द्वादशांश";
      tMap["ஷோடசாம்சம்"] = "षोडशांश";
      tMap["சோடசாம்சம்"] = "षोडशांश";
      tMap["விம்சாம்சம்"] = "विंश्यांश";
      tMap["சதுர்விம்சாம்சம்"] = "चतुर्विशांश";
      tMap["சித்தாம்சம்"] = "चतुर्विशांश";
      tMap["சப்தவிம்சாம்சம்"] = "सप्तविशांश";
      tMap["நட்சத்திராம்சம்"] = "सप्तविशांश";
      tMap["த்ரிம்சாம்சம்"] = "त्रिंशांश";
      tMap["திரிம்சாம்சம்"] = "त्रिंशांश";
      tMap["கவேதாம்சம்"] = "खवेदांश";
      tMap["அக்ஷவேதாம்சம்"] = "अक्षवेदांश";
      tMap["அட்சவேதாம்சம்"] = "अक्षवेदांश";
      tMap["ஷஷ்டியாம்சம்"] = "षष्ट्यांश";
      tMap["அனைத்தும் (Show All)"] = "सभी";

      tMap["அமைப்புகள் சேமிக்கப்பட்டன! (Settings Saved)"] = "सेटिंग्स सहेजी गईं!";
      tMap["அமைப்புகள்"] = "सेटिंग्स";
      tMap["ஜாமக்கோள் உதயம் கணக்கிடும் முறை"] = "जामक्कोल उदयम गणना विधि";
      tMap["12 மணிநேர முறை"] = "12 घंटे की विधि";
      tMap["சூரிய உதய முறை"] = "सूर्योदय विधि";
      tMap["மாந்தி உதயம் கணக்கிடும் முறை"] = "मान्दि उदय गणना विधि";
      tMap["நாள்/இரவு நாழிகை மற்றும் நிலையான நாழிகை விகிதாச்சாரம்"] = "(दिन/रात की घटिका x दिन/रात की निश्चित उदय घटिका) ÷ 30";
      tMap["8 சம பாகங்கள் மற்றும் சனியின் பாகத் தொடக்கம் (Start)"] = "8 बराबर भागों में विभाजित और शनि के भाग के प्रारंभ में";
      tMap["8 சம பாகங்கள் மற்றும் சனியின் பாக நடுப்பகுதி (Middle)"] = "8 बराबर भागों में विभाजित और शनि के भाग के मध्य में";
      tMap["8 சம பாகங்கள் மற்றும் சனியின் பாக முடிவு (End)"] = "8 बराबर भागों में विभाजित और शनि के भाग के अंत में";
      tMap["சூரியன் பாகை + நிலையான பாகை கூட்டும் முறை"] = "सूर्य अंश + दिन/रात का निश्चित उदय अंश";
      tMap["நிலையான இடம் (Default Location)"] = "डिफ़ॉल्ट स्थान";
      tMap["மாற்று"] = "बदलें";
      tMap["ஜோதிடர் விவரங்கள் (Astrologer Details)"] = "ज्योतिषी विवरण";
      tMap["ஜோதிடர் பெயர் (Name)"] = "ज्योतिषी का नाम";
      tMap["ஜோதிடர் எண் (Phone)"] = "ज्योतिषी का फोन";
      tMap["முகவரி (Address)"] = "पता";
      tMap["அமைப்புகள் (App Settings)"] = "ऐप सेटिंग्स";
      tMap["மொழி (Language)"] = "भाषा";
      tMap["எழுத்துரு அளவு (Font Size)"] = "फ़ॉन्ट आकार";
      tMap["அயனாம்சம் (Ayanamsa Mode)"] = "अयनश (Ayanamsa Mode)";
      tMap["Lahiri (Chitra Paksha)"] = "लाहिड़ी (Lahiri)";
      tMap["Raman"] = "रमन (Raman)";
      tMap["KP Old (Original)"] = "के.पी. पुराना (KP Old)";
      tMap["KP New (Modern)"] = "के.पी. नया (KP New)";
      tMap["KP Straight Line (Khullar)"] = "के.पी. स्ट्रेट लाइन (KP Khullar)";
      tMap["KP-Newcomb (Auto)"] = "के.पी. न्यूकॉम्ब (KP Newcomb)";
      tMap["கணித அமைப்புகள் (Calculation Settings)"] = "गणना सेटिंग्स";
      tMap["ராகு/கேது (Node Calculation)"] = "राहु/केतु गणना";
      tMap["சராசரி (Mean Node)"] = "औसत (Mean Node)";
      tMap["உண்மை (True Node)"] = "सत्य (True Node)";
      tMap["தசா வருட அளவு (Dasa Year Length)"] = "दशा वर्ष की लंबाई";
      tMap["360 நாட்கள்"] = "360 दिन";
      tMap["365.25 நாட்கள்"] = "365.25 दिन";
      tMap["சிறிய (Small)"] = "छोटा";
      tMap["இயல்பு (Normal)"] = "सामान्य";
      tMap["பெரிய (Large)"] = "बड़ा";
      tMap["தமிழ்"] = "तमिल";
      tMap["ஹிந்தி"] = "हिंदी";
      tMap["சந்தா (Subscription)"] = "सदस्यता";
      tMap["சந்தா திட்டங்கள்"] = "सदस्यता योजनाएँ";
      tMap["Subscription Plans"] = "सदस्यता योजनाएँ";
      tMap["சந்தா விவரங்கள்"] = "सदस्यता विवरण";
      tMap["சேமி (SAVE)"] = "सहेजें (SAVE)";
      tMap["உங்கள் பெயர் (Name)"] = "आपका नाम";
      tMap["மொபைல் எண் (Phone)"] = "मोबाइल नंबर";
      tMap["நடுத்தர (Normal)"] = "मध्यम (Normal)";
      tMap["* பாரம்பரிய பஞ்சாங்கங்கள் 'சராசரி' (Mean Node) முறையை பயன்படுத்துகின்றன."] = "* पारंपरिक पंचांग 'औसत (Mean Node)' गणना का उपयोग करते हैं।";
      tMap["* 365.25 என்பது நவீன முறை (Default). 360 என்பது பாரம்பரிய முறை."] = "* 365.25 आधुनिक विधि (Default) है। 360 पारंपरिक है।";
      tMap["நட்சத்திர நாம எழுத்து"] = "नक्षत्र नाम अक्षर";

      // Missing basic translations
      tMap["ஆண்"] = "पुरुष (Male)";
      tMap["பெண்"] = "स्त्री (Female)";
      tMap["சுப/அசுப கிரகங்கள்"] = "शुभ/अशुभ ग्रह (Benefic/Malefic)";
      tMap["நேரம் & யோகங்கள்"] = "समय और योग (Time & Yogas)";
      tMap["ஜனன கால தசை இருப்பு"] = "जन्म दशा शेष (Birth Dasa Bal)";
      tMap["நடப்பு தசா இருப்பு"] = "वर्तमान दशा शेष (Current Dasa Bal)";
      tMap["நடப்பு புத்தி இருப்பு"] = "वर्तमान भुक्ति शेष (Current Bukthi Bal)";
      tMap["திதி சூன்ய ராசிகள்"] = "तिथि शून्य राशियाँ (Tithi Sunya Rasis)";
      tMap["ராசி கட்டம்"] = "राशि चक्र (Rasi Chart)";
      tMap["பாவகம்"] = "भाव (Bhavagam)";
      tMap["லக்ன சுபர்கள்"] = "लग्न शुभ ग्रह (Lagna Benefics)";
      tMap["லக்ன பாபர்கள்"] = "लग्न पापी ग्रह (Lagna Malefics)";
      tMap["லக்ன மாரகர்"] = "लग्न मारक (Lagna Marakas)";
      tMap["ரஜ்ஜு"] = "रज्जु (Rajju)";
      tMap["நாடி"] = "नाड़ी (Naadi)";
      tMap["யோனி"] = "योनि (Yoni)";
      tMap["ஆதியந்த பரம நாழிகை"] = "आदियन्त परम नाड़िगै (Aadhiyantha Nazhigai)";
      // Short planet codes in Hindi
      tMap["சூரி"] = "सूर्य";
      tMap["சந்"] = "चंद्र";
      tMap["செவ்"] = "मंगल";
      tMap["புத"] = "बुध";
      tMap["குரு"] = "गुरु";
      tMap["சுக்"] = "शुक्र";
      tMap["சனி"] = "शनि";
      tMap["ராகு"] = "राहु";
      tMap["கேது"] = "केतु";
      tMap["மா"] = "मांदी";
      tMap["லக்"] = "लग्न";

      // Tithis, Yogas, Karanas in Hindi
      tMap["பிரதமை"] = "प्रतिपदा";
      tMap["துவிதியை"] = "द्वितीया";
      tMap["திரிதியை"] = "तृतीया";
      tMap["சதுர்த்தி"] = "चतुर्थी";
      tMap["பஞ்சமி"] = "पंचमी";
      tMap["சஷ்டி"] = "षष्ठी";
      tMap["சப்த்தமி"] = "सप्तमी";
      tMap["சப்தமி"] = "सप्तमी";
      tMap["அஷ்டமி"] = "अष्टमी";
      tMap["நவமி"] = "नवमी";
      tMap["தசமி"] = "दशमी";
      tMap["ஏகாதசி"] = "एकादशी";
      tMap["துவாதசி"] = "द्वादशी";
      tMap["திரயோகசி"] = "त्रयोदशी";
      tMap["திரயோதசி"] = "त्रयोदशी";
      tMap["சதுர்த்தசி"] = "चतुर्दशी";
      tMap["பௌர்ணமி"] = "पूर्णिमा";
      tMap["அமாவாசை"] = "अमावस्या";

      tMap["விஷ்கம்பம்"] = "विष्कम्भ";
      tMap["பிரீதி"] = "प्रीति";
      tMap["ஆயுஷ்மான்"] = "आयुष्मान";
      tMap["சௌபாக்கியம்"] = "सौभाग्य";
      tMap["சோபனம்"] = "शोभन";
      tMap["அதிகண்டம்"] = "अतिगण्ड";
      tMap["சுகர்மம்"] = "सुकर्मा";
      tMap["திருதி"] = "धृति";
      tMap["சூலம்"] = "शूल";
      tMap["கண்டம்"] = "गण्ड";
      tMap["விருத்தி"] = "वृद्धि";
      tMap["துருவம்"] = "ध्रुव";
      tMap["வியாகாதம்"] = "व्याघात";
      tMap["ஹர்ஷணம்"] = "हर्षण";
      tMap["வஜ்ரம்"] = "वज्र";
      tMap["சித்தி"] = "सिद्धि";
      tMap["வியதீபாதம்"] = "व्यतिपात";
      tMap["வரியான்"] = "वरीयान";
      tMap["பரிகம்"] = "परिघ";
      tMap["சிவம்"] = "शिव";
      tMap["சித்தம்"] = "सिद्ध";
      tMap["சாத்தியம்"] = "साध्य";
      tMap["சுபம்"] = "शुभ";
      tMap["சுக்கிலம்"] = "शुक्ल";
      tMap["பிரம்மா"] = "ब्रह्म";
      tMap["ஐந்திரம்"] = "इन्द्र";
      tMap["வைதிருதி"] = "वैधृति";

      tMap["பவம்"] = "बव";
      tMap["பாலவம்"] = "बालव";
      tMap["கௌலவம்"] = "कौलव";
      tMap["தைதிலை"] = "तैतिल";
      tMap["கரசை"] = "गर";
      tMap["பத்திரா"] = "विष्टि";
      tMap["சகுனி"] = "शकुनि";
      tMap["சதுஷ்பாதம்"] = "चतुष्पाद";
      tMap["நாகவம்"] = "नाग";
      tMap["கிம்ஸ்துக்கினம்"] = "किंस्तुघ्न";

      // Nakshatra Name Letters (Hindi)
      tMap["சு, சே, சோ, ல"] = "चू, चे, चो, ला";
      tMap["லி, லு, லே, வோ"] = "ली, लू, ले, लो";
      tMap["அ, இ, உ, எ"] = "अ, ई, उ, ए";
      tMap["ஓ, வா, வீ, வு"] = "ओ, वा, वी, वू";
      tMap["வே, வோ, கா, கி"] = "वे, वो, का, की";
      tMap["கு, க, ரு, ச"] = "कू, घ, ङ, छ";
      tMap["கே, கோ, ஹ, ஹி"] = "के, को, हा, ही";
      tMap["ஹு, ஹே, ஹோ, ட"] = "हू, हे, हो, डा";
      tMap["டி, டு, டே, டோ"] = "डी, डू, डे, डो";
      tMap["ம, மி, மு, மெ"] = "मा, मी, मू, मे";
      tMap["மோ, ட, டி, டு"] = "मो, टा, टी, टू";
      tMap["டே, டோ, ப, பி"] = "टे, टो, पा, पी";
      tMap["பு, ஷ, ண, ட"] = "पू, ष, ण, ठा";
      tMap["பே, போ, ரா, ரி"] = "पे, पो, रा, री";
      tMap["ரு, ரே, ரோ, த"] = "रू, रे, रो, ता";
      tMap["தி, து, தே, தோ"] = "ती, तू, ते, तो";
      tMap["நா, நி, நு, நே"] = "ना, नी, नू, ने";
      tMap["நோ, ய, இ, ய"] = "नो, या, यी, यू";
      tMap["யே, யோ, ப, பி"] = "ये, यो, भा, भी";
      tMap["பு, த, ப, டா"] = "भू, धा, फा, ढा";
      tMap["பே, போ, ஜ, ஜி"] = "भे, भो, जा, जी";
      tMap["கூ, கா, கே, கோ"] = "जू, जे, जो, घा";
      tMap["க, கீ, கு, கூ"] = "गा, गी, गू, गे";
      tMap["கோ, ஸ, ஸீ, ஸு"] = "गो, सा, सी, सू";
      tMap["ஸே, ஸோ, தா, தி"] = "से, सो, दा, दी";
      tMap["து, ஞ், ச, ஸ்ரீ"] = "दू, थ, झ, ञ";
      tMap["தே, தோ, ச, சி"] = "दे, दो, चा, ची";

    }

    if (tMap.containsKey(normalizedWord)) return tMap[normalizedWord]!;

    String translated = normalizedWord;

    if (languageCode == 'ta') {
      return translated;
    }

    if (languageCode == 'en' || languageCode == 'hi') {
      var sortedKeys = tMap.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
      for (var ta in sortedKeys) {
        translated = translated.replaceAll(ta, tMap[ta]!);
      }
    }

    return translated;
  }
  static String cleanLocation(BuildContext context, String location) {
    if (location.isEmpty || location == "-") return location;
    final languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == 'ta') {
      return location; // Keep as is for Tamil
    }
    // For English, Hindi, etc., remove any Tamil characters enclosed in parentheses like `(கோயம்புத்தூர்)`
    // and also remove trailing/leading spaces.
    String cleaned = location.replaceAll(RegExp(r'\s*\([\u0B80-\u0BFF\s]+\)'), '');
    // If there's still Tamil text without parentheses, we can just return it or attempt to strip it, but usually it's in ()
    return cleaned.trim();
  }
}