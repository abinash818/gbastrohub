import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @astrologicalMath.
  ///
  /// In en, this message translates to:
  /// **'Astrological Mathematics'**
  String get astrologicalMath;

  /// No description provided for @noInternetSub.
  ///
  /// In en, this message translates to:
  /// **'No internet connection to check subscription. Please turn on internet.'**
  String get noInternetSub;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @horoscope.
  ///
  /// In en, this message translates to:
  /// **'Horoscope'**
  String get horoscope;

  /// No description provided for @nadi.
  ///
  /// In en, this message translates to:
  /// **'Nadi Astrology'**
  String get nadi;

  /// No description provided for @marriageMatching.
  ///
  /// In en, this message translates to:
  /// **'Marriage Matching'**
  String get marriageMatching;

  /// No description provided for @numerology.
  ///
  /// In en, this message translates to:
  /// **'Numerology'**
  String get numerology;

  /// No description provided for @panchangam.
  ///
  /// In en, this message translates to:
  /// **'Panchangam'**
  String get panchangam;

  /// No description provided for @jamakkol.
  ///
  /// In en, this message translates to:
  /// **'Jamakkol Prasannam'**
  String get jamakkol;

  /// No description provided for @muhurtham.
  ///
  /// In en, this message translates to:
  /// **'Muhurtham'**
  String get muhurtham;

  /// No description provided for @savedHoroscopes.
  ///
  /// In en, this message translates to:
  /// **'Saved Horoscopes'**
  String get savedHoroscopes;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied. Please use Dashboard to contact Admin.'**
  String get accessDenied;

  /// No description provided for @enterEmailPass.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailPass;

  /// No description provided for @passNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passNotMatch;

  /// No description provided for @newDeviceReg.
  ///
  /// In en, this message translates to:
  /// **'You need to register the new device.'**
  String get newDeviceReg;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Account not found or details invalid. Confirm password to register.'**
  String get invalidCredentials;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use'**
  String get emailInUse;

  /// No description provided for @newDevice.
  ///
  /// In en, this message translates to:
  /// **'New Device'**
  String get newDevice;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// No description provided for @enterMobilePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to get admin approval to use this app.'**
  String get enterMobilePrompt;

  /// No description provided for @enterValidMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number'**
  String get enterValidMobile;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent to admin. You can login once approved.'**
  String get requestSent;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @hideEmailLogin.
  ///
  /// In en, this message translates to:
  /// **'Hide Email Login'**
  String get hideEmailLogin;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Login with Email / Password'**
  String get loginWithEmail;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @loginBtn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginBtn;

  /// No description provided for @createAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountBtn;

  /// No description provided for @noAccountReg.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get noAccountReg;

  /// No description provided for @haveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get haveAccountLogin;

  /// No description provided for @secureLogin.
  ///
  /// In en, this message translates to:
  /// **'Secure Login'**
  String get secureLogin;

  /// No description provided for @continueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueGoogle;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @requestApproval.
  ///
  /// In en, this message translates to:
  /// **'Request Approval'**
  String get requestApproval;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @aadhiguruSchool.
  ///
  /// In en, this message translates to:
  /// **'GB Astro Astrological Vidyalayam'**
  String get aadhiguruSchool;

  /// No description provided for @aadhiguruDesc.
  ///
  /// In en, this message translates to:
  /// **'Your trusted platform for premium Astrological math, Marriage matching, Jamakkol Prasannam and Numerology services.'**
  String get aadhiguruDesc;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @accessDeniedSub.
  ///
  /// In en, this message translates to:
  /// **'Your purchased plan does not have access to this ({serviceName}) service. Contact Admin.'**
  String accessDeniedSub(String serviceName);

  /// No description provided for @whatsappAdmin.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Admin'**
  String get whatsappAdmin;

  /// No description provided for @whatsappMsg.
  ///
  /// In en, this message translates to:
  /// **'Hello Sir, I need access to use {serviceName}.'**
  String whatsappMsg(String serviceName);

  /// No description provided for @quote1.
  ///
  /// In en, this message translates to:
  /// **'If you know the Moon! You can know the Fate!'**
  String get quote1;

  /// No description provided for @quote2.
  ///
  /// In en, this message translates to:
  /// **'If you know the Time! You can know God!'**
  String get quote2;

  /// No description provided for @quote3.
  ///
  /// In en, this message translates to:
  /// **'If you know Astrology! You can know Yourself!'**
  String get quote3;

  /// No description provided for @horoscopeCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'Horoscope Calculation'**
  String get horoscopeCalcTitle;

  /// No description provided for @nadiCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'Nadi Calculation'**
  String get nadiCalcTitle;

  /// No description provided for @kpCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'KP Horoscope Calculation'**
  String get kpCalcTitle;

  /// No description provided for @numPrasannamTitle.
  ///
  /// In en, this message translates to:
  /// **'Number Prasannam'**
  String get numPrasannamTitle;

  /// No description provided for @cowriePrasannamTitle.
  ///
  /// In en, this message translates to:
  /// **'Cowrie Prasannam'**
  String get cowriePrasannamTitle;

  /// No description provided for @betelPrasannamTitle.
  ///
  /// In en, this message translates to:
  /// **'Betel Leaf Prasannam'**
  String get betelPrasannamTitle;

  /// No description provided for @kpPrasannamTitle.
  ///
  /// In en, this message translates to:
  /// **'KP Prasannam'**
  String get kpPrasannamTitle;

  /// No description provided for @horaiPrasannamTitle.
  ///
  /// In en, this message translates to:
  /// **'Horai Prasannam'**
  String get horaiPrasannamTitle;

  /// No description provided for @prasannamTitle.
  ///
  /// In en, this message translates to:
  /// **'Prasannam'**
  String get prasannamTitle;

  /// No description provided for @nowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowTooltip;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @placeOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get placeOfBirthLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @locationDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetailsLabel;

  /// No description provided for @saveHoroscopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Save this horoscope'**
  String get saveHoroscopeLabel;

  /// No description provided for @horoscopeSaved.
  ///
  /// In en, this message translates to:
  /// **'Horoscope saved!'**
  String get horoscopeSaved;

  /// No description provided for @pdfError.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF:'**
  String get pdfError;

  /// No description provided for @submitBtn.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitBtn;

  /// No description provided for @pdfBtn.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfBtn;

  /// No description provided for @tabPrasannam.
  ///
  /// In en, this message translates to:
  /// **'Prasannam'**
  String get tabPrasannam;

  /// No description provided for @tabDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get tabDetails;

  /// No description provided for @tabChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get tabChart;

  /// No description provided for @tabPadasaram.
  ///
  /// In en, this message translates to:
  /// **'Padasaram'**
  String get tabPadasaram;

  /// No description provided for @tabKpCusps.
  ///
  /// In en, this message translates to:
  /// **'KP Cusps'**
  String get tabKpCusps;

  /// No description provided for @tabKpPlanets.
  ///
  /// In en, this message translates to:
  /// **'KP Planets'**
  String get tabKpPlanets;

  /// No description provided for @tabSignificators.
  ///
  /// In en, this message translates to:
  /// **'Significators'**
  String get tabSignificators;

  /// No description provided for @tabStarSignificators.
  ///
  /// In en, this message translates to:
  /// **'Star Significators'**
  String get tabStarSignificators;

  /// No description provided for @tabDasaBukthi.
  ///
  /// In en, this message translates to:
  /// **'Dasa Bukthi'**
  String get tabDasaBukthi;

  /// No description provided for @tabAshtakavarga.
  ///
  /// In en, this message translates to:
  /// **'Ashtakavarga'**
  String get tabAshtakavarga;

  /// No description provided for @tabDasavarga.
  ///
  /// In en, this message translates to:
  /// **'Dasavarga'**
  String get tabDasavarga;

  /// No description provided for @tabPalangal.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get tabPalangal;

  /// No description provided for @pdfDownload.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get pdfDownload;

  /// No description provided for @onePageA5.
  ///
  /// In en, this message translates to:
  /// **'One Page Horoscope (A5)'**
  String get onePageA5;

  /// No description provided for @kpOnePageA5.
  ///
  /// In en, this message translates to:
  /// **'KP One Page Horoscope (A5)'**
  String get kpOnePageA5;

  /// No description provided for @fullReport.
  ///
  /// In en, this message translates to:
  /// **'Full Horoscope (Multi Page)'**
  String get fullReport;

  /// No description provided for @dasa.
  ///
  /// In en, this message translates to:
  /// **'Dasa'**
  String get dasa;

  /// No description provided for @bukthi.
  ///
  /// In en, this message translates to:
  /// **'Bukthi'**
  String get bukthi;

  /// No description provided for @antharam.
  ///
  /// In en, this message translates to:
  /// **'Antharam'**
  String get antharam;

  /// No description provided for @sookshmam.
  ///
  /// In en, this message translates to:
  /// **'Sookshmam'**
  String get sookshmam;

  /// No description provided for @currentDasaBukthi.
  ///
  /// In en, this message translates to:
  /// **'Current Dasa Bukthi'**
  String get currentDasaBukthi;

  /// No description provided for @noneSelected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get noneSelected;

  /// No description provided for @ageFormat.
  ///
  /// In en, this message translates to:
  /// **'Age: {years} Y, {months} M, {days} D'**
  String ageFormat(int years, int months, int days);

  /// No description provided for @kpCuspsTitle.
  ///
  /// In en, this message translates to:
  /// **'KP Cusps Initial Details'**
  String get kpCuspsTitle;

  /// No description provided for @kpPlanetsTitle.
  ///
  /// In en, this message translates to:
  /// **'KP Planets Details'**
  String get kpPlanetsTitle;

  /// No description provided for @planet.
  ///
  /// In en, this message translates to:
  /// **'Planet'**
  String get planet;

  /// No description provided for @sign.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get sign;

  /// No description provided for @degree.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get degree;

  /// No description provided for @signLord.
  ///
  /// In en, this message translates to:
  /// **'S.L'**
  String get signLord;

  /// No description provided for @starLord.
  ///
  /// In en, this message translates to:
  /// **'N.L'**
  String get starLord;

  /// No description provided for @subLord.
  ///
  /// In en, this message translates to:
  /// **'Sub'**
  String get subLord;

  /// No description provided for @planetSignificators.
  ///
  /// In en, this message translates to:
  /// **'Planet Significators (Planet View)'**
  String get planetSignificators;

  /// No description provided for @houseSignificators.
  ///
  /// In en, this message translates to:
  /// **'House Significators (House View)'**
  String get houseSignificators;

  /// No description provided for @rasiChart.
  ///
  /// In en, this message translates to:
  /// **'Rasi Chart'**
  String get rasiChart;

  /// No description provided for @bhavaChart.
  ///
  /// In en, this message translates to:
  /// **'Bhava Chart'**
  String get bhavaChart;

  /// No description provided for @sarvaAshtakavarga.
  ///
  /// In en, this message translates to:
  /// **'Sarva Ashtakavarga'**
  String get sarvaAshtakavarga;

  /// No description provided for @suyaAshtakavarga.
  ///
  /// In en, this message translates to:
  /// **'Suya Varga'**
  String get suyaAshtakavarga;

  /// No description provided for @suyaVargaChakra.
  ///
  /// In en, this message translates to:
  /// **'Suya Varga Chakra'**
  String get suyaVargaChakra;

  /// No description provided for @palangal.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get palangal;

  /// No description provided for @noDetails.
  ///
  /// In en, this message translates to:
  /// **'No details available'**
  String get noDetails;

  /// No description provided for @jathagam.
  ///
  /// In en, this message translates to:
  /// **'Horoscope'**
  String get jathagam;

  /// No description provided for @jathagamWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Horoscope Workspace'**
  String get jathagamWorkspace;

  /// No description provided for @newJathagam.
  ///
  /// In en, this message translates to:
  /// **'New Horoscope'**
  String get newJathagam;

  /// No description provided for @jamakkolPrasannamTitle.
  ///
  /// In en, this message translates to:
  /// **'Jamakkol Prasannam'**
  String get jamakkolPrasannamTitle;

  /// No description provided for @placeLabel.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get placeLabel;

  /// No description provided for @jamakkolPlanet.
  ///
  /// In en, this message translates to:
  /// **'Jamakkol Planet'**
  String get jamakkolPlanet;

  /// No description provided for @jamakkolPlanetsMainPoints.
  ///
  /// In en, this message translates to:
  /// **'Jamakkol Planets & Main Points'**
  String get jamakkolPlanetsMainPoints;

  /// No description provided for @innerPlanets.
  ///
  /// In en, this message translates to:
  /// **'Inner Planets'**
  String get innerPlanets;

  /// No description provided for @nakshatra.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get nakshatra;

  /// No description provided for @pada.
  ///
  /// In en, this message translates to:
  /// **'Pada'**
  String get pada;

  /// No description provided for @udayam.
  ///
  /// In en, this message translates to:
  /// **'Udayam'**
  String get udayam;

  /// No description provided for @arudam.
  ///
  /// In en, this message translates to:
  /// **'Arudam'**
  String get arudam;

  /// No description provided for @kavippu.
  ///
  /// In en, this message translates to:
  /// **'Kavippu'**
  String get kavippu;

  /// No description provided for @strengthAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Strength Analysis'**
  String get strengthAnalysis;

  /// No description provided for @feature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get feature;

  /// No description provided for @lord.
  ///
  /// In en, this message translates to:
  /// **'Lord'**
  String get lord;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @errorCalculating.
  ///
  /// In en, this message translates to:
  /// **'Error calculating:'**
  String get errorCalculating;

  /// No description provided for @jamakkolChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Jamakkol Prasannam Chart'**
  String get jamakkolChartTitle;

  /// No description provided for @jamakkolNotes.
  ///
  /// In en, this message translates to:
  /// **'Jamakkol Notes'**
  String get jamakkolNotes;

  /// No description provided for @planetTowardsUdayam.
  ///
  /// In en, this message translates to:
  /// **'Planet coming towards Udayam'**
  String get planetTowardsUdayam;

  /// No description provided for @planetPassedUdayam.
  ///
  /// In en, this message translates to:
  /// **'Planet passed Udayam'**
  String get planetPassedUdayam;

  /// No description provided for @arudamHouse.
  ///
  /// In en, this message translates to:
  /// **'Arudam House'**
  String get arudamHouse;

  /// No description provided for @kavippuHouse.
  ///
  /// In en, this message translates to:
  /// **'Kavippu House'**
  String get kavippuHouse;

  /// No description provided for @kavippuPlanet.
  ///
  /// In en, this message translates to:
  /// **'Kavippu Planet'**
  String get kavippuPlanet;

  /// No description provided for @udayathipathiHouse.
  ///
  /// In en, this message translates to:
  /// **'Udayathipathi House'**
  String get udayathipathiHouse;

  /// No description provided for @parivarthanaYogas.
  ///
  /// In en, this message translates to:
  /// **'Parivarthana Yogas'**
  String get parivarthanaYogas;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @planetStatus.
  ///
  /// In en, this message translates to:
  /// **'Planet Status'**
  String get planetStatus;

  /// No description provided for @noDasaDetails.
  ///
  /// In en, this message translates to:
  /// **'No Dasa/Bukthi details'**
  String get noDasaDetails;

  /// No description provided for @dasaTitle.
  ///
  /// In en, this message translates to:
  /// **'Dasa'**
  String get dasaTitle;

  /// No description provided for @bukthiTitle.
  ///
  /// In en, this message translates to:
  /// **'Bukthi'**
  String get bukthiTitle;

  /// No description provided for @antharamTitle.
  ///
  /// In en, this message translates to:
  /// **'Antharam'**
  String get antharamTitle;

  /// No description provided for @sookshmamTitle.
  ///
  /// In en, this message translates to:
  /// **'Sookshmam'**
  String get sookshmamTitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @udaShort.
  ///
  /// In en, this message translates to:
  /// **'Uda'**
  String get udaShort;

  /// No description provided for @aruShort.
  ///
  /// In en, this message translates to:
  /// **'Aru'**
  String get aruShort;

  /// No description provided for @kaviShort.
  ///
  /// In en, this message translates to:
  /// **'Kavi'**
  String get kaviShort;

  /// No description provided for @utharayanam.
  ///
  /// In en, this message translates to:
  /// **'Utharayanam'**
  String get utharayanam;

  /// No description provided for @dakshinayanam.
  ///
  /// In en, this message translates to:
  /// **'Dakshinayanam'**
  String get dakshinayanam;

  /// No description provided for @vasanthaKaalam.
  ///
  /// In en, this message translates to:
  /// **'Vasantha Kaalam'**
  String get vasanthaKaalam;

  /// No description provided for @greeshmaKaalam.
  ///
  /// In en, this message translates to:
  /// **'Greeshma Kaalam'**
  String get greeshmaKaalam;

  /// No description provided for @varshaKaalam.
  ///
  /// In en, this message translates to:
  /// **'Varsha Kaalam'**
  String get varshaKaalam;

  /// No description provided for @sarathKaalam.
  ///
  /// In en, this message translates to:
  /// **'Sarath Kaalam'**
  String get sarathKaalam;

  /// No description provided for @hemanthaKaalam.
  ///
  /// In en, this message translates to:
  /// **'Hemantha Kaalam'**
  String get hemanthaKaalam;

  /// No description provided for @sisiraKaalam.
  ///
  /// In en, this message translates to:
  /// **'Sisira Kaalam'**
  String get sisiraKaalam;

  /// No description provided for @moon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get moon;

  /// No description provided for @lagna.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get lagna;

  /// No description provided for @mars.
  ///
  /// In en, this message translates to:
  /// **'Mars'**
  String get mars;

  /// No description provided for @west.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get west;

  /// No description provided for @east.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get east;

  /// No description provided for @north.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get north;

  /// No description provided for @south.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get south;

  /// No description provided for @jaggery.
  ///
  /// In en, this message translates to:
  /// **'Jaggery'**
  String get jaggery;

  /// No description provided for @curd.
  ///
  /// In en, this message translates to:
  /// **'Curd'**
  String get curd;

  /// No description provided for @milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// No description provided for @oil.
  ///
  /// In en, this message translates to:
  /// **'Oil'**
  String get oil;

  /// No description provided for @notToday.
  ///
  /// In en, this message translates to:
  /// **'Not Today'**
  String get notToday;

  /// No description provided for @panchangamTitle.
  ///
  /// In en, this message translates to:
  /// **'Panchangam'**
  String get panchangamTitle;

  /// No description provided for @detailsTab.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsTab;

  /// No description provided for @chartTab.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chartTab;

  /// No description provided for @changeDate.
  ///
  /// In en, this message translates to:
  /// **'Change Date'**
  String get changeDate;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Data Available'**
  String get noDataAvailable;

  /// No description provided for @basicDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Details'**
  String get basicDetailsTitle;

  /// No description provided for @tamilYear.
  ///
  /// In en, this message translates to:
  /// **'Tamil Year'**
  String get tamilYear;

  /// No description provided for @tamilDate.
  ///
  /// In en, this message translates to:
  /// **'Tamil Date'**
  String get tamilDate;

  /// No description provided for @englishDate.
  ///
  /// In en, this message translates to:
  /// **'English Date'**
  String get englishDate;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @kaliYear.
  ///
  /// In en, this message translates to:
  /// **'Kali Year'**
  String get kaliYear;

  /// No description provided for @kollamYear.
  ///
  /// In en, this message translates to:
  /// **'Kollam Year'**
  String get kollamYear;

  /// No description provided for @fasliYear.
  ///
  /// In en, this message translates to:
  /// **'Fasli Year'**
  String get fasliYear;

  /// No description provided for @salivahana.
  ///
  /// In en, this message translates to:
  /// **'Salivahana'**
  String get salivahana;

  /// No description provided for @hijriYear.
  ///
  /// In en, this message translates to:
  /// **'Hijri Year'**
  String get hijriYear;

  /// No description provided for @ayanamTitle.
  ///
  /// In en, this message translates to:
  /// **'Ayanam'**
  String get ayanamTitle;

  /// No description provided for @seasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get seasonTitle;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @moonDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Moon Details'**
  String get moonDetailsTitle;

  /// No description provided for @moonSign.
  ///
  /// In en, this message translates to:
  /// **'Moon Sign'**
  String get moonSign;

  /// No description provided for @chandrashtamaSign.
  ///
  /// In en, this message translates to:
  /// **'Chandrashtama Sign'**
  String get chandrashtamaSign;

  /// No description provided for @paksham.
  ///
  /// In en, this message translates to:
  /// **'Paksham'**
  String get paksham;

  /// No description provided for @tithiLabel.
  ///
  /// In en, this message translates to:
  /// **'Tithi'**
  String get tithiLabel;

  /// No description provided for @nakshatraLabel.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get nakshatraLabel;

  /// No description provided for @yogaLabel.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yogaLabel;

  /// No description provided for @karanaLabel.
  ///
  /// In en, this message translates to:
  /// **'Karana'**
  String get karanaLabel;

  /// No description provided for @amirthathiYogam.
  ///
  /// In en, this message translates to:
  /// **'Amirthathi Yogam'**
  String get amirthathiYogam;

  /// No description provided for @nethram.
  ///
  /// In en, this message translates to:
  /// **'Nethram'**
  String get nethram;

  /// No description provided for @jeevan.
  ///
  /// In en, this message translates to:
  /// **'Jeevan'**
  String get jeevan;

  /// No description provided for @soolamTitle.
  ///
  /// In en, this message translates to:
  /// **'Soolam'**
  String get soolamTitle;

  /// No description provided for @pariharamTitle.
  ///
  /// In en, this message translates to:
  /// **'Pariharam'**
  String get pariharamTitle;

  /// No description provided for @importantTimingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Timings'**
  String get importantTimingsTitle;

  /// No description provided for @nallaNeram.
  ///
  /// In en, this message translates to:
  /// **'Good Time'**
  String get nallaNeram;

  /// No description provided for @rahuKalam.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kalam'**
  String get rahuKalam;

  /// No description provided for @yemagandam.
  ///
  /// In en, this message translates to:
  /// **'Yemagandam'**
  String get yemagandam;

  /// No description provided for @kuligai.
  ///
  /// In en, this message translates to:
  /// **'Kuligai'**
  String get kuligai;

  /// No description provided for @rasiChartDataNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Rasi Chart Data Not Available'**
  String get rasiChartDataNotAvailable;

  /// No description provided for @rasiLabel.
  ///
  /// In en, this message translates to:
  /// **'Rasi'**
  String get rasiLabel;

  /// No description provided for @planetaryPositionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Planetary Positions'**
  String get planetaryPositionsTitle;

  /// No description provided for @retrograde.
  ///
  /// In en, this message translates to:
  /// **'Retrograde'**
  String get retrograde;

  /// No description provided for @untilLabel.
  ///
  /// In en, this message translates to:
  /// **'until:'**
  String get untilLabel;

  /// No description provided for @bhavam.
  ///
  /// In en, this message translates to:
  /// **'Bhavam'**
  String get bhavam;

  /// No description provided for @amirtham.
  ///
  /// In en, this message translates to:
  /// **'Amirtham'**
  String get amirtham;

  /// No description provided for @sitham.
  ///
  /// In en, this message translates to:
  /// **'Sitham'**
  String get sitham;

  /// No description provided for @maranam.
  ///
  /// In en, this message translates to:
  /// **'Maranam'**
  String get maranam;

  /// No description provided for @prabalarishtam.
  ///
  /// In en, this message translates to:
  /// **'Prabalarishtam'**
  String get prabalarishtam;

  /// No description provided for @dailyPanchangam.
  ///
  /// In en, this message translates to:
  /// **'Daily Panchangam'**
  String get dailyPanchangam;

  /// No description provided for @currentHora.
  ///
  /// In en, this message translates to:
  /// **'Current Hora'**
  String get currentHora;

  /// No description provided for @currentGowri.
  ///
  /// In en, this message translates to:
  /// **'Current Gowri'**
  String get currentGowri;

  /// No description provided for @marriageMatchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Marriage Matching'**
  String get marriageMatchingTitle;

  /// No description provided for @matchingResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Matching Results'**
  String get matchingResultsTitle;

  /// No description provided for @isMatchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Is it a match?'**
  String get isMatchingTitle;

  /// No description provided for @notMatching.
  ///
  /// In en, this message translates to:
  /// **'Not Matching'**
  String get notMatching;

  /// No description provided for @isMatching.
  ///
  /// In en, this message translates to:
  /// **'Matching'**
  String get isMatching;

  /// No description provided for @astrologerNotePrompt.
  ///
  /// In en, this message translates to:
  /// **'What should be in the astrologer\'s note?'**
  String get astrologerNotePrompt;

  /// No description provided for @girlHoroscopeTab.
  ///
  /// In en, this message translates to:
  /// **'Girl Horoscope'**
  String get girlHoroscopeTab;

  /// No description provided for @boyHoroscopeTab.
  ///
  /// In en, this message translates to:
  /// **'Boy Horoscope'**
  String get boyHoroscopeTab;

  /// No description provided for @girlDasaBukthiTab.
  ///
  /// In en, this message translates to:
  /// **'Girl Dasa Bukthi'**
  String get girlDasaBukthiTab;

  /// No description provided for @boyDasaBukthiTab.
  ///
  /// In en, this message translates to:
  /// **'Boy Dasa Bukthi'**
  String get boyDasaBukthiTab;

  /// No description provided for @matchingTab.
  ///
  /// In en, this message translates to:
  /// **'Matching'**
  String get matchingTab;

  /// No description provided for @girlDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Girl Details'**
  String get girlDetailsTitle;

  /// No description provided for @boyDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Boy Details'**
  String get boyDetailsTitle;

  /// No description provided for @girlLabel.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get girlLabel;

  /// No description provided for @boyLabel.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get boyLabel;

  /// No description provided for @totalMatchingLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Match: '**
  String get totalMatchingLabel;

  /// No description provided for @tenMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Ten Matches'**
  String get tenMatchesTitle;

  /// No description provided for @doshasTitle.
  ///
  /// In en, this message translates to:
  /// **'Horoscope Doshas'**
  String get doshasTitle;

  /// No description provided for @chevvaiDosham.
  ///
  /// In en, this message translates to:
  /// **'Chevvai Dosham (Mars)'**
  String get chevvaiDosham;

  /// No description provided for @rahuKetuDosham.
  ///
  /// In en, this message translates to:
  /// **'Rahu-Ketu Dosham'**
  String get rahuKetuDosham;

  /// No description provided for @dasaSandhi.
  ///
  /// In en, this message translates to:
  /// **'Dasa Sandhi'**
  String get dasaSandhi;

  /// No description provided for @doshaPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get doshaPresent;

  /// No description provided for @doshaAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get doshaAbsent;

  /// No description provided for @matchExcellent.
  ///
  /// In en, this message translates to:
  /// **'Match: Excellent'**
  String get matchExcellent;

  /// No description provided for @matchPoor.
  ///
  /// In en, this message translates to:
  /// **'Match: Poor'**
  String get matchPoor;

  /// No description provided for @dasaSandhiPresent.
  ///
  /// In en, this message translates to:
  /// **'Dasa Sandhi Present'**
  String get dasaSandhiPresent;

  /// No description provided for @dasaSandhiAbsent.
  ///
  /// In en, this message translates to:
  /// **'No Dasa Sandhi'**
  String get dasaSandhiAbsent;

  /// No description provided for @starMatchingLabel.
  ///
  /// In en, this message translates to:
  /// **'Star Matching'**
  String get starMatchingLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @lagnaLabel.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get lagnaLabel;

  /// No description provided for @atmakarakaLabel.
  ///
  /// In en, this message translates to:
  /// **'Atmakaraka'**
  String get atmakarakaLabel;

  /// No description provided for @ganam.
  ///
  /// In en, this message translates to:
  /// **'Ganam'**
  String get ganam;

  /// No description provided for @mirugam.
  ///
  /// In en, this message translates to:
  /// **'Mirugam'**
  String get mirugam;

  /// No description provided for @pakshi.
  ///
  /// In en, this message translates to:
  /// **'Pakshi'**
  String get pakshi;

  /// No description provided for @maram.
  ///
  /// In en, this message translates to:
  /// **'Maram'**
  String get maram;

  /// No description provided for @tamilYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Tamil Year'**
  String get tamilYearLabel;

  /// No description provided for @tamilDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Tamil Date'**
  String get tamilDateLabel;

  /// No description provided for @varaLabel.
  ///
  /// In en, this message translates to:
  /// **'Vara'**
  String get varaLabel;

  /// No description provided for @kaliYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Kali Year'**
  String get kaliYearLabel;

  /// No description provided for @kollamYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Kollam Year'**
  String get kollamYearLabel;

  /// No description provided for @sunriseLabel.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunriseLabel;

  /// No description provided for @sunsetLabel.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunsetLabel;

  /// No description provided for @paramaNazhigaiLabel.
  ///
  /// In en, this message translates to:
  /// **'Parama Nazhigai'**
  String get paramaNazhigaiLabel;

  /// No description provided for @horaLabel.
  ///
  /// In en, this message translates to:
  /// **'Hora'**
  String get horaLabel;

  /// No description provided for @amirthaYogaLabel.
  ///
  /// In en, this message translates to:
  /// **'Amirtha Yoga'**
  String get amirthaYogaLabel;

  /// No description provided for @dasaBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Dasa Balance'**
  String get dasaBalanceLabel;

  /// No description provided for @birthDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Birth Details'**
  String get birthDetailsTitle;

  /// No description provided for @astroBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Astrology Basics'**
  String get astroBasicsTitle;

  /// No description provided for @matchingAttrsTitle.
  ///
  /// In en, this message translates to:
  /// **'Matching Attributes'**
  String get matchingAttrsTitle;

  /// No description provided for @thirigonaSothanai.
  ///
  /// In en, this message translates to:
  /// **'Thirigona Sothanai'**
  String get thirigonaSothanai;

  /// No description provided for @egathipathyaSothanai.
  ///
  /// In en, this message translates to:
  /// **'Egathipathya Sothanai'**
  String get egathipathyaSothanai;

  /// No description provided for @pindangal.
  ///
  /// In en, this message translates to:
  /// **'Pindangal'**
  String get pindangal;

  /// No description provided for @rasiPindam.
  ///
  /// In en, this message translates to:
  /// **'Rasi Pindam'**
  String get rasiPindam;

  /// No description provided for @grahaPindam.
  ///
  /// In en, this message translates to:
  /// **'Graha Pindam'**
  String get grahaPindam;

  /// No description provided for @shodyaPindam.
  ///
  /// In en, this message translates to:
  /// **'Shodya Pindam'**
  String get shodyaPindam;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @amsam.
  ///
  /// In en, this message translates to:
  /// **'Navamsa'**
  String get amsam;

  /// No description provided for @gocharam.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get gocharam;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @jupiter.
  ///
  /// In en, this message translates to:
  /// **'Jupiter'**
  String get jupiter;

  /// No description provided for @venus.
  ///
  /// In en, this message translates to:
  /// **'Venus'**
  String get venus;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @rahu.
  ///
  /// In en, this message translates to:
  /// **'Rahu'**
  String get rahu;

  /// No description provided for @ketu.
  ///
  /// In en, this message translates to:
  /// **'Ketu'**
  String get ketu;

  /// No description provided for @maanthi.
  ///
  /// In en, this message translates to:
  /// **'Maanthi'**
  String get maanthi;

  /// No description provided for @aries.
  ///
  /// In en, this message translates to:
  /// **'Aries'**
  String get aries;

  /// No description provided for @taurus.
  ///
  /// In en, this message translates to:
  /// **'Taurus'**
  String get taurus;

  /// No description provided for @gemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get gemini;

  /// No description provided for @cancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get cancer;

  /// No description provided for @leo.
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get leo;

  /// No description provided for @virgo.
  ///
  /// In en, this message translates to:
  /// **'Virgo'**
  String get virgo;

  /// No description provided for @libra.
  ///
  /// In en, this message translates to:
  /// **'Libra'**
  String get libra;

  /// No description provided for @scorpio.
  ///
  /// In en, this message translates to:
  /// **'Scorpio'**
  String get scorpio;

  /// No description provided for @sagittarius.
  ///
  /// In en, this message translates to:
  /// **'Sagittarius'**
  String get sagittarius;

  /// No description provided for @capricorn.
  ///
  /// In en, this message translates to:
  /// **'Capricorn'**
  String get capricorn;

  /// No description provided for @aquarius.
  ///
  /// In en, this message translates to:
  /// **'Aquarius'**
  String get aquarius;

  /// No description provided for @pisces.
  ///
  /// In en, this message translates to:
  /// **'Pisces'**
  String get pisces;

  /// No description provided for @ashwini.
  ///
  /// In en, this message translates to:
  /// **'Ashwini'**
  String get ashwini;

  /// No description provided for @bharani.
  ///
  /// In en, this message translates to:
  /// **'Bharani'**
  String get bharani;

  /// No description provided for @krittika.
  ///
  /// In en, this message translates to:
  /// **'Krittika'**
  String get krittika;

  /// No description provided for @rohini.
  ///
  /// In en, this message translates to:
  /// **'Rohini'**
  String get rohini;

  /// No description provided for @mrigashirsha.
  ///
  /// In en, this message translates to:
  /// **'Mrigashirsha'**
  String get mrigashirsha;

  /// No description provided for @ardra.
  ///
  /// In en, this message translates to:
  /// **'Ardra'**
  String get ardra;

  /// No description provided for @punarvasu.
  ///
  /// In en, this message translates to:
  /// **'Punarvasu'**
  String get punarvasu;

  /// No description provided for @pushya.
  ///
  /// In en, this message translates to:
  /// **'Pushya'**
  String get pushya;

  /// No description provided for @ashlesha.
  ///
  /// In en, this message translates to:
  /// **'Ashlesha'**
  String get ashlesha;

  /// No description provided for @magha.
  ///
  /// In en, this message translates to:
  /// **'Magha'**
  String get magha;

  /// No description provided for @purvaPhalguni.
  ///
  /// In en, this message translates to:
  /// **'Purva Phalguni'**
  String get purvaPhalguni;

  /// No description provided for @uttaraPhalguni.
  ///
  /// In en, this message translates to:
  /// **'Uttara Phalguni'**
  String get uttaraPhalguni;

  /// No description provided for @hasta.
  ///
  /// In en, this message translates to:
  /// **'Hasta'**
  String get hasta;

  /// No description provided for @chithirai.
  ///
  /// In en, this message translates to:
  /// **'Chithirai'**
  String get chithirai;

  /// No description provided for @swati.
  ///
  /// In en, this message translates to:
  /// **'Swati'**
  String get swati;

  /// No description provided for @vishakha.
  ///
  /// In en, this message translates to:
  /// **'Vishakha'**
  String get vishakha;

  /// No description provided for @anuradha.
  ///
  /// In en, this message translates to:
  /// **'Anuradha'**
  String get anuradha;

  /// No description provided for @jyeshtha.
  ///
  /// In en, this message translates to:
  /// **'Jyeshtha'**
  String get jyeshtha;

  /// No description provided for @mula.
  ///
  /// In en, this message translates to:
  /// **'Mula'**
  String get mula;

  /// No description provided for @purvaAshadha.
  ///
  /// In en, this message translates to:
  /// **'Purva Ashadha'**
  String get purvaAshadha;

  /// No description provided for @uttaraAshadha.
  ///
  /// In en, this message translates to:
  /// **'Uttara Ashadha'**
  String get uttaraAshadha;

  /// No description provided for @shravana.
  ///
  /// In en, this message translates to:
  /// **'Shravana'**
  String get shravana;

  /// No description provided for @dhanishta.
  ///
  /// In en, this message translates to:
  /// **'Dhanishta'**
  String get dhanishta;

  /// No description provided for @shatabhisha.
  ///
  /// In en, this message translates to:
  /// **'Shatabhisha'**
  String get shatabhisha;

  /// No description provided for @purvaBhadrapada.
  ///
  /// In en, this message translates to:
  /// **'Purva Bhadrapada'**
  String get purvaBhadrapada;

  /// No description provided for @uttaraBhadrapada.
  ///
  /// In en, this message translates to:
  /// **'Uttara Bhadrapada'**
  String get uttaraBhadrapada;

  /// No description provided for @revati.
  ///
  /// In en, this message translates to:
  /// **'Revati'**
  String get revati;

  /// No description provided for @vaikasi.
  ///
  /// In en, this message translates to:
  /// **'Vaikasi'**
  String get vaikasi;

  /// No description provided for @aani.
  ///
  /// In en, this message translates to:
  /// **'Aani'**
  String get aani;

  /// No description provided for @aadi.
  ///
  /// In en, this message translates to:
  /// **'Aadi'**
  String get aadi;

  /// No description provided for @aavani.
  ///
  /// In en, this message translates to:
  /// **'Aavani'**
  String get aavani;

  /// No description provided for @purattasi.
  ///
  /// In en, this message translates to:
  /// **'Purattasi'**
  String get purattasi;

  /// No description provided for @aippasi.
  ///
  /// In en, this message translates to:
  /// **'Aippasi'**
  String get aippasi;

  /// No description provided for @karthikai.
  ///
  /// In en, this message translates to:
  /// **'Karthikai'**
  String get karthikai;

  /// No description provided for @margazhi.
  ///
  /// In en, this message translates to:
  /// **'Margazhi'**
  String get margazhi;

  /// No description provided for @thai.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get thai;

  /// No description provided for @masi.
  ///
  /// In en, this message translates to:
  /// **'Masi'**
  String get masi;

  /// No description provided for @panguni.
  ///
  /// In en, this message translates to:
  /// **'Panguni'**
  String get panguni;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
