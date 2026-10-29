import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import '../components/custom_drawer.dart';
import '../services/cloud_sync_service.dart';

class SavedHoroscopesScreen extends StatefulWidget {
  const SavedHoroscopesScreen({super.key});

  @override
  State<SavedHoroscopesScreen> createState() => _SavedHoroscopesScreenState();
}

class _SavedHoroscopesScreenState extends State<SavedHoroscopesScreen> {
  List<Map<String, dynamic>> _savedList = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadSavedHoroscopes().then((_) {
      _syncWithCloud(showFeedback: false);
    });
  }

  Future<void> _loadSavedHoroscopes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList('saved_horoscopes') ?? [];
    
    setState(() {
      _savedList = saved.map((item) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return decoded;
      }).toList().reversed.toList(); // Show newest first
      _isLoading = false;
    });
  }

  Future<void> _syncWithCloud({bool showFeedback = false}) async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final res = await CloudSyncService.syncAll();
      if (res['success'] == true) {
        await _loadSavedHoroscopes();
        if (showFeedback && mounted) {
          final int restored = res['restoredCount'] ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(restored > 0 
                ? 'கிளவுட் சிங்க் முடிந்தது! $restored ஜாதகங்கள் மீட்கப்பட்டது.' 
                : 'அனைத்து ஜாதகங்களும் கிளவுடில் புதுப்பிக்கப்பட்டுள்ளன.'),
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
      debugPrint("[CloudSync] Error in screen sync: $e");
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _deleteItem(int index) async {
    final itemToDelete = _savedList[index];
    final String? itemId = (itemToDelete['id'] ?? itemToDelete['item_id'])?.toString();

    setState(() {
      _savedList.removeAt(index);
    });
    
    final prefs = await SharedPreferences.getInstance();
    final List<String> updated = _savedList.reversed.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('saved_horoscopes', updated);

    // Delete from cloud in background
    if (itemId != null && itemId.isNotEmpty) {
      CloudSyncService.deleteFromCloud(itemId: itemId).catchError((e) {
        debugPrint("[CloudSync] Background delete error: $e");
        return false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('சேமிக்கப்பட்டவை', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isSyncing 
              ? const SizedBox(
                  width: 18, 
                  height: 18, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              : const Icon(Icons.cloud_sync_rounded, color: AppColors.primary, size: 24),
            tooltip: 'கிளவுட் சிங்க் (Cloud Sync)',
            onPressed: _isSyncing ? null : () => _syncWithCloud(showFeedback: true),
          ),
          const SizedBox(width: 8),
        ],
        leading: isWide ? null : Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: isWide ? null : const CustomDrawer(),
      body: SafeArea(
        child: Row(
          children: [
            if (isWide)
              const SizedBox(
                width: 280,
                child: CustomDrawer(),
              ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _savedList.isEmpty 
                        ? _buildEmptyState() 
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _savedList.length,
                            itemBuilder: (context, index) => _buildHoroscopeCard(index),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save_outlined, size: 80, color: const Color(0xFFB58D3D).withOpacity(0.5)),
          const SizedBox(height: 20),
          Text('ஜாதகங்கள் எதுவும் சேமிக்கப்படவில்லை', style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildHoroscopeCard(int index) {
    final item = _savedList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.04), 
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF6EE), 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3)),
          ),
          child: const Icon(Icons.person_outline_rounded, color: Color(0xFFB58D3D), size: 30),
        ),
        title: Text(item['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: const Color(0xFF5D1204))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(_getFormattedDateTime(item), style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13)),
            Text(item['place'] ?? 'Unknown Place', style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          onPressed: () => _confirmDelete(index),
        ),
        onTap: () {
          final data = Map<String, dynamic>.from(item);
          // Convert date string back to DateTime for calculation
          if (data['date'] is String) {
            data['date'] = DateTime.parse(data['date']);
          }
          AppNavigator.calculateAndNavigate(context, data);
        },
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('நீக்கலாமா?'),
        content: const Text('இந்த ஜாதகத்தை நிரந்தரமாக நீக்க விரும்புகிறீர்களா?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('இல்லை')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(index);
            }, 
            child: const Text('ஆம், நீக்கு', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  String _getFormattedDateTime(Map<String, dynamic> item) {
    try {
      if (item['date'] == null) return "No Date";
      final dt = DateTime.parse(item['date']);
      return "${DateFormat('dd/MM/yyyy').format(dt)} - ${DateFormat('hh:mm a').format(dt)}";
    } catch (e) {
      return item['date']?.toString() ?? "Invalid Date";
    }
  }
}
