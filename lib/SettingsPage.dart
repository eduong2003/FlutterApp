import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'token_storage.dart';
import 'auth_credentials.dart';
import 'UserProvider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No access token is found.';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$instanceUrl/api/v1/accounts/verify_credentials'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {

        final userData = jsonDecode(response.body);

        Provider.of<UserProvider>(context, listen: false).setUserData(userData);

        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch user data. (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occured. Please try again';
      });
    }
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _buildUserInfo(),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_userData?['avatar'] != null)
          CircleAvatar(
            backgroundImage: NetworkImage(_userData!['avatar']),
            radius: 50,
          ),
        const SizedBox(height: 16),
        Text(
          _userData?['username'] ?? 'User name not available',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          _userData?['display_name'] ?? '',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Text(
          _userData?['note'] ?? 'No bio available',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Account created on: ${_userData?['created_at'] ?? 'N/A'}',
          style: const TextStyle(color: Colors.grey),
        ),
         Text(
           'Following: ${_userData?['following_count'] ?? '0'}',
           style: const TextStyle(color: Colors.grey),
         ),
      ],
    );
  }
}
