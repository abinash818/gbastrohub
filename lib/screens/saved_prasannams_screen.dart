import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/cloud_sync_service.dart';

class SavedPrasannamsScreen extends StatefulWidget {
  final bool selectMode;
  const SavedPrasannamsScreen({super.key, this.selectMode = true});

  @override
  State<SavedPrasannamsScreen> createState() => _SavedPrasannamsScreenState();
}

class _SavedPrasannamsScreenState extends State<SavedPrasannamsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _prasannamsList = [];
  List<Map<String, dynamic>> _horoscopesList = [];

  bool _isLoading = true;
  bool _isSyncing = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    _loadAllData().then((_) {
      _syncWithCloud(showFeedback: false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Jamakkol Prasannams
    final List<String> rawPrasannams = prefs.getStringList('saved_jamakkol_prasannams') ?? [];
    final List<Map<String, dynamic>> parsedPrasannams = [];
    for (var str in rawPrasannams) {
      try {
        final decoded = jsonDecode(str) as Map<String, dynamic>;
        parsedPrasannams.add(decoded);
      } catch (_) {}
    }

    // 2. Load General Horoscopes
    final List<String> rawHoroscopes = prefs.getStringList('saved_horoscopes') ?? [];
    final List<Map<String, dynamic>> parsedHoroscopes = [];
    for (var str in rawHoroscopes) {
      try {
        final decoded = jsonDecode(str) as Map<String, dynamic>;
        parsedHoroscopes.add(decoded);
      } catch (_) {}
    }

    setState(() {
      _prasannamsList = parsedPrasannams.reversed.toList();
      _horoscopesList = parsedHoroscopes.reversed.toList();
      _isLoading = false;
    });
  }

  Future<void> _syncWithCloud({bool showFeedback = false}) async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final res = await CloudSyncService.syncAll();
      if (res['success'] == true) {
        await _loadAllData();
        if (showFeedback && mounted) {
          final int restored = res['restoredCount'] ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(restored > 0 
                ? 'கிளவுட் சிங்க் முடிந்தது! $restored பதிவுகள் மீட்கப்பட்டது.' 
                : 'அனைத்து பதிவுகளும் கிளவுடில் புதுப்பிக்கப்பட்டுள்ளன.'),
              backgroundColor: const Color(0xFF1B5E20),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'சிங்க் தோல்வியடைந்தது'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("[CloudSync] Error in prasannams sync: $e");
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _deletePrasannam(int index) async {
    final itemToDelete = _prasannamsList[index];
    final String? itemId = (itemToDelete['id'] ?? itemToDelete['item_id'])?.toString();

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prasannamsList.removeAt(index);
    });
    final updated = _prasannamsList.reversed.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('saved_jamakkol_prasannams', updated);

    if (itemId != null && itemId.isNotEmpty) {
      CloudSyncService.deleteFromCloud(itemId: itemId).catchError((e) {
        debugPrint("[CloudSync] Background delete error: $e");
        return false;
      });
    }
  }

  Future<void> _deleteHoroscope(int index) async {
    final itemToDelete = _horoscopesList[index];
    final String? itemId = (itemToDelete['id'] ?? itemToDelete['item_id'])?.toString();

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _horoscopesList.removeAt(index);
    });
    final updated = _horoscopesList.reversed.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('saved_horoscopes', updated);

    if (itemId != null && itemId.isNotEmpty) {
      CloudSyncService.deleteFromCloud(itemId: itemId).catchError((e) {
        debugPrint("[CloudSync] Background delete error: $e");
        return false;
      });
    }
  }

  List<Map<String, dynamic>> _filterList(List<Map<String, dynamic>> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final place = (item['place'] ?? '').toString().toLowerCase();
      final date = (item['date'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) || place.contains(_searchQuery) || date.contains(_searchQuery);
    }).toList();
  }

  String _formatCoordinates(dynamic lat, dynamic lon) {
    if (lat == null || lon == null) return "";
    try {
      double latD = (lat as num).toDouble();
      double lonD = (lon as num).toDouble();
      String latStr = "${latD.abs()}${latD >= 0 ? 'N' : 'S'}";
      String lonStr = "${lonD.abs()}${lonD >= 0 ? 'E' : 'W'}";
      return "$latStr , $lonStr";
    } catch (_) {
      return "$lat , $lon";
    }
  }

  String _formatDateOnly(dynamic dateVal) {
    if (dateVal == null) return "-";
    try {
      DateTime dt = dateVal is DateTime ? dateVal : DateTime.parse(dateVal.toString());
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      return dateVal.toString();
    }
  }

  String _formatTimeOnly(dynamic dateVal) {
    if (dateVal == null) return "-";
    try {
      DateTime dt = dateVal is DateTime ? dateVal : DateTime.parse(dateVal.toString());
      return DateFormat('HH:mm:ss').format(dt);
    } catch (_) {
      return "";
    }
  }

  void _onSelectPrasannam(Map<String, dynamic> item) {
    if (widget.selectMode) {
      Navigator.pop(context, item);
    } else {
      Navigator.pushReplacementNamed(context, '/jamakkol', arguments: {
        'name': item['name'],
        'date': item['date'] is DateTime ? item['date'] : DateTime.parse(item['date']),
        'place': item['place'] ?? 'Chennai (சென்னை)',
        'lat': (item['lat'] ?? item['latitude'] as num?)?.toDouble() ?? 13.0827,
        'lon': (item['lon'] ?? item['longitude'] as num?)?.toDouble() ?? 80.2707,
        'tz': (item['tz'] ?? item['timezone'] as num?)?.toDouble() ?? 5.5,
        'arudam_idx': item['arudam_idx'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'சேமிக்கப்பட்டவை',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isSyncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              : const Icon(Icons.cloud_sync_rounded, color: AppColors.primary),
            tooltip: 'கிளவுட் சிங்க் (Cloud Sync)',
            onPressed: _isSyncing ? null : () => _syncWithCloud(showFeedback: true),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'புதுப்பி (Refresh)',
            onPressed: _loadAllData,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(text: "பிரசன்னங்கள் (${_prasannamsList.length})"),
            Tab(text: "ஜாதகங்கள் (${_horoscopesList.length})"),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Box
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5D1204).withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'பெயர், ஊர் அல்லது தேதி மூலம் தேடுக...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB58D3D)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPrasannamsTab(),
                        _buildHoroscopesTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrasannamsTab() {
    final filtered = _filterList(_prasannamsList);
    if (filtered.isEmpty) {
      return _buildEmptyState(
        _searchQuery.isNotEmpty ? 'தேடலுக்குரிய பிரசன்னங்கள் எதுவும் இல்லை' : 'சேமிக்கப்பட்ட பிரசன்னங்கள் எதுவும் இல்லை',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final originalIdx = _prasannamsList.indexOf(item);
        return _buildItemCard(
          item: item,
          onTap: () => _onSelectPrasannam(item),
          onDelete: () => _confirmDelete(
            title: item['name'] ?? 'பிரசன்னம்',
            onConfirmed: () => _deletePrasannam(originalIdx),
          ),
          isPrasannam: true,
        );
      },
    );
  }

  Widget _buildHoroscopesTab() {
    final filtered = _filterList(_horoscopesList);
    if (filtered.isEmpty) {
      return _buildEmptyState(
        _searchQuery.isNotEmpty ? 'தேடலுக்குரிய ஜாதகங்கள் எதுவும் இல்லை' : 'சேமிக்கப்பட்ட ஜாதகங்கள் எதுவும் இல்லை',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final originalIdx = _horoscopesList.indexOf(item);
        return _buildItemCard(
          item: item,
          onTap: () => _onSelectPrasannam(item),
          onDelete: () => _confirmDelete(
            title: item['name'] ?? 'ஜாதகம்',
            onConfirmed: () => _deleteHoroscope(originalIdx),
          ),
          isPrasannam: false,
        );
      },
    );
  }

  Widget _buildItemCard({
    required Map<String, dynamic> item,
    required VoidCallback onTap,
    required VoidCallback onDelete,
    required bool isPrasannam,
  }) {
    final name = item['name'] ?? (isPrasannam ? 'பிரசன்னம்' : 'ஜாதகம்');
    final dateVal = item['date'];
    final dateStr = _formatDateOnly(dateVal);
    final timeStr = _formatTimeOnly(dateVal);
    final lat = item['lat'] ?? item['latitude'];
    final lon = item['lon'] ?? item['longitude'];
    final coordsStr = _formatCoordinates(lat, lon);
    final placeStr = item['place'] ?? '';
    final ayanamsa = item['ayanamsa'] ?? 'Lahari 1940';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.35), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Name & Delete
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "பெயர்: $name",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Date & Time Row
                Row(
                  children: [
                    Text(
                      "நாள்: $dateStr",
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      "நேரம்: $timeStr",
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Coordinates & Place Row
                if (coordsStr.isNotEmpty || placeStr.isNotEmpty)
                  Text(
                    coordsStr.isNotEmpty && placeStr.isNotEmpty 
                        ? "$coordsStr ($placeStr)" 
                        : (coordsStr.isNotEmpty ? coordsStr : placeStr),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),

                const SizedBox(height: 4),

                // Ayanamsa Row
                Text(
                  "அயனாம்சம்: $ayanamsa",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),

                // Optional Jamakkol Badges
                if (isPrasannam && item['udayam'] != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildChip("உதயம்: ${item['udayam']}", const Color(0xFF1B5E20)),
                      if (item['arudam'] != null) _buildChip("ஆருடம்: ${item['arudam']}", const Color(0xFF0D47A1)),
                      if (item['kavippu'] != null) _buildChip("கவிப்பு: ${item['kavippu']}", const Color(0xFFB71C1C)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmDelete({required String title, required VoidCallback onConfirmed}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('நீக்கலாமா?'),
        content: Text('"$title" பிரசன்னத்தை நிரந்தரமாக நீக்க விரும்புகிறீர்களா?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('இல்லை')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirmed();
            },
            child: const Text('ஆம், நீக்கு', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded, size: 70, color: const Color(0xFFB58D3D).withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
