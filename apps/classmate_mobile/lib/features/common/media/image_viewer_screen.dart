import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
                const Center(child: Text('Unable to load image')),
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
          errorWidget: (ctx, url, err) => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image_outlined, size: 48, color: Colors.white54),
                SizedBox(height: 8),
                Text('Unable to load image', style: TextStyle(color: Colors.white54)),
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
        backgroundColor: Colors.black.withValues(alpha: 0.75),
        foregroundColor: Colors.white,
        title: Text(resolvedTitle, style: const TextStyle(color: Colors.white)),
        actions: [
          if (isNetwork)
            IconButton(
              tooltip: 'Open externally',
              icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
              onPressed: () async {
                final uri = Uri.tryParse(imageUrl);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () async {
              if (isNetwork) {
                final uri = Uri.tryParse(imageUrl);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
        ],
      ),
      body: heroTag == null ? imageWidget : Hero(tag: heroTag!, child: imageWidget),
    );
  }
}
