import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> GeneratePlaceholderPdf(String title, int year) async {
  final pdf = pw.Document();
  final now = DateTime.now();
  final fmt = DateFormat('dd MMM yyyy HH:mm');
  pdf.addPage(
    pw.Page(
      build: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.all(36),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Tahun: $year'),
            pw.SizedBox(height: 24),
            pw.Text('Dokumen placeholder untuk demonstrasi aplikasi koperasi.'),
            pw.Spacer(),
            pw.Text('Generated: ${fmt.format(now)}'),
          ],
        ),
      ),
    ),
  );
  return Uint8List.fromList(await pdf.save());
}
