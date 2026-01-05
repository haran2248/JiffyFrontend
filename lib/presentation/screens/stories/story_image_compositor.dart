import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/presentation/screens/stories/models/story_models.dart';

/// Helper class to composite text overlays onto an image
class StoryImageCompositor {
  /// Composites text overlays onto an image and returns the composited image file
  ///
  /// [imageFile] - The source image file
  /// [overlays] - List of text overlays to composite onto the image
  ///
  /// Returns a new File with the composited image, or the original file if no overlays
  static Future<File> compositeImage({
    required File imageFile,
    required List<TextOverlay> overlays,
  }) async {
    // If no overlays, return original image
    if (overlays.isEmpty) {
      return imageFile;
    }

    // Load the image
    final imageBytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // Create a picture recorder and canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw the original image
    canvas.drawImage(image, Offset.zero, Paint());

    // Draw each text overlay
    for (final overlay in overlays) {
      _drawTextOverlay(canvas, overlay, image.width, image.height);
    }

    // Convert the canvas to an image
    final picture = recorder.endRecording();
    final compositedImage = await picture.toImage(image.width, image.height);

    // Convert the image to bytes
    final byteData = await compositedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final compositedBytes = byteData!.buffer.asUint8List();

    // Dispose resources
    image.dispose();
    compositedImage.dispose();
    picture.dispose();

    // Write the composited image to a temporary file
    final tempFile = File('${imageFile.path}_composited.png');
    await tempFile.writeAsBytes(compositedBytes);

    return tempFile;
  }

  /// Draws a single text overlay on the canvas
  static void _drawTextOverlay(
    Canvas canvas,
    TextOverlay overlay,
    int imageWidth,
    int imageHeight,
  ) {
    // Convert percentage position (0-100) to pixel position
    final xPx = (imageWidth * overlay.x / 100.0);
    final yPx = (imageHeight * overlay.y / 100.0);

    // Create text style
    final textStyle = TextStyle(
      color: overlay.color,
      fontSize: overlay.fontSizePx,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          offset: const Offset(2, 2),
          blurRadius: 8,
          color: Colors.black.withValues(alpha: 0.8),
        ),
      ],
    );

    // Create text painter
    final textPainter = TextPainter(
      text: TextSpan(text: overlay.text, style: textStyle),
      textAlign: overlay.textAlign,
      textDirection: TextDirection.ltr,
    );

    // Layout the text
    textPainter.layout(
      maxWidth: imageWidth * 0.9, // Allow text to use 90% of image width
    );

    // Calculate position based on alignment
    // The x/y coordinates represent the center of the text
    double textX = xPx - textPainter.width / 2; // Center horizontally
    final textY = yPx - textPainter.height / 2; // Center vertically

    // Position is center of text, so adjust to top-left of text bounds
    final textPosition = Offset(textX, textY);

    // Draw the text
    textPainter.paint(canvas, textPosition);
  }
}

