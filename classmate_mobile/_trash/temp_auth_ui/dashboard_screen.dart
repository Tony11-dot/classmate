import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../app/app.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.auth});
  final AuthController auth;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool? healthy;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      healthy = null;
      err = null;
    });

    try {
      final res = await ApiClient.instance.get('/health');
      final ok = (res.data is Map) ? (res.data['ok'] == true) : false;
      setState(() => healthy = ok);
    } catch (e) {
      setState(() {
        healthy = false;
        err = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = healthy == null
        ? 'Checking API...'
        : healthy == true
        ? 'API OK'
        : 'API not reachable';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () async => widget.auth.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text(err == null ? status : '$status\n$err')),
    );
  }
}
