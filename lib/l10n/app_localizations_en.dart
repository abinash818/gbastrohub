// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'Tamil';

  @override
  String get hindi => 'Hindi';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get astrologicalMath => 'Astrological Mathematics';

  @override
  String get noInternetSub =>
      'No internet connection to check subscription. Please turn on internet.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get horoscope => 'Horoscope';

  @override
  String get nadi => 'Nadi Astrology';

  @override
  String get marriageMatching => 'Marriage Matching';

  @override
  String get numerology => 'Numerology';

  @override
  String get panchangam => 'Panchangam';

  @override
  String get jamakkol => 'Jamakkol Prasannam';

  @override
  String get muhurtham => 'Muhurtham';

  @override
  String get savedHoroscopes => 'Saved Horoscopes';

  @override
  String get logout => 'Logout';

  @override
  String get accessDenied =>
      'Access Denied. Please use Dashboard to contact Admin.';

  @override
  String get enterEmailPass => 'Please enter email and password';

  @override
  String get passNotMatch => 'Passwords do not match';

  @override
  String get newDeviceReg => 'You need to register the new device.';

  @override
  String get invalidCredentials =>
      'Account not found or details invalid. Confirm password to register.';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get emailInUse => 'This email is already in use';

  @override
  String get newDevice => 'New Device';

  @override
  String get registration => 'Registration';

  @override
  String get enterMobilePrompt =>
      'Enter your mobile number to get admin approval to use this app.';

  @override
  String get enterValidMobile => 'Please enter a valid mobile number';

  @override
  String get requestSent =>
      'Your request has been sent to admin. You can login once approved.';

  @override
  String get welcome => 'Welcome';

  @override
  String get hideEmailLogin => 'Hide Email Login';

  @override
  String get loginWithEmail => 'Login with Email / Password';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get loginBtn => 'Login';

  @override
  String get createAccountBtn => 'Create Account';

  @override
  String get noAccountReg => 'Don\'t have an account? Register';

  @override
  String get haveAccountLogin => 'Already have an account? Login';

  @override
  String get secureLogin => 'Secure Login';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get cancel => 'Cancel';

  @override
  String get requestApproval => 'Request Approval';

  @override
  String get or => 'OR';

  @override
  String get aboutUs => 'About Us';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get aadhiguruSchool => 'GB Astro Astrological Vidyalayam';

  @override
  String get aadhiguruDesc =>
      'Your trusted platform for premium Astrological math, Marriage matching, Jamakkol Prasannam and Numerology services.';

  @override
  String get close => 'Close';

  @override
  String accessDeniedSub(String serviceName) {
    return 'Your purchased plan does not have access to this ($serviceName) service. Contact Admin.';
  }

  @override
  String get whatsappAdmin => 'WhatsApp Admin';

  @override
  String whatsappMsg(String serviceName) {
    return 'Hello Sir, I need access to use $serviceName.';
  }

  @override
  String get quote1 => 'If you know the Moon! You can know the Fate!';

  @override
  String get quote2 => 'If you know the Time! You can know God!';

  @override
  String get quote3 => 'If you know Astrology! You can know Yourself!';

  @override
  String get horoscopeCalcTitle => 'Horoscope Calculation';

  @override
  String get nadiCalcTitle => 'Nadi Calculation';

  @override
  String get kpCalcTitle => 'KP Horoscope Calculation';

  @override
  String get numPrasannamTitle => 'Number Prasannam';

  @override
  String get cowriePrasannamTitle => 'Cowrie Prasannam';

  @override
  String get betelPrasannamTitle => 'Betel Leaf Prasannam';

  @override
  String get kpPrasannamTitle => 'KP Prasannam';

  @override
  String get horaiPrasannamTitle => 'Horai Prasannam';

  @override
  String get prasannamTitle => 'Prasannam';

  @override
  String get nowTooltip => 'Now';

  @override
  String get nameLabel => 'Name';

  @override
  String get genderLabel => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get placeOfBirthLabel => 'Place of Birth';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get locationDetailsLabel => 'Location Details';

  @override
  String get saveHoroscopeLabel => 'Save this horoscope';

  @override
  String get horoscopeSaved => 'Horoscope saved!';

  @override
  String get pdfError => 'Error generating PDF:';

  @override
  String get submitBtn => 'Submit';

  @override
  String get pdfBtn => 'PDF';

  @override
  String get tabPrasannam => 'Prasannam';

  @override
  String get tabDetails => 'Details';

  @override
  String get tabChart => 'Chart';

  @override
  String get tabPadasaram => 'Padasaram';

  @override
  String get tabKpCusps => 'KP Cusps';

  @override
  String get tabKpPlanets => 'KP Planets';

  @override
  String get tabSignificators => 'Significators';

  @override
  String get tabStarSignificators => 'Star Significators';

  @override
  String get tabDasaBukthi => 'Dasa Bukthi';

  @override
  String get tabAshtakavarga => 'Ashtakavarga';

  @override
  String get tabDasavarga => 'Dasavarga';

  @override
  String get tabPalangal => 'Predictions';

  @override
  String get pdfDownload => 'Download PDF';

  @override
  String get onePageA5 => 'One Page Horoscope (A5)';

  @override
  String get kpOnePageA5 => 'KP One Page Horoscope (A5)';

  @override
  String get fullReport => 'Full Horoscope (Multi Page)';

  @override
  String get dasa => 'Dasa';

  @override
  String get bukthi => 'Bukthi';

  @override
  String get antharam => 'Antharam';

  @override
  String get sookshmam => 'Sookshmam';

  @override
  String get currentDasaBukthi => 'Current Dasa Bukthi';

  @override
  String get noneSelected => 'None selected';

  @override
  String ageFormat(int years, int months, int days) {
    return 'Age: $years Y, $months M, $days D';
  }

  @override
  String get kpCuspsTitle => 'KP Cusps Initial Details';

  @override
  String get kpPlanetsTitle => 'KP Planets Details';

  @override
  String get planet => 'Planet';

  @override
  String get sign => 'Sign';

  @override
  String get degree => 'Degree';

  @override
  String get signLord => 'S.L';

  @override
  String get starLord => 'N.L';

  @override
  String get subLord => 'Sub';

  @override
  String get planetSignificators => 'Planet Significators (Planet View)';

  @override
  String get houseSignificators => 'House Significators (House View)';

  @override
  String get rasiChart => 'Rasi Chart';

  @override
  String get bhavaChart => 'Bhava Chart';

  @override
  String get sarvaAshtakavarga => 'Sarva Ashtakavarga';

  @override
  String get suyaAshtakavarga => 'Suya Varga';

  @override
  String get suyaVargaChakra => 'Suya Varga Chakra';

  @override
  String get palangal => 'Predictions';

  @override
  String get noDetails => 'No details available';

  @override
  String get jathagam => 'Horoscope';

  @override
  String get jathagamWorkspace => 'Horoscope Workspace';

  @override
  String get newJathagam => 'New Horoscope';

  @override
  String get jamakkolPrasannamTitle => 'Jamakkol Prasannam';

  @override
  String get placeLabel => 'Place';

  @override
  String get jamakkolPlanet => 'Jamakkol Planet';

  @override
  String get jamakkolPlanetsMainPoints => 'Jamakkol Planets & Main Points';

  @override
  String get innerPlanets => 'Inner Planets';

  @override
  String get nakshatra => 'Nakshatra';

  @override
  String get pada => 'Pada';

  @override
  String get udayam => 'Udayam';

  @override
  String get arudam => 'Arudam';

  @override
  String get kavippu => 'Kavippu';

  @override
  String get strengthAnalysis => 'Strength Analysis';

  @override
  String get feature => 'Feature';

  @override
  String get lord => 'Lord';

  @override
  String get total => 'Total';

  @override
  String get errorCalculating => 'Error calculating:';

  @override
  String get jamakkolChartTitle => 'Jamakkol Prasannam Chart';

  @override
  String get jamakkolNotes => 'Jamakkol Notes';

  @override
  String get planetTowardsUdayam => 'Planet coming towards Udayam';

  @override
  String get planetPassedUdayam => 'Planet passed Udayam';

  @override
  String get arudamHouse => 'Arudam House';

  @override
  String get kavippuHouse => 'Kavippu House';

  @override
  String get kavippuPlanet => 'Kavippu Planet';

  @override
  String get udayathipathiHouse => 'Udayathipathi House';

  @override
  String get parivarthanaYogas => 'Parivarthana Yogas';

  @override
  String get none => 'None';

  @override
  String get planetStatus => 'Planet Status';

  @override
  String get noDasaDetails => 'No Dasa/Bukthi details';

  @override
  String get dasaTitle => 'Dasa';

  @override
  String get bukthiTitle => 'Bukthi';

  @override
  String get antharamTitle => 'Antharam';

  @override
  String get sookshmamTitle => 'Sookshmam';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get udaShort => 'Uda';

  @override
  String get aruShort => 'Aru';

  @override
  String get kaviShort => 'Kavi';

  @override
  String get utharayanam => 'Utharayanam';

  @override
  String get dakshinayanam => 'Dakshinayanam';

  @override
  String get vasanthaKaalam => 'Vasantha Kaalam';

  @override
  String get greeshmaKaalam => 'Greeshma Kaalam';

  @override
  String get varshaKaalam => 'Varsha Kaalam';

  @override
  String get sarathKaalam => 'Sarath Kaalam';

  @override
  String get hemanthaKaalam => 'Hemantha Kaalam';

  @override
  String get sisiraKaalam => 'Sisira Kaalam';

  @override
  String get moon => 'Moon';

  @override
  String get lagna => 'Lagna';

  @override
  String get mars => 'Mars';

  @override
  String get west => 'West';

  @override
  String get east => 'East';

  @override
  String get north => 'North';

  @override
  String get south => 'South';

  @override
  String get jaggery => 'Jaggery';

  @override
  String get curd => 'Curd';

  @override
  String get milk => 'Milk';

  @override
  String get oil => 'Oil';

  @override
  String get notToday => 'Not Today';

  @override
  String get panchangamTitle => 'Panchangam';

  @override
  String get detailsTab => 'Details';

  @override
  String get chartTab => 'Chart';

  @override
  String get changeDate => 'Change Date';

  @override
  String get noDataAvailable => 'No Data Available';

  @override
  String get basicDetailsTitle => 'Basic Details';

  @override
  String get tamilYear => 'Tamil Year';

  @override
  String get tamilDate => 'Tamil Date';

  @override
  String get englishDate => 'English Date';

  @override
  String get day => 'Day';

  @override
  String get kaliYear => 'Kali Year';

  @override
  String get kollamYear => 'Kollam Year';

  @override
  String get fasliYear => 'Fasli Year';

  @override
  String get salivahana => 'Salivahana';

  @override
  String get hijriYear => 'Hijri Year';

  @override
  String get ayanamTitle => 'Ayanam';

  @override
  String get seasonTitle => 'Season';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get sunset => 'Sunset';

  @override
  String get moonDetailsTitle => 'Moon Details';

  @override
  String get moonSign => 'Moon Sign';

  @override
  String get chandrashtamaSign => 'Chandrashtama Sign';

  @override
  String get paksham => 'Paksham';

  @override
  String get tithiLabel => 'Tithi';

  @override
  String get nakshatraLabel => 'Nakshatra';

  @override
  String get yogaLabel => 'Yoga';

  @override
  String get karanaLabel => 'Karana';

  @override
  String get amirthathiYogam => 'Amirthathi Yogam';

  @override
  String get nethram => 'Nethram';

  @override
  String get jeevan => 'Jeevan';

  @override
  String get soolamTitle => 'Soolam';

  @override
  String get pariharamTitle => 'Pariharam';

  @override
  String get importantTimingsTitle => 'Important Timings';

  @override
  String get nallaNeram => 'Good Time';

  @override
  String get rahuKalam => 'Rahu Kalam';

  @override
  String get yemagandam => 'Yemagandam';

  @override
  String get kuligai => 'Kuligai';

  @override
  String get rasiChartDataNotAvailable => 'Rasi Chart Data Not Available';

  @override
  String get rasiLabel => 'Rasi';

  @override
  String get planetaryPositionsTitle => 'Planetary Positions';

  @override
  String get retrograde => 'Retrograde';

  @override
  String get untilLabel => 'until:';

  @override
  String get bhavam => 'Bhavam';

  @override
  String get amirtham => 'Amirtham';

  @override
  String get sitham => 'Sitham';

  @override
  String get maranam => 'Maranam';

  @override
  String get prabalarishtam => 'Prabalarishtam';

  @override
  String get dailyPanchangam => 'Daily Panchangam';

  @override
  String get currentHora => 'Current Hora';

  @override
  String get currentGowri => 'Current Gowri';

  @override
  String get marriageMatchingTitle => 'Marriage Matching';

  @override
  String get matchingResultsTitle => 'Matching Results';

  @override
  String get isMatchingTitle => 'Is it a match?';

  @override
  String get notMatching => 'Not Matching';

  @override
  String get isMatching => 'Matching';

  @override
  String get astrologerNotePrompt =>
      'What should be in the astrologer\'s note?';

  @override
  String get girlHoroscopeTab => 'Girl Horoscope';

  @override
  String get boyHoroscopeTab => 'Boy Horoscope';

  @override
  String get girlDasaBukthiTab => 'Girl Dasa Bukthi';

  @override
  String get boyDasaBukthiTab => 'Boy Dasa Bukthi';

  @override
  String get matchingTab => 'Matching';

  @override
  String get girlDetailsTitle => 'Girl Details';

  @override
  String get boyDetailsTitle => 'Boy Details';

  @override
  String get girlLabel => 'Girl';

  @override
  String get boyLabel => 'Boy';

  @override
  String get totalMatchingLabel => 'Total Match: ';

  @override
  String get tenMatchesTitle => 'Ten Matches';

  @override
  String get doshasTitle => 'Horoscope Doshas';

  @override
  String get chevvaiDosham => 'Chevvai Dosham (Mars)';

  @override
  String get rahuKetuDosham => 'Rahu-Ketu Dosham';

  @override
  String get dasaSandhi => 'Dasa Sandhi';

  @override
  String get doshaPresent => 'Present';

  @override
  String get doshaAbsent => 'Absent';

  @override
  String get matchExcellent => 'Match: Excellent';

  @override
  String get matchPoor => 'Match: Poor';

  @override
  String get dasaSandhiPresent => 'Dasa Sandhi Present';

  @override
  String get dasaSandhiAbsent => 'No Dasa Sandhi';

  @override
  String get starMatchingLabel => 'Star Matching';

  @override
  String get ageLabel => 'Age';

  @override
  String get lagnaLabel => 'Lagna';

  @override
  String get atmakarakaLabel => 'Atmakaraka';

  @override
  String get ganam => 'Ganam';

  @override
  String get mirugam => 'Mirugam';

  @override
  String get pakshi => 'Pakshi';

  @override
  String get maram => 'Maram';

  @override
  String get tamilYearLabel => 'Tamil Year';

  @override
  String get tamilDateLabel => 'Tamil Date';

  @override
  String get varaLabel => 'Vara';

  @override
  String get kaliYearLabel => 'Kali Year';

  @override
  String get kollamYearLabel => 'Kollam Year';

  @override
  String get sunriseLabel => 'Sunrise';

  @override
  String get sunsetLabel => 'Sunset';

  @override
  String get paramaNazhigaiLabel => 'Parama Nazhigai';

  @override
  String get horaLabel => 'Hora';

  @override
  String get amirthaYogaLabel => 'Amirtha Yoga';

  @override
  String get dasaBalanceLabel => 'Dasa Balance';

  @override
  String get birthDetailsTitle => 'Birth Details';

  @override
  String get astroBasicsTitle => 'Astrology Basics';

  @override
  String get matchingAttrsTitle => 'Matching Attributes';

  @override
  String get thirigonaSothanai => 'Thirigona Sothanai';

  @override
  String get egathipathyaSothanai => 'Egathipathya Sothanai';

  @override
  String get pindangal => 'Pindangal';

  @override
  String get rasiPindam => 'Rasi Pindam';

  @override
  String get grahaPindam => 'Graha Pindam';

  @override
  String get shodyaPindam => 'Shodya Pindam';

  @override
  String get totalLabel => 'Total';

  @override
  String get amsam => 'Navamsa';

  @override
  String get gocharam => 'Transit';

  @override
  String get sun => 'Sun';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get jupiter => 'Jupiter';

  @override
  String get venus => 'Venus';

  @override
  String get saturday => 'Saturday';

  @override
  String get rahu => 'Rahu';

  @override
  String get ketu => 'Ketu';

  @override
  String get maanthi => 'Maanthi';

  @override
  String get aries => 'Aries';

  @override
  String get taurus => 'Taurus';

  @override
  String get gemini => 'Gemini';

  @override
  String get cancer => 'Cancer';

  @override
  String get leo => 'Leo';

  @override
  String get virgo => 'Virgo';

  @override
  String get libra => 'Libra';

  @override
  String get scorpio => 'Scorpio';

  @override
  String get sagittarius => 'Sagittarius';

  @override
  String get capricorn => 'Capricorn';

  @override
  String get aquarius => 'Aquarius';

  @override
  String get pisces => 'Pisces';

  @override
  String get ashwini => 'Ashwini';

  @override
  String get bharani => 'Bharani';

  @override
  String get krittika => 'Krittika';

  @override
  String get rohini => 'Rohini';

  @override
  String get mrigashirsha => 'Mrigashirsha';

  @override
  String get ardra => 'Ardra';

  @override
  String get punarvasu => 'Punarvasu';

  @override
  String get pushya => 'Pushya';

  @override
  String get ashlesha => 'Ashlesha';

  @override
  String get magha => 'Magha';

  @override
  String get purvaPhalguni => 'Purva Phalguni';

  @override
  String get uttaraPhalguni => 'Uttara Phalguni';

  @override
  String get hasta => 'Hasta';

  @override
  String get chithirai => 'Chithirai';

  @override
  String get swati => 'Swati';

  @override
  String get vishakha => 'Vishakha';

  @override
  String get anuradha => 'Anuradha';

  @override
  String get jyeshtha => 'Jyeshtha';

  @override
  String get mula => 'Mula';

  @override
  String get purvaAshadha => 'Purva Ashadha';

  @override
  String get uttaraAshadha => 'Uttara Ashadha';

  @override
  String get shravana => 'Shravana';

  @override
  String get dhanishta => 'Dhanishta';

  @override
  String get shatabhisha => 'Shatabhisha';

  @override
  String get purvaBhadrapada => 'Purva Bhadrapada';

  @override
  String get uttaraBhadrapada => 'Uttara Bhadrapada';

  @override
  String get revati => 'Revati';

  @override
  String get vaikasi => 'Vaikasi';

  @override
  String get aani => 'Aani';

  @override
  String get aadi => 'Aadi';

  @override
  String get aavani => 'Aavani';

  @override
  String get purattasi => 'Purattasi';

  @override
  String get aippasi => 'Aippasi';

  @override
  String get karthikai => 'Karthikai';

  @override
  String get margazhi => 'Margazhi';

  @override
  String get thai => 'Thai';

  @override
  String get masi => 'Masi';

  @override
  String get panguni => 'Panguni';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';
}
