
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Login.dart';
import 'home_screen.dart'; // Import HomePage from the correct file
import 'package:flut_project/UserProvider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => UserProvider(),
        child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
      '/': (context) =>LoginPage(), // 👈 add this
        '/home': (context) => const HomePage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(child: Text('404: Page Not Found')),
          ),
        );
      },
    );
  }
}
