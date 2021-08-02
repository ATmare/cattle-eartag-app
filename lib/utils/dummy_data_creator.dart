import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/country_codes.dart';
import '../models/animal.dart';
import '../utils/string_processing.dart';

/*
    Class is used to create dummy animals for newly registered users.
 */

class DummyDataCreator {
  var _random = new Random();
  var _today = DateTime.now();

  List<String> _tagIds = [
    'AT006197468',
    'AT136224268',
    'AT229136428',
    'AT229967338',
    'AT358245868',
    'AT388340768',
    'AT388566168',
    'AT388568368',
    'AT401833268',
    'AT414400568',
    'AT541649838',
    'AT764561368',
    'AT802316938',
    'AT913825868',
    'AT922641838',
    'AT922978428',
    'AT927180314',
    'AT957372738',

    'AT684431669',
    'DE1272431125',
    'DK03327301486',
    'AT315717969',
    'AT364003869'
  ];

  final _breedSuggestions = [
    'Fleckvieh',
    'Holstein',
    'Braunvieh',
    'Pinzgauer',
    'Limousin',
    'Charolais',
    'Grauvieh',
    'Angus',
    'Murbodner',
    'Weiß-blaue Belgier',
  ];

  final _additions = [
    '',
    'Medikamente',
    'Bio',
    'BT Impfung: ',
    'RB Impfung: ',
    'TW Impfung: ',
    'Wartezeit: '
  ];

  _getRandomDate(int startYear, int endYear) {
    var _randYear;
    var _randMonthInt;
    var _randDay;
    DateTime rand;

    while (true) {
      if (endYear == startYear)
        _randYear = endYear;
      else
        _randYear = startYear + _random.nextInt(endYear - startYear);
      _randMonthInt = _random.nextInt(12) + 1;
      _randDay = _random.nextInt(_maxDays(_randYear, _randMonthInt));

      rand = DateTime(_randYear, _randMonthInt, _randDay);
      if (rand.compareTo(_today) <= 0) return rand;
    }
  }

  // max number of days for given year and month
  int _maxDays(int year, int month) {
    var maxDaysMonthList = <int>[4, 6, 9, 11];
    if (month == 2) {
      return 28;
    } else {
      return maxDaysMonthList.contains(month) ? 30 : 31;
    }
  }

  String _getRandomBreed() {
    int rand = _random.nextInt(100);
    if (rand <= 75)
      return _breedSuggestions[0];
    else if (rand > 75 && rand <= 81)
      return _breedSuggestions[1];
    else if (rand > 81 && rand <= 88)
      return _breedSuggestions[2];
    else {
      int index = 3 + _random.nextInt(9 - 3);
      return _breedSuggestions[index];
    }
  }

  String _getRandomCategory() {
    int rand = _random.nextInt(6);
    return categories[rand];
  }

  // create 70% AT codes, 10 % DE codes, 20 % other european codes
  String _getRandomCountry() {
    int rand = _random.nextInt(100);
    if (rand <= 70)
      return CountryCode.COUNTRIES[0];
    else if (rand > 70 && rand < 80) return CountryCode.COUNTRIES[2];
    int index = 3 + _random.nextInt(23 - 3);
    return CountryCode.COUNTRIES[index];
  }

  List<String> _getRandomCountries() {
    List<String> list = [];
    int rand = _random.nextInt(10);
    if (rand <= 5)
      return [_getRandomCountry()];
    else if (rand > 5 && rand < 9) {
      list.add(_getRandomCountry());
      list.add(_addCountry(list));
      return list;
    }
    list.add(_getRandomCountry());
    list.add(_addCountry(list));
    list.add(_addCountry(list));
    return list;
  }

  String _addCountry(List<String> list) {
    var temp;
    while (true) {
      temp = _getRandomCountry();
      if (!list.contains(temp)) {
        return temp;
      }
    }
  }

  DateTime _getRandomPurchaseDate(DateTime birthdate) {
    while (true) {
      DateTime randomDate = _getRandomDate(birthdate.year, 2020);
      if (randomDate.compareTo(birthdate) >= 0) return randomDate;
    }
  }

  String _getRandomAdditions(DateTime birth) {
    int rand = _random.nextInt(100);
    if (rand <= 30)
      return _additions[0];
    else if (rand > 30 && rand <= 40)
      return _additions[1];
    else if (rand > 40 && rand <= 60) return _additions[2];

    int index = 3 + _random.nextInt(6 - 3);
    String tempString = _additions[index];
    DateTime tempDate;
    while (true) {
      tempDate = _getRandomDate(birth.year, 2021);
      if (tempDate.compareTo(birth) < 0)
        return tempString + StringProcessing.prettyDate(tempDate);
    }
  }

  bool _getRandomSlaugther() {
    int rand = _random.nextInt(10);
    if (rand < 6) return false;
    return true;
  }

  Map<String, Object> _createJson(String tagId) {
    var birth = _getRandomDate(2000, 2021);
    return {
      'tagId': tagId,
      'category': _getRandomCategory(),
      'dateOfBirth': Timestamp.fromDate(birth),
      'placeOfBirth': _getRandomCountry(),
      'placeOfRearing': _getRandomCountries(),
      'purchaseDate': Timestamp.fromDate(_getRandomPurchaseDate(birth)),
      'breed': _getRandomBreed(),
      'additionalInfos': _getRandomAdditions(birth),
      'slaugther': _getRandomSlaugther()
    };
  }

  /// Creates n dummy animals with realistic data.
  /// n = amount of Ids specified in private variable _tagIds.
  /// _tagIds specifies the assigned tagIds for each animal.
  createAnimals() {
    var allAnimals = [];
    List<String> ids = _tagIds;
    var jsonAnimal;
    for (int i = 0; i < ids.length; i++) {
      jsonAnimal = _createJson(ids[i]);
      allAnimals.add(Animal.animalFromJson(jsonAnimal));
    }
    return allAnimals;
  }
}
