import 'dart:ui';
import 'package:flutter/material.dart';

class CorkBoardBackground extends StatelessWidget {
  const CorkBoardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cork Board Texture
        Image.network(
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to brown gradient
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF8B6F47),
                    Color(0xFFA0826D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),
        
        // Strong Blur Effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            color: Colors.black.withOpacity(0.25),
          ),
        ),
      ],
    );
  }
}
