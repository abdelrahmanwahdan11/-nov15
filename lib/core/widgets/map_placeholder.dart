import 'package:flutter/material.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key, this.height = 220, this.borderRadius = 24});

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.1), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.location_pin, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
