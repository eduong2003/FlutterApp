import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key); // Add `const` here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: (){
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: (){
              Navigator.pushNamed(context, '/following');
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Homescreen'),
      ),
    );
  }
}
