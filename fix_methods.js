const fs = require('fs');

let palangalContent = fs.readFileSync('lib/services/palangal_service.dart', 'utf8');
const splitStr = '  Widget _buildPalangalCard(';
const splitIdx = palangalContent.indexOf(splitStr);

if (splitIdx !== -1) {
  const methodsToMoveBack = palangalContent.substring(splitIdx, palangalContent.lastIndexOf('}'));
  
  // Clean up palangal_service.dart
  const newPalangalContent = palangalContent.substring(0, splitIdx) + '}\n';
  fs.writeFileSync('lib/services/palangal_service.dart', newPalangalContent);
  
  // Append to horoscope_results_screen.dart
  let screenContent = fs.readFileSync('lib/screens/horoscope_results_screen.dart', 'utf8');
  // It currently ends with '}\n' which closes _HoroscopeResultsScreenState
  const screenEndIdx = screenContent.lastIndexOf('}');
  const newScreenContent = screenContent.substring(0, screenEndIdx) + methodsToMoveBack + '\n}\n';
  fs.writeFileSync('lib/screens/horoscope_results_screen.dart', newScreenContent);
  console.log("Successfully moved methods back");
} else {
  console.log("Could not find split string");
}
