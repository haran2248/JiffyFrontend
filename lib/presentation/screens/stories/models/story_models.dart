import 'package:flutter/material.dart';

/// Text alignment options for overlays
enum TextOverlayAlignment {
  left,
  center,
  right,
}

/// Font size options for overlays
enum TextOverlayFontSize {
  small, // 16px
  medium, // 24px
  large, // 32px
}

/// Represents a text overlay on a story
class TextOverlay {
  final String id;
  final String text;
  final double x; // X position as percentage (0-100)
  final double y; // Y position as percentage (0-100)
  final Color color; // Text color
  final TextOverlayAlignment alignment; // Text alignment
  final TextOverlayFontSize fontSize; // Font size category

  const TextOverlay({
    required this.id,
    required this.text,
    required this.x,
    required this.y,
    required this.color,
    this.alignment = TextOverlayAlignment.center,
    this.fontSize = TextOverlayFontSize.medium,
  });

  TextOverlay copyWith({
    String? id,
    String? text,
    double? x,
    double? y,
    Color? color,
    TextOverlayAlignment? alignment,
    TextOverlayFontSize? fontSize,
  }) {
    return TextOverlay(
      id: id ?? this.id,
      text: text ?? this.text,
      x: x ?? this.x,
      y: y ?? this.y,
      color: color ?? this.color,
      alignment: alignment ?? this.alignment,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  /// Get font size in pixels
  double get fontSizePx {
    switch (fontSize) {
      case TextOverlayFontSize.small:
        return 16.0;
      case TextOverlayFontSize.medium:
        return 24.0;
      case TextOverlayFontSize.large:
        return 32.0;
    }
  }

  /// Get text align from alignment enum
  TextAlign get textAlign {
    switch (alignment) {
      case TextOverlayAlignment.left:
        return TextAlign.left;
      case TextOverlayAlignment.center:
        return TextAlign.center;
      case TextOverlayAlignment.right:
        return TextAlign.right;
    }
  }
}

/// Represents a single story content item (photo + text overlays)
class StoryContent {
  final String id;
  final String imageUrl; // URL or file path
  final List<TextOverlay> overlays; // Array of text overlays
  final DateTime createdAt;
  final bool isLocal; // If true, imageUrl is a local file path

  const StoryContent({
    required this.id,
    required this.imageUrl,
    this.overlays = const [],
    required this.createdAt,
    this.isLocal = false,
  });

  StoryContent copyWith({
    String? id,
    String? imageUrl,
    List<TextOverlay>? overlays,
    DateTime? createdAt,
    bool? isLocal,
  }) {
    return StoryContent(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      overlays: overlays ?? this.overlays,
      createdAt: createdAt ?? this.createdAt,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  // Legacy support: check if has any text overlay (for backward compatibility)
  bool get hasTextOverlay => overlays.isNotEmpty;
  
  // Legacy support: get first overlay text if exists
  String? get firstOverlayText => overlays.isNotEmpty ? overlays.first.text : null;
}

/// Represents a complete story for a user
class Story {
  final String id;
  final String userId;
  final String? userName;
  final String? userImageUrl;
  final List<StoryContent> contents;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const Story({
    required this.id,
    required this.userId,
    this.userName,
    this.userImageUrl,
    required this.contents,
    required this.createdAt,
    this.expiresAt,
  });

  Story copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImageUrl,
    List<StoryContent>? contents,
    DateTime? createdAt,
    DateTime? Function()? expiresAt,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      contents: contents ?? this.contents,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt != null ? expiresAt() : this.expiresAt,
    );
  }

  /// Check if story has any content
  bool get hasContent => contents.isNotEmpty;

  /// Get the first content item
  StoryContent? get firstContent => contents.isNotEmpty ? contents.first : null;
}

