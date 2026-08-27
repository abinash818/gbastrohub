import sys
import re

def main():
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    start_str = '<div style="display: flex; gap: 4mm; margin: 4mm 0; align-items: flex-start;">'
    start_idx = content.find(start_str)
    
    if start_idx == -1:
        print("Start block not found!")
        return
        
    marker_str = '<div style="color:var(--text-red); font-weight:bold; text-align:center; font-size: 3.5mm; margin-bottom:1.5mm;">பாதசாரம் (கிரகங்கள் மற்றும் முக்கிய புள்ளிகள்)</div>'
    end_idx = content.find(marker_str, start_idx)
    
    if end_idx == -1:
        print("End marker not found!")
        return
        
    old_section = content[start_idx:end_idx].strip()

    new_section = r'''<div style="display: flex; margin: 2mm 0; align-items: stretch; border: 0.5mm solid #1E3A8A; border-radius: 1mm; background: #FAF6EE; overflow: hidden;">
            <div style="flex: 0 0 54%; padding: 4.5mm; background: #fff;">
                <table class="grid-chart" style="margin: 0; border: 0.5mm solid var(--text-red); background: #FAF6EE; width: 100%;">
                    <tr><td>${r('Pisces')}</td><td>${r('Aries')}</td><td>${r('Taurus')}</td><td>${r('Gemini')}</td></tr>
                    <tr><td>${r('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center; background: #fff;"><div class="chart-title" style="font-size:3mm;">ஜாமக்கோள்<br>பிரசன்னம் கட்டம்</div></td><td>${r('Cancer')}</td></tr>
                    <tr><td>${r('Capricorn')}</td><td>${r('Leo')}</td></tr>
                    <tr><td>${r('Sagittarius')}</td><td>${r('Scorpio')}</td><td>${r('Libra')}</td><td>${r('Virgo')}</td></tr>
                </table>
            </div>
            
            <div style="flex: 1; border-left: 0.5mm solid #1E3A8A; padding: 2mm 3mm; display: flex; flex-direction: column; justify-content: center;">
                <div style="background: var(--header-blue); color: white; padding: 1mm; font-size: 2.2mm; font-weight: bold; text-align: center; border-radius: 0.5mm; margin-bottom: 1.5mm;">
                   📄 ஜாமக்கோள் குறிப்புகள்
                </div>
                
                <table style="width: 100%; font-size: 2.0mm; line-height: 1.3; margin-bottom: 1mm;">
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">உதயத்தை நோக்கி வரும் கோள்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['towards_planet'] ?? '-'}</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">உதயத்தை கடந்த கோள்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['passed_planet'] ?? '-'}</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">ஆரூடம் உள்ள பாவகம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['arudam_house'] ?? '-'}</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">கவிப்பு உள்ள பாவகம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['kavi_house'] ?? '-'}</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">கவிக்கப்படும் கோள்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['kavi_planet'] ?? '-'}</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">உதயாதிபதி உள்ள பாவகம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">${notes['udayathipathi_house'] ?? '-'}</td></tr>
                </table>
                
                <div style="border-top: 0.3mm dashed #ccc; padding-top: 0.5mm; margin-bottom: 0.5mm;">
                   <div style="color: var(--header-blue); font-weight: bold; font-size: 2.0mm;">பரிவர்த்தனை யோகங்கள்:</div>
                   <div style="color: #E65100; font-weight: bold; font-size: 2.0mm;">${(notes['parivarthana'] as List? ?? []).isEmpty ? "இல்லை." : (notes['parivarthana'] as List).join(', ')}</div>
                </div>
                
                <div style="border-top: 0.3mm dashed #ccc; padding-top: 0.5mm; margin-bottom: 1.5mm;">
                   <div style="color: var(--header-blue); font-weight: bold; font-size: 2.0mm;">கிரக நிலை:</div>
                   <div style="color: #E65100; font-weight: bold; font-size: 2.0mm;">
                      ${(notes['planet_status'] as List? ?? []).map((e) => "${e['planet']} &rarr; ${e['status']}").join(', ')}
                   </div>
                </div>

                <div style="background: var(--header-blue); color: white; padding: 1mm; font-size: 2.2mm; font-weight: bold; text-align: center; border-radius: 0.5mm; margin-bottom: 1.5mm;">
                   ⚡ கதிர் பலம் (Strength)
                </div>
                
                <table style="width: 100%; font-size: 2.0mm; line-height: 1.3; border-collapse: collapse;">
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
          </div>'''

    content = content.replace(old_section, new_section + '\n\n          ')
    
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Updated successfully!")

if __name__ == '__main__':
    main()
