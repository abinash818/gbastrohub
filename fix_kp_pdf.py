import sys

def main():
    with open('lib/services/kp_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix sigHtml
    old_sig = r'''            final a = (sig['A'] as String).split(',').where((e)=>e.isNotEmpty).join(', ');
            final b = (sig['B'] as String).split(',').where((e)=>e.isNotEmpty).join(', ');
            final c = (sig['C'] as String).split(',').where((e)=>e.isNotEmpty).join(', ');
            final d = (sig['D'] as String).split(',').where((e)=>e.isNotEmpty).join(', ');
            sigHtml += "<tr><td>${_toTamil(k)}</td><td>$nakLord($b)</td><td>$subLord($a)</td><td>$a, $b, $c, $d</td></tr>";'''
            
    new_sig = r'''            final aList = (sig['A'] as String).split(',').where((e)=>e.isNotEmpty).toList();
            final bList = (sig['B'] as String).split(',').where((e)=>e.isNotEmpty).toList();
            final cList = (sig['C'] as String).split(',').where((e)=>e.isNotEmpty).toList();
            final dList = (sig['D'] as String).split(',').where((e)=>e.isNotEmpty).toList();
            final a = aList.join(', ');
            final b = bList.join(', ');
            final c = cList.join(', ');
            final d = dList.join(', ');
            
            final allSigs = [...aList, ...bList, ...cList, ...dList].join(', ');
            sigHtml += "<tr><td>${_toTamil(k)}</td><td>$nakLord(${b.isNotEmpty?b:'-'})</td><td>$subLord(${a.isNotEmpty?a:'-'})</td><td>$allSigs</td></tr>";'''
            
    content = content.replace(old_sig, new_sig)

    # Fix houseSigHtml
    old_house = r'''            final a = (sig['A'] as List).map((e) => _toTamil(e.toString())).join(', ');
            final b = (sig['B'] as List).map((e) => _toTamil(e.toString())).join(', ');
            final c = (sig['C'] as List).map((e) => _toTamil(e.toString())).join(', ');
            final d = (sig['D'] as List).map((e) => _toTamil(e.toString())).join(', ');
            houseSigHtml += "<tr><td>$i</td><td>-($b)</td><td>-($a)</td><td>-($hNakLord)</td><td>$a, $b, $c, $d</td></tr>";'''

    new_house = r'''            final aList = (sig['A'] as List).map((e) => _toTamil(e.toString())).where((e)=>e.isNotEmpty).toList();
            final bList = (sig['B'] as List).map((e) => _toTamil(e.toString())).where((e)=>e.isNotEmpty).toList();
            final cList = (sig['C'] as List).map((e) => _toTamil(e.toString())).where((e)=>e.isNotEmpty).toList();
            final dList = (sig['D'] as List).map((e) => _toTamil(e.toString())).where((e)=>e.isNotEmpty).toList();
            final a = aList.join(', ');
            final b = bList.join(', ');
            final c = cList.join(', ');
            final d = dList.join(', ');
            
            final allSigs = [...aList, ...bList, ...cList, ...dList].join(', ');
            houseSigHtml += "<tr><td>$i</td><td>$hSubLord(${b.isNotEmpty?b:'-'})</td><td>$hNakLord(${a.isNotEmpty?a:'-'})</td><td>$hNakLord</td><td>$allSigs</td></tr>";'''
            
    content = content.replace(old_house, new_house)

    with open('lib/services/kp_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)
        print("Updated kp_one_page_pdf_service.dart successfully!")

if __name__ == '__main__':
    main()
