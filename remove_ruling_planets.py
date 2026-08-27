import sys

def main():
    file_path = 'lib/services/kp_one_page_pdf_service.dart'
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        start_str = '              <div>\n                  <div class="ruling-planets">'
        start_idx = content.find(start_str)
        if start_idx == -1:
            # Let's try finding just the ruling planets div
            start_idx = content.find('<div class="ruling-planets">')
            if start_idx != -1:
                # Need to backtrack to the parent div
                start_idx = content.rfind('<div>', 0, start_idx)

        if start_idx == -1:
            print("Ruling planets block not found!")
            return
            
        # The block ends after the table and closing divs
        # Let's find the end of this block
        # It's followed by `</div>` for ruling-planets, then `</div>` for the wrapper div, then `</div>` for top-charts-grid
        # Let's find the next major block which is probably `<div style="display: flex; gap: 4mm;">` or similar for the next tables
        next_block = content.find('<div style="display: flex; gap: 4mm;">', start_idx)
        if next_block == -1:
            # Maybe the next block is the next div with flex
            next_block = content.find('<div style="display: flex;', start_idx + 100)
            
        if next_block == -1:
            print("Could not find the end of ruling planets block reliably.")
            return
            
        # Let's backtrack to the closing div of top-charts-grid
        end_idx = content.rfind('</div>', start_idx, next_block) + 6
        
        # Actually, if I remove the ruling planets div completely, I must also make sure I don't remove the closing div of top-charts-grid!
        # The structure is:
        # <div class="top-charts-grid">
        #    <div style="display: flex; ..."> ...charts... </div>
        #    <div><div class="ruling-planets"> ... </div></div>
        # </div>
        
        # Let's just find the exact block to remove.
        ruling_start = content.find('              <div>\n                  <div class="ruling-planets">')
        if ruling_start != -1:
            ruling_end = content.find('                  </div>\n              </div>\n          </div>', ruling_start)
            if ruling_end != -1:
                old_block = content[ruling_start:ruling_end + 37]
                new_block = '          </div>'
                content = content.replace(old_block, new_block)
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print("Successfully removed Ruling Planets section!")
                return
                
        print("Could not match the exact structure.")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()
