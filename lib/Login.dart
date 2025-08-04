
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uni_links/uni_links.dart';
import 'home_screen.dart'; // Adjust path if needed



class LoginPage extends StatefulWidget {
@override
_LoginPageState createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage>{

final TextEditingController _codeController = TextEditingController();

@override
void initState() {
  super.initState();

  final uri = Uri.base;
  final code = uri.queryParameters['code'];
  if (code != null) {
    _exchangeToken(code);
  }
}

Future <void> _launchLogin() async {
const String backendUrl = 'http://localhost:3000/auth/redirect';
final uri = Uri.parse(backendUrl);
  if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $uri';
    }
}

Future<void> _exchangeToken(String code) async {
  final response = await http.post(
    Uri.parse('http://localhost:3000/auth/token'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'code': code}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('✅ Logged in as ${data['username']}');
        // ✅ Navigate to HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
    // Navigate to your main screen or store token
  } else {
    print('❌ Token exchange failed');
  }
}


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login with Mastodon")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _launchLogin,
              child: Text("Login to Mastodon"),
            ),
          ],
        ),
      ),
    );
}
}

