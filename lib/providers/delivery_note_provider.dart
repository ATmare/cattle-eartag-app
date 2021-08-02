import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/deliveryNote.dart';
import '../utils/secure_storage.dart';
import './animals_provider.dart';
import './person_list_provider.dart';

/*
    Provides the current DeliveryNote
 */
class DeliveryNoteProvider with ChangeNotifier {
  DeliveryNoteProvider(
      {@required AnimalsProvider animalsService,
      @required PersonListProvider personService})
      : _animalsService = animalsService,
        _personService = personService {
    _deliveryNote.animalList = _animalsService.animals;
    _deliveryNote.farmer = _personService.selectedFarmer;
    _deliveryNote.buyer = _personService.selectedBuyer;
    _deliveryNote.transporter = _personService.selectedTransporter;
    _deliveryNote.intermediary = _personService.selectedIntermediary;
    _deliveryNote.vet = _personService.selectedVet;
    _deliveryNote.transport = _personService.transport;

    getDeliveryNoteCounterFromStorage();
  }

  final SecureStorage _secureStorage = SecureStorage();
  AnimalsProvider _animalsService;
  PersonListProvider _personService;

  DeliveryNote _deliveryNote = DeliveryNote(
    deliveryId: 0,
    farmer: null,
    buyer: null,
    transporter: null,
    intermediary: null,
    vet: null,
    transport: null,
    animalList: null,
  );

  DeliveryNote get currentDeliveryNote {
    return _deliveryNote;
  }

  _writeToSecureStorage(int count) async {
    await _secureStorage.writeSecureData(
        'counter', jsonEncode({'count': count}));
  }

  /// Get the current counter for the delivery note ID from storage
  Future<int> getDeliveryNoteCounterFromStorage() async {
    String count = await _secureStorage.readSecureData('counter');
    if (count == null) {
      await _writeToSecureStorage(0);
      return 0;
    } else {
      var currentCount = json.decode(count);
      _deliveryNote.deliveryId = currentCount['count'];
      return currentCount['count'];
    }
  }

  /// Increases the delivery note ID
  increaseId() async {
    var currentCount = await getDeliveryNoteCounterFromStorage();
    await _writeToSecureStorage(currentCount + 1);
    _deliveryNote.deliveryId = currentCount + 1;
  }

  /// Returns a String with an error message if mandatory data of the animal list is missing
  String checkAnimalCompleteness() {
    if (!AnimalsProvider.checkListCompleteness(_deliveryNote.animalList))
      return 'Tierliste unvollständig';
    return null;
  }

  /// Returns a String with an error message if mandatory data of the [person] is missing
  String checkPersonCompleteness(String person) {
    if (person == 'farmer') {
      if (!PersonListProvider.checkPersonCompleteness(_deliveryNote.farmer))
        return 'Landwirt unvollständig';
    } else if (person == 'vet') {
      if (!PersonListProvider.checkPersonCompleteness(_deliveryNote.vet))
        return 'Tierarzt unvollständig';
    }
    return null;
  }

  /// Returns a String with an error message if mandatory data concerning the transport is missing
  String checkTransportCompleteness() {
    if (!PersonListProvider.checkTransportCompleteness(_deliveryNote.transport))
      return 'Transport Daten unvollständig';
    return null;
  }

  /// Sets lastTrade dates for the involved persons of the transport and updates them in
  /// Firebase. Deletes the first 8 entries of the animal list and sets the transport to its default values.
  finishDeliveryNote() async {
    await _animalsService.clearFirst8Entries();
    var date = DateTime.now();
    if (_deliveryNote.buyer != null) {
      var buyer = _deliveryNote.buyer.cloneSelf();
      buyer.lastTrade = date;
      _personService.updatePerson(buyer.id, buyer);
    }

    if (_deliveryNote.farmer != null) {
      var farmer = _deliveryNote.farmer.cloneSelf();
      farmer.lastTrade = date;
      _personService.updatePerson(farmer.id, farmer);
    }

    if (_deliveryNote.vet != null) {
      var vet = _deliveryNote.vet.cloneSelf();
      vet.lastTrade = date;
      _personService.updatePerson(vet.id, vet);
    }

    if (_deliveryNote.intermediary != null) {
      var inter = _deliveryNote.intermediary.cloneSelf();
      inter.lastTrade = date;
      _personService.updatePerson(inter.id, inter);
    }

    if (_deliveryNote.transporter != null &&
        (_deliveryNote.transporter.syncWith == null ||
            _deliveryNote.transporter.syncWith == '')) {
      var transporter = _deliveryNote.transporter.cloneSelf();
      transporter.lastTrade = date;
      _personService.updatePerson(transporter.id, transporter);
    }

    await _personService.fetchAllPersons();
    _personService.setTransport(null);
    _personService.updateTransport();
  }
}
