import 'package:flutter/material.dart';

import 'skeleton_box.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 4, this.height = 80});

  final int itemCount;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SkeletonBox(height: height),
        ),
      ),
    );
  }
}
