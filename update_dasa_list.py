import sys

def main():
    files = [
        'lib/services/jamakkol_one_page_pdf_service.dart',
        'lib/services/kp_one_page_pdf_service.dart',
        'lib/services/one_page_pdf_service.dart'
    ]

    old_logic = "final displayList = selectedItem != null ? [selectedItem] : periods;"
    new_logic = '''List<dynamic> displayList = [];
    if (selectedItem != null) {
      int idx = periods.indexOf(selectedItem);
      if (idx != -1) {
        displayList = periods.sublist(idx).take(9).toList();
      } else {
        displayList = [selectedItem];
      }
    } else {
      displayList = periods.take(9).toList();
    }'''

    for file_path in files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            if old_logic in content:
                content = content.replace(old_logic, new_logic)
                
                # We need to make sure the selected item is highlighted when multiple are shown!
                # old: final isToday = selectedItem == null && DateTime.now().isAfter(p['start']) && DateTime.now().isBefore(p['end']);
                # new: final isToday = p == selectedItem || (selectedItem == null && DateTime.now().isAfter(p['start']) && DateTime.now().isBefore(p['end']));
                
                old_highlight = "final isToday = selectedItem == null && DateTime.now().isAfter(p['start']) && DateTime.now().isBefore(p['end']);"
                new_highlight = "final isToday = p == selectedItem || (selectedItem == null && DateTime.now().isAfter(p['start']) && DateTime.now().isBefore(p['end']));"
                content = content.replace(old_highlight, new_highlight)
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated {file_path}")
            else:
                print(f"Old logic not found in {file_path}")
                
        except Exception as e:
            print(f"Error in {file_path}: {e}")

if __name__ == '__main__':
    main()
