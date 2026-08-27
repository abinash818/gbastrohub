import 'package:flutter/material.dart';
import '../services/kp_service.dart';
import '../services/settings_service.dart';
import 'horoscope_results_screen.dart';
import '../theme/app_colors.dart';

class LiveDashboardScreen extends StatefulWidget {
  const LiveDashboardScreen({super.key});

  @override
  State<LiveDashboardScreen> createState() => _LiveDashboardScreenState();
}

class _LiveDashboardScreenState extends State<LiveDashboardScreen> {
  Map<String, dynamic>? _results;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculateLiveHoroscope();
  }

  Future<void> _calculateLiveHoroscope() async {
    try {
      final loc = await SettingsService.getDefaultLocation();
      final lat = loc['lat'] as double;
      final lon = loc['lon'] as double;
      final tz = loc['tz'] as double;

      final now = DateTime.now();
      
      final results = await KPService.calculateChart(
        "தற்போதைய கிரக நிலை", 
        now, 
        lat, 
        lon, 
        tz
      );

      results['birth_dt'] = now;
      results['place'] = loc['name'];

      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text("தற்போதைய கிரக நிலை கணிக்கப்படுகிறது...", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    if (_error != null || _results == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text("Error: $_error", style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return HoroscopeResultsScreen(
      results: _results!,
      name: "தற்போதைய கிரக நிலை",
    );
  }
}
