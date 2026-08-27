import 'package:flutter/services.dart';
import 'palangal_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tamil_pdf_shaper/tamil_pdf_shaper.dart';
import 'kp_service.dart';
import 'package:intl/intl.dart';

class FullReportPdfService {
  static Future<Uint8List> generateFullHoroscopePdf({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
    Map<String, String>? astroDetails,
    Uint8List? leftLogoBytes,
    Uint8List? rightLogoBytes,
  }) async {
    final pdf = pw.Document();
    final headingFont = await TamilPdfFont.loadCustomFont('assets/fonts/Uni_Ila.Sundaram-02_shaped.ttf');
    final bodyFont = await TamilPdfFont.loadCustomFont('assets/fonts/Uni_Ila.Sundaram-05_shaped.ttf');

    Uint8List? ganapathyImg;
    Uint8List? muruganImg;
    try {
      ganapathyImg = (await rootBundle.load('assets/images/ganapathy.png')).buffer.asUint8List();
      muruganImg = (await rootBundle.load('assets/images/muruga.png')).buffer.asUint8List();
    } catch (e) {
      // Ignore
    }


    final rasiData = _castToChartMap(results['rasi']);
    final amsamData = _castToChartMap(results['navamsa']);
    final pavagamData = _castToChartMap(results['pavagam']);
    final vargas = results['divisional_charts'] ?? {};
    final ashtakavarga = results['ashtakavarga'] as Map<dynamic, dynamic>? ?? {};
    
    final details = results['planet_details'] as Map<dynamic, dynamic>? ?? {};
    final panchangam = results['panchangam'] as Map<dynamic, dynamic>? ?? {};
    final dasaList = results['dasa'] as List<dynamic>? ?? [];
    final birthDt = results['birth_dt'] as DateTime?;
    final place = results['place'] ?? "-";
    final now = DateTime.now();
    final primaryColor = PdfColor.fromHex('#5D1204');
    final secondaryColor = PdfColor.fromHex('#B58D3D');
    final bgColor = PdfColor.fromHex('#FAF6EE');
    final borderColor = PdfColor.fromHex('#E0D4BE');

    pw.Widget sectionTitle(String title) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 15, bottom: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
        ),
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          children: [
            pw.Container(width: 8, height: 8, decoration: pw.BoxDecoration(color: primaryColor, shape: pw.BoxShape.circle)),
            pw.SizedBox(width: 6),
            pw.Text(title.toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 14)),
          ]
        )
      );
    }
    pw.Widget chartBox(Map<String, List<String>> chartData, String title) {
      Map<int, List<String>> rasiMap = {};
      final List<String> SIGNS = [
        "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
        "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
      ];
      chartData.forEach((sign, planets) {
        int rasiIdx = SIGNS.indexOf(sign) + 1;
        if (rasiIdx > 0) rasiMap[rasiIdx] = planets;
      });

      pw.Widget cell(int? idx) {
        if (idx == null) return pw.Container();
        final planets = rasiMap[idx] ?? [];
        return pw.Container(
          padding: const pw.EdgeInsets.all(2),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: primaryColor, width: 1.0),
            color: bgColor,
          ),
          child: pw.Center(
            child: pw.Text(planets.join(" ").toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 10), textAlign: pw.TextAlign.center)
          )
        );
      }

      return pw.Column(
        children: [
          pw.Text(title.toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 12)),
          pw.SizedBox(height: 6),
          pw.Container(
            width: 170, height: 170,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: primaryColor, width: 1.5)),
            child: pw.Column(
              children: [
                pw.Expanded(child: pw.Row(children: [pw.Expanded(child: cell(12)), pw.Expanded(child: cell(1)), pw.Expanded(child: cell(2)), pw.Expanded(child: cell(3))])),
                pw.Expanded(flex: 2, child: pw.Row(children: [
                  pw.Expanded(child: pw.Column(children: [pw.Expanded(child: cell(11)), pw.Expanded(child: cell(10))])), 
                  pw.Expanded(flex: 2, child: pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: primaryColor, width: 1.0)),
                    child: pw.Center(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.FittedBox(
                          fit: pw.BoxFit.scaleDown,
                          child: pw.Text(title.toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 14), textAlign: pw.TextAlign.center)
                        ),
                      )
                    )
                  )), 
                  pw.Expanded(child: pw.Column(children: [pw.Expanded(child: cell(4)), pw.Expanded(child: cell(5))]))
                ])),
                pw.Expanded(child: pw.Row(children: [pw.Expanded(child: cell(9)), pw.Expanded(child: cell(8)), pw.Expanded(child: cell(7)), pw.Expanded(child: cell(6))])),
              ]
            )
          )
        ]
      );
    }

    String dtStr = birthDt != null ? DateFormat('dd-MM-yyyy').format(birthDt) : "-";
    String tiStr = birthDt != null ? DateFormat('h:mm a').format(birthDt) : "-";
    String headerDateText = "$dtStr - $tiStr";

    pw.Widget buildPageBorder(pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(
          margin: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: primaryColor, width: 2.5)),
          child: pw.Container(
            margin: const pw.EdgeInsets.all(2),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: primaryColor, width: 0.5)),
          ),
        ),
      );
    }

    pw.Widget buildHeader(pw.Context context) {
      return pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Text("$name : $headerDateText".toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 10)),
              pw.Text("பக்கம் ${context.pageNumber}".toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 10)),
            ]
          ),
          pw.Divider(thickness: 1.5),
          pw.SizedBox(height: 10),
        ]
      );
    }

    final pageThemeWithHeader = pw.PageTheme(
      pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.all(35),
      theme: pw.ThemeData.withFont(base: bodyFont),
      buildBackground: buildPageBorder,
    );

    // ----------------------------------------------------
    // PAGE 1: TITLE PAGE
    // ----------------------------------------------------
    pdf.addPage(pw.Page(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.all(35),
        theme: pw.ThemeData.withFont(base: bodyFont),
        buildBackground: buildPageBorder,
      ),
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text("வாழ்க வளமுடன்".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 15),
            pw.Container(
              width: 350,
              padding: const pw.EdgeInsets.symmetric(vertical: 15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primaryColor, width: 1.5)
              ),
              child: pw.Column(
                children: [
                  pw.Text(name.toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text("ஜாதகம்".toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 16)),
                ]
              )
            ),
            pw.SizedBox(height: 15),
            pw.Text("சுத்த திருக்கணிதத்தின்படி".toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 14)),
            pw.Text("இந்த ஜாதகத்தை துல்லியமாக கணித்தவர்".toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 14)),
            pw.SizedBox(height: 15),
            pw.Container(
              width: 350,
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: primaryColor, width: 1.5)),
              child: pw.Column(
                children: [
                  pw.Text("ஜோதிடர் விபரம்".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 16)),
                  pw.SizedBox(height: 5),
                  pw.Text((astroDetails?['name'] ?? '').toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 14)),
                ]
              )
            ),
            pw.SizedBox(height: 15),
            pw.Text("Software by : www.gbastro.com\nCell: 9600666225", textAlign: pw.TextAlign.center, style: pw.TextStyle(font: bodyFont, fontSize: 10)),
          ]
        )
      )
    ));

    // ----------------------------------------------------
    // PAGE 2: BIRTH DETAILS
    // ----------------------------------------------------
    pdf.addPage(pw.Page(
      pageTheme: pageThemeWithHeader,
      build: (context) {
        String nak = _translateToTamil(details['moon']?['nakshatra'] ?? "-");
        String rasi = details['moon']?['rasi'] != null ? _translateToTamil(SIGNS_TAMIL[details['moon']?['rasi']] ?? details['moon']?['rasi']?.toString() ?? "-") : "-";
        String lagna = details['lagna']?['rasi'] != null ? _translateToTamil(SIGNS_TAMIL[details['lagna']?['rasi']] ?? details['lagna']?['rasi']?.toString() ?? "-") : "-";
        
        pw.Widget rowItem(String label, String value) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(width: 150, child: pw.Text(label.toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 12))),
                pw.Text(": ", style: pw.TextStyle(font: bodyFont, fontSize: 12)),
                pw.Expanded(child: pw.Text(value.toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 12))),
              ]
            )
          );
        }

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader(context),
            pw.SizedBox(height: 20),
            pw.Center(child: pw.Text("உ".toTamilPdf, style: pw.TextStyle(font: bodyFont, color: PdfColors.red, fontSize: 14))),
            pw.SizedBox(height: 10),
            pw.Center(child: pw.Text("ஜெனனீ ஜென்ம சௌக்கியானாம் வர்த்தனி குலசம்பதாம் பதவிபூர்வ புண்யானாம் லிக்யதே ஜென்ம பத்ரிகா!!".toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 10), textAlign: pw.TextAlign.center)),
            pw.SizedBox(height: 5),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  rowItem("ஜாதகர் பெயர்", name.isNotEmpty ? name : "ராஜமாணிக்கம்"),
                  rowItem("தந்தை பெயர்", astroDetails?['fatherName'] ?? "தங்கவேலு"),
                  rowItem("தாய் பெயர்", astroDetails?['motherName'] ?? "அலவேலு"),
                  rowItem("பிறந்த தேதி", "$dtStr @ $tiStr"),
                  rowItem("கிழமை", _translateToTamil(panchangam['vara']?.toString() ?? "-")),
                  rowItem("பிறந்த இடம்", (place == "-" || place.isEmpty) ? "Pondicherry" : place),
                  rowItem("பாலினம்", _translateToTamil(gender)),
                  rowItem("ஜென்ம நட்சத்திரம்", nak),
                  rowItem("ஜென்ம ராசி", rasi),
                  rowItem("ஜென்ம லக்னம்", lagna),
                  rowItem("ஜென்ம திதி", _translateToTamil(panchangam['tithi']?.toString() ?? "-")),
                  rowItem("ஜென்மயோகம்", _translateToTamil(panchangam['yoga']?.toString() ?? "-")),
                  rowItem("ஜென்ம கரணம்", _translateToTamil(panchangam['karana']?.toString() ?? "-")),
                ]
              )
            )
          ]
        );
      }
    ));

    // ----------------------------------------------------
    // PAGE 3: VINAYAGAR THUTHI
    // ----------------------------------------------------
    pdf.addPage(pw.Page(
      pageTheme: pageThemeWithHeader,
      build: (context) {
        return pw.Column(
          children: [
            buildHeader(context),
            pw.SizedBox(height: 15),
            pw.Center(
              child: pw.Container(
                width: 250,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
                child: pw.Center(child: pw.Text("விநாயகர் துதி".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 16, fontWeight: pw.FontWeight.bold)))
              )
            ),
            pw.SizedBox(height: 15),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (ganapathyImg != null) pw.Image(pw.MemoryImage(ganapathyImg), height: 120, fit: pw.BoxFit.contain) else pw.SizedBox(width: 120),
                pw.SizedBox(width: 30),
                pw.Expanded(
                  child: pw.Text(
                    "ஐந்து கரத்தினை ஆனை முகத்தினை\nஇந்தின் இளம்பிறை போலும் எயிற்றனை\nநந்தி மகன்தனை ஞானக் கொழுந்தினை\nபுந்தியில் வைத்தடி போற்றுகின்றேனே...".toTamilPdf, 
                    style: pw.TextStyle(font: bodyFont, fontSize: 13, lineSpacing: 2.5)
                  )
                )
              ]
            ),
            pw.SizedBox(height: 50),
            pw.Center(
              child: pw.Text(
                "மணிமாலை\nவிநாயகனே வெவ்வினையை வேரறுக்க வல்லான்\nவிநாயகனே வேட்கைதணி விப்பான் - விநாயகனே\nவிண்ணிற்கும் மண்ணிற்கும் நாதனுமாந் தன்மையினாற்\nகண்ணிற் பணிமின் கனிந்து...\nசுபமஸ்து...".toTamilPdf,
                style: pw.TextStyle(font: bodyFont, fontSize: 13, lineSpacing: 1.5),
                textAlign: pw.TextAlign.left
              )
            )
          ]
        );
      }
    ));

    // ----------------------------------------------------
    // PAGE 4: KADAVUL VAZHTHU (MURUGA)
    // ----------------------------------------------------
    pdf.addPage(pw.Page(
      pageTheme: pageThemeWithHeader,
      build: (context) {
        return pw.Column(
          children: [
            buildHeader(context),
            pw.SizedBox(height: 15),
            pw.Center(
              child: pw.Container(
                width: 250,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
                child: pw.Center(child: pw.Text("கடவுள் வாழ்த்து".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 16, fontWeight: pw.FontWeight.bold)))
              )
            ),
            pw.SizedBox(height: 15),
            if (muruganImg != null)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(pw.MemoryImage(muruganImg), height: 130, fit: pw.BoxFit.contain),
                  pw.SizedBox(width: 30),
                  pw.Expanded(
                    child: pw.Text(
                      "தங்க மான்மழு வோடாந்தித்\nதன்மதி தலையிற் கொண்டோன்\nமங்கையர் பதிக்குச் சொன்ன\nமாமொழிச் சோதிடத்தை\nஇங்குநா முரைப்பதற்கோர்\nஇமையெனும் பிழை வராமற்\nசெங்கண்மால் மருகன் யானைச்\nசிரன் பதங் காப்பதாமே.\nசுபமஸ்து...".toTamilPdf,
                      style: pw.TextStyle(font: bodyFont, fontSize: 13, lineSpacing: 1.5),
                      textAlign: pw.TextAlign.center
                    )
                  )
                ]
              )
            else
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                child: pw.Text(
                  "தங்க மான்மழு வோடாந்தித்\nதன்மதி தலையிற் கொண்டோன்\nமங்கையர் பதிக்குச் சொன்ன\nமாமொழிச் சோதிடத்தை\nஇங்குநா முரைப்பதற்கோர்\nஇமையெனும் பிழை வராமற்\nசெங்கண்மால் மருகன் யானைச்\nசிரன் பதங் காப்பதாமே.\nசுபமஸ்து...".toTamilPdf,
                  style: pw.TextStyle(font: bodyFont, fontSize: 14, lineSpacing: 2.0),
                  textAlign: pw.TextAlign.center
                )
              )
          ]
        );
      }
    ));

    // ----------------------------------------------------
    // PAGE 5: THIRUMANTHIRAM
    // ----------------------------------------------------
    pdf.addPage(pw.Page(
      pageTheme: pageThemeWithHeader,
      build: (context) {
        return pw.Column(
          children: [
            buildHeader(context),
            pw.SizedBox(height: 15),
            pw.Center(
              child: pw.Container(
                width: 250,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
                child: pw.Center(child: pw.Text("திருமந்திரம்".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 16, fontWeight: pw.FontWeight.bold)))
              )
            ),
            pw.SizedBox(height: 50),
            pw.Center(
              child: pw.Text(
                "தன்னை அறியத் தனக்கொரு கேடில்லை\nதன்னை அறியாமற் தானே கெடுகின்றான்.\nதன்னையே அறியும் அறிவை அறிந்த பின்\nதனையே, அர்ச்சிக்கத் தானிருந்த் தானே\nயாவர்க்குமாம் இறைவர்க்கு ஒரு பச்சிலை\nயாவர்க்குமாம் பசுவிற்கொரு வாயுறை\nயாவர்க்குமாம் உண்ணும் போதொரு கைப்பிடி\nயாவர்க்குமாம் பிறர்க்கு இன்னுரை தானே.".toTamilPdf,
                style: pw.TextStyle(font: bodyFont, fontSize: 14, lineSpacing: 3),
                textAlign: pw.TextAlign.center
              )
            )
          ]
        );
      }
    ));

    // ----------------------------------------------------
    // PAGE 6: JANANA VAKKIYAM
    // ----------------------------------------------------
    pdf.addPage(pw.Page(
      pageTheme: pageThemeWithHeader,
      build: (context) {
        int currentYear = birthDt?.year ?? 2024;
        
        pw.Widget vakkiyamRow(String label, String value) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              children: [
                pw.SizedBox(width: 180, child: pw.Text(label.toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 14))),
                pw.Text(":  ", style: pw.TextStyle(font: bodyFont, fontSize: 14)),
                pw.Text(value.toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 14)),
              ]
            )
          );
        }

        return pw.Column(
          children: [
            buildHeader(context),
            pw.SizedBox(height: 15),
            pw.Center(
              child: pw.Container(
                width: 250,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
                child: pw.Center(child: pw.Text("ஜெனன வாக்கியம்".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 16, fontWeight: pw.FontWeight.bold)))
              )
            ),
            pw.SizedBox(height: 15),
            pw.Center(
              child: pw.Text("ஸ்ரீஉச்சிஷ்ட மஹா கணபதியேநமஹ!!".toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 14))
            ),
            pw.SizedBox(height: 15),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 60),
              child: pw.Column(
                children: [
                  vakkiyamRow("கொல்லமாப்த வருடம்", (currentYear - 825).toString()),
                  vakkiyamRow("சாலிவாகனாப்த வருடம்", (currentYear - 78).toString()),
                  vakkiyamRow("பசலியாப்த வருடம்", (currentYear - 591).toString()),
                  vakkiyamRow("ஹிஜ்ரியாப்த வருடம்", (currentYear - 579).toString()),
                  vakkiyamRow("கலியுகாதி வருடம்", (currentYear + 3102).toString()),
                  vakkiyamRow("விக்ரமாப்த வருடம்", (currentYear + 57).toString()),
                  vakkiyamRow("திருவள்ளுவர் வருடம்", (currentYear + 31).toString()),
                ]
              )
            )
          ]
        );
      }
    ));

    // ----------------------------------------------------
    // PAGE 7: DATE LONG FORMAT
    // ----------------------------------------------------
    pdf.addPage(pw.Page(
      pageTheme: pageThemeWithHeader,
      build: (context) {
        String tVara = _translateToTamil(panchangam['vara']?.toString() ?? "");
        String tTithi = _translateToTamil(panchangam['tithi']?.toString() ?? "");
        String tNak = _translateToTamil(details['moon']?['nakshatra'] ?? "");
        String tRasi = details['moon']?['rasi'] != null ? _translateToTamil(SIGNS_TAMIL[details['moon']?['rasi']] ?? details['moon']?['rasi']?.toString() ?? "") : "";
        String tYoga = _translateToTamil(panchangam['yoga']?.toString() ?? "");
        String tKarana = _translateToTamil(panchangam['karana']?.toString() ?? "");
        String tLagna = details['lagna']?['rasi'] != null ? _translateToTamil(SIGNS_TAMIL[details['lagna']?['rasi']] ?? details['lagna']?['rasi']?.toString() ?? "") : "";
        int year = birthDt?.year ?? 0;
        int month = birthDt?.month ?? 1;
        int day = birthDt?.day ?? 1;
        String ayanam = (month >= 2 && month <= 7) ? "உத்தராயணம்" : "தக்ஷிணாயணம்";
        String tPaksham = _translateToTamil(panchangam['paksham']?.toString() ?? "கிருஷ்ண பட்சத்தில்");
        String tMonth = _translateToTamil(panchangam['tamil_month']?.toString() ?? "");
        String tYear = _translateToTamil(panchangam['tamil_year']?.toString() ?? "");
        String tDate = _translateToTamil(panchangam['tamil_date']?.toString() ?? "");
        String tNazhigai = results['nazhigai']?.toString() ?? "";

        return pw.Column(
          children: [
            buildHeader(context),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                "இங்கிலீஷ் வருடம் $year ஆம் ஆண்டு\n$month மாதம் $day ஆம் தேதிக்குச்சரியான\nநிகழும் தமிழ் $tYear வருடம்\n$tMonth மாதம் $tDate ஆம் தேதி $tVara கிழமை\nசூரிய உதயாதி $tNazhigai க்கு\n$ayanam $tPaksham\n$tLagna லக்னமும் $tTithi திதியும்\n$tNak நட்சத்திரமும்\n$tRasi ராசியும்\n$tYoga யோகமும் $tKarana கரணமும்\nஆன சுபயோக சுபதினத்தில்...".toTamilPdf,
                style: pw.TextStyle(font: bodyFont, fontSize: 13, lineSpacing: 2.0),
                textAlign: pw.TextAlign.center
              )
            )
          ]
        );
      }
    ));

    // ----------------------------------------------------
    // PAGE 8: LOCATION DETAILS
    // ----------------------------------------------------
    pdf.addPage(pw.Page(
      pageTheme: pageThemeWithHeader,
      build: (context) {
        String p = (place == "-" || place.isEmpty) ? "Pondicherry" : place;
        String f = astroDetails?['fatherName'] ?? "தங்கவேலு";
        String m = astroDetails?['motherName'] ?? "அலவேலு";
        String n = name.isNotEmpty ? name : "ராஜமாணிக்கம்";

        return pw.Column(
          children: [
            buildHeader(context),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                "$p\nஊரில் வசிக்கும்\nமஹாஸ்ரீஸ்ரீமகா கணம் பொருந்திய ஸ்ரீமான்\nதிரு.$f\nஅவர்களின் குலதர்ம பத்தினியாகிய\nதிருமதி.$m\nஅவர்களுக்கு ஸ்ரீமான் குமாரன்\n$n\nசுப ஜெனனம்.\nஅவ்வண்ணமே தற்கால கிரகநிலையறிந்து\nதிசா புத்தி பலன் உரைக்கவும்\nமாதா, பிதா, ஜாதகர் தீர்க்காயுள்\n- சுபம் -".toTamilPdf,
                style: pw.TextStyle(font: bodyFont, fontSize: 13, lineSpacing: 2.0),
                textAlign: pw.TextAlign.center
              )
            )
          ]
        );
      }
    ));

    // ----------------------------------------------------
    // PAGE 9: EPHEMERIS DETAILS
    // ----------------------------------------------------
    pdf.addPage(pw.Page(
      pageTheme: pageThemeWithHeader,
      build: (context) {
        String dasaLord = dasaList.isNotEmpty ? _translateToTamil(dasaList.first['lord']?.toString() ?? "-") : "-";
        
        String garbhaSelStr = "-";
        String dasaIruppuStr = "-";
        if (dasaList.isNotEmpty && birthDt != null) {
          DateTime start = dasaList.first['start'] as DateTime;
          DateTime end = dasaList.first['end'] as DateTime;
          
          int remainingDays = end.difference(birthDt).inDays;
          if (remainingDays < 0) remainingDays = 0;
          int rY = remainingDays ~/ 365;
          int rM = (remainingDays % 365) ~/ 30;
          int rD = (remainingDays % 365) % 30;
          dasaIruppuStr = "$rY வருடம் $rM மாதம் $rD நாள்";
          
          int pastDays = birthDt.difference(start).inDays;
          if (pastDays < 0) pastDays = 0;
          int pY = pastDays ~/ 365;
          int pM = (pastDays % 365) ~/ 30;
          int pD = (pastDays % 365) % 30;
          garbhaSelStr = "$pY வருடம் $pM மாதம் $pD நாள்";
        }

        String ayanamsaVal = panchangam['ayanamsa'] ?? "24:13:02";

        return pw.Column(
          children: [
            buildHeader(context),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                "மங்களகரமான சுப நன்னாளில் அன்று ஜெனன\nசேத்திர சூரியோதயம் ${panchangam['sunrise'] ?? '06:00 AM'} மணி நேரத்திலும்\nசூரிய அஸ்தமனம் ${panchangam['sunset'] ?? '06:00 PM'} மணி நேரத்திலும்\nஅயனாம்சம் $ayanamsaVal\n\n$dasaLord தசை விபரம்:\nகர்ப்பச் செல்: $garbhaSelStr\nதசை இருப்பு: $dasaIruppuStr\n\n- சுபம் -".toTamilPdf,
                style: pw.TextStyle(font: bodyFont, fontSize: 13, lineSpacing: 2.5),
                textAlign: pw.TextAlign.center
              )
            )
          ]
        );
      }
    ));

    // ----------------------------------------------------
    // CHARTS AND REMAINING PAGES (Using exact same functions as before, but with pageThemeWithHeader and no colors)
    // ----------------------------------------------------
    
    pw.Widget sectionTitlePlain(String title) {
      return pw.Center(
        child: pw.Container(
          width: 300,
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          margin: const pw.EdgeInsets.only(bottom: 20),
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
          child: pw.Center(child: pw.Text(title.toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 16, fontWeight: pw.FontWeight.bold)))
        )
      );
    }

    pw.Widget chartBoxPlain(Map<String, List<String>> chartData, String title, {double size = 180}) {
      Map<int, List<String>> rasiMap = {};
      final List<String> SIGNS = ["Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"];
      chartData.forEach((sign, planets) {
        int rasiIdx = SIGNS.indexOf(sign) + 1;
        if (rasiIdx > 0) rasiMap[rasiIdx] = planets;
      });

      pw.Widget cell(int? idx) {
        if (idx == null) return pw.Container();
        final planets = rasiMap[idx] ?? [];
        return pw.Container(
          padding: const pw.EdgeInsets.all(2),
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0)),
          child: pw.Center(child: pw.Text(planets.join(" ").toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 10), textAlign: pw.TextAlign.center))
        );
      }

      return pw.Column(
        children: [
          pw.Container(
            width: size, height: size,
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
            child: pw.Column(
              children: [
                pw.Expanded(child: pw.Row(children: [pw.Expanded(child: cell(12)), pw.Expanded(child: cell(1)), pw.Expanded(child: cell(2)), pw.Expanded(child: cell(3))])),
                pw.Expanded(flex: 2, child: pw.Row(children: [
                  pw.Expanded(child: pw.Column(children: [pw.Expanded(child: cell(11)), pw.Expanded(child: cell(10))])), 
                  pw.Expanded(flex: 2, child: pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0)),
                    child: pw.Center(child: pw.Text(title.toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 14, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center))
                  )), 
                  pw.Expanded(child: pw.Column(children: [pw.Expanded(child: cell(4)), pw.Expanded(child: cell(5))]))
                ])),
                pw.Expanded(child: pw.Row(children: [pw.Expanded(child: cell(9)), pw.Expanded(child: cell(8)), pw.Expanded(child: cell(7)), pw.Expanded(child: cell(6))])),
              ]
            )
          )
        ]
      );
    }
    // ----------------------------------------------------

    // ----------------------------------------------------
    // OLD PAGES (Restored)
    // ----------------------------------------------------
    pdf.addPage(pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.all(35),
        theme: pw.ThemeData.withFont(base: bodyFont),
        buildBackground: buildPageBorder,
      ),
      header: (context) => buildHeader(context),
      build: (context) {
        return [
            sectionTitle("ராசி மற்றும் நவாம்ச சக்கரம்"),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                chartBox(rasiData, "ராசி சக்கரம்"),
                chartBox(amsamData, "நவாம்ச சக்கரம்"),
              ]
            ),
            
            pw.SizedBox(height: 20),
            pw.Wrap(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    sectionTitle("பாவக சக்கரம்"),
                    pw.Center(child: chartBox(pavagamData, "பாவக சக்கரம்")),
                  ]
                )
              ]
            ),

            pw.NewPage(),

            sectionTitle("கிரக பாதசாரம்"),
            pw.Table(
              border: pw.TableBorder.all(color: borderColor),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F4EFE3')),
                  children: ["கிரகம்", "ராசி", "நட்சத்திரம்", "பாதம்", "பாகை"]
                    .map((t) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 10), textAlign: pw.TextAlign.center)))
                    .toList()
                ),
                ...['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu', 'Maanthi', 'Lagna'].map((pKey) {
                  final p = details[pKey.toLowerCase()] ?? details[pKey] ?? {};
                  String pName = _translateToTamil(pKey == 'Lagna' ? 'லக்னம்' : pKey);
                  String rasi = _translateToTamil(SIGNS_TAMIL[p['rasi']] ?? p['rasi'] ?? "-");
                  String nak = _translateToTamil(p['nakshatra'] ?? "-");
                  String pada = p['pada']?.toString() ?? "-";
                  String deg = p['longitude'] != null ? KPService.formatAbsoluteDegrees(p['longitude']) : "-";
                  return pw.TableRow(
                    children: [pName, rasi, nak, pada, deg]
                      .map((t) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 10), textAlign: pw.TextAlign.center)))
                      .toList()
                  );
                }).toList()
              ]
            ),

            // Vargas loop
            if (vargas.isNotEmpty) ...[
               for (int i = 0; i < vargas.keys.length; i += 2) ...[
                 pw.NewPage(),
                 sectionTitle("வர்க்க சக்கரங்கள்"),
                 pw.Row(
                   mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                   children: [
                     chartBox(_castToChartMap(vargas[vargas.keys.elementAt(i)]), vargas.keys.elementAt(i)),
                     if (i + 1 < vargas.length) 
                        chartBox(_castToChartMap(vargas[vargas.keys.elementAt(i+1)]), vargas.keys.elementAt(i+1))
                     else
                        pw.SizedBox(width: 170)
                   ]
                 ),
                 pw.SizedBox(height: 20),
               ]
            ],

            pw.NewPage(),

            // Dasa Bhukti
            sectionTitle("உடுமகா திசை விபரம் (தசா புக்தி)"),
            ...dasaList.map((d) {
              String lord = _translateToTamil(d['lord'] ?? "-");
              final start = d['start'] as DateTime?;
              final end = d['end'] as DateTime?;
              String startStr = start != null ? DateFormat('dd-MM-yyyy').format(start) : "-";
              String endStr = end != null ? DateFormat('dd-MM-yyyy').format(end) : "-";
              final subPeriods = d['subPeriods'] as List<dynamic>? ?? [];

              return pw.Wrap(
                children: [
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 20),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("$lord திசை விபரம் ($startStr முதல் $endStr வரை)".toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 12)),
                    pw.SizedBox(height: 6),
                    pw.Table(
                      border: pw.TableBorder.all(color: borderColor),
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F4EFE3')),
                          children: ["புக்தி", "ஆரம்பம்", "முடிவு"]
                            .map((t) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 10), textAlign: pw.TextAlign.center)))
                            .toList()
                        ),
                        ...subPeriods.map((b) {
                           String bLord = _translateToTamil(b['lord'] ?? "-");
                           final bStart = b['start'] as DateTime?;
                           final bEnd = b['end'] as DateTime?;
                           return pw.TableRow(
                             children: [
                               bLord,
                               bStart != null ? DateFormat('dd-MM-yyyy').format(bStart) : "-",
                               bEnd != null ? DateFormat('dd-MM-yyyy').format(bEnd) : "-"
                             ].map((t) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 10), textAlign: pw.TextAlign.center))).toList()
                           );
                        }).toList()
                      ]
                    )
                  ]
                )
              )
            ]);
            }).toList(),
            
            // Ashtakavarga Output (Basic table)
            if (ashtakavarga.isNotEmpty && ashtakavarga['individual'] != null) ...[
               pw.NewPage(),
               sectionTitle("அஷ்டவர்க்கம் (Ashtakavarga)"),
               pw.Wrap(
                 spacing: 40,
                 runSpacing: 10,
                 children: (ashtakavarga['individual'] as Map<dynamic, dynamic>).entries.map((entry) {
                    final pName = KPService.TAMIL_PLANETS[entry.key] ?? entry.key.toString();
                    final points = entry.value as List<int>;
                    return pw.Container(
                      width: 160,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("$pName பரல்கள்".toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 12)),
                          pw.SizedBox(height: 5),
                          pw.Text(points.join(" | ").toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 10))
                        ]
                      )
                    );
                 }).toList()
               ),
               
               if (ashtakavarga['total'] != null) ...[
                 pw.SizedBox(height: 20),
                 sectionTitle("சர்வ அஷ்டவர்க்கம்"),
                 (() {
                   Map<String, List<String>> sarvaMap = {};
                   List<dynamic> totalPoints = ashtakavarga['total'];
                   for (int i = 0; i < 12; i++) {
                     if (i < totalPoints.length) sarvaMap[KPService.SIGNS[i]] = [totalPoints[i].toString()];
                   }
                   return chartBox(sarvaMap, "சர்வ\nஅஷ்டவர்க்கம்");
                 })(),
               ],

               if (ashtakavarga['pindas'] != null) ...[
                 pw.NewPage(),
                 pw.SizedBox(height: 20),
                 sectionTitle("பிண்டங்கள்"),
                 (() {
                   final pindas = (ashtakavarga['pindas'] as Map).cast<String, dynamic>();
                   final planets = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn"];
                   return pw.Table(
                     border: pw.TableBorder.all(color: borderColor),
                     children: [
                       pw.TableRow(
                         decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F4EFE3')),
                         children: ["கிரகம்", "ராசி பிண்டம்", "கிரக பிண்டம்", "சேர்த்திய பிண்டம்"].map((t) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 10), textAlign: pw.TextAlign.center))).toList()
                       ),
                       ...planets.map((p) {
                         final pPinda = (pindas[p] as Map? ?? {}).cast<String, dynamic>();
                         final pName = KPService.TAMIL_PLANETS[p] ?? p;
                         return pw.TableRow(
                           children: [
                             pName,
                             pPinda['rasi']?.toString() ?? "0",
                             pPinda['graha']?.toString() ?? "0",
                             pPinda['total']?.toString() ?? "0",
                           ].map((t) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 10), textAlign: pw.TextAlign.center))).toList()
                         );
                       }).toList()
                     ]
                   );
                 })(),
               ],
            ],

            pw.NewPage(),
            sectionTitle("பொது பலன்கள் (Predictions)"),
            (() {
              final pancha = results['panchangam'] ?? {};
              final basics = results['planet_details'] ?? {};
              final moon = basics['moon'] ?? {};
              final lagna = basics['lagna'] ?? {};
              
              Map<String, dynamic>? activeDasa;
              Map<String, dynamic>? activeBukthi;
              final now = DateTime.now();
              for (var d in dasaList) {
                if (now.isAfter(d['start']) && now.isBefore(d['end'])) {
                  activeDasa = d;
                  for (var b in (d['subPeriods'] as List? ?? [])) {
                    if (now.isAfter(b['start']) && now.isBefore(b['end'])) {
                      activeBukthi = b;
                      break;
                    }
                  }
                  break;
                }
              }

              final String dasaPalanText = activeDasa != null 
                ? "நடப்பு தசை: ${activeDasa['lord']} (${DateFormat('dd-MM-yyyy').format(activeDasa['end'])} வரை)\n${PalangalService.getDetailedDasaPalan(activeDasa['lord'])}\n\nநடப்பு புத்தி: ${activeBukthi?['lord'] ?? '-'} (${activeBukthi != null ? DateFormat('dd-MM-yyyy').format(activeBukthi['end']) : '-'} வரை)\n${PalangalService.getDetailedBhuktiPalan(activeBukthi?['lord'])}" 
                : "தசா புத்தி விபரங்கள் இல்லை";

              final palangalListItems = [
                {"title": "லக்ன பலன்", "content": PalangalService.getDetailedLagnaPalan(lagna['rasi'])},
                {"title": "ராசி பலன்", "content": PalangalService.getDetailedRasiPalan(moon['rasi'])},
                {"title": "நட்சத்திர பலன்", "content": PalangalService.getDetailedNakshatraPalan(moon['nakshatra'], moon['pada'])},
                {"title": "யோகம்", "content": PalangalService.getDetailedYogaPalan(pancha['yoga'])},
                {"title": "கர்ணம்", "content": PalangalService.getDetailedKaranaPalan(pancha['karana']?.toString())},
                {"title": "கிழமை", "content": PalangalService.getDetailedWeekdayPalan(pancha['vara'])},
                {"title": "திதி", "content": PalangalService.getDetailedThithiPalan(pancha['tithi'])},
                {"title": "தசா புத்தி பலன்", "content": dasaPalanText},
              ];

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: palangalListItems.map((item) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 15),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item['title']!.toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 13, decoration: pw.TextDecoration.underline)),
                        pw.SizedBox(height: 6),
                        pw.Text(item['content']!.toTamilPdf, style: pw.TextStyle(font: bodyFont, color: PdfColors.black, fontSize: 11)),
                      ]
                    )
                  );
                }).toList()
              );
            })(),

          ];
        }
      )
    );

    // ----------------------------------------------------

    return pdf.save();
  }

  static Map<String, String> SIGNS_TAMIL = {
    'Aries': 'மேஷம்', 'Taurus': 'ரிஷபம்', 'Gemini': 'மிதுனம்', 'Cancer': 'கடகம்',
    'Leo': 'சிம்மம்', 'Virgo': 'கன்னி', 'Libra': 'துலாம்', 'Scorpio': 'விருச்சிகம்',
    'Sagittarius': 'தனுசு', 'Capricorn': 'மகரம்', 'Aquarius': 'கும்பம்', 'Pisces': 'மீனம்'
  };

  static String _translateToTamil(String val) {
    if (val.isEmpty) return val;
    final Map<String, String> englishToTamil = {
      "Sun": "சூரியன்", "Moon": "சந்திரன்", "Mars": "செவ்வாய்", "Mercury": "புதன்",
      "Jupiter": "குரு", "Venus": "சுக்கிரன்", "Saturn": "சனி", "Rahu": "ராகு", "Ketu": "கேது",
      "Maanthi": "மாந்தி", "Lagna": "லக்னம்",
      "Aries": "மேஷம்", "Taurus": "ரிஷபம்", "Gemini": "மிதுனம்", "Cancer": "கடகம்",
      "Leo": "சிம்மம்", "Virgo": "கன்னி", "Libra": "துலாம்", "Scorpio": "விருச்சிகம்",
      "Sagittarius": "தனுசு", "Capricorn": "மகரம்", "Aquarius": "கும்பம்", "Pisces": "மீனம்",
      "Ashwini": "அசுவனி", "Bharani": "பரணி", "Krittika": "கிருத்திகை", "Rohini": "ரோகிணி",
      "Mrigashirsha": "மிருகசீர்ஷம்", "Arudra": "திருவாதிரை", "Punarvasu": "புனர்பூசம்",
      "Pushya": "பூசம்", "Aslesha": "ஆயில்யம்", "Magha": "மகம்", "Purvaphalguni": "பூரம்",
      "Uttaraphalguni": "உத்திரம்", "Hastha": "அஸ்தம்", "Chitra": "சித்திரை", "Swati": "சுவாதி",
      "Vishakha": "விசாகம்", "Anuradha": "அனுஷம்", "Jyeshta": "கேட்டை", "Jyeshtha": "கேட்டை", "Mula": "மூலம்",
      "Purvashada": "பூராடம்", "PurvaAshadha": "பூராடம்", "Uttarashada": "உத்திராடம்", "UttaraAshadha": "உத்திராடம்",
      "Shravana": "திருவோணம்", "Dhanishta": "அவிட்டம்", "Shatabhisha": "சதயம்",
      "Purvabhadrapada": "பூரட்டாதி", "Uttarabhadrapada": "உத்திரட்டாதி", "Revati": "ரேவதி",
      "Sunday": "ஞாயிறு", "Monday": "திங்கள்", "Tuesday": "செவ்வாய்", "Wednesday": "புதன்",
      "Thursday": "வியாழன்", "Friday": "வெள்ளி", "Saturday": "சனி",
      "Prathama": "பிரதமை", "Dwitiya": "துவிதியை", "Tritiya": "திரிதியை", "Chaturthi": "சதுர்த்தி",
      "Panchami": "பஞ்சமி", "Shasthi": "சஷ்டி", "Saptami": "சப்தமி", "Ashtami": "அஷ்டமி",
      "Navami": "நவமி", "Dashami": "தசமி", "Ekadashi": "ஏகாதசி", "Dwadashi": "துவாதசி",
      "Trayodashi": "திரயோதசி", "Chaturdashi": "சதுர்த்தசி", "Pournami": "பௌர்ணமி", "Purnima": "பௌர்ணமி", "Amavasya": "அமாவாசை",
      "Sukla Paksha (Waxing)": "சுக்ல பட்சம் (வளர்பிறை)",
      "Krishna Paksha (Waning)": "கிருஷ்ண பட்சம் (தேய்பிறை)",
      "Bava": "பவம்", "Balava": "பாலவம்", "Kaulava": "கௌலவம்", "Taitila": "தைதிலை", "Garaja": "கரசை",
      "Vanija": "பத்திரா", "Vishti": "பத்திரா", "Shakuni": "சகுனி", "Chatushpada": "சதுஷ்பாதம்", "Nagawa": "நாகவம்",
      "Kimstughna": "கிம்ஸ்துக்கினம்",
      "Vishkumbha": "விஷ்கம்பம்", "Priti": "பிரீதி", "Ayushman": "ஆயுஷ்மான்", "Saubhagya": "சௌபாக்கியம்",
      "Sobhana": "சோபனம்", "Atiganda": "அதிகண்டம்", "Sukarma": "சுகர்மம்", "Dhriti": "திருதி",
      "Shula": "சூலம்", "Ganda": "கண்டம்", "Vriddhi": "விருத்தி", "Dhruva": "துருவம்",
      "Vyaghata": "வியாகாதம்", "Harshana": "ஹர்ஷணம்", "Vajra": "வஜ்ரம்", "Siddhi": "சித்தி",
      "Vyatipata": "வியதீபாதம்", "Variyan": "வரியான்", "Parigha": "பரிகம்", "Shiva": "சிவம்",
      "Siddha": "சித்தம்", "Sadhya": "சாத்தியம்", "Shubha": "சுபம்", "Shukla": "சுக்கிலம்",
      "Brahma": "பிரம்மா", "Indra": "ஐந்திரம்", "Vaidhriti": "வைதிருதி"
    };
    String res = val;
    final sortedKeys = englishToTamil.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    for (var key in sortedKeys) {
      res = res.replaceAll(key, englishToTamil[key]!);
    }
    return res;
  }

  static Map<String, List<String>> _castToChartMap(dynamic data) {
    if (data == null || data is! Map) return {};
    return data.map((key, value) {
      if (value is List) {
        return MapEntry(key.toString(), List<String>.from(value.map((e) => e.toString())));
      }
      return MapEntry(key.toString(), <String>[]);
    });
  }
}
