import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/env.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        appBar: AppBar(title: const Text('Classmate Pilot')),
        body: FutureBuilder<http.Response>(
          future: http.get(Uri.parse('${Env.apiBaseUrl}/api/health')),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            return Center(child: Text(snap.data?.body ?? 'No response'));
          },
        ),
      ),
    );
  }
}
