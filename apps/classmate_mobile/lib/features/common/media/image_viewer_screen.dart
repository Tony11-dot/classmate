import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final String? title;

  ImageViewerScreen({
    super.key,
    String? imageUrl,
    String? url,
    String? title,
    String? label,
    this.heroTag,
  })  : imageUrl = (imageUrl ?? url ?? '').trim(),
        title = (title ?? label)?.trim();

  Future<void> _download(BuildContext context) async {
    if (imageUrl.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final box = context.findRenderObject() as RenderBox?;
      String localPath;
      if (_isLocal(imageUrl)) {
        localPath = imageUrl.startsWith('file://')
            ? Uri.parse(imageUrl).toFilePath()
            : imageUrl;
      } else {
        // Fetch the network image to a temp file so the share sheet
        // can hand it to Photos / Files / etc.
        final uri = Uri.parse(imageUrl);
        final res = await http.get(uri).timeout(const Duration(seconds: 20));
        if (res.statusCode < 200 || res.statusCode >= 300) {
          throw Exception('HTTP ${res.statusCode}');
        }
        final dir = await getTemporaryDirectory();
        final fileName = (title?.trim().isNotEmpty ?? false)
            ? title!.trim()
            : 'image_${DateTime.now().millisecondsSinceEpoch}';
        // Best-effort extension from URL path
        final urlPath = uri.path.toLowerCase();
        final ext = urlPath.endsWith('.png')
            ? '.png'
            : urlPath.endsWith('.gif')
                ? '.gif'
                : urlPath.endsWith('.webp')
                    ? '.webp'
                    : '.jpg';
        final f = File('${dir.path}/$fileName$ext');
        await f.writeAsBytes(res.bodyBytes, flush: true);
        localPath = f.path;
      }
      await Share.shareXFiles(
        [XFile(localPath)],
        subject: title ?? 'Image',
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  static bool _isLocal(String url) {
    if (url.startsWith('file://')) return true;
    if (!url.startsWith('/')) return false;
    return url.startsWith('/private/') ||
        url.startsWith('/var/') ||
        url.startsWith('/tmp/') ||
        url.startsWith('/Users/');
  }

  Widget _image(BuildContext context) {
    final url = imageUrl;
    if (_isLocal(url)) {
      final path = url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
      return InteractiveViewer(
        child: Center(
          child: Image.file(
            File(path),
            fit: BoxFit.contain,
            errorBuilder: (context, e, _) =>
                Center(child: Text(AppLocalizations.of(context)!.mediaUnableToLoad)),
          ),
        ),
      );
    }
    return InteractiveViewer(
      child: Center(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (ctx, url) => const Center(child: CircularProgressIndicator(color: Colors.white54)),
          errorWidget: (ctx, url, err) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image_outlined, size: 48, color: Colors.white54),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(ctx)!.mediaUnableToLoad, style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = (title == null || title!.isEmpty) ? 'Image' : title!;
    final imageWidget = _image(context);
    final isNetwork = !_isLocal(imageUrl) && imageUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(resolvedTitle, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'Download',
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            onPressed: () => _download(context),
          ),
          if (isNetwork)
            IconButton(
              tooltip: AppLocalizations.of(context)!.mediaOpenExternally,
              icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
              onPressed: () async {
                final uri = Uri.tryParse(imageUrl);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
      body: heroTag == null ? imageWidget : Hero(tag: heroTag!, child: imageWidget),
    );
  }
}
