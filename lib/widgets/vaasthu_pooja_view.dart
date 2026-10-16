import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/vaasthu_pooja_service.dart';
import '../widgets/location_search_dialog.dart';

class VaasthuPoojaView extends StatefulWidget {
  const VaasthuPoojaView({super.key});

  @override
  State<VaasthuPoojaView> createState() => _VaasthuPoojaViewState();
}

class _VaasthuPoojaViewState extends State<VaasthuPoojaView> {
  int _selectedYear = 2026;
  String _selectedCity = 'நாமக்கல்';
  int _selectedIndex = 4; // Default to Aippasi 11 (index 4) as in the user's prompt

  final Map<int, String> _customSunrises = {};

  @override
  Widget build(BuildContext context) {
    final List<VaasthuPoojaItem> items = VaasthuPoojaService.generateYearTable(
      year: _selectedYear,
      cityName: _selectedCity,
      customSunrises: _customSunrises.isNotEmpty ? _customSunrises : null,
    );

    final selectedItem = items[_selectedIndex.clamp(0, items.length - 1)];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Banner
          _buildHeaderBanner(),
          const SizedBox(height: 16),

          // 2. City & Year Filter Card
          _buildFilterCard(),
          const SizedBox(height: 18),

          // 3. Featured Calculation (படம் 2: உதாரணக் கணக்கீடு)
          _buildFeaturedCalculationCard(selectedItem),
          const SizedBox(height: 18),

          // 4. Complete 8-Month Table Card
          _buildPoojaTableCard(items),
          const SizedBox(height: 18),

          // 5. Vaasthu Rules & Guidelines
          _buildGuidelinesCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D1204), Color(0xFF8A1538)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE082).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Color(0xFFFFE082), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'வாஸ்து / பூமி பூஜை நாள் & நேரம்',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFE082),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'வருடத்தில் வாஸ்து புருஷன் விழிக்கும் 8 நாட்கள் அட்டவணை',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'வருடம் & ஊர் தேர்வு (Year & Location):',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Year Selector Row
          Row(
            children: [
              const Text('வருடம்:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855))),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [2025, 2026, 2027, 2028].map((y) {
                    final isSel = _selectedYear == y;
                    return InkWell(
                      onTap: () => setState(() => _selectedYear = y),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF5D1204) : const Color(0xFFFAF6EE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '$y',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // City Selector Row
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Color(0xFF5D1204), size: 18),
              const SizedBox(width: 6),
              const Text('ஊர்:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855))),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.35)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: VaasthuPoojaService.standardLocations.containsKey(_selectedCity) ? _selectedCity : 'நாமக்கல்',
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5D1204)),
                      items: VaasthuPoojaService.standardLocations.keys.map((c) {
                        return DropdownMenuItem<String>(
                          value: c,
                          child: Text(
                            c,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCity = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final loc = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (ctx) => const LocationSearchDialog(),
                  );
                  if (loc != null && loc['name'] != null) {
                    setState(() {
                      _selectedCity = loc['name'].toString().split(',')[0].trim();
                    });
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D1204),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search_rounded, color: Color(0xFFFFE082), size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCalculationCard(VaasthuPoojaItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF5D1204),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'உதாரணக் கணக்கீடு (Ex)',
                  style: TextStyle(color: Color(0xFFFFE082), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${item.tamilDisplay} - வாஸ்து பூஜை நேரம்',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: const Color(0xFF5D1204),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Subtitle details pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'தேதி: ${item.englishDateFormatted}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
                ),
                Text(
                  'ஊர்: $_selectedCity',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                ),
                Text(
                  'தமிழ்: ${item.tamilDisplay}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Arithmetic Breakdown
          _buildCalculationStepRow('சூரிய உதயம்', item.sunriseStr, const Color(0xFFB45309)),
          _buildCalculationStepRow('துருவ எண்', item.rule.dhruvaTimeStr, const Color(0xFF1565C0)),
          const Divider(height: 14),
          _buildCalculationStepRow('கூட்டினால் (ஆரம்ப நேரம்)', item.startTimeStr, Colors.green.shade800, isBold: true),
          _buildCalculationStepRow('முடிவு (வரை)', '+ 00:18:00', Colors.grey.shade700),
          const Divider(height: 14),
          _buildCalculationStepRow('கூட்டினால் (முடிவு நேரம்)', item.endTimeStr, Colors.green.shade800, isBold: true),
          const SizedBox(height: 12),

          // Final Result Green Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1B5E20),
                  const Color(0xFF2E7D32),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFFFE082), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'முடிவு: ${item.englishDateFormatted} அன்று காலை ${item.startTimeStr} முதல் ${item.endTimeStr} மணி வரை வாஸ்து பூஜை நேரம் ஆகும்.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationStepRow(String title, String value, Color valueColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF444444),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoojaTableCard(List<VaasthuPoojaItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'வாஸ்து / பூமி பூஜை நாள் & நேரம் அட்டவணை:',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'குறிப்பிட்ட வரிசையைத் தொட்டு மேலே உள்ள உதாரணக் கணக்கீட்டைப் பார்க்கலாம்:',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855)),
          ),
          const SizedBox(height: 12),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5D1204),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('தமிழ்\nமாதம்', style: TextStyle(color: Color(0xFFFFE082), fontSize: 10, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('ஆங்கில\nதேதி', style: TextStyle(color: Color(0xFFFFE082), fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('சூரிய\nஉதயம்', style: TextStyle(color: Color(0xFFFFE082), fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('துருவ\nஎண்', style: TextStyle(color: Color(0xFFFFE082), fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 4, child: Text('வாஸ்து பூஜை\nநேரம் (18 நிமி)', style: TextStyle(color: Color(0xFFFFE082), fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFE0D5C1)),
            itemBuilder: (ctx, index) {
              final item = items[index];
              final bool isSelected = _selectedIndex == index;

              return InkWell(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: isSelected ? Border.all(color: Colors.green.shade700, width: 1.2) : null,
                  ),
                  child: Row(
                    children: [
                      // 1. Tamil Month & Date
                      Expanded(
                        flex: 3,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.tamilDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                              color: const Color(0xFF5D1204),
                            ),
                          ),
                        ),
                      ),

                      // 2. English Date
                      Expanded(
                        flex: 3,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            item.englishDateFormatted,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                          ),
                        ),
                      ),

                      // 3. Sunrise
                      Expanded(
                        flex: 3,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            item.sunriseStr.replaceAll(' AM', ''),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                          ),
                        ),
                      ),

                      // 4. Dhruva Number
                      Expanded(
                        flex: 2,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            item.rule.dhruvaDisplay,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                          ),
                        ),
                      ),

                      // 5. Pooja Time Window
                      Expanded(
                        flex: 4,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${item.startTimeStr.replaceAll(':00 ', ' ').replaceAll(' AM', '')} - ${item.endTimeStr.replaceAll(' AM', '')}",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelinesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'வாஸ்து புருஷன் விழிக்கும் நாட்கள் - சாஸ்திர விதிகள்:',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildRuleBullet(
            'வருடத்திற்கு 8 நாட்கள் மட்டுமே:',
            'வாஸ்து புருஷன் ஒரு தமிழ் வருடத்தில் இந்த குறிப்பிட்ட 8 நாட்களில் மட்டுமே விழித்திருப்பார். இந்நாட்களில்தான் மனை முகூர்த்தம், பூமி பூஜை செய்ய வேண்டும்.',
          ),
          _buildRuleBullet(
            '4 உறங்கும் மாதங்கள் (பூஜை தவிர்க்கவும்):',
            'ஆனி, புரட்டாசி, மார்கழி, பங்குனி ஆகிய 4 மாதங்களில் வாஸ்து புருஷன் உறங்குவதால் எக்காரணம் கொண்டும் பூமி பூஜை செய்யக் கூடாது.',
          ),
          _buildRuleBullet(
            'பூஜை காலம் 18 நிமிடங்கள் மட்டுமே:',
            'வாஸ்து புருஷன் விழித்திருக்கும் காலம் 3.6 நாழிகைகள் (18 நிமிடங்கள்) மட்டுமே. அதற்குள் சங்கல்பம், பூமி பூஜை மற்றும் அடிக்கல் நாட்டும் நிகழ்வுகளைத் தொடங்க வேண்டும்.',
          ),
          _buildRuleBullet(
            'சூரிய உதயம் அடிப்படை:',
            'ஒவ்வொரு ஊரிலும் சூரிய உதயம் நேரத்திற்கு ஏற்ப துருவ எண்ணைக் கூட்டி கணக்கிடப்படும் ஆரம்ப நேரமே சரியான வாஸ்து நேரம் ஆகும்.',
          ),
        ],
      ),
    );
  }

  Widget _buildRuleBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFFB58D3D), size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11, color: Color(0xFF333333), height: 1.35),
                children: [
                  TextSpan(text: "$title ", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
