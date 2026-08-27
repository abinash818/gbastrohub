import sys

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

            if "✍️ ஜோதிடக் குறிப்புகள்:" in content:
                content = content.replace("✍️ ஜோதிடக் குறிப்புகள்:", "✍️ ஜோதிடர் குறிப்பு:")
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated text in {file_path}")
            else:
                print(f"Text not found in {file_path}")
                
        except Exception as e:
            print(f"Error processing {file_path}: {e}")

if __name__ == '__main__':
    main()
