import sys

def main():
    with open('lib/services/kp_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # sigHtml
    old_sig = r'''            final allSigs = [...aList, ...bList, ...cList, ...dList].join(', ');
            sigHtml += "<tr><td>${_toTamil(k)}</td><td>$nakLord(${b.isNotEmpty?b:'-'})</td><td>$subLord(${a.isNotEmpty?a:'-'})</td><td>$allSigs</td></tr>";'''
            
    new_sig = r'''            final allSigs = [...aList, ...bList, ...cList, ...dList].join(', ');
            String col2 = b.isNotEmpty ? "$nakLord($b)" : nakLord;
            String col3 = a.isNotEmpty ? "$subLord($a)" : subLord;
            sigHtml += "<tr><td>${_toTamil(k)}</td><td>$col2</td><td>$col3</td><td>$allSigs</td></tr>";'''
            
    content = content.replace(old_sig, new_sig)

    # houseSigHtml
    old_house = r'''            final allSigs = [...aList, ...bList, ...cList, ...dList].join(', ');
            houseSigHtml += "<tr><td>$i</td><td>$hSubLord(${b.isNotEmpty?b:'-'})</td><td>$hNakLord(${a.isNotEmpty?a:'-'})</td><td>$hNakLord</td><td>$allSigs</td></tr>";'''
            
    new_house = r'''            final allSigs = [...aList, ...bList, ...cList, ...dList].join(', ');
            String col2 = b.isNotEmpty ? "$hSubLord($b)" : hSubLord;
            String col3 = a.isNotEmpty ? "$hNakLord($a)" : hNakLord;
            houseSigHtml += "<tr><td>$i</td><td>$col2</td><td>$col3</td><td>$hNakLord</td><td>$allSigs</td></tr>";'''
            
    content = content.replace(old_house, new_house)

    with open('lib/services/kp_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)
        print("Fixed empty brackets in kp_one_page_pdf_service.dart!")

if __name__ == '__main__':
    main()
