import sys

def main():
    file_path = 'lib/services/kp_one_page_pdf_service.dart'
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        ruling_start = content.find('<div class="ruling-planets">')
        if ruling_start != -1:
            ruling_end = content.find('</div>\n                  <table class="data-table">', ruling_start) + 6
            if ruling_end != -1:
                old_block = content[ruling_start:ruling_end]
                content = content.replace(old_block, "")
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print("Successfully removed Ruling Planets section!")
                return
                
        print("Could not match the exact structure.")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()
