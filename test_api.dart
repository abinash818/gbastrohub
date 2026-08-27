import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final response = await http.post(
    Uri.parse("https://blueviolet-barracuda-132915.hostingersite.com/muruga_api.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "action": "check_status",
      "email": "abimanyuastro@gmail.com",
      "device_id": "Unknown" 
    }),
  );
  print(response.body);
}
