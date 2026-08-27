const fs = require('fs');
const content = fs.readFileSync('lib/screens/horoscope_results_screen.dart', 'utf8');
const startStr = '  String _getDetailedWeekdayPalan(';
const startIdx = content.indexOf(startStr);
const endIdx = content.lastIndexOf('}');
const extracted = content.substring(startIdx, endIdx);
const newExtracted = extracted.replace(/String _getDetailed/g, 'static String getDetailed');
const palangalServiceContent = `import 'package:aadhiguru/services/kp_service.dart';

class PalangalService {
${newExtracted}
}
`;
fs.writeFileSync('lib/services/palangal_service.dart', palangalServiceContent);

const newContent = content.substring(0, startIdx) + '}\n';
const updatedContent = newContent.replace(/_getDetailed/g, 'PalangalService.getDetailed');
fs.writeFileSync('lib/screens/horoscope_results_screen.dart', updatedContent);
console.log("Done");
