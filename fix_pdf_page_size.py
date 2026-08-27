import sys
import re

def main():
    files = [
        'lib/services/jamakkol_one_page_pdf_service.dart',
        'lib/services/kp_one_page_pdf_service.dart',
        'lib/services/one_page_pdf_service.dart'
    ]

    css_overrides = r'''
        html { -webkit-text-size-adjust: none; text-size-adjust: none; }
        :root { --border-orange: #E0D4BE; --header-blue: #5D1204; --text-red: #5D1204; --text-green: #B58D3D; }
        body { font-family: sans-serif; margin: 0; padding: 2mm; color: #333; font-size: 2.8mm; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
        @media screen {
          body { background: #f3f4f6; display: flex; flex-direction: column; align-items: center; }
          .page { background: white; width: 210mm; min-height: 297mm; padding: 4mm; box-shadow: 0 0 3mm rgba(0,0,0,0.1); margin: 4mm 0; position: relative; box-sizing: border-box; overflow: hidden; }
          .inner-page { border: 0.5mm solid var(--text-red); padding: 2mm; min-height: 285mm; box-sizing: border-box; }
        }
        @media print {
          @page { size: A4; margin: 0mm; }
          body { background: white; padding: 5mm; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
          .page { width: 100%; padding: 0; box-shadow: none; margin: 0; box-sizing: border-box; height: 287mm; overflow: hidden; }
          .inner-page { border: 0.5mm solid var(--text-red); padding: 2mm; box-sizing: border-box; height: 100%; }
        }
        .header { border-bottom: 0.5mm solid var(--text-red); margin-bottom: 1.5mm; padding-bottom: 1mm; }
        .header-top { display: flex; justify-content: space-between; }
        .header-title { color: var(--text-red); font-weight: bold; font-size: 5.0mm; line-height: 1.1; }
        .header-sub { font-size: 2.5mm; color: #555; line-height: 1.2; }
        .banner { background: var(--text-red); color: white; text-align: center; padding: 0.8mm; font-weight: bold; font-size: 4.0mm; margin: 1mm 0; border-radius: 1mm; }
        .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 2mm; margin-bottom: 1.5mm; border-bottom: 0.3mm solid #eee; padding-bottom: 1mm; }
        .detail-row { display: flex; margin-bottom: 0.3mm; font-size: 2.6mm; }
        .detail-label { width: 28mm; color: var(--text-red); font-weight: bold; }
        
        .grid-chart { width: 100%; max-width: 100mm; margin: 0 auto; border-collapse: collapse; table-layout: fixed; }
        .grid-chart td { border: 0.3mm solid var(--text-red); height: 16mm; text-align: center; font-size: 2.2mm; font-weight: bold; padding: 0; vertical-align: middle; background: #FAF6EE; }
        .chart-title { color: var(--text-red); font-size: 3.2mm; font-weight: bold; line-height: 1.1; margin-bottom: 1mm; }
        
        .patha-tables { display: flex; justify-content: space-between; margin-bottom: 1.5mm; }
        .data-table { width: 48%; border-collapse: collapse; font-size: 1.9mm; border: 0.3mm solid var(--border-orange); }
        .data-table th { background: #eee; border: 0.3mm solid var(--border-orange); padding: 0.5mm; font-weight: bold; color: var(--text-red); }
        .data-table td { border: 0.3mm solid var(--border-orange); padding: 0.5mm; text-align: center; }

        .timeline-row { display: flex; gap: 2mm; margin-top: 1.5mm; }
        
        .footer { text-align: center; font-size: 1.8mm; margin-top: 1.5mm; font-style: italic; border-top: 0.3mm dashed #ccc; padding-top: 0.5mm; }'''

    for file_path in files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Find the existing <style> block
            style_start = content.find('<style>')
            style_end = content.find('</style>', style_start)
            
            if style_start != -1 and style_end != -1:
                old_style = content[style_start+7:style_end]
                
                # Replace the core styles but keep the print button
                # The print button was appended just before </style>
                print_btn_css = r'''
        .print-btn {
           position: fixed;
           top: 5mm;
           right: 5mm;
           background: var(--text-red);
           color: white;
           border: none;
           padding: 2mm 5mm;
           font-size: 3.5mm;
           font-weight: bold;
           border-radius: 1mm;
           cursor: pointer;
           z-index: 1000;
           box-shadow: 0 1mm 2mm rgba(0,0,0,0.3);
        }
        .print-btn:hover { background: #4A0E03; }
        @media print { .print-btn { display: none !important; } }'''

                new_style = css_overrides + print_btn_css
                content = content.replace(old_style, new_style)
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated CSS for {file_path}")
        except Exception as e:
            print(f"Error processing {file_path}: {e}")

if __name__ == '__main__':
    main()
