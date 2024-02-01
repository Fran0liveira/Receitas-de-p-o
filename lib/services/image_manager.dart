import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageManager {
  Future<File> crop(
      {FileSystemEntity file, double ratioX, double ratioY}) async {
    var image = await ImageCropper().cropImage(
        androidUiSettings: AndroidUiSettings(toolbarTitle: 'Selecionar imagem'),
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: ratioX, ratioY: ratioY));

    return image;
  }

  Future<File> compress(FileSystemEntity file) async {
    var directory = await getTemporaryDirectory();
    final newPath =
        p.join(directory.path, '${DateTime.now()}.${p.extension(file.path)}');
    final result = await FlutterImageCompress.compressAndGetFile(
        file.path, newPath,
        quality: 35);

    return result;
  }
}
