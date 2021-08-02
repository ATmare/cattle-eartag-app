import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/services.dart';

import '../widgets/label_checkbox.dart';
import '../widgets/edit_screen_header.dart';
import '../utils/string_processing.dart';
import '../models/address.dart';
import '../models/farmer.dart';
import '../models/vet.dart';
import '../models/transporter.dart';
import '../providers/person_list_provider.dart';

/*
    Renders the edit screen for a person
 */
class EditPersonScreen extends StatefulWidget {
  static const routeName = '/edit-person';

  @override
  _EditPersonScreenState createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addrStreetController = TextEditingController();
  final TextEditingController _addrNrController = TextEditingController();
  final TextEditingController _addrPLZController = TextEditingController();
  final TextEditingController _addrCityController = TextEditingController();
  final TextEditingController _lfbisIdOrAmaController = TextEditingController();
  var _keyboardVisibilityController = KeyboardVisibilityController();

  final TextEditingController _marketingOtherController =
      TextEditingController();
  final TextEditingController _marketingBioController = TextEditingController();

  bool _isInit = true;
  bool _enableTextFields = true; // used to disable textfields if information should be synced
  String personRole;
  String _headerSmallText;
  bool _isLoading = false;
  var _ama = false;
  var _gvo = false;

  var _editedPerson;

  @override
  void initState() {
    _keyboardVisibilityController.onChange.listen((bool visible) {});
    super.initState();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addrStreetController.dispose();
    _addrNrController.dispose();
    _addrPLZController.dispose();
    _addrCityController.dispose();
    _lfbisIdOrAmaController.dispose();
    _marketingOtherController.dispose();
    _marketingBioController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final person =
          (ModalRoute.of(context).settings.arguments as Map)['person'];
      personRole = (ModalRoute.of(context).settings.arguments as Map)['role'];

      if (person != null) {
        final temp = Provider.of<PersonListProvider>(context, listen: false)
            .findPerson(person);
        if (temp != null) {
          _editedPerson = temp.cloneSelf();

          if (temp is Transporter) {
            if (temp.syncWith == 'farmer' || temp.syncWith == 'intermediary')
              _enableTextFields = false;
          }

          _headerSmallText = personRole + '  bearbeiten';
        } else {
          _editedPerson = person;
          _headerSmallText = personRole + '  hinzufügen';
        }
      }
    }

