import sys
import re

def main():
    files = [
        'lib/services/jamakkol_one_page_pdf_service.dart',
        'lib/services/kp_one_page_pdf_service.dart',
        'lib/services/one_page_pdf_service.dart'
    ]

    for file_path in files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Make inner-page a flex column
            # Current CSS: .inner-page { border: 0.5mm solid var(--text-red); padding: 2mm; min-height: 285mm; box-sizing: border-box; }
            # Screen CSS:
            content = content.replace(
                '.inner-page { border: 0.5mm solid var(--text-red); padding: 2mm; min-height: 285mm; box-sizing: border-box; }',
                '.inner-page { border: 0.5mm solid var(--text-red); padding: 2mm; min-height: 285mm; box-sizing: border-box; display: flex; flex-direction: column; }'
            )
            # Print CSS:
            content = content.replace(
                '.inner-page { border: 0.5mm solid var(--text-red); padding: 2mm; box-sizing: border-box; height: 100%; }',
                '.inner-page { border: 0.5mm solid var(--text-red); padding: 2mm; box-sizing: border-box; height: 100%; display: flex; flex-direction: column; }'
            )

            # Define the notes box HTML
            notes_html = r'''
          <div style="flex: 1; min-height: 15mm; border: 0.3mm solid var(--border-orange); border-radius: 1mm; padding: 1.5mm; margin-top: 1.5mm; display: flex; flex-direction: column; background: #fff;">
             <div style="color: var(--header-blue); font-weight: bold; font-size: 2.5mm; margin-bottom: 0mm;">✍️ ஜோதிடக் குறிப்புகள்:</div>
             <div style="flex: 1; background-image: linear-gradient(to bottom, transparent 95%, #e0e0e0 95%); background-size: 100% 5mm; margin-top: 1mm;"></div>
          </div>
          '''

            # Find the footer to insert notes right before it
            # footer is usually: <div class="footer">
            footer_str = '<div class="footer">'
            if footer_str in content:
                # Let's ensure we haven't already added it
                if "✍️ ஜோதிடக் குறிப்புகள்" not in content:
                    content = content.replace(footer_str, notes_html + footer_str)
                    
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"Added Astrologer Notes to {file_path}")
                else:
                    print(f"Notes already exist in {file_path}")
            else:
                print(f"Footer not found in {file_path}")
                
        except Exception as e:
            print(f"Error processing {file_path}: {e}")

if __name__ == '__main__':
    main()
