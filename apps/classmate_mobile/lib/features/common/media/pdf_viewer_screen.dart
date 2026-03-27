import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  final String? title;

  const PdfViewerScreen({
    super.key,
    required this.url,
    String? title,
    String? label,
  }) : title = (title ?? label)?.trim();

  Future<void> _open() async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle =
        (title == null || title!.isEmpty) ? 'PDF' : title!;

    return Scaffold(
      appBar: AppBar(title: Text(resolvedTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.picture_as_pdf_outlined, size: 56),
              const SizedBox(height: 16),
              Text(
                resolvedTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                url,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _open,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
