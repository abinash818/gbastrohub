import sys

def main():
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace pixels with mm
    content = content.replace('margin-right: 15px;', 'margin-right: 4mm;')
    content = content.replace('margin-left: 15px;', 'margin-left: 4mm;')
    content = content.replace('font-size: 12px;', 'font-size: 2.5mm;')
    content = content.replace('margin-left: 6px;', 'margin-left: 1.5mm;')
    
    # Let's also make the chart table margin and padding slightly smaller to ensure no overflow
    content = content.replace('padding: 4mm; border: 0.5mm solid #1E3A8A', 'padding: 2mm; border: 0.5mm solid #1E3A8A')
    
    # Make Pathasaram text smaller if needed, currently font-size: 2.0mm. It's small enough.
    # The header images: height: 19.5mm, width 18mm.
    
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    main()
