import 'dart:io';
import 'dart:async';

import 'package:google_ml_vision/google_ml_vision.dart';

/*
    Class is used for Text Recognition
 */
class TextRecognition {
  var _text = '';

  /// Recognizes text from [pickedImage] and returns the result as Future<String>
  Future<String> recognizeText(File pickedImage) async {

    final TextRecognizer textRecognizer = GoogleVision.instance.textRecognizer();
    final GoogleVisionImage visionImage = GoogleVisionImage.fromFile(pickedImage);
    final VisionText visionText = await textRecognizer.processImage(visionImage);

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          _text = _text + element.text + ' ';
        }
      }
    }
    textRecognizer.close();
    return _text;
  }
}

final textRecognizer = TextRecognition();
