import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../utils/dummy_data.dart';
import '../models/buyer.dart';
import '../models/farmer.dart';
import '../models/intermediary.dart';
import '../models/vet.dart';
import '../models/transporter.dart';
import '../models/person.dart';
import '../models/transport.dart';
import '../models/address.dart';
import '../api/person_list_firestore.dart';

class PersonListProvider with ChangeNotifier {
  final _db = PersonListFirestore();
  String _uid;

  List<Buyer> _buyers = [];
  List<Intermediary> _intermediaries = [];
  List<Farmer> _farmers = [];
  List<Vet> _vets = [];
  List<Transporter> _transporters = [];

  String _selectedBuyer;
  String _selectedFarmer;
  String _selectedIntermediary;
  String _selectedVet;
  String _selectedTransporter;

  Transport _transport;

  PersonListProvider() {
    fetchAllPersons();
  }

  Future<List<Buyer>> fetchAllPersons() async {
    _buyers = await _db.fetchBuyers();
    _farmers = await _db.fetchFarmers();
    _vets = await _db.fetchVets();
    _transporters = await _db.fetchTransporters();
    _intermediaries = await _db.fetchIntermediary();

    if (_uid != FirebaseAuth.instance.currentUser.uid) {
      _init();
    }
    return _buyers;
  }

  void _init() {
    _uid = FirebaseAuth.instance.currentUser.uid;
    if (_buyers.length > 0) _selectedBuyer = _buyers[0].id;
    if (_farmers.length > 0) _selectedFarmer = _farmers[0].id;
    if (_transporters.length > 0) _selectedTransporter = _transporters[0].id;
    if (_vets.length > 0) _selectedVet = _vets[0].id;
    if (_intermediaries.length > 0)
      _selectedIntermediary = _intermediaries[0].id;
    updateTransport();
    notifyListeners();
  }

  void _setSelectedPersons() {
    if (_buyers.length > 0) _selectedBuyer = _buyers[0].id;
    if (_farmers.length > 0) _selectedFarmer = _farmers[0].id;
    if (_transporters.length > 0) _selectedTransporter = _transporters[0].id;
    if (_vets.length > 0) _selectedVet = _vets[0].id;
    if (_intermediaries.length > 0)
      _selectedIntermediary = _intermediaries[0].id;
    updateTransport();
    notifyListeners();
  }

  /// Sets all selected Persons to null
  setSelectedPersonNull() {
    _selectedBuyer = null;
    _selectedFarmer = null;
    _selectedTransporter = null;
    _selectedVet = null;
    _selectedIntermediary = null;
    updateTransport();
    notifyListeners();
  }

  // Used for testing to populate Firestore with Dummy Person Data
  populateDummyData() async {
    await clear();

    for (Buyer b in dummyBuyers) {
      _db.addPersonToFirebase(b, 'buyers');
    }
    for (Farmer f in dummyFarmers) {
      _db.addPersonToFirebase(f, 'farmers');
    }
    for (Vet v in dummyVets) {
      _db.addPersonToFirebase(v, 'vets');
    }
    for (Intermediary i in dummyIntermediaries) {
      _db.addPersonToFirebase(i, 'intermediaries');
    }
    for (Transporter t in [dummyTransporter]) {
      _db.addPersonToFirebase(t, 'transporters');
    }
    await fetchAllPersons();
    _setSelectedPersons();
  }

