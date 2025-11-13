import 'package:flutter/material.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.options,
    required this.active,
    required this.onSelected,
  });

  final List<String> options;
  final String? active;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((option) {
        final isSelected = option == active;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (value) => onSelected(value ? option : null),
        );
      }).toList(),
    );
  }
}
