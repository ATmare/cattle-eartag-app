import 'dart:io';
import 'dart:async';

import 'package:google_ml_vision/google_ml_vision.dart';

/*
    Class is used for BarCode Recognition
 */
class BarCodeRecognition {
  var _text = '';

  /// Recognizes barcode number from [pickedImage] and returns the result as Future<String>
  Future<String> recognizeText(File pickedImage) async {

    final BarcodeDetector barcodeDetector = GoogleVision.instance.barcodeDetector();
    final GoogleVisionImage visionImage = GoogleVisionImage.fromFile(pickedImage);
    final List<Barcode> barcodes = await barcodeDetector.detectInImage(visionImage);

    for (Barcode barcode in barcodes) {
      _text = barcode.rawValue;
    }
    barcodeDetector.close();
    return _text;
  }
}

final barCodeRecognizer = BarCodeRecognition();
