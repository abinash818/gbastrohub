import 'dart:html' as html;

void printHtmlWeb(String htmlContent) {
  try {
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print("Web Print Error: $e");
  }
}
