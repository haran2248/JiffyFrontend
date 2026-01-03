import "dart:io";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:image_cropper/image_cropper.dart";
import "package:permission_handler/permission_handler.dart";
import "../config/image_size_config.dart";

/// Central service for handling photo uploads, image picking, cropping, and processing
///
/// This service provides:
/// - Gallery photo selection
/// - Image cropping with uniform sizes
/// - Permission handling
/// - Comprehensive debug logging
class PhotoUploadService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Picks an image from the gallery, crops it, and returns the file
  ///
  /// [aspectRatio] - Desired aspect ratio (default: 1.0 for square)
  /// [width] - Desired width in pixels (default: profilePhotoSize)
  /// [height] - Desired height in pixels (default: profilePhotoSize)
  ///
  /// Returns the cropped image file, or null if cancelled or error
  Future<File?> pickAndCropImage({
    double aspectRatio = ImageSizeConfig.profilePhotoAspectRatio,
    int? width,
    int? height,
  }) async {
    debugPrint("[PhotoUploadService] Starting image pick and crop process");
    debugPrint("[PhotoUploadService] Aspect ratio: $aspectRatio");
    debugPrint(
        "[PhotoUploadService] Target size: ${width ?? ImageSizeConfig.profilePhotoSize}x${height ?? ImageSizeConfig.profilePhotoSize}");

    try {
      // Step 1: Check and request permissions
      final hasPermission = await _requestPhotoLibraryPermission();
      if (!hasPermission) {
        debugPrint("[PhotoUploadService] Permission denied by user");
        return null;
      }

      // Step 2: Pick image from gallery
      debugPrint("[PhotoUploadService] Opening gallery picker");
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: ImageSizeConfig.compressionQuality,
      );

      if (pickedFile == null) {
        debugPrint("[PhotoUploadService] User cancelled image selection");
        return null;
      }

      debugPrint("[PhotoUploadService] Image selected: ${pickedFile.path}");
      debugPrint(
          "[PhotoUploadService] Image size: ${await File(pickedFile.path).length()} bytes");

      // Step 3: Crop the image
      final croppedFile = await _cropImage(
        File(pickedFile.path),
        aspectRatio: aspectRatio,
        width: width,
        height: height,
      );

      if (croppedFile == null) {
        debugPrint("[PhotoUploadService] User cancelled cropping");
        return null;
      }

      debugPrint(
          "[PhotoUploadService] Image cropped successfully: ${croppedFile.path}");
      debugPrint(
          "[PhotoUploadService] Cropped image size: ${await croppedFile.length()} bytes");

      return croppedFile;
    } catch (e, stackTrace) {
      debugPrint("[PhotoUploadService] Error during image pick/crop: $e");
      debugPrint("[PhotoUploadService] Stack trace: $stackTrace");
      return null;
    }
  }

  /// Picks an image from gallery without cropping
  ///
  /// Returns the selected image file, or null if cancelled or error
  Future<File?> pickImageFromGallery() async {
    debugPrint("[PhotoUploadService] Starting gallery image pick (no crop)");

    try {
      final hasPermission = await _requestPhotoLibraryPermission();
      if (!hasPermission) {
        debugPrint("[PhotoUploadService] Permission denied by user");
        return null;
      }

      debugPrint("[PhotoUploadService] Opening gallery picker");
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: ImageSizeConfig.compressionQuality,
      );

      if (pickedFile == null) {
        debugPrint("[PhotoUploadService] User cancelled image selection");
        return null;
      }

      debugPrint("[PhotoUploadService] Image selected: ${pickedFile.path}");
      debugPrint(
          "[PhotoUploadService] Image size: ${await File(pickedFile.path).length()} bytes");

      return File(pickedFile.path);
    } catch (e, stackTrace) {
      debugPrint("[PhotoUploadService] Error during image pick: $e");
      debugPrint("[PhotoUploadService] Stack trace: $stackTrace");
      return null;
    }
  }

  /// Crops an existing image file
  ///
  /// [imageFile] - The image file to crop
  /// [aspectRatio] - Desired aspect ratio
  /// [width] - Desired width in pixels
  /// [height] - Desired height in pixels
  ///
  /// Returns the cropped image file, or null if cancelled or error
  Future<File?> cropImage({
    required File imageFile,
    double aspectRatio = ImageSizeConfig.profilePhotoAspectRatio,
    int? width,
    int? height,
  }) async {
    debugPrint("[PhotoUploadService] Starting image crop");
    debugPrint("[PhotoUploadService] Source file: ${imageFile.path}");
    debugPrint("[PhotoUploadService] Aspect ratio: $aspectRatio");
    debugPrint(
        "[PhotoUploadService] Target size: ${width ?? "auto"}x${height ?? "auto"}");

    return await _cropImage(
      imageFile,
      aspectRatio: aspectRatio,
      width: width,
      height: height,
    );
  }

  /// Internal method to crop an image
  Future<File?> _cropImage(
    File imageFile, {
    required double aspectRatio,
    int? width,
    int? height,
  }) async {
    try {
      // Apply default width/height if not provided
      final targetWidth = width ?? ImageSizeConfig.profilePhotoSize;
      final targetHeight = height ?? ImageSizeConfig.profilePhotoSize;
      
      // Convert aspect ratio to ratioX:ratioY format
      // For 1.0 (square): 1:1
      // For 0.75 (3:4): 3:4
      // For 1.33 (4:3): 4:3
      final (ratioX, ratioY) = _convertAspectRatioToRatios(aspectRatio);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(
          ratioX: ratioX.toDouble(),
          ratioY: ratioY.toDouble(),
        ),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop Image",
            toolbarColor: const Color(0xFF6200EE),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: "Crop Image",
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
            ],
            aspectRatioLockEnabled: true,
          ),
        ],
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: ImageSizeConfig.compressionQuality,
        maxWidth: targetWidth,
        maxHeight: targetHeight,
      );

      if (croppedFile == null) {
        debugPrint("[PhotoUploadService] Crop cancelled by user");
        return null;
      }

      debugPrint("[PhotoUploadService] Image cropped: ${croppedFile.path}");
      return File(croppedFile.path);
    } catch (e, stackTrace) {
      debugPrint("[PhotoUploadService] Error during crop: $e");
      debugPrint("[PhotoUploadService] Stack trace: $stackTrace");
      return null;
    }
  }

  /// Requests photo library permission
  ///
  /// Returns true if permission is granted, false otherwise
  /// If permission is permanently denied, opens app settings
  Future<bool> _requestPhotoLibraryPermission() async {
    debugPrint("[PhotoUploadService] Checking photo library permission");

    if (Platform.isAndroid) {
      // Android 13+ uses photos permission
      final currentStatus = await Permission.photos.status;
      debugPrint(
          "[PhotoUploadService] Current Android photos permission: ${currentStatus.toString()}");

      if (currentStatus.isGranted) {
        return true;
      }

      if (currentStatus.isPermanentlyDenied) {
        debugPrint(
            "[PhotoUploadService] Permission permanently denied, opening app settings");
        await openAppSettings();
        return false;
      }

      final status = await Permission.photos.request();
      debugPrint(
          "[PhotoUploadService] Android photos permission after request: ${status.toString()}");
      return status.isGranted;
    } else if (Platform.isIOS) {
      final currentStatus = await Permission.photos.status;
      debugPrint(
          "[PhotoUploadService] Current iOS photos permission: ${currentStatus.toString()}");

      if (currentStatus.isGranted) {
        return true;
      }

      if (currentStatus.isPermanentlyDenied) {
        debugPrint(
            "[PhotoUploadService] Permission permanently denied, opening app settings");
        await openAppSettings();
        return false;
      }

      final status = await Permission.photos.request();
      debugPrint(
          "[PhotoUploadService] iOS photos permission after request: ${status.toString()}");
      return status.isGranted;
    }

    debugPrint("[PhotoUploadService] Platform not supported for photo library");
    return false;
  }

  /// Checks if photo library permission is granted
  Future<bool> hasPhotoLibraryPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.status;
      return status.isGranted;
    }
    return false;
  }

  /// Converts a decimal aspect ratio to ratioX:ratioY format
  ///
  /// Examples:
  /// - 1.0 -> (1, 1) for square
  /// - 0.75 -> (3, 4) for 3:4 portrait
  /// - 1.33 -> (4, 3) for 4:3 landscape
  (int, int) _convertAspectRatioToRatios(double aspectRatio) {
    // Common aspect ratios
    if (aspectRatio == 1.0) {
      return (1, 1); // Square
    } else if ((aspectRatio - 0.75).abs() < 0.01) {
      return (3, 4); // 3:4 portrait
    } else if ((aspectRatio - (4 / 3)).abs() < 0.01) {
      return (4, 3); // 4:3 landscape
    } else if ((aspectRatio - (16 / 9)).abs() < 0.01) {
      return (16, 9); // 16:9 widescreen
    } else {
      // For other ratios, find a close approximation
      // Use a simple fraction approximation
      final ratio = _findClosestRatio(aspectRatio);
      return ratio;
    }
  }

  /// Finds the closest simple ratio for a given aspect ratio
  (int, int) _findClosestRatio(double aspectRatio) {
    // Try common denominators
    for (int denom = 1; denom <= 20; denom++) {
      final numerator = (aspectRatio * denom).round();
      if ((aspectRatio - numerator / denom).abs() < 0.01) {
        return (numerator, denom);
      }
    }
    // Fallback to a simple approximation
    if (aspectRatio < 1.0) {
      return (1, (1 / aspectRatio).round());
    } else {
      return (aspectRatio.round(), 1);
    }
  }
}
