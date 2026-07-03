import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageService {
  static Future<String> toBase64(Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return base64Encode(bytes);
    final resized = img.copyResize(decoded, width: 800);
    final jpg = img.encodeJpg(resized, quality: 65);
    return base64Encode(jpg);
  }
}
