library docu_scanner;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHandler {
  static ImagePicker _picker = ImagePicker();
  BuildContext context;

  ImagePickerHandler({required this.context});

  Future<String> getImage(ImageSource source) async {
    final status = await _checkPermissions(source);
    if (status == PermissionStatus.granted) {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        ImageCropper cropper = ImageCropper();
        File? croppedFile = (await cropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Colors.blue,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
          ],
        )) as File?;

        if (croppedFile != null) {
          String filePath = croppedFile.path;
          return filePath;
        }
      }
    }
    return "";
  }

  Future<PermissionStatus> _checkPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.camera.request();
        return result;
      } else {
        return PermissionStatus.granted;
      }
    } else {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        return result;
      } else {
        return PermissionStatus.granted;
      }
    }
  }
}
