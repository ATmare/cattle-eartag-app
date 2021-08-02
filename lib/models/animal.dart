import 'package:flutter/foundation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './country_codes.dart';

enum AnimalCategory { Stier, Ochs, Kuh, Kalbin, Kalb, Jungrind }

List<String> get categories {
  List<String> categories = [];
  AnimalCategory.values.forEach((category) {
    categories.add(category?.toString()?.split('.')?.elementAt(1));
  });
  return categories;
}

/*
    Represents an Animal
 */
class Animal {
  final String id;
  final String tagId;
  AnimalCategory category;
  DateTime dateOfBirth;
  CountryCode placeOfBirth;
  List<CountryCode> placeOfRearing;
  DateTime purchaseDate;
  String breed;
  String additionalInfos;
  bool slaugther;

  List<String> placesOfRearing() {
    List<String> tempList = [];
    if (placeOfRearing != null) {
      tempList = placeOfRearing.map((countryCode) => countryCode.code).toList();
    }
    return tempList;
  }

  Animal({
    @required this.tagId,
    @required this.id,
    this.category,
    this.dateOfBirth,
    this.placeOfBirth,
    this.placeOfRearing,
    this.purchaseDate,
    this.breed,
    this.additionalInfos = '',
    this.slaugther = false,
  });

  Map<String, dynamic> animalToJson({bool dateString = false}) {
    return {
      'tagId': this.tagId ?? null,
      'category': this.category != null
          ? EnumToString.convertToString(this.category)
          : null,
      'dateOfBirth': this.dateOfBirth != null
          ? (dateString
              ? this.dateOfBirth.toIso8601String()
              : Timestamp.fromDate(this.dateOfBirth))
          : null,
      'placeOfBirth': this.placeOfBirth != null ? this.placeOfBirth.code : null,
      'placeOfRearing':
          this.placeOfRearing != null ? this.placesOfRearing() : null,
      'purchaseDate': this.purchaseDate != null
          ? (dateString
              ? this.purchaseDate.toIso8601String()
              : Timestamp.fromDate(this.purchaseDate))
          : null,
      'breed': this.breed ?? null,
      'additionalInfos': this.additionalInfos ?? null,
      'slaugther': this.slaugther ?? false
    };
  }

  factory Animal.animalFromJson(Map<String, dynamic> animal,
      {bool dateString = false}) {
    _createCountryCodes(values) {
      List<CountryCode> list = [];
      if (values != null) {
        for (String code in values) {
          list.add(CountryCode(code));
        }
        return list;
      }
      return null;
    }

    return Animal(
      id: DateTime.now().toString(),
      tagId: animal['tagId'],
      category: animal['category'] != null
          ? EnumToString.fromString(AnimalCategory.values, animal['category'])
          : null,
      dateOfBirth: animal['dateOfBirth'] != null
          ? (dateString
              ? DateTime.parse(animal['dateOfBirth'])
              : (animal['dateOfBirth']).toDate())
          : null,
      placeOfBirth: CountryCode(animal['placeOfBirth']),
      placeOfRearing: _createCountryCodes(animal['placeOfRearing']),
      purchaseDate: animal['purchaseDate'] != null
          ? (dateString
              ? DateTime.parse(animal['purchaseDate'])
              : (animal['purchaseDate']).toDate())
          : null,
      breed: animal['breed'],
      additionalInfos: animal['additionalInfos'],
      slaugther: animal['slaugther'] ?? false,
    );
  }
}
