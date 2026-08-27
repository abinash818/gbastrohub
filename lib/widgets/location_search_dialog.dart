import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import '../services/location_data.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';

class LocationSearchDialog extends StatefulWidget {
  const LocationSearchDialog({super.key});

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

enum SelectionStage { country, state, city }

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  SelectionStage _stage = SelectionStage.country;
  
  List<csc.Country> _countries = [];
  List<csc.State> _states = [];
  List<csc.City> _cities = [];
  
  List<dynamic> _filteredList = [];
  bool _hasAutoSkippedState = false;
  
  csc.Country? _selectedCountry;
  csc.State? _selectedState;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() => _isLoading = true);
    final locationService = LocationService();
    
    if (!locationService.isInitialized) {
      await locationService.init();
    }
    
    setState(() {
      _countries = List.from(locationService.countries);
      _isLoading = false;
      
      // Add "All" option for the country
      _countries.insert(0, csc.Country(
        name: 'All Countries (அனைத்து நாடுகளும்)',
        isoCode: 'ALL_COUNTRY',
        phoneCode: '',
        currency: '',
        latitude: '20.0', // Approximate center or arbitrary default
        longitude: '77.0',
        flag: '🌍', // Added required flag parameter
      ));
      
      try {
        final india = _countries.firstWhere((c) => c.isoCode == 'IN');
        _loadStates(india);
      } catch (e) {
        _filteredList = _countries;
        _stage = SelectionStage.country;
      }
    });
  }

  Future<void> _loadStates(csc.Country country) async {
    setState(() {
      _isLoading = true;
      _stage = SelectionStage.state;
      _selectedCountry = country;
    });
    
    List<csc.State> states = [];
    if (country.isoCode != 'ALL_COUNTRY') {
      final rawStates = await LocationService().getStates(country.isoCode);
      states = List.from(rawStates);
    }

    final settings = await SettingsService.getDefaultLocation();
    final defaultStateName = settings['state'] as String?;
    
    setState(() {
      _isLoading = false;
      _states = states;
      
      // Add "All" option for the state
      _states.insert(0, csc.State(
        name: country.isoCode == 'ALL_COUNTRY' ? 'All States (அனைத்து மாநிலங்களும்)' : 'All of ${country.name} (முழுவதும்)',
        isoCode: 'ALL_STATE',
        countryCode: country.isoCode,
        latitude: country.latitude,
        longitude: country.longitude,
      ));
      
      csc.State? autoSelectState;
      if (defaultStateName != null && defaultStateName.isNotEmpty) {
        int index = _states.indexWhere((s) => s.name.toLowerCase() == defaultStateName.toLowerCase());
        if (index != -1) {
          autoSelectState = _states[index];
          if (index > 0) {
            final defaultState = _states.removeAt(index);
            _states.insert(1, defaultState); // Insert after "All" option
          }
        }
      }
      
      _filteredList = _states;
      _searchController.clear();

      if (autoSelectState != null && !_hasAutoSkippedState && _searchController.text.isEmpty) {
        _hasAutoSkippedState = true;
        _loadCities(autoSelectState);
      }
    });
  }

  Future<void> _loadCities(csc.State state) async {
    setState(() {
      _isLoading = true;
      _stage = SelectionStage.city;
      _selectedState = state;
    });
    
    List<csc.City> cities = [];
    if (_selectedCountry!.isoCode == 'ALL_COUNTRY' && state.isoCode == 'ALL_STATE') {
      cities = await LocationService().getAllCities();
    } else if (state.isoCode == 'ALL_STATE') {
      cities = await LocationService().getCountryCities(_selectedCountry!.isoCode);
    } else {
      cities = await LocationService().getCities(_selectedCountry!.isoCode, state.isoCode);
    }
    
    setState(() {
      _isLoading = false;
      _cities = List.from(cities);
      _filteredList = _cities;
      _searchController.clear();
    });
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        if (_stage == SelectionStage.country) _filteredList = _countries;
        if (_stage == SelectionStage.state) _filteredList = _states;
        if (_stage == SelectionStage.city) _filteredList = _cities;
      } else {
        final q = query.toLowerCase();
        if (_stage == SelectionStage.country) {
          _filteredList = _countries.where((c) => c.name.toLowerCase().contains(q)).toList();
        } else if (_stage == SelectionStage.state) {
          _filteredList = _states.where((s) => s.name.toLowerCase().contains(q)).toList();
        } else if (_stage == SelectionStage.city) {
          _filteredList = _cities.where((c) => c.name.toLowerCase().contains(q)).toList();
        }
      }
    });
  }

  void _handleBack() {
    if (_stage == SelectionStage.city) {
      setState(() {
        _stage = SelectionStage.state;
        _filteredList = _states;
        _searchController.clear();
      });
    } else if (_stage == SelectionStage.state) {
      setState(() {
        _stage = SelectionStage.country;
        _filteredList = _countries;
        _searchController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = AppColors.primary;
    String title = 'நாடு (Country)';
    if (_stage == SelectionStage.state) title = 'மாநிலம் (State)';
    if (_stage == SelectionStage.city) title = 'நகரம் (City)';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        child: Column(
          children: [
            Row(
              children: [
                if (_stage != SelectionStage.country)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: orangeColor, size: 20),
                    onPressed: _handleBack,
                  ),
                Expanded(
                  child: Wrap(
                    alignment: _stage == SelectionStage.country ? WrapAlignment.center : WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: orangeColor),
                      ),
                      if (_stage == SelectionStage.city && _selectedState != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          "(${_selectedState!.name})",
                          style: TextStyle(fontSize: 13, color: orangeColor.withOpacity(0.7), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _stage == SelectionStage.country 
                  ? 'நாட்டைத் தேடுங்கள் (Search Country)...' 
                  : _stage == SelectionStage.state 
                    ? 'மாநிலத்தைத் தேடுங்கள் (Search State)...' 
                    : 'நகரத்தைத் தேடுங்கள் (Search City)...',
                prefixIcon: const Icon(Icons.search, color: orangeColor),
                filled: true,
                fillColor: orangeColor.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _filterList,
            ),
            const SizedBox(height: 12),
            if (_selectedCountry != null && _stage != SelectionStage.country)
              _buildBreadcrumb(),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: orangeColor))
                  : _filteredList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              _stage == SelectionStage.country 
                                ? 'நாடு கிடைக்கவில்லை.\nநாட்டைத் தேர்ந்தெடுங்கள்.'
                                : 'தகவல் கிடைக்கவில்லை',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredList.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withOpacity(0.05)),
                          itemBuilder: (context, index) {
                            final item = _filteredList[index];
                            final isSuggested = _stage == SelectionStage.state && index == 0 && _searchController.text.isEmpty;
                            
                            return ListTile(
                              dense: true,
                              leading: isSuggested ? const Icon(Icons.star_rounded, color: orangeColor, size: 20) : null,
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.name, 
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isSuggested) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: orangeColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "பரிந்துரை", 
                                        style: TextStyle(fontSize: 9, color: orangeColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
                              onTap: () {
                                if (_stage == SelectionStage.country) {
                                  final countryItem = item as csc.Country;
                                  _loadStates(countryItem);
                                } else if (_stage == SelectionStage.state) {
                                  final stateItem = item as csc.State;
                                  _loadCities(stateItem);
                                } else {
                                  final cityItem = item as csc.City;
                                  _finalizeSelection(cityItem);
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    String text = _selectedCountry!.name;
    if (_selectedState != null && _stage == SelectionStage.city) {
      text += " > ${_selectedState!.name}";
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.black54), overflow: TextOverflow.ellipsis),
    );
  }

  void _finalizeSelection(csc.City city) {
    double tz = 0.0;
    if (_selectedCountry != null) {
      if (_selectedCountry!.isoCode == 'IN') {
        tz = 5.5;
      } else {
        final tzs = _selectedCountry!.timezones;
        if (tzs != null && tzs.isNotEmpty) {
          final gmt = tzs[0].gmtOffset.toString();
          // Check if it's in seconds like "19800"
          double? val = double.tryParse(gmt);
          if (val != null && val.abs() > 100) {
            tz = val / 3600.0;
          } else {
            // If it's like "+05:30" or "-05:00" from gmtOffsetName
            String gmtName = tzs[0].gmtOffsetName?.toString() ?? "";
            if (gmtName.startsWith("UTC")) gmtName = gmtName.replaceAll("UTC", "").trim();
            if (gmtName.contains(":")) {
              final parts = gmtName.split(":");
              if (parts.length >= 2) {
                double h = double.tryParse(parts[0].replaceAll(RegExp(r'[^\d\-]'), '')) ?? 0.0;
                double m = double.tryParse(parts[1].replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0;
                tz = (h < 0) ? h - (m / 60.0) : h + (m / 60.0);
              }
            } else {
               tz = val ?? 0.0;
            }
          }
        }
      }
    }

    final lat = double.tryParse(city.latitude ?? '') ?? double.tryParse(_selectedState?.latitude ?? '') ?? double.tryParse(_selectedCountry?.latitude ?? '') ?? 0.0;
    final lon = double.tryParse(city.longitude ?? '') ?? double.tryParse(_selectedState?.longitude ?? '') ?? double.tryParse(_selectedCountry?.longitude ?? '') ?? 0.0;

    if (tz == 0.0 && lon != 0.0) {
      tz = double.parse((lon / 15.0).toStringAsFixed(1));
    }

    String finalName = city.name;
    if (_selectedCountry?.isoCode != 'ALL_COUNTRY' && _selectedState?.isoCode != 'ALL_STATE') {
      finalName = "${city.name}, ${_selectedState?.name}, ${_selectedCountry?.name}";
    } else if (_selectedCountry?.isoCode != 'ALL_COUNTRY' && _selectedState?.isoCode == 'ALL_STATE') {
      finalName = "${city.name}, ${_selectedCountry?.name}";
    } else {
      finalName = city.name;
    }

    final selection = CityLocation(
      name: finalName,
      lat: lat,
      lon: lon,
      tz: tz,
      stateName: _selectedState?.name ?? '',
      countryIso: _selectedCountry?.isoCode ?? '',
    );
    Navigator.pop(context, selection);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
