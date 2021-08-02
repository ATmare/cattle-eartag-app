import 'package:cloud_firestore/cloud_firestore.dart';

import './address.dart';
import './person.dart';
import './ama_number.dart';

enum MarketingLabel { AMAGuetesiegel, GVOFrei, Bio, Other }

/*
    Represents a Farmer Person
 */
class Farmer extends Person with AmaNumber {
  Map<MarketingLabel, String> marketingAds = {};

  Farmer({
    lfbisIdOrAma,
    String id,
    String firstname,
    String lastname,
    Address address,
    String phone,
    String email,
    DateTime lastTrade,
    DateTime createdAt,
    this.marketingAds,
  }) : super(
            id: id,
            firstname: firstname,
            lastname: lastname,
            address: address,
            phone: phone,
            email: email,
            createdAt: createdAt,
            lastTrade: lastTrade) {
    initAmaNumber(lfbisIdOrAma);
  }

  /// Updates the given [label] with either the provided [value] or the provided [text]
  /// Set [value] to update checkbox-only labels (AMAGuetesiegel, GVOFrei)
  /// Set [text] to update text-based marketing information (Bio, Other)
  void updateMarketing(MarketingLabel label, {bool value, String text}) {
    if (value != null) {
      if (value)
        _addMarketing(label, '');
      else
        _removeMarketing(label);
    } else if (text != null && text.length > 0)
      _addMarketing(label, text);
    else
      _removeMarketing(label);
  }

  void _removeMarketing(MarketingLabel label) {
    marketingAds.remove(label);
  }

  void _addMarketing(MarketingLabel label, String text) {
    if (marketingAds.containsKey(label)) {
      // change marketingLabel
      marketingAds.update(label, (existingMarketing) => text);
    } else {
      // create new marketingLabel
      marketingAds.putIfAbsent(
        label,
        () => text,
      );
    }
  }

  Map<String, dynamic> _marketingToJson() {
    Map<String, dynamic> temp = {};
    if (this.marketingAds.containsKey(MarketingLabel.AMAGuetesiegel))
      temp.putIfAbsent('AMAGuetesiegel', () => true);
    if (this.marketingAds.containsKey(MarketingLabel.GVOFrei))
      temp.putIfAbsent('GVOFrei', () => true);
    if (this.marketingAds.containsKey(MarketingLabel.Bio))
      temp.putIfAbsent('Bio', () => marketingAds[MarketingLabel.Bio]);
    if (this.marketingAds.containsKey(MarketingLabel.Other))
      temp.putIfAbsent('Other', () => marketingAds[MarketingLabel.Other]);
    return temp;
  }

  @override
  Farmer cloneSelf() {
    return Farmer(
      lfbisIdOrAma: lfbisIdOrAma,
      id: id,
      firstname: firstname,
      lastname: lastname,
      address: (address == null) ? Address() : address.cloneSelf(),
      phone: phone,
      email: email,
      lastTrade: lastTrade,
      createdAt: createdAt,
      marketingAds: {...marketingAds},
    );
  }

  factory Farmer.fromJson(Map<String, dynamic> farmer, String documentID,
      {bool dateString = false}) {
    jsonToMarketing() {
      Map<MarketingLabel, String> temp = {};

      if (farmer['marketingAds'] != null) {
        if (farmer['marketingAds']['AMAGuetesiegel'] != null)
          temp.putIfAbsent(MarketingLabel.AMAGuetesiegel, () => '');
        if (farmer['marketingAds']['GVOFrei'] != null)
          temp.putIfAbsent(MarketingLabel.GVOFrei, () => '');
        if (farmer['marketingAds']['Bio'] != null)
          temp.putIfAbsent(
              MarketingLabel.Bio, () => farmer['marketingAds']['Bio']);
        if (farmer['marketingAds']['Other'] != null)
          temp.putIfAbsent(
              MarketingLabel.Other, () => farmer['marketingAds']['Other']);
      }
      return temp;
    }

    return Farmer(
        id: documentID ?? DateTime.now().toString(),
        lfbisIdOrAma: farmer['lfbisIdOrAma'],
        firstname: farmer['firstname'],
        lastname: farmer['lastname'],
        lastTrade: farmer['lastTrade'] != null
            ? (dateString
                ? DateTime.parse(farmer['lastTrade'])
                : (farmer['lastTrade']).toDate())
            : null,
        createdAt: farmer['createdAt'] != null
            ? (dateString
                ? DateTime.parse(farmer['createdAt'])
                : (farmer['createdAt']).toDate())
            : null,
        phone: farmer['phone'],
        email: farmer['email'],
        marketingAds: jsonToMarketing(),
        address: Address(
          street: farmer['address']['street'],
          streetNr: farmer['address']['streetNr'],
          postalCode: farmer['address']['postalCode'],
          city: farmer['address']['city'],
        ));
  }

  Map<String, dynamic> toJson(String id, {bool dateString = false}) {
    if (createdAt == null) createdAt = DateTime.now();
    return {
      'id': id ?? this.id,
      'lfbisIdOrAma': (this.hasAmaNr != null) ? this.hasAmaNr : null,
      'firstname': this.firstname ?? null,
      'lastname': this.lastname ?? null,
      'lastTrade': this.lastTrade != null
          ? (dateString
              ? this.lastTrade.toIso8601String()
              : Timestamp.fromDate(this.lastTrade))
          : null,
      'createdAt': this.createdAt != null
          ? (dateString
              ? this.createdAt.toIso8601String()
              : Timestamp.fromDate(this.createdAt))
          : null,
      'phone': this.phone ?? null,
      'email': this.email ?? null,
      'address': this.address != null
          ? {
              'street': this.address.street ?? null,
              'streetNr': this.address.streetNr ?? null,
              'postalCode': this.address.postalCode ?? null,
              'city': this.address.city ?? null,
            }
          : null,
      'marketingAds': _marketingToJson(),
    };
  }
}
