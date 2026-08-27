const fs = require('fs');
const content = fs.readFileSync('lib/screens/horoscope_results_screen.dart', 'utf8');
const importStmt = "import '../services/palangal_service.dart';\n";
const updatedContent = content.replace("import '../services/kp_service.dart';", "import '../services/kp_service.dart';\n" + importStmt);
fs.writeFileSync('lib/screens/horoscope_results_screen.dart', updatedContent);
