import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../ui/widgets/cm_loading.dart';

/// Opens a bagrut file. On web (where flutter_pdfview is unsupported) the file
/// opens in a new browser tab; on mobile PDFs render inline and images open in
/// a zoomable viewer.
Future<void> openBagrutFile(
  BuildContext context, {
  required String url,
  required String title,
  required bool isPdf,
}) async {
  if (kIsWeb) {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _BagrutFileScreen(url: url, title: title, isPdf: isPdf),
    ),
  );
}

class _BagrutFileScreen extends StatefulWidget {
  const _BagrutFileScreen({required this.url, required this.title, required this.isPdf});

  final String url;
  final String title;
  final bool isPdf;

  @override
  State<_BagrutFileScreen> createState() => _BagrutFileScreenState();
}

class _BagrutFileScreenState extends State<_BagrutFileScreen> {
  String? _localPath;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.isPdf) {
      _download();
    } else {
      _loading = false;
    }
  }

  Future<void> _download() async {
    try {
      final res = await http.get(Uri.parse(widget.url)).timeout(const Duration(seconds: 30));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}');
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bagrut_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(res.bodyBytes, flush: true);
      if (!mounted) return;
      setState(() {
        _localPath = file.path;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: _openExternally,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CmLoading(color: Colors.white));

    if (!widget.isPdf) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 5,
        child: Center(
          child: Image.network(
            widget.url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _errorView(),
          ),
        ),
      );
    }

    if (_localPath != null) {
      return PDFView(
        filePath: _localPath!,
        enableSwipe: true,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        fitPolicy: FitPolicy.BOTH,
      );
    }

    return _errorView();
  }

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.picture_as_pdf_rounded, color: Colors.white54, size: 64),
              const SizedBox(height: 12),
              // Never surface the raw exception — a friendly line + the
              // open-externally fallback is all the user needs.
              Text(
                _error == null
                    ? 'Unable to preview this file.'
                    : 'Unable to preview this file. Check your connection and try again.',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _openExternally,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open externally'),
              ),
            ],
          ),
        ),
      );
}