  /// Remove all Persons of all lists from Firestore and on device
  clear() async {
    try {
      await clearList('buyers', false);
      await clearList('farmers', false);
      await clearList('transporters', false);
      await clearList('vets', false);
      await clearList('intermediaries', false);
      _transport = null;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  /// Remove all Persons from the list specified in [path] from Firestore
  clearList(String path, bool notify) async {
    if (path == 'all')
      clear();
    else {
      String base = '/users/' + FirebaseAuth.instance.currentUser.uid;
      var result = await _db.deleteCollection(base + '/' + path);
      if (result != null) {
        print(result);
        throw (result);
      } else {
        switch (path) {
          case 'farmers':
            _farmers = [];
            _selectedFarmer = null;
            break;
          case 'buyers':
            _buyers = [];
            _selectedBuyer = null;
            break;
          case 'transporters':
            _transporters = [];
            _selectedTransporter = null;
            break;
          case 'vets':
            _vets = [];
            _selectedVet = null;
            break;
          case 'intermediaries':
            _intermediaries = [];
            _selectedIntermediary = null;
            break;
          default:
        }
        if (notify) notifyListeners();
      }
    }
  }

  void setTransport(Transport transport) {
    _transport = transport;
    notifyListeners();
  }

  Transport get transport {
    return _transport;
  }

  Buyer get selectedBuyer {
    return findBuyer(_selectedBuyer);
  }

  String get selectedTransporterId {
    return _selectedTransporter;
  }

  Farmer get selectedFarmer {
    return findFarmer(_selectedFarmer);
  }

  Intermediary get selectedIntermediary {
    return findIntermediary(_selectedIntermediary);
  }

  Vet get selectedVet {
    return findVet(_selectedVet);
  }

  Transporter get selectedTransporter {
    return findTransporter(_selectedTransporter);
  }

  List<Buyer> get buyers {
    return [..._buyers];
  }

  List<Intermediary> get intermediaries {
    return [..._intermediaries];
  }

  List<Farmer> get farmers {
    return [..._farmers];
  }

  List<Vet> get vets {
    return [..._vets];
  }

  List<Transporter> get transporters {
    return [..._transporters];
  }

  Farmer findFarmer(String id) {
    return _farmers.firstWhere((farmer) => farmer.id == id, orElse: () => null);
  }

  Buyer findBuyer(String id) {
    return _buyers.firstWhere((buyer) => buyer.id == id, orElse: () => null);
  }

  Intermediary findIntermediary(String id) {
    return _intermediaries.firstWhere((inter) => inter.id == id,
        orElse: () => null);
  }

  Vet findVet(String id) {
    return _vets.firstWhere((vet) => vet.id == id, orElse: () => null);
  }

  Transporter findTransporter(String id) {
    var tempTransporter;
    if (id == 'farmer') {
      tempTransporter = _syncTransporterWith('farmer');
      if (tempTransporter != null) return tempTransporter;
    } else if (id == 'intermediary') {
      tempTransporter = _syncTransporterWith('intermediary');
      if (tempTransporter != null) return tempTransporter;
    } else
      return _transporters.firstWhere((transporter) => transporter.id == id,
          orElse: () => null);
  }

  // Returns an Object of type Farmer, Buyer,...
  findPerson(Person person) {
    if (person is Buyer)
      return findBuyer(person.id);
    else if (person is Farmer)
      return findFarmer(person.id);
    else if (person is Intermediary)
      return findIntermediary(person.id);
    else if (person is Transporter)
      return findTransporter(person.id);
    else if (person is Vet) return findVet(person.id);
  }

  // Returns the index of the person within the searched list, -1 if not found
  findPersonIdx(Person person) {
    var personIndex = 0;
    if (person is Buyer) {
      personIndex = _buyers.indexWhere((buyer) => buyer.id == person.id);
    } else if (person is Farmer) {
      personIndex = _farmers.indexWhere((farmer) => farmer.id == person.id);
    } else if (person is Intermediary) {
      personIndex =
          _intermediaries.indexWhere((inter) => inter.id == person.id);
    } else if (person is Transporter) {
      personIndex = _transporters
          .indexWhere((transporter) => transporter.id == person.id);
    } else if (person is Vet) {
      personIndex = _vets.indexWhere((vet) => vet.id == person.id);
    }
    return personIndex;
  }

  _syncTransporterWith(String id) {
    if (id == 'farmer') {
      var tempfarmer = selectedFarmer;
      if (tempfarmer != null)
        return Transporter(
            lfbisIdOrAma: tempfarmer.lfbisIdOrAma,
            id: tempfarmer.id,
            firstname: tempfarmer.firstname,
            lastname: tempfarmer.lastname,
            address: (tempfarmer.address == null)
                ? Address()
                : tempfarmer.address.cloneSelf(),
            phone: tempfarmer.phone,
            email: tempfarmer.email,
            lastTrade: tempfarmer.lastTrade,
            syncWith: 'farmer');
      else
        return null;
    } else if (id == 'intermediary') {
      var tempInter = selectedIntermediary;
      if (tempInter != null)
        return Transporter(
            lfbisIdOrAma: tempInter.lfbisIdOrAma,
            id: tempInter.id,
            firstname: tempInter.firstname,
            lastname: tempInter.lastname,
            address: (tempInter.address == null)
                ? Address()
                : tempInter.address.cloneSelf(),
            phone: tempInter.phone,
            email: tempInter.email,
            lastTrade: tempInter.lastTrade,
            syncWith: 'intermediary');
      else
        return null;
    }
  }

  void updatePerson(String id, Person person) {
    var personIndex = findPersonIdx(person);
    if (person is Buyer) {
      if (personIndex >= 0) {
        _buyers[personIndex] = person;
        _db.updatePersonInFirebase(person, 'buyers');
      }
    } else if (person is Farmer) {
      if (personIndex >= 0) {
        _farmers[personIndex] = person;
        _db.updatePersonInFirebase(person, 'farmers');
      }
    } else if (person is Intermediary) {
      if (personIndex >= 0) {
        _intermediaries[personIndex] = person;
        _db.updatePersonInFirebase(person, 'intermediaries');
      }
    } else if (person is Transporter) {
      if (personIndex >= 0) {
        _transporters[personIndex] = person;
        _db.updatePersonInFirebase(person, 'transporters');
      }
    } else if (person is Vet) {
      if (personIndex >= 0) {
        _vets[personIndex] = person;
        _db.updatePersonInFirebase(person, 'vets');
      }
    }
    updateTransport();
    notifyListeners();
  }

  // sets the id of of the selected person to the incoming person.id
  void setSelectedPerson(Person person) async {
    if (person is Buyer) {
      _selectedBuyer = person.id;
    } else if (person is Farmer) {
      _selectedFarmer = person.id;
    } else if (person is Vet) {
      _selectedVet = person.id;
    } else if (person is Transporter) {
      _selectedTransporter = person.id;
    } else if (person is Intermediary) {
      _selectedIntermediary = person.id;
    }
    updateTransport();
    notifyListeners();
  }

  updateTransport() {
    Address start = (_transport != null) ? _transport.loadingPlace : Address();
    Address end = (_transport != null) ? _transport.unloadingPlace : Address();

    if (_transport == null ||
        _transport.lastEdited == null ||
        _transport.syncUnloadingPlace != null ||
        _transport.syncUnloadingPlace != '') {
      var farmer = selectedFarmer;
      var syncPerson;
      if (_transport != null) {
        if (_transport.syncUnloadingPlace == 'transporter')
          syncPerson = selectedTransporter;
        else if (_transport.syncUnloadingPlace == 'intermediary')
          syncPerson = selectedIntermediary;
        else if (_transport.syncUnloadingPlace == 'buyer')
          syncPerson = selectedBuyer;
      } else
        syncPerson = selectedBuyer;

      start = (farmer != null && farmer.address != null)
          ? farmer.address
          : Address();
      end = (syncPerson != null && syncPerson.address != null)
          ? syncPerson.address
          : Address();
    }

    _transport = Transport(
        startOfTransport:
            (_transport != null && _transport.startOfTransport != null)
                ? _transport.startOfTransport
                : (_transport != null && _transport.lastEdited != null)
                    ? null
                    : DateTime.now().add(new Duration(minutes: 20)),
        loadingPlace: start,
        unloadingPlace: end,
        transportDuration:
            (_transport != null && _transport.transportDuration != null)
                ? _transport.transportDuration
                : null,
        lastFeeding: (_transport != null && _transport.lastFeeding != null)
            ? _transport.lastFeeding
            : null,
        licensePlate: (_transport != null && _transport.licensePlate != null)
            ? _transport.licensePlate
            : null,
        lastEdited: (_transport != null && _transport.lastEdited != null)
            ? _transport.lastEdited
            : null,
        syncUnloadingPlace:
            (_transport != null && _transport.syncUnloadingPlace != null)
                ? _transport.syncUnloadingPlace
                : 'buyer');
  }

  Future<String> addPerson(Person person) async {
    var id;
    if (person is Buyer) {
      id = _db.addPersonToFirebase(person, 'buyers');
    } else if (person is Farmer) {
      id = _db.addPersonToFirebase(person, 'farmers');
    } else if (person is Intermediary) {
      id = _db.addPersonToFirebase(person, 'intermediaries');
    } else if (person is Transporter) {
      id = _db.addPersonToFirebase(person, 'transporters');
    } else if (person is Vet) {
      id = _db.addPersonToFirebase(person, 'vets');
    }

    await fetchAllPersons();
    notifyListeners();

    return id;
  }

  removePerson(String personId, Person person) async {
    if (person is Buyer) {
      await _db.removeDocumentFromFirebase(personId, 'buyers');
      if (personId == _selectedBuyer && _buyers.length > 0)
        _selectedBuyer = _buyers[0].id;
      else
        _selectedBuyer = null;
      _buyers = await _db.fetchBuyers();
    } else if (person is Farmer) {
      await _db.removeDocumentFromFirebase(personId, 'farmers');
      if (personId == _selectedFarmer && _farmers.length > 0)
        _selectedFarmer = _farmers[0].id;
      else
        _selectedFarmer = null;
      _farmers = await _db.fetchFarmers();
    } else if (person is Intermediary) {
      await _db.removeDocumentFromFirebase(personId, 'intermediaries');
      if (personId == _selectedIntermediary && _intermediaries.length > 0)
        _selectedIntermediary = _intermediaries[0].id;
      else
        _selectedIntermediary = null;
      _intermediaries = await _db.fetchIntermediary();
    } else if (person is Transporter) {
      await _db.removeDocumentFromFirebase(personId, 'transporters');
      if (personId == _selectedTransporter && _transporters.length > 0)
        _selectedTransporter = _transporters[0].id;
      else
        _selectedTransporter = null;
      _transporters = await _db.fetchTransporters();
    } else if (person is Vet) {
      await _db.removeDocumentFromFirebase(personId, 'vets');
      if (personId == _selectedVet && _vets.length > 0)
        _selectedVet = _vets[0].id;
      else
        _selectedVet = null;
      _vets = await _db.fetchVets();
    }
    notifyListeners();
  }

  static bool checkPersonCompleteness(Person person) {
    if (person == null) return false;
    if (person.hasAmaNr == null ||
        person.firstname == null ||
        person.lastname == null ||
        person.address == null ||
        person.address.streetNr == null ||
        person.address.street == null ||
        person.address.city == null ||
        person.address.postalCode == null) {
      return false;
    }
    return true;
  }

  static bool checkTransportCompleteness(Transport transport) {
    if (transport == null) return false;
    if (transport.loadingPlace == null ||
        transport.loadingPlace.street == null ||
        transport.loadingPlace.streetNr == null ||
        transport.loadingPlace.city == null ||
        transport.loadingPlace.postalCode == null ||
        transport.lastFeeding == null ||
        transport.startOfTransport == null) {
      return false;
    }
    return true;
  }
}
