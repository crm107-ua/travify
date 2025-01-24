// lib/utils/image_helper.dart

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ImageHelper {
  final ImagePicker _picker = ImagePicker();

  /// Selecciona una imagen desde la galería o cámara
  Future<File?> pickImage({required bool fromCamera}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile == null) return null;

      final File imageFile = File(pickedFile.path);
      final String newPath = await saveImageLocally(imageFile);

      return File(newPath);
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      return null;
    }
  }

  /// Guarda la imagen en el almacenamiento local y devuelve la nueva ruta
  Future<String> saveImageLocally(File image) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDirPath = join(appDir.path, 'images');
      final Directory imagesDir = Directory(imagesDirPath);

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final String fileName = basename(image.path);
      final String newPath = join(imagesDir.path, fileName);

      final File newImage = await image.copy(newPath);
      return newImage.path;
    } catch (e) {
      print('Error al guardar imagen localmente: $e');
      return image.path;
    }
  }
}
