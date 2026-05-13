import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class Multipart {
  static Future<MultipartFile> fromPlatformFile(
    PlatformFile file, {
    String? filename,
  }) async {
    if (file.bytes != null) {
      return MultipartFile.fromBytes(
        file.bytes!,
        filename: filename ?? file.name,
      );
    }

    final path = file.path;
    if (path == null || path.isEmpty) {
      throw StateError('Arquivo sem bytes e sem path: ${file.name}');
    }

    return MultipartFile.fromFile(path, filename: filename ?? file.name);
  }
}
