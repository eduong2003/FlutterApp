import 'dart:convert';

import 'package:flutter/material.dart';
import 'token_storage.dart'; // Import token storage
import 'auth_credentials.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key); // Add the Key parameter

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  String _generateAuthorizationUrl() {
    return '$instanceUrl/oauth/authorize'
        '?client_id=$clientId'
        '&response_type=code'
        '&redirect_uri=$redirectUri'
        '&scope=read write follow';
  }

  Future<void> _exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.parse('$instanceUrl/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];

      // Save the access token
      await TokenStorage.saveAccessToken(accessToken);

      setState(() {
        _isLoading = false;
      });

      // Navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print('Error: ${response.body}'); // Log the error
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to log in. Please try again.';
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Generate the authorization URL
    final authUrl = _generateAuthorizationUrl();
    print('Open this URL in your browser: $authUrl');

    // Simulate user manually entering the authorization code
    final code = await showDialog<String>(
      context: context,
      builder: (context) {
        String inputCode = '';
        return AlertDialog(
          title: const Text('Enter Authorization Code'),
          content: TextField(
            onChanged: (value) => inputCode = value,
            decoration: const InputDecoration(hintText: 'Authorization Code'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, inputCode),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (code != null && code.isNotEmpty) {
      await _exchangeCodeForToken(code);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authorization code is required.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login, // Call login logic
              child: const Text('Login with Mastodon'),
            ),
          ],
        ),
      ),
    );
  }
}

