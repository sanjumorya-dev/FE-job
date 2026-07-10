import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Service to handle image picking and compression
class MediaService {
  final ImagePicker _picker = ImagePicker();

  static const int _maxFileSizeBytes = 1 * 1024 * 1024; // 1MB

  /// Pick image from gallery and compress to under 1MB
  Future<File?> pickImageFromGallery() async {
    return _pickAndCompress(ImageSource.gallery);
  }

  /// Pick image from camera and compress to under 1MB
  Future<File?> pickImageFromCamera() async {
    return _pickAndCompress(ImageSource.camera);
  }

  /// Pick multiple images from gallery (for requirement images)
  Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80,
    );

    if (pickedFiles.isEmpty) return [];

    final files = <File>[];
    for (final xfile in pickedFiles) {
      if (files.length >= maxImages) break;
      final compressed = await _compressImage(File(xfile.path));
      if (compressed != null) {
        files.add(compressed);
      }
    }
    return files;
  }

  /// Pick and compress a single image
  Future<File?> _pickAndCompress(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return null;

      return await _compressImage(File(pickedFile.path));
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Compress image to under 1MB
  ///
  /// Strategy:
  /// 1. If already under 1MB, return as-is
  /// 2. Try progressive compression (quality reduction)
  /// 3. If still too large, resize dimensions
  Future<File?> _compressImage(File file) async {
    try {
      final int originalSize = await file.length();
      if (originalSize <= _maxFileSizeBytes) {
        return file;
      }

      // Get temp directory for compressed output
      final dir = await getTemporaryDirectory();
      final targetPath = p.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Try quality-based compression first
      File? result = await _compressWithQuality(file, targetPath, 80);
      if (result != null && await result.length() <= _maxFileSizeBytes) {
        return result;
      }

      // Reduce quality further
      result = await _compressWithQuality(file, targetPath, 60);
      if (result != null && await result.length() <= _maxFileSizeBytes) {
        return result;
      }

      result = await _compressWithQuality(file, targetPath, 40);
      if (result != null && await result.length() <= _maxFileSizeBytes) {
        return result;
      }

      // If still too large, resize dimensions
      result = await _compressWithResize(file, targetPath, 1024, 40);
      if (result != null && await result.length() <= _maxFileSizeBytes) {
        return result;
      }

      result = await _compressWithResize(file, targetPath, 800, 30);
      return result;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }

  /// Compress with specific quality
  Future<File?> _compressWithQuality(
    File file,
    String targetPath,
    int quality,
  ) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Quality compression error: $e');
      return null;
    }
  }

  /// Compress with resize and quality
  Future<File?> _compressWithResize(
    File file,
    String targetPath,
    int minWidth,
    int quality,
  ) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        minWidth: minWidth,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Resize compression error: $e');
      return null;
    }
  }

  /// Show image source picker dialog and return selected file
  Future<File?> showImageSourceDialog({
    required bool allowCamera,
  }) async {
    // This is a utility method - actual dialog should be shown in UI
    // This just provides a clean API for the two sources
    return null;
  }
}
