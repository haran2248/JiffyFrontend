import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/presentation/screens/stories/models/story_models.dart';
import 'package:path_provider/path_provider.dart';

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
      debugPrint('[StoryImageCompositor] No overlays, returning original image');
      return imageFile;
    }

    debugPrint('[StoryImageCompositor] Starting compositing with ${overlays.length} overlay(s)');

    // Load the image
    final imageBytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    debugPrint('[StoryImageCompositor] Image loaded: ${image.width}x${image.height}');

    try {
      // Create a picture recorder and canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw the original image
      canvas.drawImage(image, Offset.zero, Paint());

      // Draw each text overlay
      for (final overlay in overlays) {
        debugPrint('[StoryImageCompositor] Drawing overlay: "${overlay.text}" at (${overlay.x}, ${overlay.y})');
        _drawTextOverlay(canvas, overlay, image.width, image.height);
      }

      // Convert the canvas to an image
      final picture = recorder.endRecording();
      final compositedImage = await picture.toImage(image.width, image.height);

      try {
        // Convert the image to bytes
        final byteData = await compositedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData == null) {
          throw Exception('Failed to encode composited image to PNG');
        }

        final compositedBytes = byteData.buffer.asUint8List();

        // Write the composited image to a temporary file
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/composited_story_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(compositedBytes);
        debugPrint('[StoryImageCompositor] Composited image saved to: ${tempFile.path} (${compositedBytes.length} bytes)');

        return tempFile;
      } finally {
        // Dispose composited image resources
        compositedImage.dispose();
        picture.dispose();
      }
    } finally {
      // Dispose original image resources
      image.dispose();
      codec.dispose();
    }
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

    debugPrint('[StoryImageCompositor] Drawing text "${overlay.text}" at percentage (${overlay.x}, ${overlay.y}), pixel (${xPx.toStringAsFixed(1)}, ${yPx.toStringAsFixed(1)})');

    // Create text style (no shadows by default)
    final textStyle = ui.TextStyle(
      color: overlay.color,
      fontSize: overlay.fontSizePx,
      fontWeight: ui.FontWeight.bold,
    );

    // Convert TextAlign to ui.TextAlign
    ui.TextAlign uiTextAlign;
    switch (overlay.textAlign) {
      case TextAlign.left:
        uiTextAlign = ui.TextAlign.left;
        break;
      case TextAlign.center:
        uiTextAlign = ui.TextAlign.center;
        break;
      case TextAlign.right:
        uiTextAlign = ui.TextAlign.right;
        break;
      default:
        uiTextAlign = ui.TextAlign.center;
    }

    // Create paragraph builder for text rendering
    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: uiTextAlign,
        textDirection: ui.TextDirection.ltr,
      ),
    );
    paragraphBuilder.pushStyle(textStyle);
    paragraphBuilder.addText(overlay.text);
    paragraphBuilder.pop();

    // Build and layout the paragraph
    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: imageWidth * 0.9));

    debugPrint('[StoryImageCompositor] Text size: ${paragraph.width.toStringAsFixed(1)}x${paragraph.height.toStringAsFixed(1)}');

    // Calculate position based on alignment
    // The x/y coordinates represent the center of the text
    double textX = xPx - paragraph.width / 2; // Center horizontally
    double textY = yPx - paragraph.height / 2; // Center vertically

    debugPrint('[StoryImageCompositor] Text center position: (${textX.toStringAsFixed(1)}, ${textY.toStringAsFixed(1)})');

    // Clamp text position to ensure it stays within image bounds
    final originalX = textX;
    final originalY = textY;
    textX = textX.clamp(0.0, imageWidth - paragraph.width);
    textY = textY.clamp(0.0, imageHeight - paragraph.height);

    if (textX != originalX || textY != originalY) {
      debugPrint('[StoryImageCompositor] Text position clamped from (${originalX.toStringAsFixed(1)}, ${originalY.toStringAsFixed(1)}) to (${textX.toStringAsFixed(1)}, ${textY.toStringAsFixed(1)})');
    }

    // Position is top-left of text bounds
    final textPosition = Offset(textX, textY);

    debugPrint('[StoryImageCompositor] Final text position: (${textX.toStringAsFixed(1)}, ${textY.toStringAsFixed(1)}), color: ${overlay.color}');

    // Draw the paragraph
    canvas.drawParagraph(paragraph, textPosition);
  }
}

