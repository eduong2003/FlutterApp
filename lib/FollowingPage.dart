import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'token_storage.dart';
import 'auth_credentials.dart';
import 'UserProvider.dart';
import 'package:provider/provider.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({Key? key}) : super(key: key);

  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<Map<String, dynamic>>? _following;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Get authenticated user's data
      final userResponse = await http.get(
        Uri.parse('$instanceUrl/api/v1/accounts/verify_credentials'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);

        // Get the following list using user's id
        final followingResponse = await http.get(
          Uri.parse('$instanceUrl/api/v1/accounts/${userData['id']}/following'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (followingResponse.statusCode == 200) {
          final followingData = jsonDecode(followingResponse.body) as List;

          setState(() {
            _following = followingData.map((user) => user as Map<String, dynamic>).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _following == null || _following!.isEmpty
          ? const Center(child: Text('No users found.'))
          : SingleChildScrollView(
        child: _buildFollowingList(),
      ),
    );
  }



  Widget _buildFollowingList() {
    return Column(
      children: _following?.map<Widget>((user) {
        return Row(
          children: [
            if (user['avatar'] != null)
              CircleAvatar(
                backgroundImage: NetworkImage(user['avatar']),
                radius: 50,
              ),
            const SizedBox(height: 16),
            if(user['username'] != null)
              Text(
                user['username'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16)
          ],
        );
      }).toList() ?? [],
    );
  }


}
