import 'dart:async';

import 'package:flutter/material.dart';

class DebouncedSearchBar extends StatefulWidget {
  const DebouncedSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<DebouncedSearchBar> createState() => _DebouncedSearchBarState();
}

class _DebouncedSearchBarState extends State<DebouncedSearchBar> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      onChanged: (value) {
        _timer?.cancel();
        _timer = Timer(const Duration(milliseconds: 350), () {
          widget.onChanged(value);
        });
      },
    );
  }
}
