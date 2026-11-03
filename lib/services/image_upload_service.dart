import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';

class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndUploadImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (file == null) return null;

      final Uint8List bytes = await file.readAsBytes();
      final filename = file.name.isNotEmpty ? file.name : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final res = await ApiClient.uploadBytes(
        '${ApiConstants.baseUrl}/api/upload',
        bytes: bytes,
        filename: filename,
      );

      if (res.success && res.data is Map && res.data['url'] != null) {
        return res.data['url'] as String;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
    return null;
  }
}

