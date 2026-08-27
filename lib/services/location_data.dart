class CityLocation {
  final String name;
  final double lat;
  final double lon;
  final double tz;
  final String stateName;
  final String countryIso;

  const CityLocation({
    required this.name,
    required this.lat,
    required this.lon,
    required this.tz,
    this.stateName = '',
    this.countryIso = '',
  });
}

class LocationData {
  static const List<CityLocation> commonCities = [
    CityLocation(name: 'Chennai (சென்னை)', lat: 13.0827, lon: 80.2707, tz: 5.5),
    CityLocation(name: 'Coimbatore (கோயம்புத்தூர்)', lat: 11.0168, lon: 76.9558, tz: 5.5),
    CityLocation(name: 'Madurai (மதுரை)', lat: 9.9252, lon: 78.1198, tz: 5.5),
    CityLocation(name: 'Tiruchirappalli (திருச்சிராப்பள்ளி)', lat: 10.7905, lon: 78.7047, tz: 5.5),
    CityLocation(name: 'Salem (சேலம்)', lat: 11.6643, lon: 78.1460, tz: 5.5),
    CityLocation(name: 'Tirunelveli (திருநெல்வேலி)', lat: 8.7139, lon: 77.7567, tz: 5.5),
    CityLocation(name: 'Tiruppur (திருப்பூர்)', lat: 11.1085, lon: 77.3411, tz: 5.5),
    CityLocation(name: 'Erode (ஈரோடு)', lat: 11.3410, lon: 77.7172, tz: 5.5),
    CityLocation(name: 'Vellore (வேலூர்)', lat: 12.9165, lon: 79.1325, tz: 5.5),
    CityLocation(name: 'Thoothukudi (தூத்துக்குடி)', lat: 8.7642, lon: 78.1348, tz: 5.5),
    CityLocation(name: 'Nagercoil (நாகர்கோவில்)', lat: 8.1833, lon: 77.4119, tz: 5.5),
    CityLocation(name: 'Thanjavur (தஞ்சாவூர்)', lat: 10.7870, lon: 79.1378, tz: 5.5),
    CityLocation(name: 'Dindigul (திண்டுக்கல்)', lat: 10.3673, lon: 77.9803, tz: 5.5),
    CityLocation(name: 'Ranipet (ராணிப்பேட்டை)', lat: 12.9272, lon: 79.3331, tz: 5.5),
    CityLocation(name: 'Sivakasi (சிவகாசி)', lat: 9.4533, lon: 77.8024, tz: 5.5),
    CityLocation(name: 'Karur (கரூர்)', lat: 10.9601, lon: 78.0766, tz: 5.5),
    CityLocation(name: 'Udhagamandalam (ஊட்டி)', lat: 11.4064, lon: 76.6932, tz: 5.5),
    CityLocation(name: 'Hosur (ஓசூர்)', lat: 12.7409, lon: 77.8253, tz: 5.5),
    CityLocation(name: 'Kanchipuram (காஞ்சிபுரம்)', lat: 12.8342, lon: 79.7036, tz: 5.5),
    CityLocation(name: 'Karaikudi (காரைக்குடி)', lat: 10.0747, lon: 78.7733, tz: 5.5),
    CityLocation(name: 'Neyveli (நெய்வேலி)', lat: 11.5333, lon: 79.4833, tz: 5.5),
    CityLocation(name: 'Kumbakonam (கும்பக்கோணம்)', lat: 10.9602, lon: 79.3845, tz: 5.5),
    CityLocation(name: 'Pollachi (பொள்ளாச்சி)', lat: 10.6588, lon: 77.0101, tz: 5.5),
    CityLocation(name: 'Rajapalayam (ராஜபாளையம்)', lat: 9.4442, lon: 77.5645, tz: 5.5),
    CityLocation(name: 'Gudiyatham (குடியாத்தம்)', lat: 12.9463, lon: 78.8715, tz: 5.5),
    CityLocation(name: 'Pudukkottai (புதுக்கோட்டை)', lat: 10.3797, lon: 78.8205, tz: 5.5),
    CityLocation(name: 'Vaniyambadi (வாணியம்பாடி)', lat: 12.6841, lon: 78.6186, tz: 5.5),
    CityLocation(name: 'Ambur (ஆம்பூர்)', lat: 12.7841, lon: 78.7186, tz: 5.5),
    CityLocation(name: 'Nagapattinam (நாகப்பட்டினம்)', lat: 10.7672, lon: 79.8444, tz: 5.5),
    CityLocation(name: 'Cuddalore (கடலூர்)', lat: 11.7480, lon: 79.7714, tz: 5.5),
    CityLocation(name: 'Chengalpattu (செங்கல்பட்டு)', lat: 12.6915, lon: 79.9758, tz: 5.5),
    CityLocation(name: 'Tenkasi (தென்காசி)', lat: 8.9591, lon: 77.3150, tz: 5.5),
    CityLocation(name: 'Sankarankovil (சங்கரன்கோவில்)', lat: 9.1721, lon: 77.5342, tz: 5.5),
    CityLocation(name: 'Kovilpatti (கோவில்பட்டி)', lat: 9.1738, lon: 77.8687, tz: 5.5),
    CityLocation(name: 'Mayiladuthurai (மயிலாடுதுறை)', lat: 11.1018, lon: 79.6525, tz: 5.5),
    CityLocation(name: 'Tiruvarur (திருவாரூர்)', lat: 10.7733, lon: 79.6358, tz: 5.5),
    CityLocation(name: 'Perambalur (பெரம்பலூர்)', lat: 11.2333, lon: 78.8833, tz: 5.5),
    CityLocation(name: 'Ariyalur (அரியலூர்)', lat: 11.1401, lon: 79.0786, tz: 5.5),
    CityLocation(name: 'Namakkal (நாமக்கல்)', lat: 11.2189, lon: 78.1672, tz: 5.5),
    CityLocation(name: 'Dharmapuri (தர்மபுரி)', lat: 12.1270, lon: 78.1581, tz: 5.5),
    CityLocation(name: 'Krishnagiri (கிருஷ்ணகிரி)', lat: 12.5186, lon: 78.2137, tz: 5.5),
    CityLocation(name: 'Theni (தேனி)', lat: 10.0101, lon: 77.4768, tz: 5.5),
    CityLocation(name: 'Villupuram (விழுப்புரம்)', lat: 11.9401, lon: 79.4861, tz: 5.5),
    CityLocation(name: 'Kallakurichi (கள்ளக்குறிச்சி)', lat: 11.7373, lon: 78.9625, tz: 5.5),
    CityLocation(name: 'Tiruvannamalai (திருவண்ணாமலை)', lat: 12.2274, lon: 79.0712, tz: 5.5),
    CityLocation(name: 'Tiruvallur (திருவள்ளூர்)', lat: 13.1438, lon: 79.9129, tz: 5.5),
    CityLocation(name: 'Kanyakumari (கன்னியாகுமரி)', lat: 8.0883, lon: 77.5385, tz: 5.5),
    CityLocation(name: 'Rameswaram (ராமேஸ்வரம்)', lat: 9.2881, lon: 79.3174, tz: 5.5),
    CityLocation(name: 'Mannargudi (மன்னார்குடி)', lat: 10.6631, lon: 79.4398, tz: 5.5),
    CityLocation(name: 'Pattukkottai (பட்டுக்கோட்டை)', lat: 10.4300, lon: 79.3167, tz: 5.5),
  ];
}
