import 'dart:async';

import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/buyer.dart';
import '../models/farmer.dart';
import '../models/person.dart';
import '../models/vet.dart';
import '../models/intermediary.dart';
import '../models/transporter.dart';

/*
    Class handles fetching, creating and updating persons in Firebase Firestore.
 */
class PersonListFirestore {
  Stream<List<Buyer>> buyerStream() => _collectionStream<Buyer>(
        path: '/users/' + FirebaseAuth.instance.currentUser.uid + '/buyers',
        builder: (data, documentId) => Buyer.fromJson(data, documentId),
      );

  Stream<List<Farmer>> farmerStream() => _collectionStream<Farmer>(
        path: '/users/' + FirebaseAuth.instance.currentUser.uid + '/farmers',
        builder: (data, documentId) => Farmer.fromJson(data, documentId),
      );

  Stream<List<Transporter>> transporterStream() =>
      _collectionStream<Transporter>(
        path:
            '/users/' + FirebaseAuth.instance.currentUser.uid + '/transporters',
        builder: (data, documentId) => Transporter.fromJson(data, documentId),
      );

  Stream<List<Vet>> vetStream() => _collectionStream<Vet>(
        path: '/users/' + FirebaseAuth.instance.currentUser.uid + '/vets',
        builder: (data, documentId) => Vet.fromJson(data, documentId),
      );

  Stream<List<Intermediary>> intermediaryStream() =>
      _collectionStream<Intermediary>(
        path: '/users/' +
            FirebaseAuth.instance.currentUser.uid +
            '/intermediaries',
        builder: (data, documentId) => Intermediary.fromJson(data, documentId),
      );

  Future<QuerySnapshot> _getQueryResult(String path) async {
    var collection = FirebaseFirestore.instance.collection(
        '/users/' + FirebaseAuth.instance.currentUser.uid + '/' + path);
    var queryResult = await collection.orderBy('lastTrade', descending:true).get();
    return queryResult;
  }

  Future<List<Buyer>> fetchBuyers() async {
    var queryResult = await _getQueryResult('buyers');
    var temp = queryResult.docs.map((doc) {
      return Buyer.fromJson(doc.data(), doc.id);
    }).toList();
    return temp;
  }

  Future<List<Farmer>> fetchFarmers() async {
    var queryResult = await _getQueryResult('farmers');
    var temp = queryResult.docs.map((doc) {
      return Farmer.fromJson(doc.data(), doc.id);
    }).toList();
    return temp;
  }

  Future<List<Vet>> fetchVets() async {
    var queryResult = await _getQueryResult('vets');
    var temp = queryResult.docs.map((doc) {
      return Vet.fromJson(doc.data(), doc.id);
    }).toList();
    return temp;
  }

  Future<List<Transporter>> fetchTransporters() async {
    var queryResult = await _getQueryResult('transporters');
    var temp = queryResult.docs.map((doc) {
      return Transporter.fromJson(doc.data(), doc.id);
    }).toList();
    return temp;
  }

  Future<List<Intermediary>> fetchIntermediary() async {
    var queryResult = await _getQueryResult('intermediaries');
    var temp = queryResult.docs.map((doc) {
      return Intermediary.fromJson(doc.data(), doc.id);
    }).toList();
    return temp;
  }

  Stream<List<T>> _collectionStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentID),
    Query queryBuilder(Query query),
    int sort(T lhs, T rhs),
  }) {
    Query query = FirebaseFirestore.instance.collection(path).orderBy('lastTrade', descending:true);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  /// Removes the document associated with the uid of the user from Firstore
  Future<void> removeUserFromFirebase() {
    return FirebaseFirestore.instance
        .collection('/users/')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .delete();
  }

  /// Removes person associated with [id] from firestore.
  /// [path] specifies the collection the [id] should be searched in, e.g. 'farmers'
  Future<void> removeDocumentFromFirebase(String id, String path) {
    return FirebaseFirestore.instance
        .collection(
            '/users/' + FirebaseAuth.instance.currentUser.uid + '/' + path)
        .doc(id)
        .delete();
  }

  /// Converts [person] to JSON syntax and adds it as new entry to firestore.
  /// [path] specifies the collection the person should be added to.
  String addPersonToFirebase(Person person, String path) {
    var id = FirebaseFirestore.instance
        .collection(
            '/users/' + FirebaseAuth.instance.currentUser.uid + '/' + path)
        .doc();

    FirebaseFirestore.instance
        .collection(
            '/users/' + FirebaseAuth.instance.currentUser.uid + '/' + path)
        .doc(id.id)
        .set((person is Farmer)
            ? person.toJson(id.id)
            : Person.toJson(person, id.id));

    return id.id;
  }

  /// Converts [person] to JSON syntax and updates the document
  /// assosiated with id of the person in firestore.
  /// [path] specifies the collection the person belongs to.
  updatePersonInFirebase(Person person, String path) {
    FirebaseFirestore.instance
        .collection(
            '/users/' + FirebaseAuth.instance.currentUser.uid + '/' + path)
        .doc(person.id)
        .get()
        .then((documentSnapshot) {
      if (person is Farmer)
        documentSnapshot.reference.set(person.toJson(person.id));
      else
        documentSnapshot.reference.set(Person.toJson(person, person.id));
    });
  }

  /// Deletes the collection which is specified by [path] from Firestore
  deleteCollection(String path) async {
    try {
      return await FirebaseFirestore.instance
          .collection(path)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete().then((_) {
            print("deleted!");
          });
        }
      });
    } catch (error) {
      return error;
    }
  }
}
