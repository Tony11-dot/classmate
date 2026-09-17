import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'web_media.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String? title;

  PdfViewerScreen({
    super.key,
    required this.url,
    String? title,
    String? label,
  }) : title = (title ?? label)?.trim();

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    // Web: flutter_pdfview / path_provider have no web implementation
    // ("Missing Plugin"). The Syncfusion viewer renders straight from the
    // network URL on web, so skip the temp-file download entirely.
    if (kIsWeb) {
      setState(() => _loading = false);
      return;
    }
    try {
      final uri = Uri.parse(widget.url);
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/pdf_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
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
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  Future<void> _download() async {
    // Web: no temp file / share sheet — open the PDF URL in a new tab where
    // the browser's own viewer offers Save.
    if (await openMediaInBrowserOnWeb(widget.url)) return;
    // The PDF is already on disk in the temp dir (we wrote it in
    // _prepare). Hand it to the OS share sheet — that gives the user
    // "Save to Files", "Save to Drive", AirDrop, etc.
    if (_localPath == null) return;
    try {
      final box = context.findRenderObject() as RenderBox?;
      final fileName = (widget.title?.trim().isNotEmpty ?? false)
          ? '${widget.title!.trim()}.pdf'
          : 'document.pdf';
      // Copy to a stable name so the share sheet shows the right filename
      // instead of `pdf_1234567890.pdf`.
      final dir = await getTemporaryDirectory();
      final namedFile = File('${dir.path}/$fileName');
      await File(_localPath!).copy(namedFile.path);
      await Share.shareXFiles(
        [XFile(namedFile.path, mimeType: 'application/pdf')],
        subject: fileName,
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.commonDownloadFailed(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle =
        (widget.title == null || widget.title!.isEmpty) ? 'PDF' : widget.title!;

    // Fullscreen PDF viewer — no AppBar, no top bar. The PDF claims
    // the whole screen; two small floating buttons in the top-right
    // safe-area let the user close or open externally without
    // sacrificing any vertical space.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _loading
                ? const Center(child: CmLoading())
                : kIsWeb
                    // Web renders directly from the network URL — no native
                    // PDF plugin, no temp file.
                    ? SfPdfViewer.network(widget.url)
                    : (_localPath != null
                        ? PDFView(
                            filePath: _localPath!,
                            enableSwipe: true,
                            swipeHorizontal: false,
                            autoSpacing: true,
                            pageFling: true,
                            pageSnap: true,
                            fitPolicy: FitPolicy.BOTH,
                            preventLinkNavigation: false,
                          )
                        : _ErrorBody(
                            title: resolvedTitle,
                            error: _error,
                            onOpen: _openExternally,
                          )),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 6,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PdfFloatingButton(
                  icon: Icons.file_download_outlined,
                  tooltip: AppLocalizations.of(context)!.commonDownload,
                  // On web the download opens a new tab (no local file needed).
                  onTap: (kIsWeb || _localPath != null) ? _download : null,
                ),
                const SizedBox(width: 6),
                _PdfFloatingButton(
                  icon: Icons.open_in_new_rounded,
                  tooltip: AppLocalizations.of(context)!.commonOpenExternally,
                  onTap: _openExternally,
                ),
                const SizedBox(width: 6),
                _PdfFloatingButton(
                  icon: Icons.close_rounded,
                  tooltip: AppLocalizations.of(context)!.commonClose,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfFloatingButton extends StatelessWidget {
  const _PdfFloatingButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
        constraints: const BoxConstraints.tightFor(width: 38, height: 38),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.title,
    required this.error,
    required this.onOpen,
  });

  final String title;
  final String? error;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 48,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 56, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error ?? 'Unable to preview PDF.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l.mediaOpenExternally),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
