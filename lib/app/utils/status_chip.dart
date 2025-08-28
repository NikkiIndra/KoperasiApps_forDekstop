// status_chip.dart
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String text;

  const StatusChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // Gunakan nilai lowercase untuk konsistensi pengecekan
    final status = text.toLowerCase();

    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'active':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        displayText = 'Aktif';
        break;
      case 'inactive':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        displayText = 'Non-Aktif';
        break;
      case 'blocked':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        displayText = 'Diblokir';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        displayText = text; // Tampilkan teks asli jika tidak dikenal
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
