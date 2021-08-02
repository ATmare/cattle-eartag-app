import 'dart:io';
import 'dart:async';

import 'package:image_picker/image_picker.dart';

/*
    Class handles loading images from gallery and taking photos with default camera app
 */
class ImageInput {

  /// Takes a photo or reads image data from storage.
  ///
  /// If [source] is set to 'Camera', camera dialog opens.
  /// Else Gallery is opened
  static Future<File> pickPicture(String source) async {
    File _storedImage;
    final ImagePicker _picker = ImagePicker();
    var pickedFile;

    if (source == 'Camera')
      pickedFile = await _picker.getImage(source: ImageSource.camera);
    else
      pickedFile = await _picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null)
      _storedImage = File(pickedFile.path);
    else
      print('No image selected.');

    return _storedImage;
  }
}
