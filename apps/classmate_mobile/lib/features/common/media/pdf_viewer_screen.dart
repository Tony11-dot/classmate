import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  final String? title;

  const PdfViewerScreen({
    super.key,
    required this.url,
    String? title,
    String? label,
  }) : title = (title ?? label);

  @override
  Widget build(BuildContext context) {
    final resolvedTitle =
        (title == null || title!.trim().isEmpty) ? 'PDF' : title!.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          resolvedTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SfPdfViewer.network(
        url,
        canShowPaginationDialog: true,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
      ),
    );
  }
}
