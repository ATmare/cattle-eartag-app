import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/providers/person_list_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_picker/flutter_picker.dart';

import '../widgets/edit_screen_header.dart';
import '../utils/string_processing.dart';
import '../models/address.dart';
import '../models/transport.dart';

/*
    Renders the edit transport screen
 */
class EditTransportScreen extends StatefulWidget {
  static const routeName = '/edit-transport';

  @override
  _EditTransportScreenState createState() => _EditTransportScreenState();
}

class _EditTransportScreenState extends State<EditTransportScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  var keyboardVisibilityController = KeyboardVisibilityController();

  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  final TextEditingController _addrStreetController = TextEditingController();
  final TextEditingController _addrNrController = TextEditingController();
  final TextEditingController _addrPLZController = TextEditingController();
  final TextEditingController _addrCityController = TextEditingController();

  final TextEditingController _addrStreetToController = TextEditingController();
  final TextEditingController _addrNrToController = TextEditingController();
  final TextEditingController _addrPLZToController = TextEditingController();
  final TextEditingController _addrCityToController = TextEditingController();

  bool _isInit = true;
  bool _enableAddrFields = true;
  var _tempDuration;

  var _editedTransport = Transport(
    loadingPlace: Address(),
    unloadingPlace: Address(),
    startOfTransport: null,
    transportDuration: null,
    lastFeeding: null,
    licensePlate: '',
  );

  @override
  void initState() {
    keyboardVisibilityController.onChange.listen((bool visible) {});
    super.initState();
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _durationController.dispose();

    _addrStreetController.dispose();
    _addrNrController.dispose();
    _addrPLZController.dispose();
    _addrCityController.dispose();

    _addrStreetToController.dispose();
    _addrNrToController.dispose();
    _addrPLZToController.dispose();
    _addrCityToController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final transport =
          (ModalRoute.of(context).settings.arguments as Map)['transport'];

      if (transport != null) {
        _editedTransport = transport.cloneSelf();
      }
    }
    _setInitValues();
    _isInit = false;
    super.didChangeDependencies();
  }

  void _setInitValues() {
    if (_editedTransport.loadingPlace != null) {
      _addrStreetController.text = _editedTransport.loadingPlace.street ?? null;
      _addrNrController.text = _editedTransport.loadingPlace.streetNr ?? null;
      _addrCityController.text = _editedTransport.loadingPlace.city ?? null;
      _addrPLZController.text = _editedTransport.loadingPlace.postalCode != null
          ? _editedTransport.loadingPlace.postalCode.toString()
          : null;
    }

    if (_editedTransport.unloadingPlace != null) {
      _addrStreetToController.text =
          _editedTransport.unloadingPlace.street ?? null;
      _addrNrToController.text =
          _editedTransport.unloadingPlace.streetNr ?? null;
      _addrCityToController.text = _editedTransport.unloadingPlace.city ?? null;
      _addrPLZToController.text =
          _editedTransport.unloadingPlace.postalCode != null
              ? _editedTransport.unloadingPlace.postalCode.toString()
              : null;
    }

    _licenseController.text = _editedTransport.licensePlate ?? null;
    _durationController.text = _editedTransport.transportDuration != null
        ? (StringProcessing.prettyDuration(_editedTransport.transportDuration) +
            ' h')
        : null;

    _enableAddrFields = (_editedTransport.syncUnloadingPlace == 'buyer' ||
            _editedTransport.syncUnloadingPlace == 'transporter' ||
            _editedTransport.syncUnloadingPlace == 'intermediary')
        ? false
        : true;
  }

  void _updateTransport(String field, dynamic value) {
    setState(() {
      _editedTransport.startOfTransport = (field == 'startOfTransport')
          ? value
          : _editedTransport.startOfTransport;
      _editedTransport.transportDuration = (field == 'transportDuration')
          ? value
          : _editedTransport.transportDuration;
      _editedTransport.lastFeeding =
          (field == 'lastFeeding') ? value : _editedTransport.lastFeeding;
      _editedTransport.licensePlate =
          (field == 'licensePlate') ? value : _editedTransport.licensePlate;

      _editedTransport.lastEdited = Timestamp.now();

      // loading place update
      _updateAddress(
          field: field, value: value, addr: _editedTransport.loadingPlace);

      // unloading place update
      _updateAddress(
          field: field,
          value: value,
          addr: _editedTransport.unloadingPlace,
          street: 'streetTo',
          streetNrTo: 'streetNrTo',
          postalCode: 'postalCodeTo',
          city: 'cityTo');
    });
  }

  _updateAddress({
    String street = 'street',
    String streetNrTo = 'streetNr',
    String postalCode = 'postalCode',
    String city = 'city',
    String field,
    dynamic value,
    Address addr,
  }) {
    if (field == street ||
        field == streetNrTo ||
        field == postalCode ||
        field == city) {
      addr.street = (field == street) ? value : addr.street;
      addr.streetNr = (field == streetNrTo) ? value : addr.streetNr;
      addr.city = (field == city) ? value : addr.city;
      addr.postalCode = (field == postalCode)
          ? (value != null ? num.tryParse(value) : null)
          : addr.postalCode;
    }
  }

  void _syncAddress(String syncPerson) {
    if (syncPerson == null) {
      setState(() {
        _editedTransport.syncUnloadingPlace = '';
        _enableAddrFields = true;
      });
    } else {
      Address addr;
      var personProvider =
          Provider.of<PersonListProvider>(context, listen: false);

      if (syncPerson == 'buyer') {
        addr = personProvider.selectedBuyer != null
            ? personProvider.selectedBuyer.address
            : Address();
      } else if (syncPerson == 'transporter') {
        addr = personProvider.selectedTransporter != null
            ? personProvider.selectedTransporter.address
            : Address();
      } else if (syncPerson == 'intermediary') {
        addr = personProvider.selectedIntermediary != null
            ? personProvider.selectedIntermediary.address
            : Address();
      }
      setState(() {
        _enableAddrFields = false;
        if (addr == null) addr = Address();

        _editedTransport.syncUnloadingPlace = syncPerson;
        _editedTransport.unloadingPlace.street = addr.street;
        _editedTransport.unloadingPlace.streetNr = addr.streetNr;
        _editedTransport.unloadingPlace.city = addr.city;
        _editedTransport.unloadingPlace.postalCode = addr.postalCode;

        _addrStreetToController.text = addr.street ?? '';
        _addrNrToController.text = addr.streetNr ?? '';
        _addrPLZToController.text =
            addr.postalCode != null ? addr.postalCode.toString() : '';
        _addrCityToController.text = addr.city ?? '';
      });
    }
  }

  void _saveForm() {
    if (!_formKey.currentState.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Speichern nicht möglich. Bitte korrigieren Sie die Eingabe.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      Provider.of<PersonListProvider>(context, listen: false)
          .setTransport(_editedTransport);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Änderungen für Transport gespeichert.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  _createAddressBlock(
      {String title = 'Verladeort/-Land *',
      String streetName = 'addressStreet',
      String streetField = 'street',
      String streetNrName = 'addressStreetNr',
      String streetNrField = 'streetNr',
      String plzName = 'postalCode',
      String plzField = 'postalCode',
      String cityName = 'city',
      String cityField = 'city',
      bool first = true,
      enabled = true,
      bool showchips = false}) {
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
      ),
      SizedBox(height: 10),
      showchips
          ? Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Entladeort Informationen synchronisieren mit:',
                textAlign: TextAlign.center,
              ),
            )
          : Container(),
      showchips
          ? FormBuilderChoiceChip(
              name: 'choice_chip',
              initialValue: _editedTransport.syncUnloadingPlace ?? null,
              alignment: WrapAlignment.spaceAround,
              runAlignment: WrapAlignment.center,
              options: [
                FormBuilderFieldOption(value: 'buyer', child: Text('Käufer')),
                FormBuilderFieldOption(
                    value: 'intermediary', child: Text('Zwischenhändler')),
                FormBuilderFieldOption(
                    value: 'transporter', child: Text('Transporteur')),
              ],
              onChanged: (value) {
                _syncAddress(value);
              },
            )
          : Container(),
      SizedBox(height: 20),
      Row(
        children: [
          Flexible(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _textFieldBuilder(
                  name: streetName,
                  enabled: enabled,
                  keyboardType: TextInputType.streetAddress,
                  controller:
                      first ? _addrStreetController : _addrStreetToController,
                  labeltext: first ? 'Straße *' : 'Straße',
                  field: streetField),
            ),
          ),
          Flexible(
            flex: 2,
            child: _textFieldBuilder(
                name: streetNrName,
                enabled: enabled,
                controller: first ? _addrNrController : _addrNrToController,
                labeltext: first ? 'Nr. *' : 'Nr.',
                field: streetNrField),
          ),
        ],
      ),
      SizedBox(height: 20),
      Row(
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _textFieldBuilder(
                  name: plzName,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  validatorFunction: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(context,
                        errorText: "Nur Ganzzahlen erlaubt."),
                  ]),
                  controller: first ? _addrPLZController : _addrPLZToController,
                  labeltext: first ? 'PLZ *' : 'PLZ',
                  field: plzField),
            ),
          ),
          SizedBox(height: 20),
          Flexible(
            flex: 6,
            child: _textFieldBuilder(
                name: cityName,
                enabled: enabled,
                controller: first ? _addrCityController : _addrCityToController,
                labeltext: first ? 'Ort *' : 'Ort',
                field: cityField),
          ),
        ],
      ),
    ];
  }

  DateTimeField _createDateTimeField({String label, String field, initValue}) {
    return DateTimeField(
      format: DateFormat("HH:mm"),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onChanged: (date) => _updateTransport(field, date),
      onSaved: (date) => _updateTransport(field, date),
      onFieldSubmitted: (date) => _updateTransport(field, date),
      initialValue: initValue,
      onShowPicker: (context, currentValue) async {
        final time = await showTimePicker(
            context: context,
            initialTime:
                TimeOfDay.fromDateTime(currentValue ?? DateTime.now()));
        if (time != null) {
          return DateTimeField.convert(time);
        } else {
          return currentValue;
        }
      },
    );
  }

  FormBuilderTextField _textFieldBuilder(
      {String name = '',
      TextEditingController controller,
      Function validatorFunction,
      String labeltext = '',
      TextInputType keyboardType = TextInputType.text,
      bool enabled = true,
      String field}) {
    return FormBuilderTextField(
      name: name,
      style: enabled ? null : TextStyle(color: Colors.black45),
      enabled: enabled,
      keyboardType: keyboardType,
      controller: controller,
      validator: validatorFunction ??
          FormBuilderValidators.compose([
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
        fillColor: Colors.black12,
        filled: !enabled,
        border: OutlineInputBorder(),
        suffixIcon: controller.text.length > 0
            ? IconButton(
                icon: Icon(Icons.clear), // clear text
                onPressed: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  controller.clear();
                  if (keyboardType == TextInputType.number)
                    _updateTransport(field, null);
                  else
                    _updateTransport(field, '');
                },
              )
            : null,
        labelText: labeltext,
        hintText: labeltext,
      ),
      onChanged: (val) {
        if (keyboardType == TextInputType.number && val != null) {
          if (_formKey.currentState.fields[name].validate())
            _updateTransport(field, val);
        } else {
          if (_formKey.currentState.fields[name].validate())
            _updateTransport(field, val);
        }
      },
    );
  }

  // Callback functions for child widgets
  void _popScreen() {
    Navigator.of(context).pop();
  }

  void _showPickerNumber(BuildContext context) {
    Picker(
        cancelText: 'Abbrechen',
        confirmText: 'Bestätigen',
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
            begin: 0, end: 99,
            // postfix: Text("\$"),
            // suffix: Icon(Icons.insert_emoticon)
          ),
          NumberPickerColumn(begin: 00, end: 30, jump: 30),
        ]),
        delimiter: [
          PickerDelimiter(
              child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ))
        ],
        hideHeader: true,
        title: Text("Transportdauer wählen"),
        selectedTextStyle: TextStyle(color: Theme.of(context).primaryColor),
        onConfirm: (Picker picker, List value) {
          if (picker.getSelectedValues()[0] == 0 &&
              picker.getSelectedValues()[1] == 0) {
            _tempDuration = null;

            _updateTransport('transportDuration', null);
            _durationController.text = '';
          } else {

            String hours = picker.getSelectedValues()[0].toString();
            String minutes = picker.getSelectedValues()[1].toString();

            _tempDuration = DateFormat("HH:mm").parse(hours + ':' + minutes);
            _durationController.text = StringProcessing.prettyDuration(_tempDuration) + ' h';

            _updateTransport('transportDuration', _tempDuration);
          }
        }).showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final header = EditScreenHeader(
      title: 'Transport bearbeiten',
      smallTitle: 'Transportdetails',
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
                    child: Column(
                      children: [
                        FormBuilder(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              _createDateTimeField(
                                label: 'Transportbeginn *',
                                field: 'startOfTransport',
                                initValue:
                                    _editedTransport.startOfTransport ?? null,
                              ),
                              SizedBox(height: 20),
                              _createDateTimeField(
                                label: 'Letzte Fütterung / Tränkung *',
                                field: 'lastFeeding',
                                initValue: _editedTransport.lastFeeding ?? null,
                              ),
                              SizedBox(height: 20),
                              _textFieldBuilder(
                                  name: 'licensePlate',
                                  controller: _licenseController,
                                  labeltext: 'KFZ Kennzeichen',
                                  field: 'licensePlate'),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: () => _showPickerNumber(context),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: _durationController,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Vorauss. Beförderungsdauer in h',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 40),
                              ..._createAddressBlock(),
                              SizedBox(height: 40),
                              ..._createAddressBlock(
                                  title: 'Entladeort/- land',
                                  streetName: 'addressStreetTo',
                                  streetField: 'streetTo',
                                  streetNrName: 'addressStreetNrTo',
                                  streetNrField: 'streetNrTo',
                                  plzName: 'postalCodeTo',
                                  plzField: 'postalCodeTo',
                                  cityName: 'cityTo',
                                  cityField: 'cityTo',
                                  first: false,
                                  showchips: true,
                                  enabled: _enableAddrFields),
                              SizedBox(
                                height: 30,
                              ),
                              ElevatedButton(
                                onPressed: _saveForm,
                                child: Text(
                                  'Eintrag speichern',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              TextButton(
                                onPressed: () {
                                  Provider.of<PersonListProvider>(context,
                                          listen: false)
                                      .setTransport(null);
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Transportdaten gelöscht.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Eintrag dauerhaft löschen',
                                  style: TextStyle(
                                      color: Theme.of(context).errorColor,
                                      fontSize: 16),
                                ),
                              ),
                              Text(
                                'Löscht alle für den Transport gespeicherten Daten. Vorgang kann nicht rückgängig gemacht werden',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
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
