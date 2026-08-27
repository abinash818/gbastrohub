import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'horoscope_results_screen.dart';
import '../services/kp_service.dart';
import '../services/settings_service.dart';
import 'input_screen.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class TabData {
  final String title;
  final Widget content;
  
  TabData({required this.title, required this.content});
}

class HoroscopeWorkspaceScreen extends StatefulWidget {
  final Map<String, dynamic> initialJathagamData;

  const HoroscopeWorkspaceScreen({super.key, required this.initialJathagamData});

  @override
  State<HoroscopeWorkspaceScreen> createState() => _HoroscopeWorkspaceScreenState();
}

class _HoroscopeWorkspaceScreenState extends State<HoroscopeWorkspaceScreen> {
  List<TabData> _tabs = [];
  int _currentIndex = 0;
  bool _isLoadingTimeChart = true;

  @override
  void initState() {
    super.initState();
    _initializeWorkspace();
  }

  Future<void> _initializeWorkspace() async {
    // Add the user's initial Jathagam first (or second, let's load time chart first)
    // Wait, Time Chart needs to be calculated
    final timeChartData = await _calculateTimeChart();
    
    setState(() {
      _tabs.add(TabData(
        title: 'Time Chart',
        content: HoroscopeResultsScreen(
          results: timeChartData,
          name: 'Time Chart',
        ),
      ));
      
      _tabs.add(TabData(
        title: widget.initialJathagamData['name'] ?? '${AppLocalizations.of(context)!.jathagam} 1',
        content: HoroscopeResultsScreen(
          results: widget.initialJathagamData,
          name: widget.initialJathagamData['name'] ?? AppLocalizations.of(context)!.jathagam,
        ),
      ));
      
      _currentIndex = 1; // Focus on the newly generated Jathagam
      _isLoadingTimeChart = false;
    });
  }

  Future<Map<String, dynamic>> _calculateTimeChart() async {
    try {
      final now = DateTime.now();
      final location = await SettingsService.getDefaultLocation();
      final double lat = double.tryParse(location['lat'].toString()) ?? 13.0827;
      final double lon = double.tryParse(location['lon'].toString()) ?? 80.2707;
      final double tz = double.tryParse(location['tz'].toString()) ?? 5.5;

      final double yearLength = await SettingsService.getDasaYearLength();
      final int siderealMode = await SettingsService.getAyanamsa();

      final results = await KPService.calculateChart(
        'Time Chart',
        now,
        lat,
        lon,
        tz,
        yearLength: yearLength,
        siderealModeIndex: siderealMode,
      );
      
      results['name'] = 'Time Chart';
      results['birth_dt'] = now;
      results['lat'] = lat.toString();
      results['lon'] = lon.toString();
      results['place'] = location['name'] ?? 'Chennai';
      results['isKp'] = false;
      return results;
    } catch (e) {
      debugPrint("Error calculating time chart: $e");
      return {};
    }
  }
  
  void _addNewJathagam() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InputScreen(
        isPopup: true,
        isKp: false,
        isNadi: false,
        onCompleted: (results) {
          Navigator.pop(context); // Close the popup dialog
          setState(() {
            _tabs.add(TabData(
              title: results['name'] ?? '${AppLocalizations.of(context)!.jathagam} ${_tabs.length}',
              content: HoroscopeResultsScreen(
                results: results,
                name: results['name'] ?? AppLocalizations.of(context)!.jathagam,
              ),
            ));
            _currentIndex = _tabs.length - 1;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTimeChart) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.jathagamWorkspace, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 20)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            tooltip: AppLocalizations.of(context)!.newJathagam,
            onPressed: _addNewJathagam,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _tabs.map((t) => t.content).toList(),
            ),
          ),
          _buildBottomTabBar(),
        ],
      ),
    );
  }

  Widget _buildBottomTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _currentIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _currentIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tabs[index].title,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (index != 0) ...[ // Don't allow closing Time Chart
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _tabs.removeAt(index);
                                if (_currentIndex >= _tabs.length) {
                                  _currentIndex = _tabs.length - 1;
                                }
                              });
                            },
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
