import 'package:flutter/material.dart';
import '../theme.dart';

class CertifyToggle extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;

  const CertifyToggle({required this.value, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: value ? AppTheme.accent : Colors.white.withOpacity(0.12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.ink,
            ),
          ),
        ),
      ),
    );
  }
}
