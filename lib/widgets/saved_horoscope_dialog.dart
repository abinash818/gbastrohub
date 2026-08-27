import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class SavedHoroscopeDialog extends StatefulWidget {
  const SavedHoroscopeDialog({Key? key}) : super(key: key);

  @override
  State<SavedHoroscopeDialog> createState() => _SavedHoroscopeDialogState();
}

class _SavedHoroscopeDialogState extends State<SavedHoroscopeDialog> {
  List<Map<String, dynamic>> _savedList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedHoroscopes();
  }

  Future<void> _loadSavedHoroscopes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList('saved_horoscopes') ?? [];
    
    setState(() {
      _savedList = saved.map((item) {
        return jsonDecode(item) as Map<String, dynamic>;
      }).toList().reversed.toList();
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('சேமிக்கப்பட்ட ஜாதகங்கள்', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
            const SizedBox(height: 15),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _savedList.isEmpty 
                  ? Center(child: Text('ஜாதகங்கள் எதுவும் இல்லை', style: GoogleFonts.outfit(color: Colors.grey.shade600)))
                  : ListView.builder(
                      itemCount: _savedList.length,
                      itemBuilder: (context, index) {
                        final item = _savedList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                          color: Colors.white,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF6EE), 
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.person_outline_rounded, color: Color(0xFFB58D3D), size: 24),
                            ),
                            title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                            subtitle: Text(_getFormattedDateTime(item), style: const TextStyle(fontSize: 12)),
                            onTap: () {
                              Navigator.pop(context, item);
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('மூடு (Close)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
