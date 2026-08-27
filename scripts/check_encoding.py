import os

source_path = r"D:\MaanavarSeyali\MaanavarSeyali\TmkProject\TmkAstroProj\app\src\main\java\com\astro\tmk\tmkastroproj\db\BhiruguNandhiData.java"

def check_encoding():
    with open(source_path, "rb") as f:
        raw = f.read()
    
    # Try UTF-8
    try:
        decoded = raw.decode("utf-8")
        print("UTF-8 Decoded successfully")
        print("Snippet:", decoded[300:500])
    except Exception as e:
        print("UTF-8 failed:", e)

    # Try Latin-1
    try:
        decoded = raw.decode("latin-1")
        print("Latin-1 Decoded successfully")
        print("Snippet:", decoded[300:500])
        # If it looks like à®², try to fix it
        fixed = decoded.encode("latin-1").decode("utf-8")
        print("Fixed from Latin-1 snippet:", fixed[300:500])
    except Exception as e:
        print("Latin-1 fix failed:", e)

    # Try UTF-16
    try:
        decoded = raw.decode("utf-16")
        print("UTF-16 Decoded successfully")
    except Exception as e:
        print("UTF-16 failed")

if __name__ == "__main__":
    check_encoding()
