import 'dart:io';
import 'package:flutter/material.dart';

import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/pdf_api.dart';
import '../providers/pdf_provider.dart';
import '../providers/delivery_note_provider.dart';
import '../models/deliveryNote.dart';

/*
    Class renders a delivery note PDF document and offers methods
    to share the PDF or to load a PDF from storage
 */
class PdfScreen extends StatefulWidget {
  static const routeName = '/pdf';

  @override
  _PdfScreenState createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  DeliveryNoteProvider _deliveryData;
  bool _loadFromStorage = false;
  bool _isLoading = false;
  bool _currentHasBeenRenderedBefore = false;

  @override
  void didChangeDependencies() {
    _deliveryData = Provider.of<DeliveryNoteProvider>(context);
    super.didChangeDependencies();
  }

  // Checks if viewed PDF is the current delivery note or an older delivery note.
  // Returns true if number of viewed PDF is the same ID as the current delivery note
  bool _checkPath(String currentPath) {
    int currentId = _deliveryData.currentDeliveryNote.deliveryId;
    if (currentPath != null) {
      var start = "vvs_";
      var end = ".pdf";
      final startIndex = currentPath.indexOf(start);
      final endIndex = currentPath.indexOf(end, startIndex + start.length);
      var id = currentPath.substring(startIndex + start.length, endIndex);
      int idNum = num.tryParse(id);
      return currentId == idNum;
    }
    return false;
  }

  // opens a PDF file that is stored in storage or generates a new PDF
  Future<File> _openFile(
      BuildContext context, DeliveryNote deliveryNote) async {
    var uid = FirebaseAuth.instance.currentUser.uid;
    Provider.of<PdfProvider>(context, listen: false)
        .setOldPdfPath(pdfPath: null);

    if (!_loadFromStorage) {
      if (deliveryNote.deliveryId == 0) {
        deliveryNote.deliveryId = await _deliveryData.getDeliveryNoteCounterFromStorage();
      }
      if (_currentHasBeenRenderedBefore) {
        var p = Provider.of<PdfProvider>(context, listen: false).pdfPath;
        return File('$p');
      }
      // generate new PDF with current deliveryNote data
      return PdfApi.generatePDF(deliveryNote, uid);
    }
    // load PDF from storage
    else {
      var dir;
      if (Platform.isIOS)
        dir = await getLibraryDirectory();
      else
        dir = await getExternalStorageDirectory();
      final subDir = Directory(dir.path + '/' + uid);
      String storagePath = await FilesystemPicker.open(
        title: 'Lieferschein Übersicht',
        context: context,
        rootName: 'Gespeicherte Lieferscheine',
        rootDirectory: subDir,
        fsType: FilesystemType.file,
        folderIconColor: Colors.teal,
        allowedExtensions: ['.pdf'],
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        requestPermission: () async =>
            await Permission.storage.request().isGranted,
      );
      _loadFromStorage = false;
      if (storagePath != null) {
        var file = File('$storagePath');
        if (!_checkPath(storagePath))
          Provider.of<PdfProvider>(context, listen: false)
              .setOldPdfPath(pdfPath: file.path);
        return file;
      } else {
        storagePath = Provider.of<PdfProvider>(context, listen: false).pdfPath;
        return File('$storagePath');
      }
    }
  }

  _finishDeliveryNote(File file) async {
    await _deliveryData.increaseId();
    await _deliveryData.finishDeliveryNote();
    Share.shareFiles([file.path], text: p.basename(file.path));
  }

  // Returns List that shows [text] as error message
  _buildErrorRow(String text) {
    if (text == null)
      return [Container()];
    else
      return [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).errorColor,
              radius: 10,
              child: Padding(
                padding: EdgeInsets.all(3),
                child: FittedBox(
                  child: Text(
                    '!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(text),
            ),
          ],
        )
      ];
  }

  // dialog that is shown if user presses 'Lieferschein abschließen'
  _showDialog({File file}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _isLoading
            ? Scaffold(body: CircularProgressIndicator())
            : AlertDialog(
                insetPadding: EdgeInsets.all(10),
                title: Text('Lieferschein abschließen'),
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 20,
                      maxHeight: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Nach Abschluss des Lieferscheins wird dieser auf Ihrem Gerät gespeichert '
                          'und kann nicht mehr bearbeitet werden. Möchten Sie den Lieferschein jetzt abschließen?'),
                      SizedBox(height: 10),
                      ..._buildErrorRow(_deliveryData.checkAnimalCompleteness()),
                      ..._buildErrorRow(
                          _deliveryData.checkPersonCompleteness('farmer')),
                      ..._buildErrorRow(
                          _deliveryData.checkPersonCompleteness('vet')),
                      ..._buildErrorRow(
                          _deliveryData.checkTransportCompleteness()),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("Abbrechen"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                      child: Text('Abschließen'),
                      onPressed: () async {
                        // setState(() {
                        //   _isLoading = true;
                        // });
                        Navigator.of(context).pop();
                        await _finishDeliveryNote(file);

                        setState(() {
                          _isLoading = false;
                        });
                      }),
                ],
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryNote = _deliveryData.currentDeliveryNote;

    return FutureBuilder<File>(
      future: _openFile(context, deliveryNote), // async work
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else {
              if (Provider.of<PdfProvider>(context, listen: false).oldPath ==
                  null)
                Provider.of<PdfProvider>(context, listen: false)
                    .setPdfPath(pdfPath: snapshot.data.path);

              return Stack(children: [
                PdfViewer.openFile(
                  snapshot.data.path,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            _checkPath(snapshot.data.path)
                                ? _showDialog(file: snapshot.data)
                                : setState(() {
                                    _loadFromStorage = false;
                                    _currentHasBeenRenderedBefore = true;
                                  });
                          },
                          child: Text(
                            _checkPath(snapshot.data.path)
                                ? 'Lieferschein abschließen'
                                : 'Zurück zum aktuellen Schein',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        // Button to load PDF from storage
                        IconButton(
                          iconSize: 50,
                          icon: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 25,
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: FittedBox(
                                child: Icon(
                                  Icons.snippet_folder_outlined,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _loadFromStorage = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ]);
            }
        }
      },
    );
  }
}
