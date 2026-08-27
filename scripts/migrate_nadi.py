import re
import os

source_path = r"D:\MaanavarSeyali\MaanavarSeyali\TmkProject\TmkAstroProj\app\src\main\java\com\astro\tmk\tmkastroproj\db\BhiruguNandhiData.java"
output_path = r"c:\Users\abina\astrology_flutter\lib\data\nadi_predictions.dart"

INDEX_TO_KEY = {
    "0": "lagna", "1": "sun", "2": "moon", "3": "mars", "4": "mercury",
    "5": "jupiter", "6": "venus", "7": "saturn", "8": "rahu", "9": "ketu", "10": "maanthi"
}

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
            # If it's a multi-byte character that was ALREADY correctly decoded,
            # this logic might break it. But in a double-encoded scenario, 
            # we shouldn't have many of these.
            # Let's encode it as utf-8 and append those bytes.
            bytes_list.extend(char.encode('utf-8'))
    
    try:
        return bytes(bytes_list).decode('utf-8')
    except:
        return s

def migrate():
    with open(source_path, "r", encoding="utf-8") as f:
        content = f.read()

    match = re.search(r"GET_PALAN_ARRAY\(\)\{\s*String\[\] dataArr = new String\[\]\{(.*?)\};", content, re.DOTALL)
    if not match: return

    data_content = match.group(1)
    entries = re.findall(r'"(.*?)"', data_content)

    predictions = {}
    for entry in entries:
        if "|" not in entry: continue
        parts = entry.split("|")
        indices_str = parts[0].strip()
        palan_raw = parts[1].strip()

        palan = fix_double_encoding(palan_raw).replace("$", "\n")
        
        indices = indices_str.split("+")
        keys = [INDEX_TO_KEY[idx] for idx in indices if idx in INDEX_TO_KEY]
        if len(keys) == len(indices):
            predictions["+".join(keys)] = palan

    # Write output
    dart_content = "const Map<String, String> NADI_PREDICTIONS = {\n"
    for key, val in predictions.items():
        escaped_val = val.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n")
        dart_content += f"  '{key}': '{escaped_val}',\n"
    dart_content += "};\n"

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(dart_content)
    print(f"Migrated {len(predictions)} entries and fixed encoding.")

if __name__ == "__main__":
    migrate()