    _setInitValues();
    _isInit = false;
    super.didChangeDependencies();
  }

  void _setInitValues() {
    _firstnameController.text = _editedPerson.firstname ?? null;
    _lastnameController.text = _editedPerson.lastname ?? null;
    _emailController.text = _editedPerson.email ?? null;
    _phoneController.text = _editedPerson.phone ?? null;
    if (_editedPerson.address != null) {
      _addrStreetController.text = _editedPerson.address.street ?? null;
      _addrNrController.text = _editedPerson.address.streetNr ?? null;
      _addrCityController.text = _editedPerson.address.city ?? null;
      _addrPLZController.text = _editedPerson.address.postalCode != null
          ? _editedPerson.address.postalCode.toString()
          : null;
    } else
      _editedPerson.address = Address();

    _lfbisIdOrAmaController.text = _editedPerson.hasAmaNr != null
        ? _editedPerson.hasAmaNr.toString()
        : null;

    if (_editedPerson is Farmer) _setInitMarketing();
  }

  void _setInitMarketing() {
    if ((_editedPerson as Farmer).marketingAds != null) {
      _ama = ((_editedPerson as Farmer)
          .marketingAds
          .containsKey(MarketingLabel.AMAGuetesiegel));
      _gvo = ((_editedPerson as Farmer)
          .marketingAds
          .containsKey(MarketingLabel.GVOFrei));

      if ((_editedPerson as Farmer)
          .marketingAds
          .containsKey(MarketingLabel.Bio))
        _marketingBioController.text =
            (_editedPerson as Farmer).marketingAds[MarketingLabel.Bio];

      if ((_editedPerson as Farmer)
          .marketingAds
          .containsKey(MarketingLabel.Other))
        _marketingOtherController.text =
            (_editedPerson as Farmer).marketingAds[MarketingLabel.Other];
    } else
      (_editedPerson as Farmer).marketingAds = {};
  }

  void _updatePerson(String field, dynamic value) {
    setState(() {
      _editedPerson
          .setAmaNr((field == 'lfbisIdOrAma') ? value : _editedPerson.hasAmaNr);
      _editedPerson.firstname =
          (field == 'firstname') ? value : _editedPerson.firstname;
      _editedPerson.lastname =
          (field == 'lastname') ? value : _editedPerson.lastname;
      _editedPerson.phone = (field == 'phone') ? value : _editedPerson.phone;
      _editedPerson.email = (field == 'email') ? value : _editedPerson.email;

      if (field == 'street' ||
          field == 'streetNr' ||
          field == 'postalCode' ||
          field == 'city') {
        _editedPerson.address.street =
            (field == 'street') ? value : _editedPerson.address.street;
        _editedPerson.address.streetNr =
            (field == 'streetNr') ? value : _editedPerson.address.streetNr;
        _editedPerson.address.city =
            (field == 'city') ? value : _editedPerson.address.city;
        _editedPerson.address.postalCode = (field == 'postalCode')
            ? (value != null ? num.tryParse(value) : null)
            : _editedPerson.address.postalCode;
      }
    });
  }

  void _updateMarketing(MarketingLabel label, {bool value, String text}) {
    setState(() {
      if (label == MarketingLabel.GVOFrei ||
          label == MarketingLabel.AMAGuetesiegel)
        (_editedPerson as Farmer).updateMarketing(label, value: value);
      else if (label == MarketingLabel.Bio || label == MarketingLabel.Other)
        (_editedPerson as Farmer)
            .updateMarketing(label, value: value, text: text);
    });
  }

  void _saveForm() async {
    if (!_formKey.currentState.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Speichern nicht möglich. Bitte korrigieren Sie die Eingabe.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      var id;
      var personProvider =
          Provider.of<PersonListProvider>(context, listen: false);
      if (personProvider.findPersonIdx(_editedPerson) > -1) {
        personProvider.updatePerson(_editedPerson.id, _editedPerson);
      } else {
        id = await personProvider.addPerson(_editedPerson);
        _editedPerson.id = id;
      }

      personProvider.setSelectedPerson(_editedPerson);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Änderungen für ' +
              StringProcessing.buildNameString(_editedPerson) +
              ' gespeichert.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Callback functions for child widgets
  void _popScreen() {
    Navigator.of(context).pop();
  }

  void amaCallback(val) {
    _ama = !_ama;
    _updateMarketing(MarketingLabel.AMAGuetesiegel, value: val);
  }

  void gvoCallback(val) {
    _gvo = !_gvo;
    _updateMarketing(MarketingLabel.GVOFrei, value: val);
  }

  _buildMarketing() {
    return [
      SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: LabeledCheckbox(
          label: 'AMA Gütesiegel',
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          fontSize: 17,
          gap: 10,
          value: _ama ?? false,
          onTap: amaCallback,
        ),
      ),
      SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: LabeledCheckbox(
          label: 'zert. GVO-freie Fütterung',
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          fontSize: 17,
          gap: 10,
          value: _gvo ?? false,
          onTap: gvoCallback,
        ),
      ),
      SizedBox(height: 20),
      _textFieldBuilder(
          name: 'bio',
          controller: _marketingBioController,
          labeltext: 'Bio',
          field: 'bio'),
      SizedBox(height: 20),
      _textFieldBuilder(
          name: 'other',
          controller: _marketingOtherController,
          labeltext: 'Andere Angaben',
          field: 'other'),
      SizedBox(height: 20),
    ];
  }

  FormBuilderTextField _textFieldBuilder(
      {String name = '',
      TextEditingController controller,
      Function validatorFunction,
      String labeltext = '',
      TextInputType keyboardType = TextInputType.text,
      String field}) {
    return FormBuilderTextField(
      name: name,
      enabled: _enableTextFields,
      style: _enableTextFields ? null : TextStyle(color: Colors.black45),
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
        filled: !_enableTextFields,
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
                    _updatePerson(field, null);
                  else
                    _updatePerson(field, '');
                },
              )
            : null,
        labelText: labeltext,
      ),
      onChanged: (val) {
        if (val != null) val = val.trim();
        if (name == 'other')
          _updateMarketing(MarketingLabel.Other, text: val);
        else if (name == 'bio') _updateMarketing(MarketingLabel.Bio, text: val);
        if (keyboardType == TextInputType.number && val != null) {
          if (_formKey.currentState.fields[name].validate())
            _updatePerson(field, val);
        } else {
          if (_formKey.currentState.fields[name].validate())
            _updatePerson(field, val);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final header = EditScreenHeader(
      title: StringProcessing.buildNameString(_editedPerson),
      smallTitle: _headerSmallText,
      checkAction: _saveForm,
      abortAction: _popScreen,
    );

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                                    if (_editedPerson.hasAmaNr != 'no')
                                      _textFieldBuilder(
                                          name: 'lfbisIdOrAma',
                                          keyboardType: TextInputType.number,
                                          controller: _lfbisIdOrAmaController,
                                          validatorFunction:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.numeric(
                                                context,
                                                errorText:
                                                    "Nur Ganzzahlen erlaubt"),
                                            (val) {
                                              if (_editedPerson is Farmer &&
                                                  val.length > 1 &&
                                                  val.length < 7)
                                                return 'LFBIS-Nr. zu kurz';
                                              else if (!(_editedPerson
                                                      is Farmer) &&
                                                  val.length > 1 &&
                                                  val.length < 8)
                                                return 'LFBIS-Nr. / AMA-Klienten-Nr. zu kurz';
                                              else if (_editedPerson
                                                      is Farmer &&
                                                  val.length > 7)
                                                return 'LFBIS-Nr. zu lange';
                                              else if (val.length > 8)
                                                return 'LFBIS-Nr. / AMA-Klienten-Nr. zu lange';
                                              return null;
                                            },
                                          ]),
                                          labeltext: (_editedPerson is Farmer)
                                              ? 'LFBIS-Nr. *'
                                              : 'LFBIS- / AMA-Klienten-Nr.',
                                          field: 'lfbisIdOrAma'),
                                    SizedBox(height: 20),
                                    _textFieldBuilder(
                                        name: 'firstname',
                                        controller: _firstnameController,
                                        labeltext:
                                            'Vorname und/ oder Unternehmen' +
                                                ((_editedPerson is Farmer ||
                                                        _editedPerson is Vet)
                                                    ? ' *'
                                                    : ''),
                                        field: 'firstname'),
                                    SizedBox(height: 20),
                                    _textFieldBuilder(
                                        name: 'lastname',
                                        controller: _lastnameController,
                                        labeltext: 'Nachname' +
                                            ((_editedPerson is Farmer ||
                                                    _editedPerson is Vet)
                                                ? ' *'
                                                : ''),
                                        field: 'lastname'),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Flexible(
                                          flex: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: _textFieldBuilder(
                                                name: 'addressStreet',
                                                keyboardType:
                                                    TextInputType.streetAddress,
                                                controller:
                                                    _addrStreetController,
                                                labeltext: 'Straße' +
                                                    ((_editedPerson is Farmer ||
                                                            _editedPerson
                                                                is Vet)
                                                        ? ' *'
                                                        : ''),
                                                field: 'street'),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: _textFieldBuilder(
                                              name: 'addressStreetNr',
                                              controller: _addrNrController,
                                              labeltext: 'Nr.' +
                                                  ((_editedPerson is Farmer ||
                                                          _editedPerson is Vet)
                                                      ? ' *'
                                                      : ''),
                                              field: 'streetNr'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: _textFieldBuilder(
                                                name: 'postalCode',
                                                keyboardType:
                                                    TextInputType.number,
                                                validatorFunction:
                                                    FormBuilderValidators
                                                        .compose([
                                                  FormBuilderValidators.numeric(
                                                      context,
                                                      errorText:
                                                          "Nur Ganzzahlen erlaubt."),
                                                ]),
                                                controller: _addrPLZController,
                                                labeltext: 'PLZ' +
                                                    ((_editedPerson is Farmer ||
                                                            _editedPerson
                                                                is Vet)
                                                        ? ' *'
                                                        : ''),
                                                field: 'postalCode'),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Flexible(
                                          flex: 6,
                                          child: _textFieldBuilder(
                                              name: 'city',
                                              controller: _addrCityController,
                                              labeltext: 'Ort' +
                                                  ((_editedPerson is Farmer ||
                                                          _editedPerson is Vet)
                                                      ? ' *'
                                                      : ''),
                                              field: 'city'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    _textFieldBuilder(
                                        name: 'phone',
                                        keyboardType: TextInputType.phone,
                                        controller: _phoneController,
                                        labeltext: 'Telefonnummer',
                                        field: 'phone'),
                                    SizedBox(height: 20),
                                    _textFieldBuilder(
                                        name: 'email',
                                        validatorFunction:
                                            FormBuilderValidators.email(context,
                                                errorText:
                                                    'Keine gültige E-Mail Addresse'),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: _emailController,
                                        labeltext: 'E-Mail',
                                        field: 'email'),
                                    SizedBox(height: 20),
                                    if (_editedPerson is Farmer)
                                      ..._buildMarketing(),
                                    ElevatedButton(
                                        onPressed: _saveForm,
                                        child: Text(
                                          'Eintrag speichern',
                                          style: TextStyle(fontSize: 17),
                                        )),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        if (_editedPerson.id != null) {
                                          await Provider.of<PersonListProvider>(
                                                  context,
                                                  listen: false)
                                              .removePerson(_editedPerson.id,
                                                  _editedPerson);
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('Person ' +
                                                  _editedPerson.firstname +
                                                  ' gelöscht.'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        } else
                                          Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Eintrag dauerhaft löschen',
                                        style: TextStyle(
                                            color: Theme.of(context).errorColor,
                                            fontSize: 16),
                                      ),
                                    ),
                                    Text(
                                      'Löscht alle Daten der Person vom Gerät. Vorgang kann nicht rückgängig gemacht werden',
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
