import sys

def main():
    file_path = 'lib/services/kp_one_page_pdf_service.dart'
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        old_str = """    String houseSigHtml = "";
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
    
        new_str = """    String topHouseSigHtml = "";
    final hSigs = sigs?['house_view'] as Map<dynamic, dynamic>?;
    if (hSigs != null) {
      for (int i = 1; i <= 12; i++) {
        final s = hSigs[i] ?? hSigs[i.toString()];
        if (s != null) {
          String a = (s['A'] as List).join(',');
          String b = (s['B'] as List).join(',');
          String c = (s['C'] as List).join(',');
          String d = (s['D'] as List).join(',');
          topHouseSigHtml += "<tr><td>$i</td><td style='color:blue;'>$a</td><td style='color:blue;'>$b</td><td style='color:blue;'>$c</td><td style='color:blue;'>$d</td></tr>";
        }
      }
    }"""
    
        content = content.replace(old_str, new_str)
        content = content.replace('$houseSigHtml\n                  </table>\n              </div>\n', '$topHouseSigHtml\n                  </table>\n              </div>\n')

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Fixed compilation errors!")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()
