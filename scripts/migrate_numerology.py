import re
import json

def fix_double_encoding(s):
    mapping = {
        0x20ac: 0x80, 0x201a: 0x82, 0x0192: 0x83, 0x201e: 0x84, 0x2026: 0x85,
        0x2020: 0x86, 0x2021: 0x87, 0x02c6: 0x88, 0x2030: 0x89, 0x0160: 0x8a,
        0x2039: 0x8b, 0x0152: 0x8c, 0x017d: 0x8e, 0x2018: 0x91, 0x2019: 0x92,
        0x201c: 0x93, 0x201d: 0x94, 0x2022: 0x95, 0x2013: 0x96, 0x2014: 0x97,
        0x02dc: 0x98, 0x2122: 0x99, 0x0161: 0x9a, 0x203a: 0x9b, 0x0153: 0x9c,
        0x017e: 0x9e, 0x0178: 0x9f
    }
    
    bytes_list = []
    for char in s:
        cp = ord(char)
        if cp in mapping:
            bytes_list.append(mapping[cp])
        elif cp < 256:
            bytes_list.append(cp)
        else:
            bytes_list.extend(char.encode('utf-8'))
    
    try:
        return bytes(bytes_list).decode('utf-8')
    except:
        return s

def migrate_numerology():
    java_file_path = r'D:\MaanavarSeyali\MaanavarSeyali\TmkProject\TmkAstroProj\app\src\main\java\com\astro\tmk\tmkastroproj\db\DataFromFile.java'
    output_file_path = r'c:\Users\abina\astrology_flutter\lib\data\numerology_data.dart'

    with open(java_file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the ENN_KANITHAM_EXTRA_INFO_ARRAY block
    match = re.search(r'String\[\] ENN_KANITHAM_EXTRA_INFO_ARRAY = new String\[\]\{(.*?)\};', content, re.DOTALL)
    if not match:
        # Try without 'new String[]'
        match = re.search(r'String\[\] ENN_KANITHAM_EXTRA_INFO_ARRAY = \{(.*?)\};', content, re.DOTALL)
    
    if not match:
        print("Could not find ENN_KANITHAM_EXTRA_INFO_ARRAY in Java file.")
        return

    data_block = match.group(1)
    
    # Split by lines and extract strings
    entries = re.findall(r'"(.*?)"', data_block)
    
    numerology_map = {}
    
    for entry in entries:
        if '|' not in entry:
            continue
        
        parts = entry.split('|')
        if len(parts) < 3:
            continue
            
        key = parts[0].strip() # "1,1"
        subject = fix_double_encoding(parts[1].strip())
        value = fix_double_encoding(parts[2].strip())
        
        if key not in numerology_map:
            numerology_map[key] = []
            
        numerology_map[key].append({
            "subject": subject,
            "value": value.replace('\n', ' ')
        })

    # Generate Dart file
    with open(output_file_path, 'w', encoding='utf-8') as f:
        f.write("const Map<String, List<Map<String, String>>> NUMEROLOGY_RECOMMENDATIONS = ")
        f.write(json.dumps(numerology_map, ensure_ascii=False, indent=2))
        f.write(";")

    print(f"Successfully migrated {len(numerology_map)} numerology combinations to {output_file_path}")

if __name__ == "__main__":
    migrate_numerology()
