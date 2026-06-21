import 'package:flutter/material.dart';
import '../theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ColoredBox(color: AppTheme.bg, child: SizedBox.expand()),
        Positioned(
          left: 0,
          right: 0,
          top: -80,
          child: Container(
            height: 480,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.0,
                colors: [AppTheme.bgTint, AppTheme.bg.withOpacity(0)],
                stops: const [0.0, 0.58],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
