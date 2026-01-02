# Photo Upload Service Usage Guide

The `PhotoUploadService` provides a centralized way to handle photo uploads, image picking and cropping throughout the app.

## Features

- ✅ Pick images from gallery
- ✅ Crop images to uniform sizes
- ✅ Comprehensive debug logging
- ✅ Permission handling
- ✅ Configurable aspect ratios and sizes

## Basic Usage

### 1. Access the Service

In a ViewModel or Widget with Riverpod:

```dart
import 'package:jiffy/core/services/service_providers.dart';

// In a ViewModel
@riverpod
class MyViewModel extends _$MyViewModel {
  PhotoUploadService get _photoUploadService => 
      ref.read(photoUploadServiceProvider);
  
  // ... rest of viewmodel
}

// In a Widget (ConsumerWidget)
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUploadService = ref.read(photoUploadServiceProvider);
    // ... use photoUploadService
  }
}
```

### 2. Pick and Crop Image (Most Common)

```dart
// Pick and crop to square (default)
final imageFile = await photoUploadService.pickAndCropImage();

// Pick and crop to 3:4 aspect ratio (portrait)
final imageFile = await photoUploadService.pickAndCropImage(
  aspectRatio: ImageSizeConfig.mainPhotoAspectRatio,
  width: ImageSizeConfig.mainPhotoWidth,
  height: ImageSizeConfig.mainPhotoHeight,
);

// Pick and crop to custom size
final imageFile = await photoUploadService.pickAndCropImage(
  aspectRatio: 1.0, // Square
  width: 800,
  height: 800,
);
```

### 3. Pick Image Without Cropping

```dart
final imageFile = await photoUploadService.pickImageFromGallery();
```

### 4. Crop an Existing Image

```dart
final existingFile = File('/path/to/image.jpg');
final croppedFile = await photoUploadService.cropImage(
  imageFile: existingFile,
  aspectRatio: ImageSizeConfig.profilePhotoAspectRatio,
  width: ImageSizeConfig.profilePhotoSize,
  height: ImageSizeConfig.profilePhotoSize,
);
```

### 5. Check Permissions

```dart
final hasPermission = await photoUploadService.hasPhotoLibraryPermission();
if (!hasPermission) {
  // Show permission request dialog
}
```

## Standard Image Sizes

Use `ImageSizeConfig` for consistent image sizes:

```dart
import 'package:jiffy/core/config/image_size_config.dart';

// Profile photo (square)
ImageSizeConfig.profilePhotoSize // 800x800

// Main photo (3:4 portrait)
ImageSizeConfig.mainPhotoWidth  // 1080
ImageSizeConfig.mainPhotoHeight // 1440
ImageSizeConfig.mainPhotoAspectRatio // 0.75 (3/4)

// Thumbnail
ImageSizeConfig.thumbnailSize // 200x200
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/services/service_providers.dart';
import 'package:jiffy/core/config/image_size_config.dart';
import 'dart:io';

class PhotoUploadButton extends ConsumerWidget {
  final Function(File) onImageSelected;

  const PhotoUploadButton({
    super.key,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUploadService = ref.read(photoUploadServiceProvider);

    return ElevatedButton(
      onPressed: () async {
        final imageFile = await photoUploadService.pickAndCropImage(
          aspectRatio: ImageSizeConfig.profilePhotoAspectRatio,
          width: ImageSizeConfig.profilePhotoSize,
          height: ImageSizeConfig.profilePhotoSize,
        );

        if (imageFile != null) {
          onImageSelected(imageFile);
        } else {
          // User cancelled or error occurred
          // Check debug logs for details
        }
      },
      child: const Text('Upload Photo'),
    );
  }
}
```

## Debug Logging

The service provides comprehensive debug logging. All operations are logged with the prefix `[PhotoUploadService]`:

- Permission requests
- Image selection
- File sizes
- Crop operations
- Errors with stack traces

Check your debug console for detailed information about each operation.

## Error Handling

The service returns `null` in these cases:
- User cancels image selection
- User cancels cropping
- Permission denied
- Any error during the process

Always check for `null` before using the returned file:

```dart
final imageFile = await photoUploadService.pickAndCropImage();
if (imageFile != null) {
  // Use the image file
  // Upload to server, display in UI, etc.
} else {
  // Handle cancellation or error
  // Check debug logs for details
}
```

## Notes

- Images are automatically compressed to 85% quality
- The service handles permissions automatically
- All operations are logged for debugging
- Uniform image sizes ensure consistent UI appearance

