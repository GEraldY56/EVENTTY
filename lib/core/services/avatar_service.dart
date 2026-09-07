import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Avatar Service
/// Generate AI-powered avatars using DiceBear API (free, no API key needed)
/// https://www.dicebear.com/
class AvatarService {
  // Singleton pattern
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  // Available avatar styles
  static const List<String> _avatarStyles = [
    'adventurer',      // Cartoon style with accessories
    'adventurer-neutral', // Neutral cartoon
    'avataaars',       // Popular style like Avataaars
    'big-ears',        // Cute big ears style
    'big-ears-neutral', // Neutral big ears
    'bottts',          // Robot/bot style
    'croodles',        // Doodle style
    'fun-emoji',       // Fun emoji faces
    'icons',           // Simple icon style
    'identicon',       // Geometric patterns
    'lorelei',         // Female characters
    'micah',           // Illustrated faces
    'miniavs',         // Minimalist avatars
    'open-peeps',      // Hand-drawn style
    'personas',        // Business personas
    'pixel-art',       // 8-bit pixel art
    'shapes',          // Abstract shapes
  ];

  // Default style for EVENTTY
  static const String _defaultStyle = 'adventurer';

  /// Generate avatar URL based on seed (usually username or user ID)
  String generateAvatarUrl({
    required String seed,
    String? style,
    int size = 200,
  }) {
    final selectedStyle = style ?? _defaultStyle;
    
    // DiceBear API v7 format
    // https://api.dicebear.com/7.x/{style}/svg?seed={seed}&size={size}
    return 'https://api.dicebear.com/7.x/$selectedStyle/svg?seed=${Uri.encodeComponent(seed)}&size=$size';
  }

  /// Generate avatar URL with specific background color
  String generateAvatarUrlWithBackground({
    required String seed,
    String? style,
    String? backgroundColor, // hex color without #
    int size = 200,
  }) {
    final selectedStyle = style ?? _defaultStyle;
    final bg = backgroundColor ?? 'b6e3f4';
    
    return 'https://api.dicebear.com/7.x/$selectedStyle/svg?seed=${Uri.encodeComponent(seed)}&size=$size&backgroundColor=$bg';
  }

  /// Generate consistent avatar style based on user ID
  /// Same user will always get same style (deterministic)
  String generateConsistentAvatarUrl({
    required String userId,
    required String userName,
    int size = 200,
  }) {
    // Use user ID to generate consistent style index
    final hash = md5.convert(utf8.encode(userId)).toString();
    final styleIndex = int.parse(hash.substring(0, 8), radix: 16) % _avatarStyles.length;
    final style = _avatarStyles[styleIndex];
    
    // Use userName as seed for avatar generation
    return generateAvatarUrl(
      seed: userName,
      style: style,
      size: size,
    );
  }

  /// Get random avatar style
  String getRandomStyle() {
    final random = Random();
    return _avatarStyles[random.nextInt(_avatarStyles.length)];
  }

  /// Get all available styles
  List<String> getAllStyles() {
    return List.from(_avatarStyles);
  }

  /// Generate multiple avatar options for user to choose
  List<String> generateAvatarOptions({
    required String seed,
    int count = 6,
  }) {
    final options = <String>[];
    final random = Random(seed.hashCode); // Deterministic random
    
    // Select random styles
    final selectedStyles = <String>[];
    while (selectedStyles.length < count && selectedStyles.length < _avatarStyles.length) {
      final style = _avatarStyles[random.nextInt(_avatarStyles.length)];
      if (!selectedStyles.contains(style)) {
        selectedStyles.add(style);
      }
    }
    
    // Generate URLs
    for (final style in selectedStyles) {
      options.add(generateAvatarUrl(seed: seed, style: style));
    }
    
    return options;
  }

  /// Preview URL for testing
  String getPreviewUrl(String style, String seed) {
    return 'https://api.dicebear.com/7.x/$style/svg?seed=${Uri.encodeComponent(seed)}&size=200';
  }
}
