import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

import '../providers/animals_provider.dart';
import '../models/animal.dart';
import '../models/country_codes.dart';
import '../widgets/label_checkbox.dart';
import '../widgets/edit_screen_header.dart';
import '../utils/string_processing.dart';

/*
    Renders the edit screen for an animal
 */
class EditAnimalScreen extends StatefulWidget {
  static const routeName = '/edit-animal';

  @override
  _EditAnimalScreenState createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends State<EditAnimalScreen> {
  final _form = GlobalKey<FormBuilderState>();

  final TextEditingController _placeOfBirthController = TextEditingController();
  final TextEditingController _placesOfRearingController =
      TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _additionalText = TextEditingController();
  final _additionalInfoFocusNode = FocusNode();
  var _keyboardVisibilityController = KeyboardVisibilityController();

  bool _isInit = true;

  final _breedSuggestions = [
    'Fleckvieh',
    'Pinzgauer',
    'Braunvieh',
    'Grauvieh',
    'Holstein'
  ];

  var _editedAnimal = Animal(
      id: DateTime.now().toString(),
      tagId: '',
      category: null,
      dateOfBirth: null,
      placeOfBirth: null,
      placeOfRearing: [],
      purchaseDate: null,
      breed: '',
      additionalInfos: '',
      slaugther: false);

  @override
  void initState() {
    _keyboardVisibilityController.onChange.listen((bool visible) {});
    super.initState();
  }

  @override
  void dispose() {
    _additionalInfoFocusNode.dispose();
    _placeOfBirthController.dispose();
    _placesOfRearingController.dispose();
    _breedController.dispose();
    _additionalText.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final tagId = ModalRoute.of(context).settings.arguments as String;
      if (tagId != null) {
        _editedAnimal = Provider.of<AnimalsProvider>(context, listen: false)
            .findById(tagId);

        if (_editedAnimal.breed != null)
          _breedController.text = _editedAnimal.breed;

        if (_editedAnimal.placeOfBirth != null)
          _placeOfBirthController.text = _editedAnimal.placeOfBirth.code;

        if (_editedAnimal.placeOfRearing != null)
          _placesOfRearingController.text =
              _editedAnimal.placesOfRearing().join(',');
      }
    }
    _additionalText.text = _editedAnimal.additionalInfos ?? null;
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateAnimal(String field, dynamic value) {
    setState(() {
      _editedAnimal = Animal(
        tagId: _editedAnimal.tagId,
        id: _editedAnimal.id,
        category: (field == 'category')
            ? (value != null
                ? EnumToString.fromString(AnimalCategory.values, value)
                : null)
            : _editedAnimal.category,
        dateOfBirth:
            (field == 'dateOfBirth') ? value : _editedAnimal.dateOfBirth,
        placeOfBirth: (field == 'placeOfBirth')
            ? CountryCode(_placeOfBirthController.text.toUpperCase())
            : _editedAnimal.placeOfBirth,
        placeOfRearing: (field == 'placeOfRearing')
            ? _createCountryCodes(value)
            : _editedAnimal.placeOfRearing,
        purchaseDate:
            (field == 'purchaseDate') ? value : _editedAnimal.purchaseDate,
        breed: (field == 'breed') ? _breedController.text : _editedAnimal.breed,
        additionalInfos: (field == 'additionalInfos')
            ? value
            : _editedAnimal.additionalInfos,
        slaugther: (field == 'slaugther') ? value : _editedAnimal.slaugther,
      );
    });
  }

  List<CountryCode> _createCountryCodes(values) {
    List<CountryCode> list = [];
    if (values != null) {
      for (String code in values) {
        list.add(CountryCode(code));
      }
      return list;
    }
    return null;
  }

  void _saveForm() {
    if (!_form.currentState.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Speichern nicht möglich. Bitte korrigieren Sie die Eingabe'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      Provider.of<AnimalsProvider>(context, listen: false)
          .updateAnimal(_editedAnimal.tagId, _editedAnimal);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Änderungen für ' + _editedAnimal.tagId + ' gespeichert.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _popScreen() {
    Navigator.of(context).pop();
  }

  // callback function
  void toggleSlaugther(val) {
    setState(() {
      _editedAnimal.slaugther = !_editedAnimal.slaugther;
    });
  }

  String _lookUpEUCountry() {
    var isEUText;
    if (_placeOfBirthController.text.length > 1)
      isEUText = CountryCode.checkEUCode(_placeOfBirthController.text);
    return isEUText;
  }

  TypeAheadFormField _buildPlaceOfBirthInput() {
    return TypeAheadFormField(
      hideOnEmpty: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (val) {
        if (val.length > 2) return 'Kein gültiger Ländercode.';
        if (val == null ||
            val == '' ||
            StringProcessing.isAscii(val) ||
            StringProcessing.isAlpha(val))
          return null;
        else
          return 'Kein gültiger Ländercode.';
      },
      textFieldConfiguration: TextFieldConfiguration(
          onSubmitted: (value) {
            if (value != null) value = value.trim();
            _updateAnimal('placeOfBirth', value.toUpperCase());
          },
          onChanged: (value) {
            if (value != null) value = value.trim();
            _updateAnimal('placeOfBirth', value.toUpperCase());
          },
          controller: this._placeOfBirthController,
          decoration: InputDecoration(
            labelText: 'Geburtsland *',
            border: OutlineInputBorder(),
            helperText: _lookUpEUCountry(),
            suffixIcon: _placeOfBirthController.text.length > 0
                ? IconButton(
                    icon: Icon(Icons.clear),
                    // clear text
                    onPressed: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      this._placeOfBirthController.clear();
                      _updateAnimal('placeOfBirth', null);
                    },
                  )
                : null,
          )),
      autoFlipDirection: true,
      suggestionsCallback: (pattern) {
        List<String> matches = <String>[];
        matches.addAll(CountryCode.COUNTRIES);
        matches.retainWhere(
            (s) => s.toLowerCase().contains(pattern.toLowerCase()));
        return matches.length > 0 ? matches : [];
      },
      itemBuilder: (context, suggestion) {
        return SizedBox(
          height: 50,
          child: ListTile(
            title: Text(suggestion),
          ),
        );
      },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      onSuggestionSelected: (suggestion) {
        this._placeOfBirthController.text = suggestion;
        _updateAnimal('placeOfBirth', suggestion);
      },
    );
  }

  ChipsInput _buildChipSelectInput() {
    return ChipsInput(
      initialValue: _editedAnimal.placesOfRearing(),
      decoration: InputDecoration(
        labelText: "Länder der Aufzucht und Mast * ",
        border: OutlineInputBorder(),
      ),
      maxChips: 5,
      findSuggestions: (String query) {
        if (query.length != 0) {
          var suggestions = CountryCode.COUNTRIES.where((country) {
            return country.toLowerCase().contains(query.toLowerCase());
          }).toList(growable: false);
          if (suggestions.length < 1)
            return [query.toUpperCase()];
          return suggestions;
        } else {
          return const [];
        }
      },
      onChanged: (data) {
        _updateAnimal('placeOfRearing', data);
      },
      chipBuilder: (context, state, suggest) {
        return InputChip(
          key: ObjectKey(suggest),
          label: Text(suggest),
          onDeleted: () => state.deleteChip(suggest),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
      suggestionBuilder: (context, state, suggest) {
        var euCountry = CountryCode.COUNTRIES.contains(suggest);
        return ListTile(
          key: ObjectKey(suggest),
          title: Text.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(text: suggest),
                if (!euCountry) TextSpan(
                    text: ' (Kein EU Land)',
                    style: TextStyle(color: Colors.grey,)),
              ],
            ),
          ),
          onTap: () => state.selectSuggestion(suggest),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final header = EditScreenHeader(
      title: _editedAnimal.tagId,
      smallTitle: 'Tier bearbeiten',
      checkAction: _saveForm,
      abortAction: _popScreen,
    );

    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Expanded(
              child: KeyboardDismissOnTap(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    reverse: _isInit ? false : false,
                    child: Column(
                      children: [
                        FormBuilder(
                          key: _form,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: LabeledCheckbox(
                                  label: 'Schlachtung',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 20),
                                  fontSize: 17,
                                  gap: 10,
                                  value: _editedAnimal.slaugther ?? false,
                                  onTap: toggleSlaugther,
                                ),
                              ),
                              SizedBox(height: 20),
                              DropdownSearch<String>(
                                  autoFocusSearchBox: true,
                                  hint: "Kategorie wählen",
                                  mode: Mode.MENU,
                                  showSelectedItem: true,
                                  items: categories,
                                  label: "Kategorie *",
                                  showClearButton: true,
                                  // extra clear button is needed to change styling
                                  clearButton: IconButton(
                                    padding: EdgeInsets.only(bottom: 0),
                                    icon: Icon(Icons.clear, size: 24),
                                  ),
                                  onChanged: (data) {
                                    _updateAnimal('category', data);
                                  },
                                  selectedItem: _editedAnimal.category != null
                                      ? EnumToString.convertToString(
                                          _editedAnimal.category)
                                      : null),
                              SizedBox(height: 20),
                              TypeAheadFormField(
                                hideOnEmpty: true,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (val) {
                                  if (val == null ||
                                      val == '' ||
                                      StringProcessing.isAscii(val) ||
                                      StringProcessing.isAlpha(val))
                                    return null;
                                  else
                                    return 'Ungültiges Sonderzeichen.';
                                },
                                textFieldConfiguration: TextFieldConfiguration(
                                    onSubmitted: (value) {
                                      if (value != null) value = value.trim();
                                      _updateAnimal('breed', value);
                                    },
                                    onChanged: (value) {
                                      if (value != null) value = value.trim();
                                      _updateAnimal('breed', value);
                                    },
                                    controller: this._breedController,
                                    decoration: InputDecoration(
                                      labelText: 'Rasse *',
                                      border: OutlineInputBorder(),
                                      suffixIcon: _breedController.text.length >
                                              0
                                          ? IconButton(
                                              icon: Icon(Icons.clear),
                                              onPressed: () {
                                                FocusScopeNode currentFocus =
                                                    FocusScope.of(context);
                                                if (!currentFocus
                                                    .hasPrimaryFocus) {
                                                  currentFocus.unfocus();
                                                }
                                                this._breedController.clear();
                                                _updateAnimal('breed', null);
                                              },
                                            )
                                          : null,
                                    )),
                                autoFlipDirection: true,
                                suggestionsCallback: (pattern) {
                                  List<String> matches = <String>[];
                                  matches.addAll(_breedSuggestions);
                                  matches.retainWhere((s) => s
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase()));
                                  return matches.length > 0 ? matches : [];
                                },
                                itemBuilder: (context, suggestion) {
                                  return SizedBox(
                                    height: 50,
                                    child: ListTile(
                                      title: Text(suggestion),
                                    ),
                                  );
                                },
                                transitionBuilder:
                                    (context, suggestionsBox, controller) {
                                  return suggestionsBox;
                                },
                                onSuggestionSelected: (suggestion) {
                                  this._breedController.text = suggestion;
                                  _updateAnimal('breed', suggestion);
                                },
                              ),
                              SizedBox(height: 20),
                              DateTimeField(
                                format: DateFormat('dd.MM.yyyy'),
                                decoration: InputDecoration(
                                  labelText: 'Geburtsdatum *',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (date) =>
                                    _updateAnimal('dateOfBirth', date),
                                onSaved: (date) =>
                                    _updateAnimal('dateOfBirth', date),
                                onFieldSubmitted: (date) =>
                                    _updateAnimal('dateOfBirth', date),
                                initialValue: _editedAnimal.dateOfBirth ?? null,
                                onShowPicker: (context, currentValue) async {
                                  final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1900),
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime.now());
                                  if (date != null) {
                                    return date;
                                  } else {
                                    return currentValue;
                                  }
                                },
                              ),
                              SizedBox(height: 20),
                              DateTimeField(
                                format: DateFormat('dd.MM.yyyy'),
                                decoration: InputDecoration(
                                  labelText: 'Einstelldatum',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (date) =>
                                    _updateAnimal('purchaseDate', date),
                                onSaved: (date) =>
                                    _updateAnimal('purchaseDate', date),
                                onFieldSubmitted: (date) =>
                                    _updateAnimal('purchaseDate', date),
                                initialValue:
                                    _editedAnimal.purchaseDate ?? null,
                                onShowPicker: (context, currentValue) async {
                                  final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1900),
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime.now());
                                  if (date != null) {
                                    return date;
                                  } else {
                                    return currentValue;
                                  }
                                },
                              ),
                              SizedBox(height: 20),
                              _buildPlaceOfBirthInput(),
                              SizedBox(height: 20),
                              _buildChipSelectInput(),
                              SizedBox(height: 20),
                              FormBuilderTextField(
                                  name: 'additionalInfos',
                                  focusNode: _additionalInfoFocusNode,
                                  controller: _additionalText,
                                  validator: FormBuilderValidators.compose([
                                    (val) {
                                      if (val == null ||
                                          val == '' ||
                                          StringProcessing.isAscii(val) ||
                                          StringProcessing.isAlpha(val))
                                        return null;
                                      else
                                        return 'Ungültiges Sonderzeichen.';
                                    },
                                  ]),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    suffixIcon: _additionalText.text.length > 0
                                        ? IconButton(
                                            icon:
                                                Icon(Icons.clear), // clear text
                                            onPressed: () {
                                              setState(() {
                                                FocusScopeNode currentFocus =
                                                    FocusScope.of(context);
                                                if (!currentFocus
                                                    .hasPrimaryFocus) {
                                                  currentFocus.unfocus();
                                                }
                                                _additionalInfoFocusNode
                                                    .unfocus();
                                                _additionalText.clear();
                                                _updateAnimal(
                                                    'additionalInfos', '');
                                              });
                                            },
                                          )
                                        : null,
                                    labelText: 'Nähere Angaben',
                                  ),
                                  onChanged: (val) {
                                    if (_form
                                        .currentState.fields['additionalInfos']
                                        .validate())
                                      _updateAnimal('additionalInfos', val);
                                  }),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4),
                                child: Text(
                                  'z.B. BIO, zert. GVO-freie Fütterung, Impfung, offene Wartezeit. '
                                  '\nAngabe des letzten Impfdatums - verpflichtend bei Blauzungenkrankehit (BT), Rauschbrand (RB), Milzbrand (MB), Tollwut (TW).'
                                  '\nBei Tieren mit offener Wartezeit ist gemäß Abgabebeleg das Ende der Wartezeit sowie der Name ds Arzneimittels anzugeben.',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                  onPressed: _saveForm,
                                  child: Text(
                                    'Eintrag speichern',
                                    style: TextStyle(fontSize: 17),
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              TextButton(
                                onPressed: () {
                                  Provider.of<AnimalsProvider>(context,
                                          listen: false)
                                      .removeAnimal(_editedAnimal.tagId);
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Eintrag ' +
                                          _editedAnimal.tagId +
                                          ' gelöscht.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Eintrag entfernen',
                                  style: TextStyle(
                                      color: Theme.of(context).errorColor,
                                      fontSize: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 0),
                                child: Text(
                                  'Löscht das Tier aus der Tierliste',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
    );
  }
}
