import 'package:flutter/material.dart';

class AnimatedImageOverlayCard extends StatefulWidget {
  const AnimatedImageOverlayCard({
    super.key,
    required this.imageUrl,
    required this.front,
    required this.back,
  });

  final String imageUrl;
  final Widget front;
  final Widget back;

  @override
  State<AnimatedImageOverlayCard> createState() => _AnimatedImageOverlayCardState();
}

class _AnimatedImageOverlayCardState extends State<AnimatedImageOverlayCard>
    with SingleTickerProviderStateMixin {
  bool _showFront = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFront = !_showFront;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          final rotate = Tween(begin: 1.0, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final angle = (1 - rotate.value) * 3.1416;
              return Transform(
                transform: Matrix4.rotationY(angle),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: _showFront
            ? _FrontSide(key: const ValueKey('front'), imageUrl: widget.imageUrl, child: widget.front)
            : _BackSide(key: const ValueKey('back'), child: widget.back),
      ),
    );
  }
}

class _FrontSide extends StatelessWidget {
  const _FrontSide({super.key, required this.imageUrl, required this.child});

  final String imageUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: 200),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: child,
        ),
      ],
    );
  }
}

class _BackSide extends StatelessWidget {
  const _BackSide({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
