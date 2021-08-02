import 'package:cloud_firestore/cloud_firestore.dart';

import 'address.dart';
import 'clone_interface.dart';

abstract class AmaMethods {
  // this method is overwritten in amaNumber mixin
  // implementing it here too avoids type-checks in EditPersonScreen class,
  // because vet objects can call this method without having an effect
  void setAmaNr(amaNr) {}

  get hasAmaNr {
    return 'no';
  }
}

/*
    Represents a Person Superclass
 */
abstract class Person extends AmaMethods implements CloneMethod {
  String id;
  String firstname;
  String lastname;
  Address address;
  String phone;
  String email;
  DateTime lastTrade;
  DateTime createdAt;

  Person(
      {this.id,
      this.firstname,
      this.lastname,
      this.address,
      this.phone,
      this.email,
      this.lastTrade,
      this.createdAt});

  static Map<String, dynamic> toJson(Person person, String id,
      {bool dateString = false}) {
    if (person.createdAt == null) person.createdAt = DateTime.now();
    return {
      'id': id ?? person.id,
      'lfbisIdOrAma': (person.hasAmaNr != null && person.hasAmaNr != 'no')
          ? person.hasAmaNr
          : null,
      'firstname': person.firstname ?? null,
      'lastname': person.lastname ?? null,
      'lastTrade': person.lastTrade != null
          ? (dateString
              ? person.lastTrade.toIso8601String()
              : Timestamp.fromDate(person.lastTrade))
          : null,
      'createdAt': person.createdAt != null
          ? (dateString
              ? person.createdAt.toIso8601String()
              : Timestamp.fromDate(person.createdAt))
          : null,
      'phone': person.phone ?? null,
      'email': person.email ?? null,
      'address': person.address != null
          ? {
              'street': person.address.street ?? null,
              'streetNr': person.address.streetNr ?? null,
              'postalCode': person.address.postalCode ?? null,
              'city': person.address.city ?? null,
            }
          : null
    };
  }
}
