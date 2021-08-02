import 'dart:io';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../utils/custom_swatches.dart';
import '../utils/image_input.dart';
import '../utils/text_recognition.dart';
import '../utils/barcode_recognition.dart';
import '../utils/custom_icons.dart';
import '../utils/string_processing.dart';

import '../models/animal.dart';
import '../providers/animals_provider.dart';

/*
    Renders the screen to add new cattle eartag numbers
 */
class EditTagNumberScreen extends StatefulWidget {
  static const routeName = '/edit-tagnumber';

  @override
  _EditTagNumberScreenState createState() => _EditTagNumberScreenState();
}

class _EditTagNumberScreenState extends State<EditTagNumberScreen> {
  File _croppedImage;
  final _textInputController = TextEditingController();
  var _errorText;
  bool _isInit = true;
  bool _isInputValid = false;
  bool _animalFound = false;
  bool _useBarcode = false;
  var _barcodeAccuracy = 0.0;

  String _text = '';
  String _imageSuggestionText;
  List<Animal> _animalList;

  @override
  void initState() {
    _textInputController.addListener(() {
      setState(() {
        _errorText = _validate();
        if (_errorText != null) {
          _isInputValid = false;
        } else
          _isInputValid = true;
      });
    });
    _errorText = '';

    super.initState();
  }

