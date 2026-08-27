import sys

def main():
    file_path = 'lib/services/kp_one_page_pdf_service.dart'
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Add the string builder for houseSigHtml
        var_insert = "String sigHtml = \"\";"
        new_var_insert = """String sigHtml = "";
    
    String houseSigHtml = "";
    final hSigs = significators['house_view'] as Map<int, dynamic>?;
    if (hSigs != null) {
      for (int i = 1; i <= 12; i++) {
        final sigs = hSigs[i] as Map<String, dynamic>?;
        if (sigs != null) {
          String a = (sigs['A'] as List).join(',');
          String b = (sigs['B'] as List).join(',');
          String c = (sigs['C'] as List).join(',');
          String d = (sigs['D'] as List).join(',');
          houseSigHtml += "<tr><td>$i</td><td style='color:blue;'>$a</td><td style='color:blue;'>$b</td><td style='color:blue;'>$c</td><td style='color:blue;'>$d</td></tr>";
        }
      }
    }"""
        
        if var_insert in content:
            content = content.replace(var_insert, new_var_insert, 1)

        old_html = r'''              <div>
                  
                  <table class="data-table">
                      <tr><th colspan="4">12 பாவ நிலைகள்</th><th colspan="4" style="border-left:0.5mm solid var(--border-orange);">கிரக நிலைகள்</th></tr>
                      <tr>
                          <td>பா</td><td>ந.அ</td><td>உ.அ</td><td>உ.உ</td>
                          <td style="border-left:0.5mm solid var(--border-orange);">கிரகம்</td><td>ந.அ</td><td>உ.அ</td><td>உ.உ</td>
                      </tr>
                      $pTableHtml
                  </table>
              </div>'''
              
        new_html = r'''              <div style="display: flex; justify-content: space-between; gap: 4mm;">
                  <table class="data-table">
                      <tr><th colspan="4">12 பாவ நிலைகள்</th><th colspan="4" style="border-left:0.5mm solid var(--border-orange);">கிரக நிலைகள்</th></tr>
                      <tr>
                          <td>பா</td><td>ந.அ</td><td>உ.அ</td><td>உ.உ</td>
                          <td style="border-left:0.5mm solid var(--border-orange);">கிரகம்</td><td>ந.அ</td><td>உ.அ</td><td>உ.உ</td>
                      </tr>
                      $pTableHtml
                  </table>
                  <table class="data-table">
                      <tr><th colspan="5">பாவ தொடர்புகள் (A, B, C, D)</th></tr>
                      <tr>
                          <td>பா</td><td>A</td><td>B</td><td>C</td><td>D</td>
                      </tr>
                      $houseSigHtml
                  </table>
              </div>'''

        if old_html in content:
            content = content.replace(old_html, new_html)
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print("Successfully added house significators table!")
        else:
            print("Old HTML block not found!")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()
