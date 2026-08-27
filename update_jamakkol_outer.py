import sys

def main():
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the renderOuterLabel and r(String sign) functions
    old_r_func = r'''    String renderOuterLabel(String sign) {
        final namingMap = isAltNaming ? JamakkolService.JAMAKKOL_TAMIL_ALT : JamakkolService.JAMAKKOL_TAMIL_SHORT;
        final pDegs = outer['planet_degrees'] as Map? ?? {};
        List<String> items = [];
        
        for (var pName in JamakkolService.JAMAKKOL_PLANETS) {
            double deg = (pDegs[pName] ?? 0.0).toDouble();
            String pSign = KPService.SIGNS[(deg / 30).floor() % 12];
            if (pSign == sign) {
                double lon = deg % 30;
                int d = lon.floor();
                int m = ((lon - d) * 60).floor();
                items.add("${namingMap[pName] ?? pName} $d&deg; $m'");
            }
        }
        return items.join(' &nbsp; ');
    }

    String r(String sign) {
        final innerItems = rasiMap[sign] ?? [];
        String innerHtml = innerItems.join('<br>');
        String outerHtml = renderOuterLabel(sign);
        
        String outerDiv = "";
        if (outerHtml.isNotEmpty) {
            String style = "";
            if (['Pisces', 'Aries', 'Taurus', 'Gemini'].contains(sign)) {
                style = "position: absolute; top: -5mm; left: 0; width: 100%; text-align: center; color: #1E3A8A; font-weight: bold; font-size: 2.5mm; white-space: nowrap;";
            } else if (['Cancer', 'Leo', 'Virgo'].contains(sign)) {
                style = "position: absolute; right: -5mm; top: 50%; transform: translateY(-50%) rotate(90deg); text-align: center; color: #1E3A8A; font-weight: bold; font-size: 2.5mm; white-space: nowrap; transform-origin: center;";
            } else if (['Libra', 'Scorpio', 'Sagittarius'].contains(sign)) {
                style = "position: absolute; bottom: -5mm; left: 0; width: 100%; text-align: center; color: #1E3A8A; font-weight: bold; font-size: 2.5mm; white-space: nowrap;";
            } else if (['Capricorn', 'Aquarius'].contains(sign)) {
                style = "position: absolute; left: -5mm; top: 50%; transform: translateY(-50%) rotate(-90deg); text-align: center; color: #1E3A8A; font-weight: bold; font-size: 2.5mm; white-space: nowrap; transform-origin: center;";
            }
            outerDiv = "<div style='$style'>$outerHtml</div>";
        }

        return """
        <div style='position: relative; height: 100%; width: 100%;'>
            $outerDiv
            <div style='position: absolute; bottom: 0; right: 0; padding: 1mm; text-align: right;'>$innerHtml</div>
        </div>
        """;
    }'''

    new_r_func = r'''    String renderOuterLabel(String sign) {
        final namingMap = isAltNaming ? JamakkolService.JAMAKKOL_TAMIL_ALT : JamakkolService.JAMAKKOL_TAMIL_SHORT;
        final pDegs = outer['planet_degrees'] as Map? ?? {};
        List<String> items = [];
        
        for (var pName in JamakkolService.JAMAKKOL_PLANETS) {
            double deg = (pDegs[pName] ?? 0.0).toDouble();
            String pSign = KPService.SIGNS[(deg / 30).floor() % 12];
            if (pSign == sign) {
                double lon = deg % 30;
                int d = lon.floor();
                int m = ((lon - d) * 60).floor();
                items.add("${namingMap[pName] ?? pName} $d&deg; $m'");
            }
        }
        return items.join(' &nbsp; ');
    }

    String r(String sign) {
        final innerItems = rasiMap[sign] ?? [];
        String innerHtml = innerItems.join('<br>');
        String outerHtml = renderOuterLabel(sign);
        
        String outerDiv = "";
        if (outerHtml.isNotEmpty) {
            String style = "";
            if (['Aries', 'Taurus', 'Gemini'].contains(sign)) {
                style = "position: absolute; bottom: calc(100% + 1mm); left: 50%; transform: translateX(-50%); color: #1E3A8A; font-weight: bold; font-size: 2.5mm; white-space: nowrap;";
            } else if (['Cancer', 'Leo', 'Virgo'].contains(sign)) {
                style = "position: absolute; left: calc(100% + 1mm); top: 50%; transform: translateY(-50%); writing-mode: vertical-rl; color: #1E3A8A; font-weight: bold; font-size: 2.5mm; white-space: nowrap;";
            } else if (['Libra', 'Scorpio', 'Sagittarius'].contains(sign)) {
                style = "position: absolute; top: calc(100% + 1mm); left: 50%; transform: translateX(-50%); color: #1E3A8A; font-weight: bold; font-size: 2.5mm; white-space: nowrap;";
            } else if (['Capricorn', 'Aquarius', 'Pisces'].contains(sign)) {
                style = "position: absolute; right: calc(100% + 1mm); top: 50%; transform: translateY(-50%) rotate(180deg); writing-mode: vertical-rl; color: #1E3A8A; font-weight: bold; font-size: 2.5mm; white-space: nowrap;";
            }
            outerDiv = "<div style='$style'>$outerHtml</div>";
        }

        return """
        <div style='position: relative; height: 100%; width: 100%;'>
            $outerDiv
            <div style='position: absolute; bottom: 0; right: 0; padding: 1mm; text-align: right;'>$innerHtml</div>
        </div>
        """;
    }'''

    content = content.replace(old_r_func, new_r_func)

    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    main()
