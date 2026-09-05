import 'package:flutter/material.dart';
import '../../../../../core/constants/text_styles.dart';

class StickyNote extends StatelessWidget {
  final String text;
  final Color color;
  final double rotation;
  final Widget? child;

  const StickyNote({
    super.key,
    required this.text,
    this.color = const Color(0xFFFFF9C4),
    this.rotation = 0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * 3.14159 / 180, // degrees to radians
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child ??
            Text(
              text,
              style: AppTextStyles.body2.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
      ),
    );
  }
}
