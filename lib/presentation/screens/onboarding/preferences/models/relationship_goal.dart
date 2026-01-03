import 'package:flutter/material.dart';

enum RelationshipGoal {
  longTerm(
    'Long-term relationship',
    'Ready to find something real and meaningful',
    '💖',
    Color(0xFFFF2D55),
  ),
  casual(
    'Casual dating',
    'Keeping it fun and low-key for now',
    '☕',
    Color(0xFF8B5CF6),
  ),
  figuringItOut(
    'Still figuring it out',
    'Exploring what feels right for me',
    '🧭',
    Color(0xFFF59E0B),
  ),
  intimacy(
    'Intimacy without commitment',
    'Looking for physical connection, no strings',
    '🔥',
    Color(0xFFFF453A),
  );

  final String title;
  final String subtitle;
  final String emoji;
  final Color color;

  const RelationshipGoal(this.title, this.subtitle, this.emoji, this.color);
}
