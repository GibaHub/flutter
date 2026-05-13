import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/theme/app_colors.dart';

class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final pdfUrl = url;
    return Scaffold(
      appBar: AppBar(title: const Text('PDF')),
      body: pdfUrl == null || pdfUrl.isEmpty
          ? Center(
              child: Text(
                'URL do PDF ausente',
                style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.7)),
              ),
            )
          : SfPdfViewer.network(pdfUrl),
    );
  }
}

