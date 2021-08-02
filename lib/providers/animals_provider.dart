import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/animal.dart';
import '../utils/secure_storage.dart';

/*
    Provides and manages a list of those animals, which should be transported.
 */
class AnimalsProvider with ChangeNotifier {
  var _uid = FirebaseAuth.instance.currentUser.uid;
  bool _init = true;
  final SecureStorage _secureStorage = SecureStorage();

  List<Animal> _animals = [];

  AnimalsProvider() {
    initAnimals;
  }

  // check if provider was created for the first time. Check for uid is
  // necessary, because provider keeps alive after user logs out and does not
  // close the app. A different, newly logged in user would otherwise access a
  // wrong uid.
  Future<List<Animal>> get initAnimals async {
    if (_uid != FirebaseAuth.instance.currentUser.uid || _init) {
      _uid = FirebaseAuth.instance.currentUser.uid;
      List<Animal> animals = await _getFromSecureStorage();
      _animals = animals;
      _init = false;
      return _animals;
    } else
      return _animals;
  }

  List<Animal> get animals {
    return _animals;
  }

  int get animalCount {
    return _animals == null ? 0 : _animals.length;
  }

  /// Searches the animal-list for the given [id].
  /// Returns Animal if [id] was found.
  /// Will throw an error if [id] is not in list
  Animal findById(String id) {
    return _animals.firstWhere((animal) => animal.tagId == id);
  }

  /// Searches the animal-list for the given [id].
  /// Returns the index if [id] was found, returns -1 otherwise.
  int findIdxById(String id) {
    var idx = _animals.indexWhere((animal) => animal.tagId == id);
    return idx;
  }

  _getFromSecureStorage() async {
    String json = await _secureStorage
        .readSecureData(FirebaseAuth.instance.currentUser.uid + 'animals');
    var animals = await _jsonToList(json);
    return animals;
  }

  /// Removes the animal with the given [animalId] from the animals-list and from storage
  void removeAnimal(String animalId, {bool notify = true}) async {
    final existingIndex = _animals.indexWhere((animal) {
      return animal.tagId == animalId;
    });
    // when found, delete the animal
    if (existingIndex >= 0) {
      print('try remove animal with id' + animalId);
      _animals.removeAt(existingIndex);

      // Sync with persistent storage
      String json = _listToJson();
      await _secureStorage.writeSecureData(
          FirebaseAuth.instance.currentUser.uid + 'animals', json);
    }
    if (notify) notifyListeners();
  }

  /// Removes all animals from the animals-list and from storage
  void clear() async {
    _animals = [];
    await _secureStorage.writeSecureData(
        FirebaseAuth.instance.currentUser.uid + 'animals', jsonEncode([]));
    notifyListeners();
  }

  /// Removes the first 8 entries from the animal-list and from storage
  void clearFirst8Entries() async {
    if (_animals != null && _animals.length > 8) {
      _animals = _animals.sublist(8, _animals.length);
    }
    else
      _animals = [];

    String json = _listToJson();
    await _secureStorage.writeSecureData(
        FirebaseAuth.instance.currentUser.uid + 'animals', json);

    notifyListeners();
  }

  /// Updates the [animal] in the animal-list and persists the changes in storage
  void updateAnimal(String tagId, Animal newAnimal) async {
    final animalIndex = _animals.indexWhere((animal) => animal.tagId == tagId);
    if (animalIndex >= 0) {
      _animals[animalIndex] = newAnimal;
    }

    String json = _listToJson();
    await _secureStorage.writeSecureData(
        FirebaseAuth.instance.currentUser.uid + 'animals', json);
    notifyListeners();
  }

  /// Adds the [animal] to the animal-list
  void addAnimal(Animal animal) async {
    final newAnimal = Animal(
      tagId: animal.tagId,
      id: DateTime.now().toString(),
      category: animal.category ?? null,
      dateOfBirth: animal.dateOfBirth ?? null,
      placeOfBirth: animal.placeOfBirth ?? null,
      placeOfRearing: animal.placeOfRearing ?? null,
      purchaseDate: animal.purchaseDate ?? null,
      breed: animal.breed ?? '',
      additionalInfos: animal.additionalInfos ?? '',
      slaugther: animal.slaugther ?? false,
    );
    _animals.insert(0, newAnimal);

    String json = _listToJson();
    await _secureStorage.writeSecureData(
        FirebaseAuth.instance.currentUser.uid + 'animals', json);
    notifyListeners();
  }

  /// Creates an animal object for the given [tagId] and
  /// adds the created animal to the animal-list
  void addAnimalByTagId(String tagId) {
    addAnimal(Animal(tagId: tagId, id: null));
    notifyListeners();
  }

  String _listToJson() {
    var jsonList = [];
    for (Animal a in _animals) {
      jsonList.add(a.animalToJson(dateString: true));
    }
    return (jsonEncode(jsonList));
  }

  _jsonToList(String contents) async {
    List<Animal> templist = [];
    try {
      if (contents != null) {
        // parse json
        var _json = json.decode(contents);
        for (int i = 0; i < _json.length; i++) {
          templist.add(
            Animal.animalFromJson(_json[i], dateString: true),
          );
        }
        _animals = templist;
        return _animals;
      }
    } on FileSystemException catch (_) {
      // the file did not exist before
    } catch (e) {
      print(e);
    }
    return templist;
  }

  /// Checks if the mandatory data for the given [animal] is complete.
  static bool checkAnimalCompleteness(Animal animal) {
    if (animal.placeOfBirth == null || animal.placeOfBirth.code == null ||
        animal.category == null ||
        animal.dateOfBirth == null ||
        animal.breed == null ||
        animal.breed == '' ||
        animal.placeOfRearing == null || animal.placeOfRearing.length == 0 ||
        animal.purchaseDate == null) return false;
    return true;
  }

  /// Checks if the mandatory data for all animals in the list [animals] is complete.
  static bool checkListCompleteness(List<Animal> animals) {
    if (animals == null || animals.length == 0) return false;
    for (Animal a in animals) {
      if (checkAnimalCompleteness(a) == false) return false;
    }
    return true;
  }
}
