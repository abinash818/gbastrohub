import sys

def main():
    file_path = 'lib/services/kp_one_page_pdf_service.dart'
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        start_str = '<div class="top-charts-grid">'
        start_idx = content.find(start_str)
        if start_idx == -1:
            print("Start not found!")
            return
            
        ruling_str = '<div class="ruling-planets">'
        end_idx = content.find(ruling_str, start_idx)
        if end_idx == -1:
            print("End not found!")
            return
            
        # Extract the old block (everything from <div class="top-charts-grid"> up to <div class="ruling-planets">)
        # But we need to keep the structure. Let's just find the closing tags carefully or use replacement strings.
        
        # We can just replace the opening of top-charts-grid and the two tables.
        
        table1_start = content.find('<table class="grid-chart">', start_idx)
        table1_end = content.find('</table>', table1_start) + 8
        
        table2_start = content.find('<table class="grid-chart">', table1_end)
        table2_end = content.find('</table>', table2_start) + 8
        
        if table1_start == -1 or table2_start == -1:
            print("Tables not found!")
            return
            
        table1 = content[table1_start:table1_end]
        table2 = content[table2_start:table2_end]
        
        new_tables = f'''<div style="display: flex; justify-content: space-between; gap: 4mm; margin-bottom: 2mm;">
              <div style="flex: 1;">
                  {table1.replace('<table class="grid-chart">', '<table class="grid-chart" style="max-width: 100%;">')}
              </div>
              <div style="flex: 1;">
                  {table2.replace('<table class="grid-chart">', '<table class="grid-chart" style="max-width: 100%;">')}
              </div>
          </div>'''
          
        old_block = content[start_idx:table2_end]
        new_block = '<div class="top-charts-grid">\n          ' + new_tables
        
        content = content.replace(old_block, new_block)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Updated KP charts layout successfully!")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()
