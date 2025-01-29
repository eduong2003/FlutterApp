import 'dart:convert';
import 'package:flut_project/Profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'FollowingPage.dart';
import 'token_storage.dart';
import 'auth_credentials.dart';
import 'UserProvider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          if (_userData?['avatar'] != null)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(_userData!['avatar']),
                radius: 30,
              ),
            ),
        ],
      ),
      body: const Center(
        child: Text('Homescreen'),
      ),
    );
  }
}
