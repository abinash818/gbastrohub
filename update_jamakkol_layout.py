import sys

def main():
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # We need to extract notes and strength from results
    # Find: final outer = results['outer'] as Map<dynamic, dynamic>? ?? {};
    old_extract = "final outer = results['outer'] as Map<dynamic, dynamic>? ?? {};"
    new_extract = '''final outer = results['outer'] as Map<dynamic, dynamic>? ?? {};
    final notes = results['notes'] as Map<dynamic, dynamic>? ?? {};
    final strength = results['strength'] as Map<dynamic, dynamic>? ?? {};'''
    content = content.replace(old_extract, new_extract)

    # Change CSS of grid-chart
    old_css = r'''.grid-chart { width: 100%; max-width: 130mm; margin: 0 auto 3mm auto; border-collapse: collapse; border: 0.5mm solid var(--text-red); table-layout: fixed; }
        .grid-chart td { border: 0.3mm solid var(--text-red); height: 26mm; text-align: center; font-size: 2.8mm; font-weight: bold; padding: 0; vertical-align: middle; background: #FAF6EE; }'''
    
    new_css = r'''.grid-chart { width: 100%; max-width: 100mm; margin: 0 auto; border-collapse: collapse; table-layout: fixed; }
        .grid-chart td { border: 0.3mm solid var(--text-red); height: 18mm; text-align: center; font-size: 2.2mm; font-weight: bold; padding: 0; vertical-align: middle; background: #FAF6EE; }'''
    
    content = content.replace(old_css, new_css)
    
    # Change outer fonts to 2.0mm
    content = content.replace('font-size: 2.5mm', 'font-size: 2.0mm')

    # Find the chart wrapper and replace it with Flex layout
    old_chart = r'''          <div style="margin: 6mm auto; padding: 5mm; border: 0.5mm solid #1E3A8A; width: fit-content; border-radius: 1mm;">
              <table class="grid-chart" style="margin: 0; border: 0.5mm solid var(--text-red);">
                  <tr><td>${r('Pisces')}</td><td>${r('Aries')}</td><td>${r('Taurus')}</td><td>${r('Gemini')}</td></tr>
                  <tr><td>${r('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title">ஜாமக்கோள்<br>பிரசன்னம் கட்டம்</div></td><td>${r('Cancer')}</td></tr>
                  <tr><td>${r('Capricorn')}</td><td>${r('Leo')}</td></tr>
                  <tr><td>${r('Sagittarius')}</td><td>${r('Scorpio')}</td><td>${r('Libra')}</td><td>${r('Virgo')}</td></tr>
              </table>
          </div>'''

    new_chart = r'''          <div style="display: flex; gap: 4mm; margin: 4mm 0; align-items: flex-start;">
            <div style="flex: 0 0 52%; padding: 4mm; border: 0.5mm solid #1E3A8A; border-radius: 1mm;">
                <table class="grid-chart" style="margin: 0; border: 0.5mm solid var(--text-red);">
                    <tr><td>${r('Pisces')}</td><td>${r('Aries')}</td><td>${r('Taurus')}</td><td>${r('Gemini')}</td></tr>
                    <tr><td>${r('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title" style="font-size:3mm;">ஜாமக்கோள்<br>பிரசன்னம் கட்டம்</div></td><td>${r('Cancer')}</td></tr>
                    <tr><td>${r('Capricorn')}</td><td>${r('Leo')}</td></tr>
                    <tr><td>${r('Sagittarius')}</td><td>${r('Scorpio')}</td><td>${r('Libra')}</td><td>${r('Virgo')}</td></tr>
                </table>
            </div>
            
            <div style="flex: 0 0 45%;">
                <div style="border: 0.3mm solid var(--border-orange); border-radius: 1mm; padding: 2mm; margin-bottom: 2mm; background: #fff;">
                  <div style="color: var(--header-blue); font-weight: bold; font-size: 3mm; margin-bottom: 2mm; display: flex; align-items: center;">
                     <span>📄 ஜாமக்கோள் குறிப்புகள்</span>
                  </div>
                  <table style="width: 100%; font-size: 2.2mm; line-height: 1.5;">
                    <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.5mm;">உதயத்தை நோக்கி வரும் கோள்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['towards_planet'] ?? '-'}</td></tr>
                    <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.5mm;">உதயத்தை கடந்த கோள்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['passed_planet'] ?? '-'}</td></tr>
                    <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.5mm;">ஆரூடம் உள்ள பாவகம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['arudam_house'] ?? '-'}</td></tr>
                    <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.5mm;">கவிப்பு உள்ள பாவகம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['kavi_house'] ?? '-'}</td></tr>
                    <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.5mm;">கவிக்கப்படும் கோள்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['kavi_planet'] ?? '-'}</td></tr>
                    <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.5mm;">உதயாதிபதி உள்ள பாவகம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['udayathipathi_house'] ?? '-'}</td></tr>
                  </table>
                  <div style="border-top: 0.3mm solid var(--border-orange); margin-top: 1mm; padding-top: 1mm;">
                     <div style="color: var(--header-blue); font-weight: bold; font-size: 2.2mm;">பரிவர்த்தனை யோகங்கள்:</div>
                     <div style="color: #E65100; font-weight: bold; font-size: 2.2mm;">${(notes['parivarthana'] as List? ?? []).isEmpty ? "இல்லை." : (notes['parivarthana'] as List).join(', ')}</div>
                  </div>
                  <div style="margin-top: 1mm;">
                     <div style="color: var(--header-blue); font-weight: bold; font-size: 2.2mm;">கிரக நிலை:</div>
                     <div style="color: #E65100; font-weight: bold; font-size: 2.2mm;">
                        ${(notes['planet_status'] as List? ?? []).map((e) => "${e['planet']} &rarr; ${e['status']}").join(', ')}
                     </div>
                  </div>
                </div>

                <div style="border: 0.3mm solid var(--border-orange); border-radius: 1mm; padding: 2mm; background: #fff;">
                  <div style="color: var(--header-blue); font-weight: bold; font-size: 3mm; margin-bottom: 2mm; display: flex; align-items: center;">
                     <span>⚡ கதிர் பலம் (Strength)</span>
                  </div>
                  <table style="width: 100%; font-size: 2.2mm; line-height: 1.5; border-collapse: collapse;">
                    <tr style="border-bottom: 0.3mm solid #ccc; color: #555;">
                       <th style="text-align: left; padding-bottom: 0.5mm;">அம்சம்</th>
                       <th style="text-align: center; padding-bottom: 0.5mm;">ராசி</th>
                       <th style="text-align: center; padding-bottom: 0.5mm;">அதிபதி</th>
                       <th style="text-align: right; padding-bottom: 0.5mm;">மொத்தம்</th>
                    </tr>
                    <tr>
                       <td style="color: var(--header-blue); font-weight: bold; padding: 0.5mm 0;">உதயம்</td>
                       <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['udayam']?['rasi'] ?? '-'}</td>
                       <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['udayam']?['lord'] ?? '-'}</td>
                       <td style="text-align: right; color: #E65100; font-weight: bold;">${strength['udayam']?['total'] ?? '-'}</td>
                    </tr>
                    <tr>
                       <td style="color: var(--header-blue); font-weight: bold; padding: 0.5mm 0;">ஆரூடம்</td>
                       <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['arudam']?['rasi'] ?? '-'}</td>
                       <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['arudam']?['lord'] ?? '-'}</td>
                       <td style="text-align: right; color: #E65100; font-weight: bold;">${strength['arudam']?['total'] ?? '-'}</td>
                    </tr>
                    <tr>
                       <td style="color: var(--header-blue); font-weight: bold; padding: 0.5mm 0;">கவிப்பு</td>
                       <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['kavi']?['rasi'] ?? '-'}</td>
                       <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['kavi']?['lord'] ?? '-'}</td>
                       <td style="text-align: right; color: #E65100; font-weight: bold;">${strength['kavi']?['total'] ?? '-'}</td>
                    </tr>
                    <tr style="border-top: 0.3mm solid #ccc;">
                       <td colspan="3" style="color: var(--header-blue); font-weight: bold; padding-top: 1mm;">ஜாமக் கிரகம் (${strength['jamam']?['planet'] ?? '-'})</td>
                       <td style="text-align: right; color: #E65100; font-weight: bold; padding-top: 1mm;">${strength['jamam']?['total'] ?? '-'}</td>
                    </tr>
                  </table>
                </div>
            </div>
          </div>'''

    content = content.replace(old_chart, new_chart)

    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    main()
