
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class LoginPage extends StatelessWidget {
final String backendUrl = 'http://localhost:3000/auth/redirect';

Future <void> _redirectLogin() async {
final uri = Uri.parse(backendUrl);
  if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $uri';
    }
}






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async{
            print('Button pressed');
            await _redirectLogin();
          }, 
          child: Text('Login with Mastodon'),
        ),
      ),
    );
  }
}

