import 'package:flutter/material.dart';

class SideItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool extended;

  const SideItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.extended,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? const Color(0xFF6366F1) : Colors.black54,
      ),
      title: extended ? Text(label) : null,
      selected: selected,
      onTap: onTap,
      selectedTileColor: const Color(0xFFEFF0FD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      dense: true,
    );
  }
}
