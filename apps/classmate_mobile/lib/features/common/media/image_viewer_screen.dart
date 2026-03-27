import 'package:flutter/material.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final String? title;

  const ImageViewerScreen({
    super.key,
    String? imageUrl,
    String? url,
    String? title,
    String? label,
    this.heroTag,
  })  : imageUrl = (imageUrl ?? url ?? '').trim(),
        title = (title ?? label)?.trim();

  @override
  Widget build(BuildContext context) {
    final resolvedTitle =
        (title == null || title!.isEmpty) ? 'Image' : title!;

    final image = InteractiveViewer(
      child: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Center(child: Text('Unable to load image')),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(resolvedTitle)),
      body: heroTag == null ? image : Hero(tag: heroTag!, child: image),
    );
  }
}
