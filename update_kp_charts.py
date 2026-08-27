import sys

def main():
    file_path = 'lib/services/kp_one_page_pdf_service.dart'
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        old_html = r'''          <div class="top-charts-grid">
              <table class="grid-chart">
                  <tr><td>${r('Pisces')}</td><td>${r('Aries')}</td><td>${r('Taurus')}</td><td>${r('Gemini')}</td></tr>
                  <tr><td>${r('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title">ராசி கட்டம்</div></td><td>${r('Cancer')}</td></tr>
                  <tr><td>${r('Capricorn')}</td><td>${r('Leo')}</td></tr>
                  <tr><td>${r('Sagittarius')}</td><td>${r('Scorpio')}</td><td>${r('Libra')}</td><td>${r('Virgo')}</td></tr>
              </table>
              <table class="grid-chart">
                  <tr><td>${b('Pisces')}</td><td>${b('Aries')}</td><td>${b('Taurus')}</td><td>${b('Gemini')}</td></tr>
                  <tr><td>${b('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title">பாவக கட்டம்</div></td><td>${b('Cancer')}</td></tr>
                  <tr><td>${b('Capricorn')}</td><td>${b('Leo')}</td></tr>
                  <tr><td>${b('Sagittarius')}</td><td>${b('Scorpio')}</td><td>${b('Libra')}</td><td>${b('Virgo')}</td></tr>
              </table>
              <div>'''

        new_html = r'''          <div class="top-charts-grid">
              <div style="display: flex; justify-content: space-between; gap: 4mm; margin-bottom: 2mm;">
                  <div style="flex: 1;">
                      <table class="grid-chart" style="max-width: 100%;">
                          <tr><td>${r('Pisces')}</td><td>${r('Aries')}</td><td>${r('Taurus')}</td><td>${r('Gemini')}</td></tr>
                          <tr><td>${r('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title">ராசி கட்டம்</div></td><td>${r('Cancer')}</td></tr>
                          <tr><td>${r('Capricorn')}</td><td>${r('Leo')}</td></tr>
                          <tr><td>${r('Sagittarius')}</td><td>${r('Scorpio')}</td><td>${r('Libra')}</td><td>${r('Virgo')}</td></tr>
                      </table>
                  </div>
                  <div style="flex: 1;">
                      <table class="grid-chart" style="max-width: 100%;">
                          <tr><td>${b('Pisces')}</td><td>${b('Aries')}</td><td>${b('Taurus')}</td><td>${b('Gemini')}</td></tr>
                          <tr><td>${b('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title">பாவக கட்டம்</div></td><td>${b('Cancer')}</td></tr>
                          <tr><td>${b('Capricorn')}</td><td>${b('Leo')}</td></tr>
                          <tr><td>${b('Sagittarius')}</td><td>${b('Scorpio')}</td><td>${b('Libra')}</td><td>${b('Virgo')}</td></tr>
                      </table>
                  </div>
              </div>
              <div>'''

        if old_html in content:
            content = content.replace(old_html, new_html)
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print("Updated KP charts layout")
        else:
            print("Old HTML not found!")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()
