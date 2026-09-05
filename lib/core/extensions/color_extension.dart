import 'package:flutter/material.dart';

/// Color Extensions
extension ColorExtension on Color {
  /// Get color with opacity (non-deprecated way)
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity);
  }
}
