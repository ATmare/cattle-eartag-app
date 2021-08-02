import 'package:flutter/material.dart';

/*
    Class is used to provide the path to the currently viewed PDF
 */
class PdfProvider with ChangeNotifier {
  String _path = '';
  String oldPath;

  setPdfPath({@required String pdfPath}) async {
    oldPath = null;
    _path = pdfPath;
  }

  setOldPdfPath({@required String pdfPath}) async {
    oldPath = pdfPath;
  }

  String get pdfPath {
    if (oldPath != null) return oldPath;
    return _path;
  }
}
