import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      rethrow;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      rethrow;
    }
  }

  // Upload image to Supabase Storage
  Future<String?> uploadImage(File imageFile, String folder) async {
    try {
      // Validate file exists and is readable
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final String filePath = '$folder/$fileName';

      print('📤 Uploading image...');
      print('  File: ${imageFile.path}');
      print('  Destination: $filePath');

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();
      print('  Size: ${bytes.length} bytes');

      if (bytes.isEmpty) {
        throw Exception('Image file is empty');
      }

      // Upload to Supabase Storage
      final response =
          await _supabase.storage.from('report-images').uploadBinary(
                filePath,
                bytes,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: false,
                ),
              );

      print('✅ Upload successful: $response');

      // Get public URL
      final String publicUrl =
          _supabase.storage.from('report-images').getPublicUrl(filePath);

      print('🔗 Public URL: $publicUrl');

      // Validate URL format
      if (!publicUrl.startsWith('http')) {
        throw Exception('Invalid public URL format: $publicUrl');
      }

      return publicUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      print('Error details: ${e.toString()}');
      if (e is StorageException) {
        print('Storage error code: ${e.statusCode}');
        print('Storage error message: ${e.message}');
      }
      rethrow;
    }
  }

  // Delete image from Supabase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final Uri uri = Uri.parse(imageUrl);
      final String filePath = uri.pathSegments.last;

      await _supabase.storage.from('report-images').remove([filePath]);

      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages(
      List<File> imageFiles, String folder) async {
    List<String> uploadedUrls = [];

    for (File imageFile in imageFiles) {
      String? url = await uploadImage(imageFile, folder);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  // Compress and upload image
  Future<String?> compressAndUploadImage(File imageFile, String folder) async {
    try {
      // In a real app, you'd use image compression library here
      // For now, we'll just upload directly
      return await uploadImage(imageFile, folder);
    } catch (e) {
      print('Error compressing and uploading image: $e');
      return null;
    }
  }
}
