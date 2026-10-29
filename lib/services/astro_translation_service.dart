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
      "மிருகசீரிஷம்": "மிருகசீர்ஷம்", "மிருகசீரிடம்": "மிருகசீர்ஷம்", "அஸ்வினி": "அசுவனி", "அசுவினி": "அசுவனி",
      "கார்த்திகை": "கிருத்திகை", "ஹஸ்தம்": "அஸ்தம்",
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
      "அஸ்வினி": l10n.ashwini,
      "அசுவினி": l10n.ashwini,
      "பரணி": l10n.bharani,
      "கார்த்திகை": l10n.krittika,
      "கிருத்திகை": l10n.krittika,
      "ரோகிணி": l10n.rohini,
      "மிருகசீர்ஷம்": l10n.mrigashirsha,
      "மிருகசீரிஷம்": l10n.mrigashirsha,
      "மிருகசீரிடம்": l10n.mrigashirsha,
      "ஹஸ்தம்": l10n.hasta,
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
      tMap[" (வ)"] = " (R)";
      tMap["(வ)"] = "(R)";
      tMap[" (அ)"] = " (C)";
      tMap["(அ)"] = "(C)";
      
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
      tMap["ஜனன கால புத்தி இருப்பு"] = "Birth Bhukti Balance";
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
      tMap["அதிக பாகை பெற்ற கிரகம்"] = "Highest Degree Planet";
      tMap["குறைந்த பாகை பெற்ற கிரகம்"] = "Lowest Degree Planet";
      tMap["ஆகமி கிரகம்"] = "Aagami Planet(s)";
      tMap["ஆகாமி கிரகம்"] = "Aagami Planet(s)";
      tMap["வரு"] = "Y";
      tMap["மா"] = "M";
      tMap["நா"] = "D";
      tMap["வரை"] = "until";
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

      // Horoscope Result Card Titles & Subsections
      tMap["பிறப்பு விவரம்"] = "Birth Details";
      tMap["பஞ்சாங்கம்"] = "Panchangam";
      tMap["ஜோதிட அடிப்படை"] = "Astrological Basics";
      tMap["நேரம் யோகங்கள்"] = "Time & Yogas";
      tMap["நேரம் & யோகங்கள்"] = "Time & Yogas";
      tMap["யோகி அவயோகி பாத அமைப்புகள்"] = "Yogi & Avayogi Placements";
      tMap["வைனாசிகம் புஷ்கர நவம்சம்"] = "Vainashika & Pushkara Navamsha";
      tMap["அதிக பாதை பெற்ற கிரகம் குறைந்த பாகை பெற்ற கிரகம்"] = "Highest & Lowest Degree Planets";
      tMap["அதிக பாகை பெற்ற கிரகம் குறைந்த பாகை பெற்ற கிரகம்"] = "Highest & Lowest Degree Planets";
      tMap["கிரகங்களின் பாகை விவரம் (இறங்கு வரிசை):"] = "Planetary Degrees (Descending Order):";
      tMap["கிரகங்களின் பாகை விவரம்"] = "Planetary Degrees";
      tMap["ஆகமிக்கிரகம்"] = "Aagami Planets";
      tMap["ஆகமி கிரகங்கள்"] = "Aagami Planets";
      tMap["ஆகமிக் கிரகம்"] = "Aagami Planet";
      tMap["ஆகமி கிரகம்"] = "Aagami Planet";
      tMap["ஆகாமி கிரகம்"] = "Aagami Planet";
      tMap["தன் சொந்த நட்சத்திர சாரத்தில் பிற கிரகங்கள் அமையப் பெறாத கிரகங்கள் ஆகமி கிரகங்கள் ஆகும்."] = "Planets that do not have other planets placed in their star constellations are Aagami planets.";
      tMap["அனைத்து கிரகங்களின் நட்சத்திர சாரங்களிலும் பிற கிரகங்கள் அமர்ந்துள்ளன."] = "All planets have other planets situated in their star constellations.";
      tMap["ஆகமி கிரகம் (எந்தக் கிரகமும் அமையவில்லை)"] = "Aagami Planet (No planets situated)";
      tMap["(எந்தக் கிரகமும் அமையவில்லை)"] = "(No planets situated)";
      tMap["அமர்ந்துள்ள கிரகங்கள்:"] = "Occupying planets:";
      tMap["அமர்ந்துள்ள கிரகங்கள்"] = "Occupying planets";
      tMap["இல்லை"] = "None";
      tMap["கிரக அவஸ்தைகள்"] = "Planetary Avasthas";
      tMap["நட்சத்திர விவரம்"] = "Nakshatra Details";
      tMap["சுப அசுப கிரகங்கள்"] = "Benefic & Malefic Planets";
      tMap["சுப/அசுப கிரகங்கள்"] = "Benefic & Malefic Planets";
      tMap["சிறப்பு லக்கின புள்ளிகள்"] = "Special Lagna Points";
      tMap["உபகிரகங்கள் (மிருத்யு, எமகண்டன் உள்ளிட்டவை)"] = "Upagrahas (including Mrityu, Yamakantaka)";
      tMap["உபகிரகங்கள்"] = "Upagrahas";
      tMap["ஜெமினி ஏழு காரகங்கள்"] = "Jaimini Seven Karakas";
      tMap["பரிவர்த்தனை யோகங்கள்"] = "Parivarthana Yogas";
      tMap["கால நட்பு"] = "Kala Natpu (Temporal Friends)";
      tMap["காலநட்பு"] = "Kala Natpu";
      tMap["காலப்பகை"] = "Kala Pagai (Temporal Enemies)";
      tMap["காலநட்பு வயது & திசை விவரங்கள்:"] = "Temporal Friend Age & Dasa Details:";
      tMap["காலப்பகை வயது & திசை விவரங்கள்:"] = "Temporal Enemy Age & Dasa Details:";
      tMap["காலப்பகை தசா - புத்தி எச்சரிக்கைகள்:"] = "Temporal Enemy Dasa - Bhukthi Warnings:";
      tMap["விவரங்கள் இல்லை"] = "No details available";
      tMap["(தற்போது நடக்கிறது)"] = "(Currently running)";
      tMap["திக்பலம்"] = "Digbala";
      tMap["பாலதி"] = "Baladi";
      tMap["தீப்தாதி"] = "Deeptadi";
      tMap["ஜாக்ரதாதி"] = "Jagradadi";

      // Baladi, Deeptadi, Jagradadi states
      tMap["பால அவஸ்தை (குழந்தை)"] = "Bala Avastha (Infant)";
      tMap["குமார அவஸ்தை (வாலிபம்)"] = "Kumara Avastha (Youth)";
      tMap["யுவ அவஸ்தை (முழு பலம்)"] = "Yuva Avastha (Adult - Full Strength)";
      tMap["விருத்த அவஸ்தை (முதியவர்)"] = "Vriddha Avastha (Old Age)";
      tMap["மிருத அவஸ்தை (மரண நிலை)"] = "Mrita Avastha (Dead - Minimal)";
      tMap["சாந்த அவஸ்தை (அமைதி)"] = "Shanta Avastha (Peaceful)";
      tMap["கோப அவஸ்தை (அஸ்தமனம்)"] = "Kopa Avastha (Combust)";
      tMap["தீப்த அவஸ்தை (உச்சம்)"] = "Deepta Avastha (Exalted)";
      tMap["சுவஸ்த அவஸ்தை (ஆட்சி)"] = "Swastha Avastha (Own Sign)";
      tMap["முதித அவஸ்தை (நட்பு)"] = "Mudita Avastha (Friend Sign)";
      tMap["தீன அவஸ்தை (பகை)"] = "Deena Avastha (Enemy Sign)";
      tMap["கல அவஸ்தை (நீசம்)"] = "Khala Avastha (Debilitated)";
      tMap["ஸ்வப்ன நிலை (கனவு - 50%)"] = "Swapna (Dreaming - 50%)";
      tMap["ஜாக்ரத் நிலை (விழிப்பு - 100%)"] = "Jagrat (Awake - 100%)";
      tMap["சுஷுப்தி நிலை (உறக்கம் - 0%)"] = "Sushupti (Deep Sleep - 0%)";

      // Other Card Details
      tMap["ஜென்ம நட்சத்திரம்"] = "Janma Nakshatra";
      tMap["சந்திராஷ்டம நட்சத்திரம்"] = "Chandrashtama Nakshatra";
      tMap["யோகி கிரகம் / நட்சத்திரம்"] = "Yogi Planet / Nakshatra";
      tMap["அவயோகி கிரகம் / நட்சத்திரம்"] = "Avayogi Planet / Nakshatra";
      tMap["துணை யோகி (பகர்ப்பு யோகி)"] = "Upayogi (Duplicate Yogi)";
      tMap["முடக்கு ராசி / நட்சத்திரம்"] = "Mudakku Rasi / Nakshatra";
      tMap["பாதகாதிபதி"] = "Badhakadhipati";
      tMap["தாரக கிரகங்கள் (5, 9 திரிகோண அதிபதிகள்)"] = "Tharaka Planets (5, 9 Trikona Lords)";
      tMap["வைநாசிக நட்சத்திரம் / அதிபதி"] = "Vainashika Nakshatra / Lord";
      tMap["வைநாசிக பாதத்தில் உள்ள கிரகம்"] = "Planet in Vainashika Pada";
      tMap["கிரகங்கள் இல்லை (சுபம்)"] = "No planets (Auspicious)";
      tMap["புஷ்கர நவாம்சம்"] = "Pushkara Navamsha";
      tMap["புஷ்கர நிலை"] = "Pushkara Status";
      tMap["கர்ம நட்சத்திரம் (10-வது நட்சத்திரம்)"] = "Karma Nakshatra (10th Star)";
      tMap["கர்ம நட்சத்திரம்"] = "Karma Nakshatra";
      tMap["ராசி பரிவர்த்தனை"] = "Rasi Parivarthana";
      tMap["நட்சத்திர பரிவர்த்தனை"] = "Nakshatra Parivarthana";
      tMap["இந்து லக்னம் (Indu Lagna)"] = "Indu Lagna";
      tMap["பார்ச்சூனா புள்ளி (Fortuna)"] = "Fortuna Point";
      tMap["பதா / ஆருட லக்னம் (AL)"] = "Arudha Lagna (AL)";
      tMap["உபபதா லக்னம் (UL)"] = "Upapada Lagna (UL)";
      tMap["ஹோரா லக்னம் (HL)"] = "Hora Lagna (HL)";
      tMap["கடிகா லக்னம் (GL)"] = "Ghatika Lagna (GL)";
      tMap["கதிர்கள்"] = "Rays";

      // Sri, Tithi, Paksham
      tMap["ஸ்ரீ"] = "Sri";
      tMap["தேய்பிறை"] = "Waning Moon (Krishna Paksha)";
      tMap["வளர்பிறை"] = "Waxing Moon (Shukla Paksha)";
      tMap["(கிருஷ்ண பக்ஷம்)"] = "(Krishna Paksha)";
      tMap["(சுக்ல பக்ஷம்)"] = "(Shukla Paksha)";
      tMap["கிருஷ்ண பக்ஷம்"] = "Krishna Paksha";
      tMap["சுக்ல பக்ஷம்"] = "Shukla Paksha";
      tMap["பௌர்ணமி (சுக்ல பக்ஷம்)"] = "Full Moon (Shukla Paksha)";
      tMap["அமாவாசை (கிருஷ்ண பக்ஷம்)"] = "New Moon (Krishna Paksha)";
      tMap["பௌர்ணமி"] = "Pournami (Full Moon)";
      tMap["அமாவாசை"] = "Amavasya (New Moon)";

      // Chandrashtama & Ordinals
      tMap["சந்திராஷ்டம ராசி"] = "Chandrashtama Rasi";
      tMap["சந்திராஷ்டம நட்சத்திரம்"] = "Chandrashtama Nakshatra";
      tMap["சந்திராஷ்டம"] = "Chandrashtama";
      tMap["(17-வது நட்சத்திரம்)"] = "(17th Star)";
      tMap["17-வது நட்சத்திரம்"] = "17th Star";
      tMap["17-வது"] = "17th";
      tMap["(10-வது நட்சத்திரம்)"] = "(10th Star)";
      tMap["10-வது நட்சத்திரம்"] = "10th Star";
      tMap["10-வது"] = "10th";
      tMap["(19-வது நட்சத்திரம்)"] = "(19th Star)";
      tMap["19-வது நட்சத்திரம்"] = "19th Star";
      tMap["19-வது"] = "19th";
      tMap["(88-வது பாதம்)"] = "(88th Pada)";
      tMap["(88-வது Pada)"] = "(88th Pada)";
      tMap["88-வது பாதம்"] = "88th Pada";
      tMap["88-வது"] = "88th";
      tMap["-வது நட்சத்திரம்"] = "th Star";
      tMap["-வது பாதம்"] = "th Pada";
      tMap["-வது"] = "th";
      tMap["-ம் பாதம்"] = " Pada";
      tMap["-ம்"] = "";
      tMap["நட்சத்திரம்"] = "Star";

      // Vainashika & Tharais
      tMap["வைநாசிக தோஷ பாதம் (88-வது பாதம்)"] = "Vainashika Dosha Pada (88th Pada)";
      tMap["வைநாசிக தோஷ பாதம்"] = "Vainashika Dosha Pada";
      tMap["வைநாசிக தோஷ"] = "Vainashika Dosha";
      tMap["வைநாசிக"] = "Vainashika";
      tMap["1. ஜென்ம தாரை"] = "1. Janma Tharai";
      tMap["2. சம்பத்து தாரை"] = "2. Sampat Tharai";
      tMap["3. விபத்து தாரை"] = "3. Vipat Tharai";
      tMap["4. சேம தாரை"] = "4. Kshema Tharai";
      tMap["5. பிரத்யக் தாரை"] = "5. Pratyak Tharai";
      tMap["6. சாதக தாரை"] = "6. Sadhaka Tharai";
      tMap["7. வதை தாரை (அதி எச்சரிக்கை)"] = "7. Vadhai Tharai (High Warning)";
      tMap["7. வதை தாரை"] = "7. Vadhai Tharai";
      tMap["8. மைத்ர தாரை"] = "8. Mitra Tharai";
      tMap["9. பரம மைத்ர தாரை"] = "9. Parama Mitra Tharai";
      tMap["ஜென்ம தாரை"] = "Janma Tharai";
      tMap["சம்பத்து தாரை"] = "Sampat Tharai";
      tMap["விபத்து தாரை"] = "Vipat Tharai";
      tMap["சேம தாரை"] = "Kshema Tharai";
      tMap["பிரத்யக் தாரை"] = "Pratyak Tharai";
      tMap["சாதக தாரை"] = "Sadhaka Tharai";
      tMap["வதை தாரை"] = "Vadhai Tharai";
      tMap["மைத்ர தாரை"] = "Mitra Tharai";
      tMap["பரம மைத்ர தாரை"] = "Parama Mitra Tharai";
      tMap["தாரை"] = "Tharai";
      tMap["தாரைகளில்"] = "in Tharais";
      tMap["ஆதான நட்சத்திரம்"] = "Aadhana Nakshatra";
      tMap["கர்ம நட்சத்திரம்"] = "Karma Nakshatra";

      // Extreme Degrees & Notes
      tMap["வீட்டு அதிபதி"] = "House Lord";
      tMap["(வீட்டு அதிபதி"] = "(House Lord";
      tMap["கிரகங்களின் பாகை விவரம் (இறங்கு வரிசை):"] = "Planetary Degrees (Descending Order):";
      tMap["கிரகங்களின் பாகை விவரம் (இறங்கு வரிசை)"] = "Planetary Degrees (Descending Order)";
      tMap["கிரகங்களின் பாகை விவரம்"] = "Planetary Degrees";
      tMap["இறங்கு வரிசை"] = "Descending Order";

      // Special Lagna Points
      tMap["சிறப்பு லக்கின புள்ளிகள்"] = "Special Lagna Points";
      tMap["இந்து லக்னம் (Indu Lagna)"] = "Indu Lagna";
      tMap["இந்து லக் (Indu லக்)"] = "Indu Lagna";
      tMap["இந்து லக்னம்"] = "Indu Lagna";
      tMap["இந்து லக்"] = "Indu Lagna";
      tMap["இந்து Asc (Indu Asc)"] = "Indu Lagna";
      tMap["இந்து"] = "Indu";
      tMap["பார்ச்சூனா புள்ளி (Fortuna)"] = "Fortuna Point";
      tMap["பார்ச்சூனா புள்ளி"] = "Fortuna Point";
      tMap["பதா / ஆருட லக்னம் (AL)"] = "Pada / Arudha Lagna (AL)";
      tMap["பதா / ஆருட லக்னம்"] = "Pada / Arudha Lagna (AL)";
      tMap["பதா / ஆரூட லக்னம் (AL)"] = "Pada / Arudha Lagna (AL)";
      tMap["பதா / ஆரூட லக்னம்"] = "Pada / Arudha Lagna (AL)";
      tMap["பதா / ஆரூட Asc (AL)"] = "Pada / Arudha Lagna (AL)";
      tMap["பதா / ஆருட Asc (AL)"] = "Pada / Arudha Lagna (AL)";
      tMap["பதா / ஆரூட"] = "Pada / Arudha";
      tMap["பதா / ஆருட"] = "Pada / Arudha";
      tMap["ஆருட லக்னம்"] = "Arudha Lagna";
      tMap["ஆரூட லக்னம்"] = "Arudha Lagna";
      tMap["உபபதா லக்னம் (UL)"] = "Upapada Lagna (UL)";
      tMap["உபபதா லக்னம்"] = "Upapada Lagna (UL)";
      tMap["உபபதா Asc (UL)"] = "Upapada Lagna (UL)";
      tMap["உபபதா"] = "Upapada";
      tMap["ஹோரா லக்னம் (HL)"] = "Hora Lagna (HL)";
      tMap["ஹோரா லக்னம்"] = "Hora Lagna (HL)";
      tMap["ஹோரா Asc (HL)"] = "Hora Lagna (HL)";
      tMap["ஹோரா"] = "Hora";
      tMap["கடிகா லக்னம் (GL)"] = "Ghatika Lagna (GL)";
      tMap["கடிகா லக்னம்"] = "Ghatika Lagna (GL)";
      tMap["கடிகா Asc (GL)"] = "Ghatika Lagna (GL)";
      tMap["கடிகா"] = "Ghatika";

      // Tabs
      tMap["ஷட்பலம்"] = "Shadbala";
      tMap["வழிபாட்டு தலங்கள்"] = "Worship Temples";
      tMap["வழிபாட்டுத் தலங்கள்"] = "Worship Temples";

      // Shadbala Strengths
      tMap["மிக பலம் (Very Strong)"] = "Very Strong";
      tMap["போதுமான பலம் (Strong)"] = "Strong";
      tMap["பலவீனமானது (Weak)"] = "Weak";
      tMap["மிக பலம்"] = "Very Strong";
      tMap["போதுமான பலம்"] = "Strong";
      tMap["பலவீனமானது"] = "Weak";

      // Worship Temples Screen
      tMap["ஜாதகருக்குரிய வழிபாட்டு அட்டவணை"] = "Personalized Temple Worship Schedule";
      tMap["நட்சத்திரம், யோகி, அவயோகி, திதி அதிதேவதை, கரண நாதன், வைநாசிகம் மற்றும் முடக்கு பாவகம் அடிப்படையிலான திருத்தலங்கள்"] = "Temples based on Birth Star, Yogi, Avayogi, Thithi Deity, Karana Lord, Vainasika and Mudakku Bhava";
      tMap["1. ஜன்ம நட்சத்திரக் கோவில்"] = "1. Birth Star Temple (Janma Nakshatra)";
      tMap["2. யோகி கோவில் (சுப யோகம்)"] = "2. Yogi Temple (Auspicious Yoga)";
      tMap["3. அவயோகி பரிகாரக் கோவில் (தோஷ நிவர்த்தி)"] = "3. Avayogi Remedy Temple (Dosha Relief)";
      tMap["4. திதி அதிதேவதை & கோவில்"] = "4. Thithi Deity & Temple";
      tMap["5. கரண நாதன் கோவில்"] = "5. Karana Lord Temple";
      tMap["6. வைநாசிக நட்சத்திரக் கோவில் (88-வது பாதம்)"] = "6. Vainasika Star Temple (88th Pada)";
      tMap["7. முடக்கு ராசி / பாவகக் கோவில்"] = "7. Mudakku Rasi / House Temple";

      tMap["ஜன்ம நட்சத்திர அதிதேவதை அருள், ஆயுள் பலம் & மன அமைதிக்கு"] = "For blessings of Birth Star deity, longevity & peace of mind";
      tMap["சுப யோக பலன்கள் முழுமையாகக் கிடைக்க, தன வரவு & தொழில் மேன்மை"] = "To receive full auspicious yoga benefits, wealth inflow & career growth";
      tMap["அவயோக தோஷம் நீங்க, தடைகள் மற்றும் மன உளைச்சல்கள் விலக"] = "For relief from Avayoga dosha, removal of obstacles & mental distress";
      tMap["திதி சூன்ய தோஷம் நீங்க, ஆத்ம பலம் மற்றும் காரிய சித்தி"] = "For relief from Thithi Shoonya dosha, inner strength & success in endeavors";
      tMap["தொழில், உத்தியோகம் & அன்றாடச் செயல்களில் தடைகள் நீங்கி வெற்றி"] = "For success in profession, employment & smooth daily activities";
      tMap["88-வது பாத வைநாசிக தோஷ நிவர்த்தி, விபத்து & கண்டங்கள் விலக"] = "For relief from 88th pada Vainasika dosha, protection from accidents & dangers";
      tMap["முடக்கு தோஷம் நிவர்த்தியாகி பாவக காரகங்கள் நற்பலன் தர"] = "For remedy of Mudakku dosha & to activate positive house results";

      tMap["அவயோகி கிரகம்:"] = "Avayogi Planet:";
      tMap["அவயோகி கிரகம்"] = "Avayogi Planet";
      tMap["யோகி கிரகம்"] = "Yogi Planet";
      tMap["துணை யோகி"] = "Upayogi";
      tMap["முடக்கு ராசி"] = "Mudakku Rasi";
      tMap["முடக்கு பாவம்"] = "Mudakku Bhava";
      tMap["வளர்பிறை"] = "Waxing (Shukla)";
      tMap["தேய்பிறை"] = "Waning (Krishna)";
      tMap["தெய்வம்:"] = "Deity:";
      tMap["தெய்வம்"] = "Deity";
      tMap["மிருகம்:"] = "Animal:";
      tMap["மிருகம்"] = "Animal";
      tMap["கதிர்கள்"] = "Rays";
      tMap["நாதா:"] = "Lord:";
      tMap["நாதன்:"] = "Lord:";
      tMap["யோகி:"] = "Yogi:";
      tMap["-ஆம் பாதம்"] = "Pada";
      tMap["-ஆம் பாவம்"] = "House";
      tMap["லக்னத்திலிருந்து"] = "from Lagna";

      // Nakshatra Details: Animals (Mirugam)
      tMap["ஆண்குதிரை"] = "Male Horse";
      tMap["பெண்குதிரை"] = "Female Horse";
      tMap["ஆண்யானை"] = "Male Elephant";
      tMap["பெண்யானை"] = "Female Elephant";
      tMap["பெண் ஆடு"] = "Female Sheep / Goat";
      tMap["ஆண்ஆடு"] = "Male Ram / Goat";
      tMap["ஆண்நாகம்"] = "Male Cobra";
      tMap["பெண்சாரை"] = "Female Rat Snake";
      tMap["ஆண்நாய்"] = "Male Dog";
      tMap["பெண்நாய்"] = "Female Dog";
      tMap["ஆண்பூனை"] = "Male Cat";
      tMap["பெண்பூனை"] = "Female Cat";
      tMap["ஆண்எலி"] = "Male Rat";
      tMap["பெண்எலி"] = "Female Rat";
      tMap["ஆண்பசு"] = "Bull";
      tMap["பெண்பசு"] = "Cow";
      tMap["ஆண்கீரி/பசு"] = "Male Mongoose / Cow";
      tMap["ஆண்கீரி"] = "Male Mongoose";
      tMap["பெண்கீரி"] = "Female Mongoose";
      tMap["ஆண்எருமை"] = "Male Buffalo";
      tMap["பெண்எருமை"] = "Female Buffalo";
      tMap["ஆண்புலி"] = "Male Tiger";
      tMap["பெண்புலி"] = "Female Tiger";
      tMap["ஆண்மான்"] = "Male Deer";
      tMap["பெண்மான்"] = "Female Deer";
      tMap["ஆண்குரங்கு"] = "Male Monkey";
      tMap["பெண்குரங்கு"] = "Female Monkey";
      tMap["ஆண்சிங்கம்"] = "Male Lion";
      tMap["பெண்சிங்கம்"] = "Female Lion";

      // Birds (Pakshi)
      tMap["ராசாளி"] = "Hawk / Eagle";
      tMap["காகம்"] = "Crow";
      tMap["மயில்"] = "Peacock";
      tMap["ஆந்தை"] = "Owl";
      tMap["கோழி"] = "Cock / Hen";
      tMap["அன்றில்"] = "Nightjar";
      tMap["அன்னம்"] = "Swan";
      tMap["நீர்காகம்"] = "Cormorant";
      tMap["கிச்சிலி"] = "Kingfisher";
      tMap["ஆண்கழுகு"] = "Male Vulture";
      tMap["பெண்கழுகு"] = "Female Vulture";
      tMap["கழுகு"] = "Vulture";
      tMap["கௌதாரி"] = "Partridge";
      tMap["பருந்து"] = "Kite";
      tMap["மரங்கொத்தி"] = "Woodpecker";
      tMap["தேனீ"] = "Honeybee";
      tMap["குருவி"] = "Sparrow";
      tMap["வானம்பாடி"] = "Skylark";
      tMap["சக்கரவாளம்"] = "Ruddy Shelduck";
      tMap["செம்பருந்து"] = "Brahminy Kite";
      tMap["வலியான்"] = "Drongo";
      tMap["நாரை"] = "Stork";
      tMap["பொன்வண்டு"] = "Golden Beetle";
      tMap["அண்டங்காக்கை"] = "Raven";
      tMap["உள்ளான்"] = "Sandpiper";
      tMap["கோட்டான்"] = "Barn Owl";
      tMap["வல்லூறு"] = "Falcon";

      // Trees (Maram)
      tMap["எட்டி"] = "Strychnine Tree";
      tMap["நெல்லி"] = "Amla";
      tMap["அத்தி(பா)"] = "Cluster Fig";
      tMap["அத்தி"] = "Cluster Fig";
      tMap["நாவல்(பா)"] = "Jamun";
      tMap["நாவல்"] = "Jamun";
      tMap["கருங்காலி"] = "Ebony (Black Catechu)";
      tMap["செங்கரு"] = "Red Catechu";
      tMap["மூங்கில்"] = "Bamboo";
      tMap["அரசு(பா)"] = "Peepal";
      tMap["அரசு"] = "Peepal";
      tMap["புன்னை(பா)"] = "Alexandrian Laurel";
      tMap["புன்னை"] = "Alexandrian Laurel";
      tMap["ஆல்(பா)"] = "Banyan";
      tMap["ஆல்"] = "Banyan";
      tMap["பலா(பா)"] = "Jackfruit";
      tMap["பலா"] = "Jackfruit";
      tMap["அலரி(பா)"] = "Oleander";
      tMap["அலரி"] = "Oleander";
      tMap["வில்வம்"] = "Bael Tree";
      tMap["மருதம்"] = "Arjuna Tree";
      tMap["விளா"] = "Wood Apple";
      tMap["மகிழம்"] = "Bakula Tree";
      tMap["பராய்(பா)"] = "Siamese Rough Bush";
      tMap["பராய்"] = "Siamese Rough Bush";
      tMap["மராமரம்"] = "Sal Tree";
      tMap["வஞ்சி(பா)"] = "Willow Tree";
      tMap["வஞ்சி"] = "Willow Tree";
      tMap["எருக்கு(பா)"] = "Calotropis";
      tMap["எருக்கு"] = "Calotropis";
      tMap["வன்னி"] = "Khejri Tree";
      tMap["கடம்பு"] = "Kadamba";
      tMap["தேமா(பா)"] = "Sweet Mango";
      tMap["தேமா"] = "Sweet Mango";
      tMap["வேம்பு"] = "Neem";
      tMap["இலுப்பை"] = "Mahua";

      // Ganam, Naadi, Rajju, Angam
      tMap["தேவ"] = "Deva";
      tMap["மனுஷ"] = "Manusha";
      tMap["ராக்ஷஸ"] = "Rakshasa";
      tMap["தஷிண பார்சுவ நாடி"] = "Dakshina Parsva Naadi";
      tMap["மத்திய பார்சுவ நாடி"] = "Madhya Parsva Naadi";
      tMap["வாம பார்சுவ நாடி"] = "Vama Parsva Naadi";
      tMap["சிரசு(தலை)"] = "Head";
      tMap["சிரசு"] = "Head";
      tMap["ஏறுபாதம்"] = "Ascending Foot";
      tMap["ஏறுதொடை"] = "Ascending Thigh";
      tMap["ஏறுவயிறு"] = "Ascending Abdomen";
      tMap["ஏறுகழுத்து"] = "Ascending Neck";
      tMap["இறங்குகழுத்து"] = "Descending Neck";
      tMap["இறங்குவயிறு"] = "Descending Abdomen";
      tMap["இறங்குதொடை"] = "Descending Thigh";
      tMap["இறங்குபாதம்"] = "Descending Foot";
      tMap["சிரசு ரஜ்ஜு"] = "Sirsu Rajju";
      tMap["கண்ட ரஜ்ஜு"] = "Kanta Rajju";
      tMap["உதர ரஜ்ஜு"] = "Udara Rajju";
      tMap["நாபி ரஜ்ஜு"] = "Nabhi Rajju";
      tMap["கட்டி ரஜ்ஜு"] = "Kati Rajju";
      tMap["பாத ரஜ்ஜு"] = "Pada Rajju";
      tMap["ஆரோகண சிரசு ரஜ்ஜு"] = "Arohana Sirasu Rajju";
      tMap["அவரோகண சிரசு ரஜ்ஜு"] = "Avarohana Sirasu Rajju";
      tMap["யோனி"] = "Yoni";
      tMap["ரஜ்ஜு"] = "Rajju";
      tMap["நாடி"] = "Naadi";
      tMap["அங்கம்"] = "Angam";
      tMap["ஆண்"] = "Male";
      tMap["பெண்"] = "Female";

      // Kala Natpu & Kala Pagai phrases
      tMap["கால நட்பு"] = "Kala Natpu (Auspicious Period)";
      tMap["காலப்பகை"] = "Kala Pagai (Inauspicious Period)";
      tMap["தற்போது காலநட்பு பருவம்"] = "Current Auspicious Kala Natpu Period";
      tMap["தற்போது காலப்பகை பருவம்"] = "Current Inauspicious Kala Pagai Period";
      tMap["காலநட்பு வயது & திசை விவரங்கள்:"] = "Kala Natpu Age & Dasa Details:";
      tMap["காலப்பகை வயது & திசை விவரங்கள்:"] = "Kala Pagai Age & Dasa Details:";
      tMap["காலப்பகை தசா - புத்தி எச்சரிக்கைகள்:"] = "Kala Pagai Dasa - Bhukthi Warnings:";
      tMap["திசை"] = "Dasa";
      tMap["தசை"] = "Dasa";
      tMap["புத்தி"] = "Bhukthi";
      tMap["நடைபெறுகிறது"] = "is currently running";
      tMap["தற்போது நடக்கிறது"] = "Currently Running";
      tMap["காலப்பகை அமைப்பாகும்"] = "is a Kala Pagai period";

      // Upagrahas
      tMap["உபகிரகங்கள் (மிருத்யு, எமகண்டன் உள்ளிட்டவை)"] = "Upagrahas (including Mrityu, Yamakantaka)";
      tMap["உபகிரகங்கள்"] = "Upagrahas";
      tMap["தூமன் (Dhuma)"] = "Dhuma";
      tMap["வ்யதீபாதன் (Vyatipata)"] = "Vyatipata";
      tMap["பரிவேடன் (Parivesha)"] = "Parivesha";
      tMap["இந்திரதனுசு (Indradhanusu)"] = "Indradhanusu";
      tMap["உபகேது (Upaketu)"] = "Upaketu";
      tMap["எமகண்டன் (Yamagandan)"] = "Yamakantaka (Yamagandan)";
      tMap["மிருத்யு (Mrityu)"] = "Mrityu";
      tMap["தூமன்"] = "Dhuma";
      tMap["வ்யதீபாதன்"] = "Vyatipata";
      tMap["பரிவேடன்"] = "Parivesha";
      tMap["இந்திரதனுசு"] = "Indradhanusu";
      tMap["உபகேது"] = "Upaketu";
      tMap["எமகண்டன்"] = "Yamakantaka";
      tMap["மிருத்யு"] = "Mrityu";

      // Jaimini Seven Karakas
      tMap["ஜெமினி ஏழு காரகங்கள்"] = "Jaimini Seven Karakas";
      tMap["ஆத்மகாரகன் (AK)"] = "Atmakaraka (AK)";
      tMap["அமாத்யகாரகன் (AmK)"] = "Amatyakaraka (AmK)";
      tMap["பிராத்ருகாரகன் (BK)"] = "Bhratrukaraka (BK)";
      tMap["மாத்ருகாரகன் (MK)"] = "Matrukaraka (MK)";
      tMap["புத்ரகாரகன் (PK)"] = "Putrakaraka (PK)";
      tMap["ஞானதிகாரகன் (GK)"] = "Gnatikaraka (GK)";
      tMap["தாரகாரகன் (DK)"] = "Darakaraka (DK)";
      tMap["ஆத்மகாரகன்"] = "Atmakaraka";
      tMap["அமாத்யகாரகன்"] = "Amatyakaraka";
      tMap["பிராத்ருகாரகன்"] = "Bhratrukaraka";
      tMap["மாத்ருகாரகன்"] = "Matrukaraka";
      tMap["புத்ரகாரகன்"] = "Putrakaraka";
      tMap["ஞானதிகாரகன்"] = "Gnatikaraka";
      tMap["தாரகாரகன்"] = "Darakaraka";
      tMap["ஆன்மா, தலைமை, சுய வளர்ச்சி (Highest Degree)"] = "Soul, Leadership, Self-Growth (Highest Degree)";
      tMap["தொழில், அந்தஸ்து, அமைச்சர் நிலை"] = "Profession, Status, Position";
      tMap["சகோதரம், தைரியம், வழிகாட்டுதல்"] = "Siblings, Courage, Guidance";
      tMap["தாய், கல்வி, சுகபோகங்கள்"] = "Mother, Education, Luxuries";
      tMap["புத்திர பாக்கியம், புத்தி கூர்மை"] = "Children, Intellect, Wisdom";
      tMap["எதிரிகள், கடன், நோய், உறவுகள்"] = "Enemies, Debts, Illness, Relatives";
      tMap["வாழ்க்கைத் துணை, கூட்டுத் தொழில் (Lowest Degree)"] = "Spouse, Partnerships (Lowest Degree)";

      // Age and Age Ranges
      tMap["வயது"] = "Age";
      tMap["வயது வரை"] = "Years";
      tMap["வயதுக்குள்"] = "Years";
      tMap["முதல்"] = "to";
      tMap["வரை"] = "to";
      tMap["1 வயதுக்குள்"] = "Within 1 Year";
      tMap["2 முதல் 3 வயது வரை"] = "Age 2 to 3";
      tMap["4 முதல் 12 வயது வரை"] = "Age 4 to 12";
      tMap["12 முதல் 32 வயது வரை"] = "Age 12 to 32";
      tMap["33 முதல் 50 வயது வரை"] = "Age 33 to 50";
      tMap["51 முதல் 70 வயது வரை"] = "Age 51 to 70";
      tMap["71 முதல் 120 வயது வரை"] = "Age 71 to 120";
      tMap["2 வயது வரை"] = "Up to Age 2";
      tMap["3 முதல் 18 வயதுக்குள்"] = "Age 3 to 18";
      tMap["11 முதல் 12 வயதுக்குள்"] = "Age 11 to 12";
      tMap["18 முதல் 34 வயதுக்குள்"] = "Age 18 to 34";
      tMap["34 முதல் 52 வயதுக்குள்"] = "Age 34 to 52";
      tMap["52 முதல் 68 வயதுக்குள்"] = "Age 52 to 68";
      tMap["68 முதல் 100 வயதுக்குள்"] = "Age 68 to 100";

      // Dasa / Disai terms
      tMap["சூரிய தசை"] = "Sun Dasa";
      tMap["சூரியன் தசை"] = "Sun Dasa";
      tMap["சூரிய திசை"] = "Sun Dasa";
      tMap["சூரியன் திசை"] = "Sun Dasa";
      tMap["சந்திர தசை"] = "Moon Dasa";
      tMap["சந்திரன் தசை"] = "Moon Dasa";
      tMap["சந்திர திசை"] = "Moon Dasa";
      tMap["சந்திரன் திசை"] = "Moon Dasa";
      tMap["செவ்வாய் தசை"] = "Mars Dasa";
      tMap["செவ்வாய் திசை"] = "Mars Dasa";
      tMap["புதன் தசை"] = "Mercury Dasa";
      tMap["புதன் திசை"] = "Mercury Dasa";
      tMap["குரு தசை"] = "Jupiter Dasa";
      tMap["குரு திசை"] = "Jupiter Dasa";
      tMap["சுக்கிர தசை"] = "Venus Dasa";
      tMap["சுக்கிரன் தசை"] = "Venus Dasa";
      tMap["சுக்கிர திசை"] = "Venus Dasa";
      tMap["சுக்கிரன் திசை"] = "Venus Dasa";
      tMap["சனி தசை"] = "Saturn Dasa";
      tMap["சனி திசை"] = "Saturn Dasa";
      tMap["ராகு தசை"] = "Rahu Dasa";
      tMap["ராகு திசை"] = "Rahu Dasa";
      tMap["கேது தசை"] = "Ketu Dasa";
      tMap["கேது திசை"] = "Ketu Dasa";

      // Dasa Nalvar
      tMap["தசா நாதனின் நால்வர் (போதகன், வேதகன், பாசகன், காரகன்)"] = "Dasa Lord's Associates (Bodhaka, Vedhaka, Pachaka, Karaka)";
      tMap["தசா நாதனின் நால்வர்"] = "Dasa Lord's Associates";
      tMap["நால்வர் (துணைவர்கள்)"] = "Four Associates (Nalvar)";
      tMap["நால்வர்"] = "Four Associates";
      tMap["போதகன்"] = "Bodhaka (Instructor)";
      tMap["வேதகன்"] = "Vedhaka (Blocker)";
      tMap["பாசகன்"] = "Pachaka (Activator)";
      tMap["காரகன்"] = "Karaka (Significator)";
      tMap["நற்பலன் தருபவர்"] = "Giver of good results";
      tMap["தடை தருபவர்"] = "Creator of obstacles";
      tMap["அனுபவிக்க வைப்பவர்"] = "Bringer of experiences";
      tMap["நிலைநிறுத்துபவர்"] = "Establisher & Sustainer";

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
      tMap["ஜனன கால புத்தி இருப்பு"] = "जन्म भुक्ति शेष (Birth Bhukti Bal)";
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
      tMap["அதிக பாகை பெற்ற கிரகம்"] = "अधिकतम अंश वाला ग्रह (Highest Degree Planet)";
      tMap["குறைந்த பாகை பெற்ற கிரகம்"] = "न्यूनतम अंश वाला ग्रह (Lowest Degree Planet)";
      tMap["ஆகமி கிரகம்"] = "आगामी ग्रह (Aagami Grahas)";
      tMap["ஆகாமி கிரகம்"] = "आगामी ग्रह (Aagami Grahas)";
      tMap["வரு"] = "वर्ष";
      tMap["மா"] = "माह";
      tMap["நா"] = "दिन";
      tMap["வரை"] = "तक";
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

      // Horoscope Result Card Titles & Subsections
      tMap["பிறப்பு விவரம்"] = "जन्म विवरण";
      tMap["பஞ்சாங்கம்"] = "पंचांग";
      tMap["ஜோதிட அடிப்படை"] = "ज्योतिषीय मूल बातें";
      tMap["நேரம் யோகங்கள்"] = "समय एवं योग";
      tMap["நேரம் & யோகங்கள்"] = "समय एवं योग";
      tMap["யோகி அவயோகி பாத அமைப்புகள்"] = "योगी अवयोगी स्थिति";
      tMap["வைனாசிகம் புஷ்கர நவம்சம்"] = "वैनाशिक एवं पुष्कर नवांश";
      tMap["அதிக பாதை பெற்ற கிரகம் குறைந்த பாகை பெற்ற கிரகம்"] = "अधिकतम एवं न्यूनतम अंश ग्रह";
      tMap["அதிக பாகை பெற்ற கிரகம் குறைந்த பாகை பெற்ற கிரகம்"] = "अधिकतम एवं न्यूनतम अंश ग्रह";
      tMap["கிரகங்களின் பாகை விவரம் (இறங்கு வரிசை):"] = "ग्रह अंश विवरण (अवरोही क्रम):";
      tMap["கிரகங்களின் பாகை விவரம்"] = "ग्रह अंश विवरण";
      tMap["ஆகமிக்கிரகம்"] = "आगामी ग्रह";
      tMap["ஆகமி கிரகங்கள்"] = "आगामी ग्रह";
      tMap["ஆகமிக் கிரகம்"] = "आगामी ग्रह";
      tMap["ஆகமி கிரகம்"] = "आगामी ग्रह";
      tMap["ஆகாமி கிரகம்"] = "आगामी ग्रह";
      tMap["தன் சொந்த நட்சத்திர சாரத்தில் பிற கிரகங்கள் அமையப் பெறாத கிரகங்கள் ஆகமி கிரகங்கள் ஆகும்."] = "वे ग्रह जिनके अपने नक्षत्र में अन्य ग्रह स्थित नहीं हैं, आगामी ग्रह कहलाते हैं।";
      tMap["அனைத்து கிரகங்களின் நட்சத்திர சாரங்களிலும் பிற கிரகங்கள் அமர்ந்துள்ளன."] = "सभी ग्रहों के नक्षत्रों में अन्य ग्रह स्थित हैं।";
      tMap["ஆகமி கிரகம் (எந்தக் கிரகமும் அமையவில்லை)"] = "आगामी ग्रह (कोई ग्रह स्थित नहीं)";
      tMap["(எந்தக் கிரகமும் அமையவில்லை)"] = "(कोई ग्रह स्थित नहीं)";
      tMap["அமர்ந்துள்ள கிரகங்கள்:"] = "स्थित ग्रह:";
      tMap["அமர்ந்துள்ள கிரகங்கள்"] = "स्थित ग्रह";
      tMap["இல்லை"] = "कोई नहीं";
      tMap["கிரக அவஸ்தைகள்"] = "ग्रह अवस्थाएं";
      tMap["நட்சத்திர விவரம்"] = "नक्षत्र विवरण";
      tMap["சுப அசுப கிரகங்கள்"] = "शुभ एवं अशुभ ग्रह";
      tMap["சுப/அசுப கிரகங்கள்"] = "शुभ एवं अशुभ ग्रह";
      tMap["சிறப்பு லக்கின புள்ளிகள்"] = "विशेष लग्न बिंदु";
      tMap["உபகிரகங்கள் (மிருத்யு, எமகண்டன் உள்ளிட்டவை)"] = "उपग्रह (मृत्यु, यमघंटक सहित)";
      tMap["உபகிரகங்கள்"] = "उपग्रह";
      tMap["ஜெமினி ஏழு காரகங்கள்"] = "जैमिनी सात कारक";
      tMap["பரிவர்த்தனை யோகங்கள்"] = "परिवर्तन योग";
      tMap["கால நட்பு"] = "काल मित्र";
      tMap["காலநட்பு"] = "काल मित्र";
      tMap["காலப்பகை"] = "काल शत्रु";
      tMap["காலநட்பு வயது & திசை விவரங்கள்:"] = "काल मित्र आयु एवं दशा विवरण:";
      tMap["காலப்பகை வயது & திசை விவரங்கள்:"] = "काल शत्रु आयु एवं दशा विवरण:";
      tMap["காலப்பகை தசா - புத்தி எச்சரிக்கைகள்:"] = "काल शत्रु दशा - भुक्ति चेतावनी:";
      tMap["விவரங்கள் இல்லை"] = "विवरण उपलब्ध नहीं";
      tMap["(தற்போது நடக்கிறது)"] = "(वर्तमान में सक्रिय)";
      tMap["திக்பலம்"] = "दिग्बल";
      tMap["பாலதி"] = "बालादि";
      tMap["தீப்தாதி"] = "दीप्तादि";
      tMap["ஜாக்ரதாதி"] = "जाग्रदादि";

      // Baladi, Deeptadi, Jagradadi states
      tMap["பால அவஸ்தை (குழந்தை)"] = "बाल अवस्था (शिशु)";
      tMap["குமார அவஸ்தை (வாலிபம்)"] = "कुमार अवस्था (युवा)";
      tMap["யுவ அவஸ்தை (முழு பலம்)"] = "युव अवस्था (पूर्ण बल)";
      tMap["விருத்த அவஸ்தை (முதியவர்)"] = "वृद्ध अवस्था (वृद्ध)";
      tMap["மிருத அவஸ்தை (மரண நிலை)"] = "मृत अवस्था (शून्य बल)";
      tMap["சாந்த அவஸ்தை (அமைதி)"] = "शांत अवस्था (शांति)";
      tMap["கோப அவஸ்தை (அஸ்தமனம்)"] = "कोप अवस्था (अस्त)";
      tMap["தீப்த அவஸ்தை (உச்சம்)"] = "दीप्त अवस्था (उच्च)";
      tMap["சுவஸ்த அவஸ்தை (ஆட்சி)"] = "स्वस्थ अवस्था (स्वराशि)";
      tMap["முதித அவஸ்தை (நட்பு)"] = "मुदित अवस्था (मित्र राशि)";
      tMap["தீன அவஸ்தை (பகை)"] = "दीन अवस्था (शत्रु राशि)";
      tMap["கல அவஸ்தை (நீசம்)"] = "खल अवस्था (नीच)";
      tMap["ஸ்வப்ன நிலை (கனவு - 50%)"] = "स्वप्न अवस्था (50%)";
      tMap["ஜாக்ரத் நிலை (விழிப்பு - 100%)"] = "जाग्रत अवस्था (100%)";
      tMap["சுஷுப்தி நிலை (உறக்கம் - 0%)"] = "सुषुप्ति अवस्था (0%)";

      // Other Card Details
      tMap["ஜென்ம நட்சத்திரம்"] = "जन्म नक्षत्र";
      tMap["சந்திராஷ்டம நட்சத்திரம்"] = "चंद्राष्टम नक्षत्र";
      tMap["யோகி கிரகம் / நட்சத்திரம்"] = "योगी ग्रह / नक्षत्र";
      tMap["அவயோகி கிரகம் / நட்சத்திரம்"] = "अवयोगी ग्रह / नक्षत्र";
      tMap["துணை யோகி (பகர்ப்பு யோகி)"] = "उपयोगी";
      tMap["முடக்கு ராசி / நட்சத்திரம்"] = "मुडक्कु राशि / नक्षत्र";
      tMap["பாதகாதிபதி"] = "बाधकाधिपति";
      tMap["தாரக கிரகங்கள் (5, 9 திரிகோண அதிபதிகள்)"] = "तारक ग्रह (5, 9 त्रिकोण स्वामी)";
      tMap["வைநாசிக நட்சத்திரம் / அதிபதி"] = "वैनाशिक नक्षत्र / स्वामी";
      tMap["வைநாசிக பாதத்தில் உள்ள கிரகம்"] = "वैनाशिक पद में स्थित ग्रह";
      tMap["கிரகங்கள் இல்லை (சுபம்)"] = "कोई ग्रह नहीं (शुभ)";
      tMap["புஷ்கர நவாம்சம்"] = "पुष्कर नवांश";
      tMap["புஷ்கர நிலை"] = "पुष्कर स्थिति";
      tMap["கர்ம நட்சத்திரம் (10-வது நட்சத்திரம்)"] = "कर्म नक्षत्र (10वां नक्षत्र)";
      tMap["கர்ம நட்சத்திரம்"] = "कर्म नक्षत्र";
      tMap["ராசி பரிவர்த்தனை"] = "राशि परिवर्तन";
      tMap["நட்சத்திர பரிவர்த்தனை"] = "नक्षत्र परिवर्तन";
      tMap["இந்து லக்னம் (Indu Lagna)"] = "इंदु लग्न";
      tMap["பார்ச்சூனா புள்ளி (Fortuna)"] = "फॉर्च्यूना बिंदु";
      tMap["பதா / ஆருட லக்னம் (AL)"] = "आरूढ़ लग्न (AL)";
      tMap["உபபதா லக்னம் (UL)"] = "उपपद लग्न (UL)";
      tMap["ஹோரா லக்னம் (HL)"] = "होरा लग्न (HL)";
      tMap["கடிகா லக்னம் (GL)"] = "घटिका लग्न (GL)";
      tMap["கதிர்கள்"] = "किरणें";

      // Sri, Tithi, Paksham
      tMap["ஸ்ரீ"] = "श्री";
      tMap["தேய்பிறை"] = "कृष्ण पक्ष";
      tMap["வளர்பிறை"] = "शुक्ल पक्ष";
      tMap["(கிருஷ்ண பக்ஷம்)"] = "(कृष्ण पक्ष)";
      tMap["(சுக்ல பக்ஷம்)"] = "(शुक्ल पक्ष)";
      tMap["கிருஷ்ண பக்ஷம்"] = "कृष्ण पक्ष";
      tMap["சுக்ல பக்ஷம்"] = "शुक्ल पक्ष";
      tMap["பௌர்ணமி (சுக்ல பக்ஷம்)"] = "पूर्णिमा (शुक्ल पक्ष)";
      tMap["அமாவாசை (கிருஷ்ண பக்ஷம்)"] = "अमावस्या (कृष्ण पक्ष)";
      tMap["பௌர்ணமி"] = "पूर्णिमा";
      tMap["அமாவாசை"] = "अमावस्या";

      // Chandrashtama & Ordinals
      tMap["சந்திராஷ்டம ராசி"] = "चंद्राष्टम राशि";
      tMap["சந்திராஷ்டம நட்சத்திரம்"] = "चंद्राष्टम नक्षत्र";
      tMap["சந்திராஷ்டம"] = "चंद्राष्टम";
      tMap["(17-வது நட்சத்திரம்)"] = "(17वां नक्षत्र)";
      tMap["17-வது நட்சத்திரம்"] = "17वां नक्षत्र";
      tMap["17-வது"] = "17वां";
      tMap["(10-வது நட்சத்திரம்)"] = "(10वां नक्षत्र)";
      tMap["10-வது நட்சத்திரம்"] = "10वां नक्षत्र";
      tMap["10-வது"] = "10वां";
      tMap["(19-வது நட்சத்திரம்)"] = "(19वां नक्षत्र)";
      tMap["19-வது நட்சத்திரம்"] = "19वां नक्षत्र";
      tMap["19-வது"] = "19वां";
      tMap["(88-வது பாதம்)"] = "(88वां पद)";
      tMap["(88-வது Pada)"] = "(88वां पद)";
      tMap["88-வது பாதம்"] = "88वां पद";
      tMap["88-வது"] = "88वां";
      tMap["-வது நட்சத்திரம்"] = "वां नक्षत्र";
      tMap["-வது பாதம்"] = "वां पद";
      tMap["-வது"] = "वां";
      tMap["-ம் பாதம்"] = " पद";
      tMap["-ம்"] = "";
      tMap["நட்சத்திரம்"] = "नक्षत्र";

      // Vainashika & Tharais
      tMap["வைநாசிக தோஷ பாதம் (88-வது பாதம்)"] = "वैनाशिक दोष पद (88वां पद)";
      tMap["வைநாசிக தோஷ பாதம்"] = "वैनाशिक दोष पद";
      tMap["வைநாசிக தோஷ"] = "वैनाशिक दोष";
      tMap["வைநாசிக"] = "वैनाशिक";
      tMap["1. ஜென்ம தாரை"] = "1. जन्म तारा";
      tMap["2. சம்பத்து தாரை"] = "2. संपत तारा";
      tMap["3. விபத்து தாரை"] = "3. विपत तारा";
      tMap["4. சேம தாரை"] = "4. क्षेम तारा";
      tMap["5. பிரத்யக் தாரை"] = "5. प्रत्यक तारा";
      tMap["6. சாதக தாரை"] = "6. साधक तारा";
      tMap["7. வதை தாரை (அதி எச்சரிக்கை)"] = "7. वध तारा (अति चेतावनी)";
      tMap["7. வதை தாரை"] = "7. वध तारा";
      tMap["8. மைத்ர தாரை"] = "8. मित्र तारा";
      tMap["9. பரம மைத்ர தாரை"] = "9. परम मित्र तारा";
      tMap["ஜென்ம தாரை"] = "जन्म तारा";
      tMap["சம்பத்து தாரை"] = "संपत तारा";
      tMap["விபத்து தாரை"] = "विपत तारा";
      tMap["சேம தாரை"] = "क्षेम तारा";
      tMap["பிரத்யக் தாரை"] = "प्रत्यक तारा";
      tMap["சாதக தாரை"] = "साधक तारा";
      tMap["வதை தாரை"] = "वध तारा";
      tMap["மைத்ர தாரை"] = "मित्र तारा";
      tMap["பரம மைத்ர தாரை"] = "परम मित्र तारा";
      tMap["தாரை"] = "तारा";
      tMap["தாரைகளில்"] = "ताराओं में";
      tMap["ஆதான நட்சத்திரம்"] = "आधान नक्षत्र";
      tMap["கர்ம நட்சத்திரம்"] = "कर्म नक्षत्र";

      // Extreme Degrees & Notes
      tMap["வீட்டு அதிபதி"] = "भाव स्वामी";
      tMap["(வீட்டு அதிபதி"] = "(भाव स्वामी";
      tMap["கிரகங்களின் பாகை விவரம் (இறங்கு வரிசை):"] = "ग्रहों का अंश विवरण (अवरोही क्रम):";
      tMap["கிரகங்களின் பாகை விவரம் (இறங்கு வரிசை)"] = "ग्रहों का अंश विवरण (अवरोही क्रम)";
      tMap["கிரகங்களின் பாகை விவரம்"] = "ग्रहों का अंश विवरण";
      tMap["இறங்கு வரிசை"] = "अवरोही क्रम";

      // Special Lagna Points
      tMap["சிறப்பு லக்கின புள்ளிகள்"] = "विशेष लग्न बिंदु";
      tMap["இந்து லக்னம் (Indu Lagna)"] = "इंदु लग्न";
      tMap["இந்து லக் (Indu லக்)"] = "इंदु लग्न";
      tMap["இந்து லக்னம்"] = "इंदु लग्न";
      tMap["இந்து லக்"] = "इंदु लग्न";
      tMap["இந்து Asc (Indu Asc)"] = "इंदु लग्न";
      tMap["இந்து"] = "इंदु";
      tMap["பார்ச்சூனா புள்ளி (Fortuna)"] = "फॉर्च्यूना पॉइंट (Fortuna)";
      tMap["பார்ச்சூனா புள்ளி"] = "फॉर्च्यूना पॉइंट";
      tMap["பதா / ஆருட லக்னம் (AL)"] = "पदा / आरूढ़ लग्न (AL)";
      tMap["பதா / ஆருட லக்னம்"] = "पदा / आरूढ़ लग्न (AL)";
      tMap["பதா / ஆரூட லக்னம் (AL)"] = "पदा / आरूढ़ लग्न (AL)";
      tMap["பதா / ஆரூட லக்னம்"] = "पदा / आरूढ़ लग्न (AL)";
      tMap["பதா / ஆரூட Asc (AL)"] = "पदा / आरूढ़ लग्न (AL)";
      tMap["பதா / ஆருட Asc (AL)"] = "पदा / आरूढ़ लग्न (AL)";
      tMap["பதா / ஆரூட"] = "पदा / आरूढ़";
      tMap["பதா / ஆருட"] = "पदा / आरूढ़";
      tMap["ஆருட லக்னம்"] = "आरूढ़ लग्न";
      tMap["ஆரூட லக்னம்"] = "आरूढ़ लग्न";
      tMap["உபபதா லக்னம் (UL)"] = "उपपद लग्न (UL)";
      tMap["உபபதா லக்னம்"] = "उपपद लग्न (UL)";
      tMap["உபபதா Asc (UL)"] = "उपपद लग्न (UL)";
      tMap["உபபதா"] = "उपपद";
      tMap["ஹோரா லக்னம் (HL)"] = "होरा लग्न (HL)";
      tMap["ஹோரா லக்னம்"] = "होरा लग्न (HL)";
      tMap["ஹோரா Asc (HL)"] = "होरा लग्न (HL)";
      tMap["ஹோரா"] = "होरा";
      tMap["கடிகா லக்னம் (GL)"] = "घटिका लग्न (GL)";
      tMap["கடிகா லக்னம்"] = "घटिका लग्न (GL)";
      tMap["கடிகா Asc (GL)"] = "घटिका लग्न (GL)";
      tMap["கடிகா"] = "घटिका";

      // Tabs
      tMap["ஷட்பலம்"] = "षड्बल";
      tMap["வழிபாட்டு தலங்கள்"] = "पूजा स्थल";
      tMap["வழிபாட்டுத் தலங்கள்"] = "पूजा स्थल";

      // Shadbala Strengths
      tMap["மிக பலம் (Very Strong)"] = "अत्यधिक बली (Very Strong)";
      tMap["போதுமான பலம் (Strong)"] = "पर्याप्त बली (Strong)";
      tMap["பலவீனமானது (Weak)"] = "निर्बल (Weak)";
      tMap["மிக பலம்"] = "अत्यधिक बली";
      tMap["போதுமான பலம்"] = "पर्याप्त बली";
      tMap["பலவீனமானது"] = "निर्बल";

      // Worship Temples Screen
      tMap["ஜாதகருக்குரிய வழிபாட்டு அட்டவணை"] = "जातक के लिए विशेष पूजा अनुसूची";
      tMap["நட்சத்திரம், யோகி, அவயோகி, திதி அதிதேவதை, கரண நாதன், வைநாசிகம் மற்றும் முடக்கு பாவகம் அடிப்படையிலான திருத்தலங்கள்"] = "जन्म नक्षत्र, योगी, अवयोगी, तिथि देवता, करण नाथ, वैनासिक एवं मुडक्कू भाव पर आधारित तीर्थ स्थल";
      tMap["1. ஜன்ம நட்சத்திரக் கோவில்"] = "1. जन्म नक्षत्र मंदिर (Janma Nakshatra)";
      tMap["2. யோகி கோவில் (சுப யோகம்)"] = "2. योगी मंदिर (शुभ योग)";
      tMap["3. அவயோகி பரிகாரக் கோவில் (தோஷ நிவர்த்தி)"] = "3. अवयोगी निवारण मंदिर (दोष शांति)";
      tMap["4. திதி அதிதேவதை & கோவில்"] = "4. तिथि देवता एवं मंदिर";
      tMap["5. கரண நாதன் கோவில்"] = "5. करण नाथ मंदिर";
      tMap["6. வைநாசிக நட்சத்திரக் கோவில் (88-வது பாதம்)"] = "6. वैनासिक नक्षत्र मंदिर (88वां पद)";
      tMap["7. முடக்கு ராசி / பாவகக் கோவில்"] = "7. मुडक्कू राशि / भाव मंदिर";

      tMap["ஜன்ம நட்சத்திர அதிதேவதை அருள், ஆயுள் பலம் & மன அமைதிக்கு"] = "जन्म नक्षत्र देवता की कृपा, दीर्घायु और मानसिक शांति हेतु";
      tMap["சுப யோக பலன்கள் முழுமையாகக் கிடைக்க, தன வரவு & தொழில் மேன்மை"] = "शुभ योग के पूर्ण फल, धन आगमन एवं व्यापार में उन्नति हेतु";
      tMap["அவயோக தோஷம் நீங்க, தடைகள் மற்றும் மன உளைச்சல்கள் விலக"] = "अवयोग दोष निवारण, बाधाएं एवं मानसिक तनाव दूर करने हेतु";
      tMap["திதி சூன்ய தோஷம் நீங்க, ஆத்ம பலம் மற்றும் காரிய சித்தி"] = "तिथि शून्य दोष निवारण, आत्मबल एवं कार्य सिद्धि हेतु";
      tMap["தொழில், உத்தியோகம் & அன்றாடச் செயல்களில் தடைகள் நீங்கி வெற்றி"] = "व्यापार, नौकरी और दैनिक कार्यों में बाधा निवारण एवं सफलता हेतु";
      tMap["88-வது பாத வைநாசிக தோஷ நிவர்த்தி, விபத்து & கண்டங்கள் விலக"] = "88वें पद वैनासिक दोष निवारण, दुर्घटना एवं संकट निवारण हेतु";
      tMap["முடக்கு தோஷம் நிவர்த்தியாகி பாவக காரகங்கள் நற்பலன் தர"] = "मुडक्कू दोष शांति एवं भाव कारकतत्वों के शुभ फल प्राप्ति हेतु";

      tMap["அவயோகி கிரகம்:"] = "अवयोगी ग्रह:";
      tMap["அவயோகி கிரகம்"] = "अवयोगी ग्रह";
      tMap["யோகி கிரகம்"] = "योगी ग्रह";
      tMap["துணை யோகி"] = "उपयोगी";
      tMap["முடக்கு ராசி"] = "मुडक्कू राशि";
      tMap["முடக்கு பாவம்"] = "मुडक्कू भाव";
      tMap["வளர்பிறை"] = "शुक्ल पक्ष";
      tMap["தேய்பிறை"] = "कृष्ण पक्ष";
      tMap["தெய்வம்:"] = "देवता:";
      tMap["தெய்வம்"] = "देवता";
      tMap["மிருகம்:"] = "पशु:";
      tMap["மிருகம்"] = "पशु";
      tMap["கதிர்கள்"] = "किरणें";
      tMap["நாதா:"] = "स्वामी:";
      tMap["நாதன்:"] = "स्वामी:";
      tMap["யோகி:"] = "योगी:";
      tMap["-ஆம் பாதம்"] = "पद";
      tMap["-ஆம் பாவம்"] = "भाव";
      tMap["லக்னத்திலிருந்து"] = "लग्न से";

      // Nakshatra Details: Animals (Mirugam)
      tMap["ஆண்குதிரை"] = "अश्व (नर घोड़ा)";
      tMap["பெண்குதிரை"] = "अश्विनी (मादा घोड़ा)";
      tMap["ஆண்யானை"] = "गज (नर हाथी)";
      tMap["பெண்யானை"] = "हथिनी (मादा हाथी)";
      tMap["பெண் ஆடு"] = "मेषी (मादा बकरी)";
      tMap["ஆண்ஆடு"] = "मेष (नर बकरा)";
      tMap["ஆண்நாகம்"] = "सर्प (नर नाग)";
      tMap["பெண்சாரை"] = "सर्पिणी (मादा सांप)";
      tMap["ஆண்நாய்"] = "श्वान (नर कुत्ता)";
      tMap["பெண்நாய்"] = "श्वानी (मादा कुतिया)";
      tMap["ஆண்பூனை"] = "मार्जार (नर बिल्ली)";
      tMap["பெண்பூனை"] = "मार्जारी (मादा बिल्ली)";
      tMap["ஆண்எலி"] = "मूषक (नर चूहा)";
      tMap["பெண்எலி"] = "मूषिका (मादा चुहिया)";
      tMap["ஆண்பசு"] = "वृषभ (बैल)";
      tMap["பெண்பசு"] = "धेनु (गाय)";
      tMap["ஆண்கீரி/பசு"] = "नकुल (नेवला)";
      tMap["ஆண்கீரி"] = "नकुल (नेवला)";
      tMap["பெண்கீரி"] = "मादा नेवला";
      tMap["ஆண்எருமை"] = "महिष (भैंसा)";
      tMap["பெண்எருமை"] = "महिषी (भैंस)";
      tMap["ஆண்புலி"] = "व्याघ्र (बाघ)";
      tMap["பெண்புலி"] = "व्याघ्री (बाघिन)";
      tMap["ஆண்மான்"] = "मृग (नर हिरण)";
      tMap["பெண்மான்"] = "मृगी (मादा हिरण)";
      tMap["ஆண்குரங்கு"] = "वानर (नर बंदर)";
      tMap["பெண்குரங்கு"] = "वानरी (मादा बंदर)";
      tMap["ஆண்சிங்கம்"] = "सिंह (नर शेर)";
      tMap["பெண்சிங்கம்"] = "सिंहनी (मादा शेरनी)";

      // Birds (Pakshi)
      tMap["ராசாளி"] = "गरुड़ / चील";
      tMap["காகம்"] = "कौवा";
      tMap["மயில்"] = "मोर";
      tMap["ஆந்தை"] = "उल्लू";
      tMap["கோழி"] = "मुर्गा / मुर्गी";
      tMap["அன்றில்"] = "क्रौंच पक्षी";
      tMap["அன்னம்"] = "हंस";
      tMap["நீர்காகம்"] = "पनकौवा";
      tMap["கிச்சிலி"] = "नीलकंठ पक्षी";
      tMap["ஆண்கழுகு"] = "नर गिद्ध";
      tMap["பெண்கழுகு"] = "मादा गिद्ध";
      tMap["கழுகு"] = "गिद्ध";
      tMap["கௌதாரி"] = "तीतर";
      tMap["பருந்து"] = "चील";
      tMap["மரங்கொத்தி"] = "कठफोड़वा";
      tMap["தேனீ"] = "मधुमक्खी";
      tMap["குருவி"] = "गौरैया";
      tMap["வானம்பாடி"] = "चातक / लवा";
      tMap["சக்கரவாளம்"] = "चक्रवाक";
      tMap["செம்பருந்து"] = "लाल चील";
      tMap["வலியான்"] = "भारद्वाज पक्षी";
      tMap["நாரை"] = "बगुला / सारस";
      tMap["பொன்வண்டு"] = "स्वर्ण भृंग";
      tMap["அண்டங்காக்கை"] = "काला कौवा";
      tMap["உள்ளான்"] = "जलमुर्गी पक्षी";
      tMap["கோட்டான்"] = "उल्लू";
      tMap["வல்லூறு"] = "बाज";

      // Trees (Maram)
      tMap["எட்டி"] = "कुचिला";
      tMap["நெல்லி"] = "आंवला";
      tMap["அத்தி(பா)"] = "गूलर";
      tMap["அத்தி"] = "गूलर";
      tMap["நாவல்(பா)"] = "जामुन";
      tMap["நாவல்"] = "जामुन";
      tMap["கருங்காலி"] = "खदिर (आबनूस)";
      tMap["செங்கரு"] = "लाल खैर";
      tMap["மூங்கில்"] = "बांस";
      tMap["அரசு(பா)"] = "पीपल";
      tMap["அரசு"] = "पीपल";
      tMap["புன்னை(பா)"] = "पुन्नाग";
      tMap["புன்னை"] = "पुन्नाग";
      tMap["ஆல்(பா)"] = "बरगद";
      tMap["ஆல்"] = "बरगद";
      tMap["பலா(பா)"] = "कटहल";
      tMap["பலா"] = "कटहल";
      tMap["அலரி(பா)"] = "कनेर";
      tMap["அலரி"] = "कनेर";
      tMap["வில்வம்"] = "बेलपत्र";
      tMap["மருதம்"] = "अर्जुन वृक्ष";
      tMap["விளா"] = "कैथा";
      tMap["மகிழம்"] = "मौलसिरी (बकुल)";
      tMap["பராய்(பா)"] = "साखू";
      tMap["பராய்"] = "साखू";
      tMap["மராமரம்"] = "साल वृक्ष";
      tMap["வஞ்சி(பா)"] = "बंज वृक्ष";
      tMap["வஞ்சி"] = "बंज वृक्ष";
      tMap["எருக்கு(பா)"] = "मदार (आक)";
      tMap["எருக்கு"] = "मदार (आक)";
      tMap["வன்னி"] = "शमी वृक्ष";
      tMap["கடம்பு"] = "कदंब";
      tMap["தேமா(பா)"] = "आम का पेड़";
      tMap["தேமா"] = "आम का पेड़";
      tMap["வேம்பு"] = "नीम";
      tMap["இலுப்பை"] = "महुआ";

      // Ganam, Naadi, Rajju, Angam
      tMap["தேவ"] = "देव";
      tMap["மனுஷ"] = "मनुष्य";
      tMap["ராக்ஷஸ"] = "राक्षस";
      tMap["தஷிண பார்சுவ நாடி"] = "दक्षिण पार्श्व नाड़ी";
      tMap["மத்திய பார்சுவ நாடி"] = "मध्य पार्श्व नाड़ी";
      tMap["வாம பார்சுவ நாடி"] = "वाम पार्श्व नाड़ी";
      tMap["சிரசு(தலை)"] = "शिर (सिर)";
      tMap["சிரசு"] = "शिर (सिर)";
      tMap["ஏறுபாதம்"] = "आरोही पद";
      tMap["ஏறுதொடை"] = "आरोही जंघा";
      tMap["ஏறுவயிறு"] = "आरोही उदर";
      tMap["ஏறுகழுத்து"] = "आरोही ग्रीवा";
      tMap["இறங்குகழுத்து"] = "अवरोही ग्रीवा";
      tMap["இறங்குவயிறு"] = "अवरोही उदर";
      tMap["இறங்குதொடை"] = "अवरोही जंघा";
      tMap["இறங்குபாதம்"] = "अवरोही पद";
      tMap["சிரசு ரஜ்ஜு"] = "शिरो रज्जु";
      tMap["கண்ட ரஜ்ஜு"] = "कंठ रज्जु";
      tMap["உதர ரஜ்ஜு"] = "उदर रज्जु";
      tMap["நாபி ரஜ்ஜு"] = "नाभि रज्जु";
      tMap["கட்டி ரஜ்ஜு"] = "कटि रज्जु";
      tMap["பாத ரஜ்ஜு"] = "पाद रज्जु";
      tMap["ஆரோகண சிரசு ரஜ்ஜு"] = "आरोहण शिरो रज्जु";
      tMap["அவரோகண சிரசு ரஜ்ஜு"] = "अवरोहण शिरो रज्जु";
      tMap["யோனி"] = "योनि";
      tMap["ரஜ்ஜு"] = "रज्जु";
      tMap["நாடி"] = "नाड़ी";
      tMap["அங்கம்"] = "अंग";
      tMap["ஆண்"] = "पुरुष";
      tMap["பெண்"] = "स्त्री";

      // Kala Natpu & Kala Pagai phrases
      tMap["கால நட்பு"] = "काल मित्रता";
      tMap["காலப்பகை"] = "काल शत्रुता";
      tMap["தற்போது காலநட்பு பருவம்"] = "वर्तमान काल मित्र अवधि";
      tMap["தற்போது காலப்பகை பருவம்"] = "वर्तमान काल शत्रु अवधि";
      tMap["காலநட்பு வயது & திசை விவரங்கள்:"] = "काल मित्र आयु और दशा विवरण:";
      tMap["காலப்பகை வயது & திசை விவரங்கள்:"] = "काल शत्रु आयु और दशा विवरण:";
      tMap["காலப்பகை தசா - புத்தி எச்சரிக்கைகள்:"] = "काल शत्रु दशा - भुक्ति चेतावनियाँ:";
      tMap["திசை"] = "दशा";
      tMap["தசை"] = "दशा";
      tMap["புத்தி"] = "भुक्ति";
      tMap["நடைபெறுகிறது"] = "वर्तमान में चल रही है";
      tMap["தற்போது நடக்கிறது"] = "वर्तमान में जारी";
      tMap["காலப்பகை அமைப்பாகும்"] = "एक काल शत्रु अवधि है";

      // Upagrahas
      tMap["உபகிரகங்கள் (மிருத்யு, எமகண்டன் உள்ளிட்டவை)"] = "उपग्रह (मृत्यु, यमगंड आदि)";
      tMap["உபகிரகங்கள்"] = "उपग्रह";
      tMap["தூமன் (Dhuma)"] = "धूम (Dhuma)";
      tMap["வ்யதீபாதன் (Vyatipata)"] = "व्यतीपात (Vyatipata)";
      tMap["பரிவேடன் (Parivesha)"] = "परिवेश (Parivesha)";
      tMap["இந்திரதனுசு (Indradhanusu)"] = "इंद्रधनुष (Indradhanusu)";
      tMap["உபகேது (Upaketu)"] = "उपकेतु (Upaketu)";
      tMap["எமகண்டன் (Yamagandan)"] = "यमगंड (Yamagandan)";
      tMap["மிருத்யு (Mrityu)"] = "मृत्यु (Mrityu)";
      tMap["தூமன்"] = "धूम";
      tMap["வ்யதீபாதன்"] = "व्यतीपात";
      tMap["பரிவேடன்"] = "परिवेश";
      tMap["இந்திரதனுசு"] = "इंद्रधनुष";
      tMap["உபகேது"] = "उपकेतु";
      tMap["எமகண்டன்"] = "यमगंड";
      tMap["மிருத்யு"] = "मृत्यु";

      // Jaimini Seven Karakas
      tMap["ஜெமினி ஏழு காரகங்கள்"] = "जैमिनी सात कारक";
      tMap["ஆத்மகாரகன் (AK)"] = "आत्मकारक (AK)";
      tMap["அமாத்யகாரகன் (AmK)"] = "अमात्यकारक (AmK)";
      tMap["பிராத்ருகாரகன் (BK)"] = "भ्रातृकारक (BK)";
      tMap["மாத்ருகாரகன் (MK)"] = "मातृकारक (MK)";
      tMap["புத்ரகாரகன் (PK)"] = "पुत्रकारक (PK)";
      tMap["ஞானதிகாரகன் (GK)"] = "ज्ञािकारक (GK)";
      tMap["தாரகாரகன் (DK)"] = "दाराकारक (DK)";
      tMap["ஆத்மகாரகன்"] = "आत्मकारक";
      tMap["அமாத்யகாரகன்"] = "अमात्यकारक";
      tMap["பிராத்ருகாரகன்"] = "भ्रातृकारक";
      tMap["மாத்ருகாரகன்"] = "मातृकारक";
      tMap["புத்ரகாரகன்"] = "पुत्रकारक";
      tMap["ஞானதிகாரகன்"] = "ज्ञािकारक";
      tMap["தாரகாரகன்"] = "दाराकारक";
      tMap["ஆன்மா, தலைமை, சுய வளர்ச்சி (Highest Degree)"] = "आत्मा, नेतृत्व, आत्म-विकास (उच्चतम अंश)";
      tMap["தொழில், அந்தஸ்து, அமைச்சர் நிலை"] = "कर्म, प्रतिष्ठा, पद-प्रतिष्ठा";
      tMap["சகோதரம், தைரியம், வழிகாட்டுதல்"] = "भाई-बहन, साहस, मार्गदर्शन";
      tMap["தாய், கல்வி, சுகபோகங்கள்"] = "माता, शिक्षा, सुख-सुविधाएं";
      tMap["புத்திர பாக்கியம், புத்தி கூர்மை"] = "संतान, बुद्धि, विवेक";
      tMap["எதிரிகள், கடன், நோய், உறவுகள்"] = "शत्रु, ऋण, रोग, संबंध";
      tMap["வாழ்க்கைத் துணை, கூட்டுத் தொழில் (Lowest Degree)"] = "जीवनसाथी, साझेदारी (न्यूनतम अंश)";

      // Age and Age Ranges
      tMap["வயது"] = "आयु";
      tMap["வயது வரை"] = "वर्ष तक";
      tMap["வயதுக்குள்"] = "वर्ष के भीतर";
      tMap["முதல்"] = "से";
      tMap["வரை"] = "तक";
      tMap["1 வயதுக்குள்"] = "1 वर्ष के भीतर";
      tMap["2 முதல் 3 வயது வரை"] = "आयु 2 से 3 वर्ष";
      tMap["4 முதல் 12 வயது வரை"] = "आयु 4 से 12 वर्ष";
      tMap["12 முதல் 32 வயது வரை"] = "आयु 12 से 32 वर्ष";
      tMap["33 முதல் 50 வயது வரை"] = "आयु 33 से 50 वर्ष";
      tMap["51 முதல் 70 வயது வரை"] = "आयु 51 से 70 वर्ष";
      tMap["71 முதல் 120 வயது வரை"] = "आयु 71 से 120 वर्ष";
      tMap["2 வயது வரை"] = "2 वर्ष तक";
      tMap["3 முதல் 18 வயதுக்குள்"] = "आयु 3 से 18 वर्ष";
      tMap["11 முதல் 12 வயதுக்குள்"] = "आयु 11 से 12 वर्ष";
      tMap["18 முதல் 34 வயதுக்குள்"] = "आयु 18 से 34 वर्ष";
      tMap["34 முதல் 52 வயதுக்குள்"] = "आयु 34 से 52 वर्ष";
      tMap["52 முதல் 68 வயதுக்குள்"] = "आयु 52 से 68 वर्ष";
      tMap["68 முதல் 100 வயதுக்குள்"] = "आयु 68 से 100 वर्ष";

      // Dasa / Disai terms
      tMap["சூரிய தசை"] = "सूर्य दशा";
      tMap["சூரியன் தசை"] = "सूर्य दशा";
      tMap["சூரிய திசை"] = "सूर्य दशा";
      tMap["சூரியன் திசை"] = "सूर्य दशा";
      tMap["சந்திர தசை"] = "चंद्र दशा";
      tMap["சந்திரன் தசை"] = "चंद्र दशा";
      tMap["சந்திர திசை"] = "चंद्र दशा";
      tMap["சந்திரன் திசை"] = "चंद्र दशा";
      tMap["செவ்வாய் தசை"] = "मंगल दशा";
      tMap["செவ்வாய் திசை"] = "मंगल दशा";
      tMap["புதன் தசை"] = "बुध दशा";
      tMap["புதன் திசை"] = "बुध दशा";
      tMap["குரு தசை"] = "गुरु दशा";
      tMap["குரு திசை"] = "गुरु दशा";
      tMap["சுக்கிர தசை"] = "शुक्र दशा";
      tMap["சுக்கிரன் தசை"] = "शुक्र दशा";
      tMap["சுக்கிர திசை"] = "शुक्र दशा";
      tMap["சுக்கிரன் திசை"] = "शुक्र दशा";
      tMap["சனி தசை"] = "शनि दशा";
      tMap["சனி திசை"] = "शनि दशा";
      tMap["ராகு தசை"] = "राहु दशा";
      tMap["ராகு திசை"] = "राहु दशा";
      tMap["கேது தசை"] = "केतु दशा";
      tMap["கேது திசை"] = "केतु दशा";

      // Dasa Nalvar
      tMap["தசா நாதனின் நால்வர் (போதகன், வேதகன், பாசகன், காரகன்)"] = "दशा स्वामी के चार सहायक (बोधक, वेधक, पाचक, कारक)";
      tMap["தசா நாதனின் நால்வர்"] = "दशा स्वामी के चार सहायक";
      tMap["நால்வர் (துணைவர்கள்)"] = "चार सहायक (नाल्वर)";
      tMap["நால்வர்"] = "चार सहायक";
      tMap["போதகன்"] = "बोधक (शुभ फलदाता)";
      tMap["வேதகன்"] = "वेधक (बाधा कारक)";
      tMap["பாசகன்"] = "पाचक (अनुभव प्रदाता)";
      tMap["காரகன்"] = "कारक (स्थायित्व कर्ता)";
      tMap["நற்பலன் தருபவர்"] = "शुभ फल देने वाले";
      tMap["தடை தருபவர்"] = "बाधा उत्पन्न करने वाले";
      tMap["அனுபவிக்க வைப்பவர்"] = "अनुभव कराने वाले";
      tMap["நிலைநிறுத்துபவர்"] = "स्थिर रखने वाले";

    }

    if (tMap.containsKey(normalizedWord)) return tMap[normalizedWord]!;

    String translated = normalizedWord;

    if (languageCode == 'ta') {
      return translated;
    }

    if (languageCode == 'en' || languageCode == 'hi') {
      var sortedKeys = tMap.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
      for (var ta in sortedKeys) {
        if (!translated.contains(ta)) continue;

        // Multi-word phrases, phrases with punctuation, or phrases containing delimiters can be replaced directly
        if (ta.contains(' ') || ta.contains('/') || ta.contains('-') || ta.contains('(') || ta.contains(',')) {
          translated = translated.replaceAll(ta, tMap[ta]!);
        } else {
          // Single Tamil words/tokens must be bounded by start/end or non-Tamil characters,
          // so internal roots/syllables of larger words are NEVER corrupted
          // (e.g. 'தனுசு' inside 'இந்திரதனுசு', 'புத்தி' inside 'புத்திர', 'லக்' inside other words).
          final escaped = RegExp.escape(ta);
          final pattern = RegExp(r'(?<=^|[^\u0B80-\u0BFF])' + escaped + r'(?=[^\u0B80-\u0BFF]|$)');
          translated = translated.replaceAll(pattern, tMap[ta]!);
        }
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