import sys
import re

def main():
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the right pane flex box
    start_str = '<div style="flex: 1; border-left: 0.5mm solid #1E3A8A; padding: 2mm 3mm; display: flex; flex-direction: column; justify-content: center;">'
    start_idx = content.find(start_str)
    
    if start_idx == -1:
        print("Could not find the right pane block.")
        return
        
    end_str = '</div>\n          </div>' # The end of the flex container
    end_idx = content.find(end_str, start_idx)
    
    if end_idx == -1:
        print("Could not find the end of the right pane block.")
        return
        
    end_idx += len(end_str)
    
    # Extract the block
    right_pane = content[start_idx:end_idx]
    
    # Replace font sizes
    new_right_pane = right_pane.replace('font-size: 2.0mm;', 'font-size: 2.2mm;')
    
    # Let's also slightly increase the line-height from 1.3 to 1.4 to make it more breathable, 
    # since we have some vertical space.
    new_right_pane = new_right_pane.replace('line-height: 1.3;', 'line-height: 1.4;')
    
    # Replace in content
    content = content[:start_idx] + new_right_pane + content[end_idx:]
    
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Updated successfully.")

if __name__ == '__main__':
    main()
