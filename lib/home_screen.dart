import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'token_storage.dart';
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
  
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          if (_userData?['avatar'] != null)
            GestureDetector(
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