  @override
  void dispose() {
    _textInputController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, File>;
      if (routeArgs != null && _text.isEmpty) {
        _cropImage(routeArgs['pickedImage']);
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  bool _addAnimal(String tagId, AnimalsProvider animalData) {
    var animal;
    var idx = _animalList.indexWhere((animal) => animal.tagId == tagId);
    if (idx > -1) animal = _animalList[idx];

    var alreadyInList =
        Provider.of<AnimalsProvider>(context, listen: false).findIdxById(tagId.toUpperCase());

    if (alreadyInList > -1) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tier bereits in Liste vorhanden'),
        duration: Duration(seconds: 2),
      ));
      return false;
    } else if (animal != null && alreadyInList == -1) {
      animalData.addAnimal(animal);
    } else
      animalData.addAnimalByTagId(
        tagId.toUpperCase(),
      );
    return true;
  }

  String _validate() {
    _errorText = null;
    if (_textInputController.text.isEmpty) {
      _errorText = 'Feld darf nicht leer sein.';
    } else if ((_textInputController.text.length > 0 &&
            _textInputController.text.length < 2 &&
            !StringProcessing.isAlpha(_textInputController.text.substring(0, 1))) ||
        (_textInputController.text.length > 0 &&
            _textInputController.text.length >= 2 &&
            !StringProcessing.isAlpha(_textInputController.text.substring(0, 2)))) {
      _errorText = 'Ohrmarke muss mit zwei Buchstaben [A-Z] beginnen.';
    } else if (_textInputController.text.length > 2 &&
        !StringProcessing.isNumeric(_textInputController.text.substring(2))) {
      _errorText = 'Ohrmarke muss mit mind. 9 Ganzzahlen [0-9] enden.';
    } else if (_textInputController.text.length < 11) {
      _errorText =
          'Ohrmarke zu kurz. Ohrmarke muss aus mind. 11 Zeichen bestehen.';
    } else if (_textInputController.text.length > 13) {
      _errorText = 'Ohrmarke zu lange. ';
    } else if (_textInputController.text.length > 1 &&
        !StringProcessing.isAlphanumeric(_textInputController.text)) {
      _errorText =
          'Ohrmarke darf nur Ganzzahlen [0-9] und Buchstaben [A-Z] enthalten.';
    }
    return _errorText;
  }

  // has to stay Future<bool> because of WillPopScope
  Future<bool> _onBackPressed() {
    Navigator.pop(context);
  }

  // get image from Gallery or Camera and crop it
  void _getImage([String source = 'Gallery']) async {
    File img = await ImageInput.pickPicture(source);
    if (img != null) {
      var cropped = await _cropImage(img);
      if (cropped != null) {
        setState(() {
          _text = '';
          _imageSuggestionText = '';
          _croppedImage = cropped;
        });
      }
    }
  }

  // Select bottom bar action
  void _selectAction(int index) async {
    if (index == 0) {
      _getImage('Camera');
    } else if (index == 1) {
      _getImage('Gallery');
    } else if (index == 2) {
      _onBackPressed();
    }
  }

  // start with Barcode Recognition. If animal can not be found,
  // continue with Text Recognition.
  Future<String> _startRecognition() async {
    if (_text.isEmpty) {

      // perform barcode recognition
      BarCodeRecognition bar = BarCodeRecognition();
      Future<String> futureTextBarcode = bar.recognizeText(_croppedImage);
      var barText = await futureTextBarcode;

      if (barText.isNotEmpty) {
        barText = barText.replaceAll(new RegExp(r"\s+"), "");
        if (barText.indexOf('0') == 0)
          barText = barText.substring(1);
        barText = 'AT' + barText;
      }

      _imageSuggestionText = await _getSuggestions(barText, true);

      // if animal was already found with barcode recognition, text recognition is not necessary
      if (_animalFound) {
        _barcodeAccuracy = 0;
        _useBarcode = false;
        _text = barText;
        return barText;
      }

      // perform text recognition
      TextRecognition rec = TextRecognition();
      Future<String> futureText = rec.recognizeText(_croppedImage);
      var txt = await futureText;

      if (txt.isNotEmpty) txt = txt.replaceAll(new RegExp(r"\s+"), "");
      _imageSuggestionText = await _getSuggestions(txt, false);

      // if barcode recnogition had better accuracy than text recognition, use barcode results
      if (_useBarcode) {
        _text = barText;
        _barcodeAccuracy = 0;
        _useBarcode = false;
        return barText;
      } else
        _text = await futureText;

      _barcodeAccuracy = 0;
      _useBarcode = false;

      return futureText;
    } else

    return _text;
  }

  _calculateSimilarity(String txt, values, bool isBarcode) {
    var matches = txt.bestMatch(values);
    var accuracy = num.tryParse(matches.bestMatch.rating.toString());
    if (isBarcode)
      _barcodeAccuracy = accuracy;
    else
      if (accuracy < _barcodeAccuracy) {
        _useBarcode = true;
        return _imageSuggestionText;
      }

    if (accuracy > 0.3) return values[matches.bestMatchIndex];
    return null;
  }

  List<Animal> _findExactMatches(String query) {
    if (query.length < 1) return [];
    List<Animal> matches = <Animal>[];
    matches.addAll(_animalList);

    matches.retainWhere(
        (animal) => animal.tagId.toLowerCase() == (query.toLowerCase()));

    return matches;
  }

  List<Animal> _getMatchingAnimals(String query)  {
    if (query.length < 1) return [];
    List<Animal> matches = <Animal>[];
    matches.addAll(_animalList);

    matches.retainWhere(
        (animal) => animal.tagId.toLowerCase().contains(query.toLowerCase()));

    return matches;
  }

  _getSuggestions(String query, bool isBarcode) async {
    _animalFound = false;
    if (query.isNotEmpty) {
      List<Animal> matches = _findExactMatches(query);
      if (matches.isEmpty) {
        List<String> tagIds = [];

        for (Animal a in _animalList) {
          tagIds.add(a.tagId);
        }

        var bestMatch = _calculateSimilarity(query, tagIds, isBarcode);
        _imageSuggestionText = bestMatch;
        return bestMatch;
      } else
        _animalFound = true;
    }
    return null;
  }

  Future<File> _cropImage(imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        androidUiSettings: AndroidUiSettings(
            cropFrameStrokeWidth: 4,
            activeControlsWidgetColor: Theme.of(context).primaryColor,
            toolbarTitle: 'Bild zuschneiden',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Bild zuschneiden',
        ));
    if (croppedFile != null) {
      setState(() {
        _croppedImage = croppedFile;
        _text = '';
      });
      return _croppedImage;
    }
    return null;
  }

  Widget _showCropImage() {
    return _croppedImage != null
        ? Image.file(
            _croppedImage,
            fit: BoxFit.cover,
            width: double.infinity,
          )
        : Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Bild aus Galerie',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _croppedImage == null ? _getImage : () {},
                  child: Icon(
                    cow_tag,
                    color: Colors.white70,
                    size: 140.0,
                  ),
                ),
                const Text(
                  'Fügen Sie ein Bild aus Ihrer Galerie hinzu, um die Marke automatisch auszulesen',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
  }

  LinearGradient _buildGradient() {
    return LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topCenter,
      colors: [
        Theme.of(context).accentColor,
        customColor.shade800,
      ],
    );
  }

  Expanded _buildTextInputField() {
    return Expanded(
      child: TypeAheadFormField(
          validator: (value) => _validate(),
          hideOnEmpty: true,
          hideOnLoading: true,
          textFieldConfiguration: TextFieldConfiguration(
            style: TextStyle(color: Colors.white),
            controller: _textInputController,
            decoration: InputDecoration(
              focusedBorder: _border,
              enabledBorder: _border,
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).errorColor,
                ),
              ),
              errorStyle: TextStyle(
                color: Theme.of(context).errorColor,
                fontWeight: FontWeight.bold,
              ),
              hintText: 'AT  _ _  _ _ _ _  _ _ _ ',
              hintStyle: TextStyle(color: Colors.white60),
              labelText: 'Ohrmarken-ID',
              labelStyle: TextStyle(
                color: Colors.white,
              ),
              border: OutlineInputBorder(),
              // errorText: _validate(),
              contentPadding: EdgeInsets.all(10),
              suffixIcon: (_textInputController.text != null &&
                      _textInputController.text.isNotEmpty)
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white60,
                      ),
                      onPressed: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        _textInputController.clear();
                      },
                    )
                  : null,
            ),
          ),
          suggestionsCallback: (pattern) async {
            return _getMatchingAnimals(pattern);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion.tagId),
            );
          },
          onSuggestionSelected: (suggestion) {
            setState(() {
              _textInputController.text = suggestion.tagId;
            });
          },
          noItemsFoundBuilder: (context) => Container(height: 0)),
    );
  }

  Container _buildErrorText() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: CircleAvatar(
              backgroundColor: Colors.white60,
              radius: 8,
              child: Padding(
                padding: EdgeInsets.all(1),
                child: FittedBox(
                  child: Text(
                    '!',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AutoSizeText(_errorText ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: true,
                style: TextStyle(
                  color: Colors.white60,
                )),
          ),
        ],
      ),
    );
  }

  _buildBottomArea(AsyncSnapshot<String> snapshot) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            'Text erkannt ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Icon(
                            (_text.isNotEmpty)
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            color: (_text.isNotEmpty)
                                ? Theme.of(context).accentColor
                                : Theme.of(context).errorColor,
                            size: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: (_text.isNotEmpty)
                        ? AutoSizeText(
                            snapshot.data.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          )
                        : Text('Kein Text erkannt'),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            'Datenbank ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Icon(
                            _animalFound
                                ? Icons.check_circle_outline
                                : ((_imageSuggestionText != null)
                                    ? Icons.announcement_outlined
                                    : Icons.cancel_outlined),
                            color: _animalFound
                                ? Theme.of(context).accentColor
                                : (_imageSuggestionText != null)
                                    ? Colors.grey
                                    : Theme.of(context).errorColor,
                            size: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: (_imageSuggestionText != null || _animalFound)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                (!_animalFound ? 'Ähnliche ' : '') +
                                    'Marke gefunden: ',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                              InputChip(
                                onPressed: () {
                                  _textInputController.text =
                                      _imageSuggestionText ?? _text.replaceAll(new RegExp(r"\s+"), "");
                                },
                                label: Text(_imageSuggestionText != null
                                    ? _imageSuggestionText
                                    : _text.replaceAll(new RegExp(r"\s+"), "")),
                              ),
                            ],
                          )
                        : AutoSizeText('Keine passenden Einträge gefunden'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  final _border = OutlineInputBorder(
    borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
    borderSide: BorderSide(
      width: 2,
      color: Colors.white,
    ),
  );

  @override
  Widget build(BuildContext context) {

    final animalData = Provider.of<AnimalsProvider>(context, listen: false);
    _animalList = Provider.of<List<Animal>>(context);

    final bottomBar = BottomNavigationBar(
      selectedItemColor: Colors.white60,
      unselectedItemColor: Colors.white60,
      backgroundColor: Theme.of(context).primaryColor,
      onTap: _selectAction,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          label: 'Neues Foto',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.image_rounded),
          label: 'Galerie',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.clear),
          label: 'Abbrechen',
        ),
      ],
    );

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                height: MediaQuery.of(context).size.height * 0.3,
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Neue Marke eingeben',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        _buildTextInputField(),
                        Container(
                          decoration: BoxDecoration(
                              color: _isInputValid ? Colors.white : Colors.white60,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10))),
                          child: IconButton(
                              icon: Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                if (_isInputValid) {
                                  if (_addAnimal(
                                      _textInputController.text, animalData))
                                    _onBackPressed();
                                }
                              }),
                        ),
                      ],
                    ),
                    if (!_isInputValid && !_errorText.isEmpty) _buildErrorText(),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(20),
                  height: 300,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: _croppedImage == null ? _buildGradient() : null,
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: _showCropImage(),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              (_croppedImage != null)
                  ? FutureBuilder<String>(
                      future: _startRecognition(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            if (snapshot.hasError)
                              return Text('Error: ${snapshot.error}');
                            else
                              return _buildBottomArea(snapshot);
                        }
                      },
                    )
                  : Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kein Bild zur Texterkennung gewählt',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
        bottomNavigationBar: bottomBar,
      ),
    );
  }
}
