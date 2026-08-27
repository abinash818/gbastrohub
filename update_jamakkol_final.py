import sys

def main():
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Increase outer planet font size to 2.2mm
    content = content.replace('font-size: 2.0mm; white-space: nowrap;', 'font-size: 2.2mm; white-space: nowrap;')
    
    # Increase padding of the blue border container to 4.5mm so planets don't overlap the blue box
    # Old: padding: 2mm; border: 0.5mm solid #1E3A8A
    content = content.replace('padding: 2mm; border: 0.5mm solid #1E3A8A', 'padding: 4.5mm; border: 0.5mm solid #1E3A8A')
    
    # Decrease empty spaces in right pane
    # padding: 2mm -> padding: 1mm for the white boxes
    content = content.replace('padding: 2mm; margin-bottom: 2mm; background: #fff;', 'padding: 1.5mm; margin-bottom: 1.5mm; background: #fff;')
    content = content.replace('padding: 2mm; background: #fff;', 'padding: 1.5mm; background: #fff;')
    
    # Table cell paddings
    content = content.replace('padding-bottom: 0.5mm;', 'padding-bottom: 0.2mm;')
    
    # Margins for parivarthana and planet status
    content = content.replace('margin-top: 1mm; padding-top: 1mm;', 'margin-top: 0.5mm; padding-top: 0.5mm;')
    
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    main()
